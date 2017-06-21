#ifndef SOURCETOOLS_CORE_UTIL_H
#define SOURCETOOLS_CORE_UTIL_H

#include <string>
#include <memory>
#include <cctype>
#include <cstdlib>

namespace sourcetools {
namespace detail {

class noncopyable
{
protected:
  noncopyable() {}
  ~noncopyable() {}

private:
  noncopyable(const noncopyable&);
  noncopyable& operator=(const noncopyable&);
};

} // namespace detail
typedef detail::noncopyable noncopyable;

template <typename T>
class scoped_ptr : noncopyable
{
public:
  explicit scoped_ptr(T* pData) : pData_(pData) {}
  T& operator*() const { return *pData_; }
  T* operator->() const { return pData_; }
  operator T*() const { return pData_; }
  ~scoped_ptr() { delete pData_; }
private:
  T* pData_;
};

template <typename T>
class scoped_array : noncopyable
{
public:
  explicit scoped_array(T* pData) : pData_(pData) {}
  T& operator*() const { return *pData_; }
  T* operator->() const { return pData_; }
  operator T*() const { return pData_; }
  ~scoped_array() { delete[] pData_; }
private:
  T* pData_;
};

namespace utils {

inline bool isWhitespace(char ch)
{
  return
    ch == ' ' ||
    ch == '\f' ||
    ch == '\r' ||
    ch == '\n' ||
    ch == '\t' ||
    ch == '\v';
}

template <typename T>
inline bool countWhitespaceBytes(const char* data,
                                 T* pBytes)
{
  T bytes = 0;
  while (isWhitespace(*data)) {
    ++data;
    ++bytes;
  }

  *pBytes = bytes;
  return bytes != 0;
}

inline bool isDigit(char ch)
{
  return
    (ch >= '0' && ch <= '9');
}

inline bool isAlphabetic(char ch)
{
  return
    (ch >= 'a' && ch <= 'z') ||
    (ch >= 'A' && ch <= 'Z');
}

inline bool isAlphaNumeric(char ch)
{
  return
    (ch >= 'a' && ch <= 'z') ||
    (ch >= 'A' && ch <= 'Z') ||
    (ch >= '0' && ch <= '9');
}

inline bool isHexDigit(char ch)
{
  return
    (ch >= '0' && ch <= '9') ||
    (ch >= 'a' && ch <= 'f') ||
    (ch >= 'A' && ch <= 'F');
}

inline bool isValidForStartOfRSymbol(char ch)
{
  return
    isAlphabetic(ch) ||
    ch == '.' ||
    ch < 0;
}

inline bool isValidForRSymbol(char ch)
{
  return
    isAlphaNumeric(ch) ||
    ch == '.' ||
    ch == '_' ||
    ch < 0;
}

inline std::string escape(char ch)
{
  switch (ch) {
  case '\r':
    return "\\r";
  case '\n':
    return "\\n";
  case '\t':
    return "\\t";
  default:
    return std::string(1, ch);
  }
}

} // namespace utils
} // namespace sourcetools

#endif /* SOURCETOOLS_CORE_UTIL_H */
