#ifndef dplyr__Call_h
#define dplyr__Call_h

namespace Rcpp {

class Call {
public:

  Call() : data(R_NilValue) {}

  Call(SEXP x) : data(x) {
    if (data != R_NilValue) R_PreserveObject(data);
  }

  ~Call() {
    if (data != R_NilValue) R_ReleaseObject(data);
  }

  Call(const Call& other) : data(other.data) {
    if (data != R_NilValue) R_PreserveObject(data);
  }

  Call& operator=(SEXP other) {
    if (other != data) {
      if (data != R_NilValue) R_ReleaseObject(data);
      data = other;
      if (data != R_NilValue) R_PreserveObject(data);
    }
    return *this;
  }

  inline SEXP eval(SEXP env) const {
    return Rcpp_eval(data, env);
  }

  inline operator SEXP() const {
    return data;
  }

private:
  SEXP data;

  Call& operator=(const Call& other);
  // {
  //   *this = other.data;
  //   return *this;
  // }

};

}

#endif

