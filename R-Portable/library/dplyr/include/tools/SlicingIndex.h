#ifndef dplyr_tools_SlicingIndex_H
#define dplyr_tools_SlicingIndex_H

// A SlicingIndex allows specifying which rows of a data frame are selected in which order, basically a 0:n -> 0:m map.
// It also can be used to split a data frame in groups.
// Important special cases can be implemented without materializing the map.
class SlicingIndex {
public:
  virtual int size() const = 0;
  virtual int operator[](int i) const = 0;
  virtual int group() const = 0;
  virtual bool is_identity(SEXP) const {
    return FALSE;
  };
};

// A GroupedSlicingIndex is the most general slicing index,
// the 0:n -> 0:m map is specified and stored as an IntegerVector.
// A group identifier can be assigned on construction.
// It is used in grouped operations (group_by()).
class GroupedSlicingIndex : public SlicingIndex {
public:
  GroupedSlicingIndex(IntegerVector data_) : data(data_), group_index(-1) {}
  GroupedSlicingIndex(IntegerVector data_, int group_) : data(data_), group_index(group_) {}

  virtual int size() const {
    return data.size();
  }

  virtual int operator[](int i) const {
    return data[i];
  }

  virtual int group() const {
    return group_index;
  }

private:
  IntegerVector data;
  int group_index;
};

// A RowwiseSlicingIndex selects a single row, which is also the group ID by definition.
// It is used in rowwise operations (rowwise()).
class RowwiseSlicingIndex : public SlicingIndex {
public:
  RowwiseSlicingIndex(const int start_) : start(start_) {}

  inline int size() const {
    return 1;
  }

  inline int operator[](int i) const {
    if (i != 0)
      stop("Can only use 0 for RowwiseSlicingIndex, queried %d", i);
    return start;
  }

  inline int group() const {
    return start;
  }

private:
  int start;
};

// A NaturalSlicingIndex selects an entire data frame as a single group.
// It is used when the entire data frame needs to be processed by a processor that expects a SlicingIndex
// to address the rows.
class NaturalSlicingIndex : public SlicingIndex {
public:
  NaturalSlicingIndex(const int n_) : n(n_) {}

  virtual int size() const {
    return n;
  }

  virtual int operator[](int i) const {
    if (i < 0 || i >= n)
      stop("Out of bounds index %d queried for NaturalSlicingIndex", i);
    return i;
  }

  virtual int group() const {
    return -1;
  }

  virtual bool is_identity(SEXP x) const {
    const R_len_t length = Rf_length(x);
    return length == n;
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
    if (i < 0 || i >= n)
      stop("Out of bounds index %d queried for OffsetSlicingIndex", i);
    return i + start;
  }

  inline int group() const {
    return -1;
  }

private:
  int start, n;
};

#endif
