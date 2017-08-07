#ifndef dplyr_tools_FullDataFrame_H
#define dplyr_tools_FullDataFrame_H

namespace dplyr {

class FullDataFrame {
public:
  typedef NaturalSlicingIndex slicing_index;

  FullDataFrame(const DataFrame& data_) : index(data_.nrows()) {}

  const SlicingIndex& get_index() const {
    return index;
  }

  inline int nrows() const {
    return index.size();
  }

private:
  NaturalSlicingIndex index;
};

}
#endif
