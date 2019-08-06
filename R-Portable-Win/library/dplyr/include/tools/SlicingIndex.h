#ifndef dplyr_tools_SlicingIndex_H
#define dplyr_tools_SlicingIndex_H

#include <tools/VectorView.h>

// A SlicingIndex allows specifying which rows of a data frame are selected in which order, basically a 0:n -> 0:m map.
// It also can be used to split a data frame in groups.
// Important special cases can be implemented without materializing the map.
class SlicingIndex {
public:
  virtual ~SlicingIndex() {};
  virtual int size() const = 0;
  virtual int operator[](int i) const = 0;
  virtual int group() const = 0;
};

// A GroupedSlicingIndex is the most general slicing index,
// the 0:n -> 0:m map is specified and stored as an IntegerVector.
// A group identifier can be assigned on construction.
// It is used in grouped operations (group_by()).
class GroupedSlicingIndex : public SlicingIndex {
public:
  GroupedSlicingIndex(): data(), group_index(-1), preserved(true) {
    R_PreserveObject(data);
  }

  ~GroupedSlicingIndex() {
    if (preserved) {
      R_ReleaseObject(data);
    }
  }

  GroupedSlicingIndex(SEXP data_, int group_) : data(data_), group_index(group_), preserved(false) {}

  GroupedSlicingIndex(int group_) : data(Rf_ScalarInteger(group_ + 1)), group_index(group_), preserved(true) {
    R_PreserveObject(data);
  }

  virtual int size() const {
    return data.size();
  }

  virtual int operator[](int i) const {
    return data[i] - 1;
  }

  virtual int group() const {
    return group_index;
  }

  inline operator SEXP() const {
    return data;
  }

private:
  // in general we don't need to protect data because
  // it is already protected by the .rows column of the grouped_df
  //
  // but we do when using the default constructor, hence the
  // R_PreserveObject / R_ReleaseObject above
  Rcpp::IntegerVectorView data;

  int group_index;
  bool preserved;
};

// A RowwiseSlicingIndex selects a single row, which is also the group ID by definition.
// It is used in rowwise operations (rowwise()).
class RowwiseSlicingIndex : public SlicingIndex {
public:
  RowwiseSlicingIndex(): start(0) {}
  RowwiseSlicingIndex(const int start_) : start(start_) {}

  inline int size() const {
    return 1;
  }

  inline int operator[](int i) const {
    return start;
  }

  inline int group() const {
    return start;
  }

  inline operator SEXP() const {
    return Rf_ScalarInteger(start + 1);
  }

private:
  int start;
};

// A NaturalSlicingIndex selects an entire data frame as a single group.
// It is used when the entire data frame needs to be processed by a processor that expects a SlicingIndex
// to address the rows.
class NaturalSlicingIndex : public SlicingIndex {
public:
  NaturalSlicingIndex(): n(0) {}
  NaturalSlicingIndex(const int n_) : n(n_) {}

  virtual int size() const {
    return n;
  }

  virtual int operator[](int i) const {
    return i;
  }

  virtual int group() const {
    return 0 ;
  }

private:
  int n;
};

// An OffsetSlicingIndex selects a consecutive part of a data frame, starting at a specific row.
// It is used for binding data frames vertically (bind_rows()).
class OffsetSlicingIndex : public SlicingIndex {
public:
  OffsetSlicingIndex(const int start_, const int n_) : start(start_), n(n_) {}

  inline int size() const {
    return n;
  }

  inline int operator[](int i) const {
    return i + start;
  }

  inline int group() const {
    return 0;
  }

private:
  int start, n;
};

#endif
