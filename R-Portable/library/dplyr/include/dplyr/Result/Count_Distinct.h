#ifndef dplyr_Result_Count_Distinct_H
#define dplyr_Result_Count_Distinct_H

#include <tools/hash.h>

#include <dplyr/visitor_set/VisitorEqualPredicate.h>
#include <dplyr/visitor_set/VisitorHash.h>
#include <dplyr/Result/Processor.h>

namespace dplyr {

template <typename Visitor>
class Count_Distinct : public Processor<INTSXP, Count_Distinct<Visitor> > {
public:
  typedef VisitorHash<Visitor> Hash;
  typedef VisitorEqualPredicate<Visitor> Pred;
  typedef dplyr_hash_set<int, Hash, Pred > Set;

  Count_Distinct(Visitor v_):
    v(v_), set(0, Hash(v), Pred(v))
  {}

  inline int process_chunk(const SlicingIndex& indices) {
    set.clear();
    set.rehash(indices.size());
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      set.insert(indices[i]);
    }
    return set.size();
  }

private:
  Visitor v;
  Set set;
};

template <typename Visitor>
class Count_Distinct_Narm : public Processor<INTSXP, Count_Distinct_Narm<Visitor> > {
public:
  typedef VisitorHash<Visitor> Hash;
  typedef VisitorEqualPredicate<Visitor> Pred;
  typedef dplyr_hash_set<int, Hash, Pred > Set;

  Count_Distinct_Narm(Visitor v_):
    v(v_), set(0, Hash(v), Pred(v))
  {}

  inline int process_chunk(const SlicingIndex& indices) {
    set.clear();
    set.rehash(indices.size());
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      int index = indices[i];
      if (! v.is_na(index)) {
        set.insert(index);
      }
    }
    return set.size();
  }

private:
  Visitor v;
  Set set;
};


}

#endif
