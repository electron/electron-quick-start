#ifndef dplyr_visitors_SliceVisitor_h
#define dplyr_visitors_SliceVisitor_h

namespace dplyr {
namespace visitors {

template <typename Vector, typename Index>
class SliceVisitor {
public:
  typedef typename Vector::stored_type stored_type;

  SliceVisitor(const Vector& data_, const Index& index_) :
    data(data_),
    index(index_)
  {}

  inline stored_type operator[](int i) const {
    return data[index[i]];
  }

  inline int size() const {
    return index.size();
  }

private:
  const Vector& data;
  const Index& index;
};

template <typename Vector, typename Index>
class WriteSliceVisitor {
public:
  typedef typename Vector::Proxy Proxy;
  typedef typename Vector::stored_type stored_type;

  WriteSliceVisitor(Vector& data_, const Index& index_) :
    data(data_),
    index(index_)
  {}

  inline Proxy operator[](int i) {
    return data[index[i]];
  }

  inline int size() const {
    return index.size();
  }

private:
  Vector& data;
  const Index& index;
};

}
}
#endif
