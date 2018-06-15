#ifndef dplyr_HASH_H
#define dplyr_HASH_H

#include <boost/functional/hash.hpp>

#ifndef dplyr_hash_map
#if defined(_WIN32)
#define dplyr_hash_map RCPP_UNORDERED_MAP
#else
#include <boost/unordered_map.hpp>
#define dplyr_hash_map boost::unordered_map
#endif
#endif // #ifndef dplyr_hash_map

#ifndef dplyr_hash_set
#if defined(_WIN32)
#define dplyr_hash_set RCPP_UNORDERED_SET
#else
#include <boost/unordered_set.hpp>
#define dplyr_hash_set boost::unordered_set
#endif
#endif // #ifndef dplyr_hash_set

inline std::size_t hash_value(const Rcomplex& cx) {
  boost::hash<double> hasher;
  size_t seed = hasher(cx.r);
  boost::hash_combine(seed, hasher(cx.i));
  return seed;
}

#endif
