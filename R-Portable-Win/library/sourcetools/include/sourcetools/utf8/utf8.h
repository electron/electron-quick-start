#ifndef SOURCETOOLS_UTF8_UTF8_H
#define SOURCETOOLS_UTF8_UTF8_H

#include <cstddef>

#include <sourcetools/core/core.h>

namespace sourcetools {
namespace utf8 {

namespace detail {
static const unsigned char mask[] = {
  0,    // 00000000
  0x7F, // 01111111
  0x1F, // 00011111
  0x0F, // 00001111
  0x07, // 00000111
  0x03, // 00000011
  0x01  // 00000001
};
} // namespace detail

class iterator
{
public:
  iterator(const char* data)
    : data_(reinterpret_cast<const unsigned char*>(data)),
      offset_(0)
  {
  }

  iterator(const iterator& other)
    : data_(other.data_),
      offset_(other.offset_)
  {
  }

  wchar_t operator*()
  {
    std::size_t n = size();
    if (n == 0 || n > 6)
      return -1;

    const unsigned char* it = data_ + offset_;
    wchar_t ch = (*it++) & detail::mask[n];
    for (std::size_t i = 1; i < n; ++i)
    {
      ch <<= 6;
      ch |= (*it++) & 0x3F;
    }

    return ch;
  }

  iterator& operator++()
  {
    offset_ += size();
    return *this;
  }

  iterator operator++(int)
  {
    iterator copy(*this);
    operator++();
    return copy;
  }

  bool operator==(const iterator& it)
  {
    return
      data_ + offset_ ==
      it.data_ + it.offset_;
  }

  bool operator!=(const iterator& it)
  {
    return
      data_ + offset_ !=
      it.data_ + it.offset_;
  }

private:

  int size()
  {
    unsigned char ch = data_[offset_];
    if (ch == 0)
      return 0;
    else if (ch < 192)
      return 1;
    else if (ch < 224)
      return 2;
    else if (ch < 240)
      return 3;
    else if (ch < 248)
      return 4;
    else if (ch < 252)
      return 5;
    else if (ch < 254)
      return 6;

    // TODO: on error?
    return 1;
  }

private:

  const unsigned char* data_;
  std::size_t offset_;
};

} // namespace utf8
} // namespace sourcetools

#endif /* SOURCETOOLS_UTF8_UTF8_H */
