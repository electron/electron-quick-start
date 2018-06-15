#ifndef SOURCETOOLS_CORE_MACROS_H
#define SOURCETOOLS_CORE_MACROS_H

#include <cstdio>

#include <string>
#include <iostream>

/* Utility */
#ifdef __GNUC__
# define LIKELY(x)   __builtin_expect(!!(x), 1)
# define UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
# define LIKELY(x) x
# define UNLIKELY(x) x
#endif

#define SOURCE_TOOLS_CHECK_MASK(__SELF__, __MASK__)                    \
  ((__MASK__ & __SELF__) == __MASK__)

#define SOURCE_TOOLS_LOWER_BITS(__VALUE__, __BITS__)                   \
  (((1 << __BITS__) - 1) & __VALUE__)

#define SOURCE_TOOLS_PASTE(__X__, __Y__) __X__ ## __Y__
#define SOURCE_TOOLS_STRINGIFY(__X__) #__X__

/* Logging */
namespace sourcetools {
namespace debug {

inline std::string shortFilePath(const std::string& filePath)
{
  std::string::size_type index = filePath.find_last_of("/");
  if (index != std::string::npos)
    return filePath.substr(index + 1);
  return filePath;
}

inline std::string debugPosition(const char* filePath, int line)
{
  static const int N = 1024;
  char buffer[N + 1];
  std::string shortPath = shortFilePath(filePath);
  if (shortPath.size() > N / 2)
    shortPath = shortPath.substr(0, N / 2);
  std::sprintf(buffer, "[%s:%4i]", shortPath.c_str(), line);
  return buffer;
}

} // namespace debug
} // namespace sourcetools

// Flip on/off as necessary
#define SOURCE_TOOLS_ENABLE_DEBUG_LOGGING

#ifdef SOURCE_TOOLS_ENABLE_DEBUG_LOGGING

#include <iostream>

#define DEBUG(__X__)                                                   \
  std::cerr << ::sourcetools::debug::debugPosition(__FILE__, __LINE__) \
            << ": " << __X__ << ::std::endl;
#define DEBUG_BLOCK(x)

#else

#define DEBUG(x)
#define DEBUG_BLOCK(x) if (false)

#endif

#endif /* SOURCETOOLS_CORE_MACROS_H */
