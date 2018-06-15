#ifndef DPLYR_SOLARIS_H
#define DPLYR_SOLARIS_H

#if defined(__SUNPRO_CC) && !defined(Rcpp__platform__solaris_h)

namespace Rcpp {
namespace traits {

template <typename T> struct is_convertible< std::vector<T>, SEXP> : public false_type {};
template <> struct is_convertible<Range, SEXP> : public false_type {};

template <int RTYPE, bool NA>
struct is_convertible< sugar::Minus_Vector_Primitive< RTYPE, NA, Vector<RTYPE> >, SEXP> : public false_type {};

template <int RTYPE, bool NA>
struct is_convertible< sugar::Plus_Vector_Primitive< RTYPE, NA, Vector<RTYPE> >, SEXP> : public false_type {};

}
}

#endif

#endif
