#ifndef dplyr_tools_pointer_vector_H
#define dplyr_tools_pointer_vector_H

namespace dplyr {

template <typename T>
class pointer_vector {
public:

  typedef typename std::vector<T*> Vector;
  typedef typename Vector::reference reference;
  typedef typename Vector::const_reference const_reference;
  typedef typename Vector::size_type size_type;
  typedef typename Vector::value_type value_type;
  typedef typename Vector::iterator iterator;

  pointer_vector() : data() {}
  pointer_vector(size_type n) : data(n) {}
  inline ~pointer_vector() {
    typedef typename Vector::size_type size_type;
    size_type n = data.size();
    iterator it = data.end();
    --it;
    for (size_type i = 0; i < n; --it, i++) delete *it;
  }

  inline reference operator[](size_type i) {
    return data[i];
  }
  inline const_reference operator[](size_type i) const {
    return data[i];
  }
  inline void push_back(const value_type& value) {
    data.push_back(value);
  }
  inline size_type size() const {
    return data.size();
  }

private:
  Vector data;
  pointer_vector(const pointer_vector&);
};
}

#endif
