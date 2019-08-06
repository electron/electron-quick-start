#ifndef dplyr_hybrid_dispatch_h
#define dplyr_hybrid_dispatch_h

#include <dplyr/hybrid/HybridVectorScalarResult.h>
#include <dplyr/hybrid/Column.h>

namespace dplyr {
namespace hybrid {

struct Summary {
  template <typename T>
  inline SEXP operator()(const T& obj) const {
    return obj.summarise();
  }
};

struct Window {
  template <typename T>
  inline SEXP operator()(const T& obj) const {
    return obj.window();
  }
};

struct Match {
  template <typename T>
  inline SEXP operator()(const T& obj) const {
    return Rf_mkString(DEMANGLE(T));
  }
};

}
}


#endif
