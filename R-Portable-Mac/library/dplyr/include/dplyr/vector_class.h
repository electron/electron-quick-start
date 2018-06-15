#ifndef dplyr_vector_class_H
#define dplyr_vector_class_H

namespace dplyr {

template <int RTYPE>
inline std::string vector_class();

template <>
inline std::string vector_class<INTSXP>() {
  return "integer";
}
template <>
inline std::string vector_class<REALSXP>() {
  return "numeric";
}
template <>
inline std::string vector_class<STRSXP>() {
  return "character";
}
template <>
inline std::string vector_class<LGLSXP>() {
  return "logical";
}
template <>
inline std::string vector_class<VECSXP>() {
  return "list";
}
template <>
inline std::string vector_class<CPLXSXP>() {
  return "complex";
}


}

#endif
