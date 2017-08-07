#ifndef dplyr_Result_CallbackProcessor_H
#define dplyr_Result_CallbackProcessor_H

#include <boost/scoped_ptr.hpp>

#include <tools/all_na.h>

#include <dplyr/Result/Result.h>
#include <dplyr/Result/DelayedProcessor.h>

#include <dplyr/bad.h>

namespace dplyr {

// classes inherit from this template when they have a method with this signature
// SEXP process_chunk( const SlicingIndex& indices)
//
// the first time process_chunk is called, CallbackProcessor finds the right type
// for storing the results, and it creates a suitable DelayedProcessor
// object which is then used to fill the vector
//
// DelayedReducer is an example on how CallbackReducer is used
//
// it is assumed that the SEXP comes from evaluating some R expression, so
// it should be one of a integer vector of length one, a numeric vector of
// length one or a character vector of length one
template <typename CLASS>
class CallbackProcessor : public Result {
public:
  CallbackProcessor() {}

  CLASS* obj() {
    return static_cast<CLASS*>(this);
  }

  virtual SEXP process(const GroupedDataFrame& gdf) {
    return process_data<GroupedDataFrame>(gdf, obj()).run();
  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    return process_data<RowwiseDataFrame>(gdf, obj()).run();
  }

  virtual SEXP process(const Rcpp::FullDataFrame& df) {
    return obj()->process_chunk(df.get_index());
  }

  virtual SEXP process(const SlicingIndex&) {
    return R_NilValue;
  }

private:

  template <typename Data>
  class process_data {
  public:
    process_data(const Data& gdf, CLASS* chunk_source_) : git(gdf.group_begin()), ngroups(gdf.ngroups()), chunk_source(chunk_source_) {}

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
      const RObject& first_result = fetch_chunk();
      LOG_INFO << "instantiating delayed processor for type " << type2name(first_result)
               << " for column `" << chunk_source->get_name().get_utf8_cstring() << "`";

      processor.reset(get_delayed_processor<CLASS>(first_result, ngroups, chunk_source->get_name()));
      LOG_VERBOSE << "processing " << ngroups << " groups with " << processor->describe() << " processor";
    }

    void process_rest() {
      for (int i = 1; i < ngroups; ++i) {
        const RObject& chunk = fetch_chunk();
        if (!try_handle_chunk(chunk)) {
          LOG_VERBOSE << "not handled group " << i;
          handle_chunk_with_promotion(chunk, i);
        }
      }
    }

    bool try_handle_chunk(const RObject& chunk) const {
      return processor->try_handle(chunk);
    }

    void handle_chunk_with_promotion(const RObject& chunk, const int i) {
      IDelayedProcessor* new_processor = processor->promote(chunk);
      if (!new_processor) {
        bad_col(chunk_source->get_name(), "can't promote group {group} to {type}",
                _["group"] = i, _["type"] =  processor->describe());
      }

      LOG_VERBOSE << "promoted group " << i;
      processor.reset(new_processor);
    }

    RObject fetch_chunk() {
      const RObject& chunk = chunk_source->process_chunk(*git);
      ++git;
      return chunk;
    }

    SEXP get_processed() const {
      return processor->get();
    }

    static SEXP get_processed_empty() {
      return LogicalVector(0, NA_LOGICAL);
    }

  private:
    typename Data::group_iterator git;
    const int ngroups;
    boost::scoped_ptr<IDelayedProcessor> processor;
    CLASS* chunk_source;
  };

};
}
#endif
