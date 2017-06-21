#ifndef SOURCETOOLS_READ_MEMORY_MAPPED_READER_H
#define SOURCETOOLS_READ_MEMORY_MAPPED_READER_H

#include <vector>
#include <string>
#include <algorithm>

#include <sourcetools/core/macros.h>

#include <sourcetools/r/RHeaders.h>
#include <sourcetools/r/RUtils.h>

#ifndef _WIN32
# include <sourcetools/read/posix/FileConnection.h>
# include <sourcetools/read/posix/MemoryMappedConnection.h>
#else
# include <sourcetools/read/windows/FileConnection.h>
# include <sourcetools/read/windows/MemoryMappedConnection.h>
#endif

namespace sourcetools {
namespace detail {

class MemoryMappedReader
{
public:

  class VectorReader
  {
  public:

    explicit VectorReader(std::vector<std::string>* pData)
      : pData_(pData)
    {
    }

    template <typename T>
    void operator()(const T& lhs, const T& rhs)
    {
      pData_->push_back(std::string(lhs, rhs));
    }

  private:
    std::vector<std::string>* pData_;
  };

  static bool read(const char* path, std::string* pContent)
  {
    // Open file connection
    FileConnection conn(path);
    if (!conn.open())
      return false;

    // Get size of file
    std::size_t size;
    if (!conn.size(&size))
      return false;

    // Early return for empty files
    if (UNLIKELY(size == 0))
      return true;

    // mmap the file
    MemoryMappedConnection map(conn, size);
    if (!map.open())
      return false;

    pContent->assign(map, size);
    return true;
  }

  template <typename F>
  static bool read_lines(const char* path, F f)
  {
    FileConnection conn(path);
    if (!conn.open())
      return false;

    // Get size of file
    std::size_t size;
    if (!conn.size(&size))
      return false;

    // Early return for empty files
    if (UNLIKELY(size == 0))
      return true;

    // mmap the file
    MemoryMappedConnection map(conn, size);
    if (!map.open())
      return false;

    // special case: just a '\n'
    bool endsWithNewline = map[size - 1] == '\n';
    if (size == 1 && endsWithNewline)
      return true;

    // Search for newlines
    const char* lower = map;
    const char* upper = map;
    const char* end = map + size;
    while (true)
    {
      upper = std::find(lower, end, '\n');
      if (upper == end)
        break;

      // Handle '\r\n'
      int CR = *(upper - 1) == '\r';
      upper -= CR;

      // Pass to functor
      f(lower, upper);

      // Update
      lower = upper + 1 + CR;
    }

    // If this file ended with a newline, we're done
    if (endsWithNewline)
      return true;

    // Otherwise, consume one more string, then we're done
    f(lower, end);
    return true;
  }

  static bool read_lines(const char* path, std::vector<std::string>* pContent)
  {
    VectorReader reader(pContent);
    return read_lines(path, reader);
  }

};

} // namespace detail
} // namespace sourcetools

#endif /* SOURCETOOLS_READ_MEMORY_MAPPED_READER_H */
