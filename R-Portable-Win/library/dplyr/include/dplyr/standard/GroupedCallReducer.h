#ifndef dplyr_GroupedCallReducer_H
#define dplyr_GroupedCallReducer_H

#include <dplyr/data/DataMask.h>
#include <dplyr/checks.h>

#include <boost/scoped_ptr.hpp>

#include <tools/all_na.h>
#include <tools/bad.h>
#include <tools/hash.h>
#include <tools/scalar_type.h>
#include <tools/utils.h>
#include <tools/vector_class.h>

namespace dplyr {

class IDelayedProcessor {
public:
  IDelayedProcessor() {}
  virtual ~IDelayedProcessor() {}

  virtual bool try_handle(const Rcpp::RObject& chunk) = 0;
  virtual IDelayedProcessor* promote(const Rcpp::RObject& chunk) = 0;
  virtual SEXP get() = 0;
  virtual std::string describe() = 0;
};

template <int RTYPE>
bool valid_conversion(int rtype) {
  return rtype == RTYPE;
}

template <>
inline bool valid_conversion<REALSXP>(int rtype) {
  switch (rtype) {
  case REALSXP:
  case INTSXP:
  case LGLSXP:
    return true;
  default:
    break;
  }
  return false;
}

template <>
inline bool valid_conversion<INTSXP>(int rtype) {
  switch (rtype) {
  case INTSXP:
  case LGLSXP:
    return true;
  default:
    break;
  }
  return false;
}

template <int RTYPE>
inline bool valid_promotion(int) {
  return false;
}

template <>
inline bool valid_promotion<INTSXP>(int rtype) {
  return rtype == REALSXP;
}

template <>
inline bool valid_promotion<LGLSXP>(int rtype) {
  return rtype == REALSXP || rtype == INTSXP;
}

template <int RTYPE, typename CLASS>
class DelayedProcessor : public IDelayedProcessor {
public:
  typedef typename traits::scalar_type<RTYPE>::type STORAGE;
  typedef Rcpp::Vector<RTYPE> Vec;

  DelayedProcessor(const Rcpp::RObject& first_result, int ngroups_, const SymbolString& name_) :
    res(Rcpp::no_init(ngroups_)), pos(0), seen_na_only(true), name(name_)
  {
    LOG_VERBOSE;

    if (!try_handle(first_result)) {
      Rcpp::stop("cannot handle result of type %i for column '%s'", first_result.sexp_type(), name.get_utf8_cstring());
    }
    copy_most_attributes(res, first_result);
  }

  DelayedProcessor(int pos_, const Rcpp::RObject& chunk, SEXP res_, const SymbolString& name_) :
    pos(pos_), seen_na_only(false), name(name_)
  {
    LOG_VERBOSE;

    copy_most_attributes(res, chunk);

    // We need to copy carefully here to avoid accessing uninitialized
    // parts of res_, which triggers valgrind failures and is inefficient
    Rcpp::Shelter<SEXP> shelter;

    R_xlen_t orig_length = Rf_xlength(res_);
    SEXP short_res_ = shelter(Rf_xlengthgets(res_, pos));
    res = shelter(Rf_xlengthgets(shelter(Rcpp::as<Vec>(short_res_)), orig_length));

    // try_handle() changes pos as a side effect, needs to be done after copying
    // (we don't care about the unnecessary copy in the failure case)
    if (!try_handle(chunk)) {
      Rcpp::stop("cannot handle result of type %i in promotion for column '%s'",
                 chunk.sexp_type(), name.get_utf8_cstring()
                );
    }
  }

  virtual bool try_handle(const Rcpp::RObject& chunk) {
    LOG_VERBOSE;

    check_supported_type(chunk, name);
    check_length(Rf_length(chunk), 1, "a summary value", name);

    int rtype = TYPEOF(chunk);
    if (!valid_conversion<RTYPE>(rtype)) {
      return false;
    }

    // copy, and memoize the copied value
    const typename Vec::stored_type& converted_chunk = (res[pos++] = Rcpp::as<STORAGE>(chunk));
    if (!Vec::is_na(converted_chunk))
      seen_na_only = false;

    return true;
  }

  virtual IDelayedProcessor* promote(const Rcpp::RObject& chunk) {
    LOG_VERBOSE;

    if (!can_promote(chunk)) {
      LOG_VERBOSE << "can't promote";
      return 0;
    }

    int rtype = TYPEOF(chunk);
    switch (rtype) {
    case LGLSXP:
      return new DelayedProcessor<LGLSXP, CLASS>(pos, chunk, res, name);
    case INTSXP:
      return new DelayedProcessor<INTSXP, CLASS>(pos, chunk, res, name);
    case REALSXP:
      return new DelayedProcessor<REALSXP, CLASS>(pos, chunk, res, name);
    case CPLXSXP:
      return new DelayedProcessor<CPLXSXP, CLASS>(pos, chunk, res, name);
    case STRSXP:
      return new DelayedProcessor<STRSXP, CLASS>(pos, chunk, res, name);
    default:
      break;
    }
    return 0;
  }

  virtual SEXP get() {
    return res;
  }

  virtual std::string describe() {
    return vector_class<RTYPE>();
  }


private:
  bool can_promote(const Rcpp::RObject& chunk) {
    return seen_na_only || valid_promotion<RTYPE>(TYPEOF(chunk));
  }


private:
  Vec res;
  int pos;
  bool seen_na_only;
  const SymbolString name;

};

template <typename CLASS>
class FactorDelayedProcessor : public IDelayedProcessor {
private:
  typedef dplyr_hash_map<SEXP, int> LevelsMap;

public:

  FactorDelayedProcessor(SEXP first_result, int ngroups, const SymbolString& name_) :
    res(Rcpp::no_init(ngroups)), pos(0), name(name_)
  {
    copy_most_attributes(res, first_result);
    Rcpp::CharacterVector levels = get_levels(first_result);
    int n = levels.size();
    for (int i = 0; i < n; i++) levels_map[ levels[i] ] = i + 1;
    if (!try_handle(first_result))
      Rcpp::stop("cannot handle factor result for column '%s'", name.get_utf8_cstring());
  }

  virtual bool try_handle(const Rcpp::RObject& chunk) {
    Rcpp::CharacterVector lev = get_levels(chunk);
    update_levels(lev);

    int val = Rcpp::as<int>(chunk);
    if (val != NA_INTEGER) val = levels_map[lev[val - 1]];
    res[pos++] = val;
    return true;
  }

  virtual IDelayedProcessor* promote(const Rcpp::RObject&) {
    return 0;
  }

  virtual SEXP get() {
    int n = levels_map.size();
    Rcpp::CharacterVector levels(n);
    LevelsMap::iterator it = levels_map.begin();
    for (int i = 0; i < n; i++, ++it) {
      levels[it->second - 1] = it->first;
    }
    set_levels(res, levels);
    return res;
  }

  virtual std::string describe() {
    return "factor";
  }

private:

  void update_levels(const Rcpp::CharacterVector& lev) {
    int nlevels = levels_map.size();
    int n = lev.size();
    for (int i = 0; i < n; i++) {
      SEXP s = lev[i];
      if (! levels_map.count(s)) {
        levels_map.insert(std::make_pair(s, ++nlevels));
      }
    }
  }

  Rcpp::IntegerVector res;
  int pos;
  LevelsMap levels_map;
  const SymbolString name;
};



template <typename CLASS>
class DelayedProcessor<VECSXP, CLASS> : public IDelayedProcessor {
public:
  DelayedProcessor(SEXP first_result, int ngroups, const SymbolString& name_) :
    res(ngroups), pos(0), name(name_)
  {
    copy_most_attributes(res, first_result);
    if (!try_handle(first_result))
      Rcpp::stop("cannot handle list result for column '%s'", name.get_utf8_cstring());
  }

  virtual bool try_handle(const Rcpp::RObject& chunk) {
    if (Rcpp::is<Rcpp::List>(chunk) && Rf_length(chunk) == 1) {
      res[pos++] = Rf_duplicate(VECTOR_ELT(chunk, 0));
      return true;
    }
    return false;
  }

  virtual IDelayedProcessor* promote(const Rcpp::RObject&) {
    return 0;
  }

  virtual SEXP get() {
    return res;
  }

  virtual std::string describe() {
    return "list";
  }

private:
  Rcpp::List res;
  int pos;
  const SymbolString name;
};

template <typename CLASS>
IDelayedProcessor* get_delayed_processor(SEXP first_result, int ngroups, const SymbolString& name) {
  check_supported_type(first_result, name);
  check_length(Rf_length(first_result), 1, "a summary value", name);

  if (Rf_inherits(first_result, "factor")) {
    return new FactorDelayedProcessor<CLASS>(first_result, ngroups, name);
  } else if (Rcpp::is<int>(first_result)) {
    return new DelayedProcessor<INTSXP, CLASS>(first_result, ngroups, name);
  } else if (Rcpp::is<double>(first_result)) {
    return new DelayedProcessor<REALSXP, CLASS>(first_result, ngroups, name);
  } else if (Rcpp::is<Rcpp::String>(first_result)) {
    return new DelayedProcessor<STRSXP, CLASS>(first_result, ngroups, name);
  } else if (Rcpp::is<bool>(first_result)) {
    return new DelayedProcessor<LGLSXP, CLASS>(first_result, ngroups, name);
  } else if (Rcpp::is<Rcpp::List>(first_result)) {
    return new DelayedProcessor<VECSXP, CLASS>(first_result, ngroups, name);
  } else if (TYPEOF(first_result) == CPLXSXP) {
    return new DelayedProcessor<CPLXSXP, CLASS>(first_result, ngroups, name);
  }

  Rcpp::stop("unknown result of type %d for column '%s'", TYPEOF(first_result), name.get_utf8_cstring());
}


template <typename SlicedTibble>
class GroupedCallReducer  {
public:
  typedef typename SlicedTibble::slicing_index Index ;

  GroupedCallReducer(const NamedQuosure& quosure_, DataMask<SlicedTibble>& data_mask_) :
    quosure(quosure_),
    data_mask(data_mask_)
  {
    data_mask.setup();
  }

  SEXP process(const SlicedTibble& gdf) ;

  inline SEXP process_chunk(const Index& indices) {
    return data_mask.eval(quosure.get(), indices);
  }

  const SymbolString& get_name() const {
    return quosure.name();
  }

private:
  const NamedQuosure& quosure;
  DataMask<SlicedTibble>& data_mask;
};


template <typename SlicedTibble>
class process_data {
public:
  process_data(const SlicedTibble& gdf, GroupedCallReducer<SlicedTibble>& chunk_source_) :
    git(gdf.group_begin()),
    ngroups(gdf.ngroups()),
    chunk_source(chunk_source_)
  {}

  SEXP run() {
    if (ngroups == 0) {
      LOG_INFO << "no groups to process";
      return get_processed_empty();
    }

    LOG_INFO << "processing groups";
    process_first();
    process_rest();
    return get_processed();
  }

private:
  void process_first() {
    Rcpp::RObject first_result = fetch_chunk();
    LOG_INFO << "instantiating delayed processor for type " << type2name(first_result)
             << " for column `" << chunk_source.get_name().get_utf8_cstring() << "`";

    processor.reset(get_delayed_processor< GroupedCallReducer<SlicedTibble> >(first_result, ngroups, chunk_source.get_name()));
    LOG_VERBOSE << "processing " << ngroups << " groups with " << processor->describe() << " processor";
  }

  void process_rest() {
    for (int i = 1; i < ngroups; ++i) {
      const Rcpp::RObject& chunk = fetch_chunk();
      if (!try_handle_chunk(chunk)) {
        LOG_VERBOSE << "not handled group " << i;
        handle_chunk_with_promotion(chunk, i);
      }
    }
  }

  bool try_handle_chunk(const Rcpp::RObject& chunk) const {
    return processor->try_handle(chunk);
  }

  void handle_chunk_with_promotion(const Rcpp::RObject& chunk, const int i) {
    IDelayedProcessor* new_processor = processor->promote(chunk);
    if (!new_processor) {
      bad_col(chunk_source.get_name(), "can't promote group {group} to {type}",
              Rcpp::_["group"] = i, Rcpp::_["type"] =  processor->describe());
    }

    LOG_VERBOSE << "promoted group " << i;
    processor.reset(new_processor);
  }

  Rcpp::RObject fetch_chunk() {
    Rcpp::RObject chunk = chunk_source.process_chunk(*git);
    ++git;
    return chunk;
  }

  SEXP get_processed() const {
    return processor->get();
  }

  SEXP get_processed_empty() {
    SEXP res = PROTECT(chunk_source.process_chunk(typename SlicedTibble::slicing_index()));
    // recycle res 0 times
    SEXP out = PROTECT(Rf_allocVector(TYPEOF(res), 0));
    copy_attributes(out, res);
    UNPROTECT(2);
    return out;
  }

private:
  typename SlicedTibble::group_iterator git;
  const int ngroups;
  boost::scoped_ptr<IDelayedProcessor> processor;
  GroupedCallReducer<SlicedTibble>& chunk_source;
};

template <typename SlicedTibble>
inline SEXP GroupedCallReducer<SlicedTibble>::process(const SlicedTibble& gdf) {
  return process_data<SlicedTibble>(gdf, *this).run();
}

template <>
inline SEXP GroupedCallReducer<NaturalDataFrame>::process(const NaturalDataFrame& gdf) {
  return process_chunk(NaturalSlicingIndex(gdf.nrows())) ;
}

}

#endif
