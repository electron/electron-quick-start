#ifndef SOURCETOOLS_MULTIBYTE_MULTIBYTE_H
#define SOURCETOOLS_MULTIBYTE_MULTIBYTE_H

#include <cstdlib>
#include <cwchar>

namespace sourcetools {
namespace multibyte {

template <typename T>
inline bool countWhitespaceBytes(const char* data,
                                 T* pBytes)
{
  wchar_t ch;
  T bytes = 0;
  const char* it = data;

  while (true) {

    int status = std::mbtowc(&ch, it, MB_CUR_MAX);
    if (status == 0) {
      break;
    } else if (status == -1) {
      break;
    }

    if (!std::iswspace(ch))
      break;

    bytes += status;
    it += status;
  }

  *pBytes = bytes;
  return bytes != 0;
}

} // namespace multibyte
} // namespace sourcetools

#endif /* SOURCETOOLS_MULTIBYTE_MULTIBYTE_H */
