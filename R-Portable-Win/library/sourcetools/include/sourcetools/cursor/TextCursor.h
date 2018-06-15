#ifndef SOURCETOOLS_CURSOR_TEXT_CURSOR_H
#define SOURCETOOLS_CURSOR_TEXT_CURSOR_H

#include <string>

#include <sourcetools/core/macros.h>
#include <sourcetools/collection/Position.h>

namespace sourcetools {
namespace cursors {

class TextCursor
{
public:

  TextCursor(const char* text, std::size_t n)
      : text_(text),
        n_(n),
        offset_(0),
        position_(0, 0)
  {
  }

  char peek(std::size_t offset = 0)
  {
    std::size_t index = offset_ + offset;
    if (UNLIKELY(index >= n_))
      return '\0';
    return text_[index];
  }

  void advance(std::size_t times = 1)
  {
    for (std::size_t i = 0; i < times; ++i) {
      if (peek() == '\n') {
        ++position_.row;
        position_.column = 0;
      } else {
        ++position_.column;
      }
      ++offset_;
    }
  }

  operator const char*() const { return text_ + offset_; }

  std::size_t offset() const { return offset_; }

  const collections::Position& position() const { return position_; }
  std::size_t row() const { return position_.row; }
  std::size_t column() const { return position_.column; }

  const char* begin() const { return text_; }
  const char* end() const { return text_ + n_; }

private:
  const char* text_;
  std::size_t n_;
  std::size_t offset_;
  collections::Position position_;
};

} // namespace cursors
} // namespace sourcetools

#endif /* SOURCETOOLS_CURSOR_TEXT_CURSOR_H */
