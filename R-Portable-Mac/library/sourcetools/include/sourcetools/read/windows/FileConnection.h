#ifndef SOURCETOOLS_READ_WINDOWS_FILE_CONNECTION_H
#define SOURCETOOLS_READ_WINDOWS_FILE_CONNECTION_H

#undef Realloc
#undef Free
#include <windows.h>

namespace sourcetools {
namespace detail {

class FileConnection
{
public:
  typedef HANDLE FileDescriptor;

  FileConnection(const char* path, int flags = GENERIC_READ)
  {
    handle_ = ::CreateFile(path, flags, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
  }

  ~FileConnection()
  {
    if (open())
      ::CloseHandle(handle_);
  }

  bool open()
  {
    return handle_ != INVALID_HANDLE_VALUE;
  }

  bool size(std::size_t* pSize)
  {
    *pSize = ::GetFileSize(handle_, NULL);
    return true;
  }

  operator FileDescriptor() const
  {
    return handle_;
  }

private:
  FileDescriptor handle_;
};

} // namespace detail
} // namespace sourcetools

#endif /* SOURCETOOLS_READ_WINDOWS_FILE_CONNECTION_H */
