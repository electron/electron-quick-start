#ifndef SOURCETOOLS_TOKENIZATION_TOKEN_H
#define SOURCETOOLS_TOKENIZATION_TOKEN_H

#include <cstring>
#include <cstdio>

#include <vector>
#include <string>
#include <map>
#include <sstream>

#include <sourcetools/core/core.h>
#include <sourcetools/tokenization/Registration.h>
#include <sourcetools/collection/Position.h>
#include <sourcetools/cursor/TextCursor.h>

namespace sourcetools {
namespace tokens {

class Token
{
private:
  typedef cursors::TextCursor TextCursor;
  typedef collections::Position Position;

public:

  Token()
    : begin_(NULL),
      end_(NULL),
      offset_(0),
      type_(INVALID)
  {
  }

  explicit Token(TokenType type)
    : begin_(NULL),
      end_(NULL),
      offset_(0),
      type_(type)
  {
  }

  Token(const Position& position)
    : begin_(NULL),
      end_(NULL),
      offset_(0),
      position_(position),
      type_(INVALID)
  {
  }

  Token(const TextCursor& cursor, TokenType type, std::size_t length)
    : begin_(cursor.begin() + cursor.offset()),
      end_(cursor.begin() + cursor.offset() + length),
      offset_(cursor.offset()),
      position_(cursor.position()),
      type_(type)
  {
  }

  const char* begin() const { return begin_; }
  const char* end() const { return end_; }
  std::size_t offset() const { return offset_; }
  std::size_t size() const { return end_ - begin_; }

  std::string contents() const
  {
    return std::string(begin_, end_);
  }

  bool contentsEqual(const char* string)
  {
    return std::strcmp(begin_, string);
  }

  bool contentsEqual(const std::string& string) const
  {
    if (string.size() != size())
      return false;

    return std::memcmp(begin_, string.c_str(), size()) == 0;
  }

  const Position& position() const { return position_; }
  std::size_t row() const { return position_.row; }
  std::size_t column() const { return position_.column; }

  TokenType type() const { return type_; }
  bool isType(TokenType type) const { return type_ == type; }

private:
  const char* begin_;
  const char* end_;
  std::size_t offset_;

  Position position_;
  TokenType type_;
};

inline bool isBracket(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_BRACKET_MASK);
}

inline bool isLeftBracket(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_BRACKET_LEFT_MASK);
}

inline bool isRightBracket(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_BRACKET_RIGHT_MASK);
}

inline bool isComplement(TokenType lhs, TokenType rhs)
{
  static const TokenType mask =
    SOURCE_TOOLS_BRACKET_BIT | SOURCE_TOOLS_BRACKET_LEFT_BIT | SOURCE_TOOLS_BRACKET_RIGHT_BIT;

  if (SOURCE_TOOLS_CHECK_MASK((lhs | rhs), mask))
    return SOURCE_TOOLS_LOWER_BITS(lhs, 4) == SOURCE_TOOLS_LOWER_BITS(rhs, 4);

  return false;
}

inline TokenType complement(TokenType type)
{
  static const TokenType mask =
    SOURCE_TOOLS_BRACKET_LEFT_BIT | SOURCE_TOOLS_BRACKET_RIGHT_BIT;

  return type ^ mask;
}

inline bool isKeyword(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_KEYWORD_MASK);
}

inline bool isControlFlowKeyword(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_KEYWORD_CONTROL_FLOW_MASK);
}

inline bool isOperator(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_OPERATOR_MASK);
}

inline bool isUnaryOperator(const Token& token)
{
  return SOURCE_TOOLS_CHECK_MASK(token.type(), SOURCE_TOOLS_OPERATOR_UNARY_MASK);
}

inline bool isNonUnaryOperator(const Token& token)
{
  return isOperator(token) && !isUnaryOperator(token);
}

inline bool isComparisonOperator(const Token& token)
{
  switch (token.type())
  {
  case OPERATOR_AND_SCALAR:
  case OPERATOR_AND_VECTOR:
  case OPERATOR_OR_SCALAR:
  case OPERATOR_OR_VECTOR:
  case OPERATOR_EQUAL:
  case OPERATOR_NOT_EQUAL:
  case OPERATOR_LESS:
  case OPERATOR_LESS_OR_EQUAL:
  case OPERATOR_GREATER:
  case OPERATOR_GREATER_OR_EQUAL:
    return true;
  default:
    return false;
  }
}

inline bool isWhitespace(const Token& token)
{
  return token.type() == WHITESPACE;
}

inline bool isComment(const Token& token)
{
  return token.type() == COMMENT;
}

inline bool isSymbol(const Token& token)
{
  return token.type() == SYMBOL;
}

inline bool isEnd(const Token& token)
{
  return token.type() == END;
}

inline bool isString(const Token& token)
{
  return token.type() == STRING;
}

inline bool isSymbolic(const Token& token)
{
  static const TokenType mask = SYMBOL | NUMBER | STRING;
  return (token.type() & mask) != 0;
}

inline bool isNumeric(const Token& token)
{
  return (token.type() & NUMBER) != 0;
}

inline bool isCallOperator(const Token& token)
{
  return token.type() == LPAREN ||
         token.type() == LBRACKET ||
         token.type() == LDBRACKET;
}

inline bool isAssignmentOperator(const Token& token)
{
  switch (token.type())
  {
  case OPERATOR_ASSIGN_LEFT:
  case OPERATOR_ASSIGN_LEFT_COLON:
  case OPERATOR_ASSIGN_LEFT_EQUALS:
  case OPERATOR_ASSIGN_LEFT_PARENT:
  case OPERATOR_ASSIGN_RIGHT:
  case OPERATOR_ASSIGN_RIGHT_PARENT:
    return true;
  default:
    return false;
  }
}

namespace detail {

inline bool isHexDigit(char c)
{
  if (c >= '0' && c <= '9')
    return true;
  else if (c >= 'a' && c <= 'f')
    return true;
  else if (c >= 'A' && c <= 'F')
    return true;
  return false;
}

inline int hexValue(char c)
{
  if (c >= '0' && c <= '9')
    return c - '0';
  else if (c >= 'a' && c <= 'f')
    return c - 'a' + 10;
  else if (c >= 'A' && c <= 'F')
    return c - 'A' + 10;

  return 0;
}

// Parses an octal escape sequence, e.g. '\012'.
inline bool parseOctal(const char*& it, char*& output)
{
  // Check for opening escape
  if (*it != '\\')
    return false;

  // Check for number following
  char lookahead = *(it + 1);
  if (lookahead < '0' || lookahead > '7')
    return false;
  ++it;

  // Begin parsing. Consume up to three numbers.
  unsigned char result = 0;
  const char* end = it + 3;
  for (; it != end; ++it)
  {
    char ch = *it;
    if ('0' <= ch && ch <= '7')
      result = 8 * result + ch - '0';
    else
      break;
  }

  // Assign result, and return.
  *output++ = result;
  return true;
}

// Parse a hex escape sequence, e.g. '\xFF'.
inline bool parseHex(const char*& it, char*& output)
{
  // Check for opening escape.
  if (*it != '\\')
    return false;

  if (*(it + 1) != 'x')
    return false;

  if (!isHexDigit(*(it + 2)))
    return false;

  // Begin parsing.
  it += 2;
  unsigned char value = 0;
  const char* end = it + 2;
  for (; it != end; ++it)
  {
    int result = hexValue(*it);
    if (result == 0)
      break;
    value = 16 * value + result;
  }

  *output++ = value;
  return true;
}

// Parse a unicode escape sequence.
inline bool parseUnicode(const char*& it, char*& output)
{
  if (*it != '\\')
    return false;

  char lookahead = *(it + 1);
  int size;
  if (lookahead == 'u')
    size = 4;
  else if (lookahead == 'U')
    size = 8;
  else
    return false;

  // Clone the input iterator (only set it on success)
  const char* clone = it;
  clone += 2;

  // Check for e.g. '\u{...}'
  //                   ^
  bool delimited = *clone == '{';
  clone += delimited;

  // Check for a hex digit.
  if (!isHexDigit(*clone))
    return false;

  // Begin parsing hex digits
  wchar_t value = 0;
  const char* end = clone + size;
  for (; clone != end; ++clone)
  {
    if (!isHexDigit(*clone))
      break;

    int hex = hexValue(*clone);
    value = 16 * value + hex;
  }

  // Eat a closing '}' if we had a starting '{'.
  if (delimited)
  {
    if (*clone != '}')
      return false;
    ++clone;
  }

  std::mbstate_t state;
  std::memset(&state, 0, sizeof(state));
  std::size_t bytes = std::wcrtomb(output, value, &state);
  if (bytes == static_cast<std::size_t>(-1))
    return false;

  // Update iterator state
  it = clone;
  output += bytes;
  return true;
}

} // namespace detail

inline std::string stringValue(const char* begin, const char* end)
{
  if (begin == end)
    return std::string();

  std::size_t n = end - begin;
  scoped_array<char> buffer(new char[n + 1]);

  const char* it = begin;
  char* output = buffer;

  while (it < end)
  {
    if (*it == '\\')
    {
      if (detail::parseOctal(it, output) ||
          detail::parseHex(it, output) ||
          detail::parseUnicode(it, output))
      {
        continue;
      }

      // Handle the rest
      ++it;
      switch (*it)
      {
      case 'a':  *output++ = '\a'; break;
      case 'b':  *output++ = '\b'; break;
      case 'f':  *output++ = '\f'; break;
      case 'n':  *output++ = '\n'; break;
      case 'r':  *output++ = '\r'; break;
      case 't':  *output++ = '\t'; break;
      case 'v':  *output++ = '\v'; break;
      case '\\': *output++ = '\\'; break;
      default:   *output++ = *it;  break;
      }
      ++it;
    }
    else
    {
      *output++ = *it++;
    }
  }

  // Ensure null termination, just in case
  *output++ = '\0';

  // Construct the result string and return
  std::string result(buffer, output - buffer);
  return result;
}

inline std::string stringValue(const Token& token)
{
  switch (token.type())
  {
  case STRING:
    return stringValue(token.begin() + 1, token.end() - 1);
  case SYMBOL:
    if (*token.begin() == '`')
      return stringValue(token.begin() + 1, token.end() - 1);
  default:
    return stringValue(token.begin(), token.end());
  }
}

} // namespace tokens

inline std::string toString(tokens::TokenType type)
{
  using namespace tokens;

       if (type == INVALID)    return "invalid";
  else if (type == END)        return "end";
  else if (type == EMPTY)      return "empty";
  else if (type == MISSING)    return "missing";
  else if (type == SEMI)       return "semi";
  else if (type == COMMA)      return "comma";
  else if (type == SYMBOL)     return "symbol";
  else if (type == COMMENT)    return "comment";
  else if (type == WHITESPACE) return "whitespace";
  else if (type == STRING)     return "string";
  else if (type == NUMBER)     return "number";

  else if (SOURCE_TOOLS_CHECK_MASK(type, SOURCE_TOOLS_BRACKET_MASK))
    return "bracket";
  else if (SOURCE_TOOLS_CHECK_MASK(type, SOURCE_TOOLS_KEYWORD_MASK))
    return "keyword";
  else if (SOURCE_TOOLS_CHECK_MASK(type, SOURCE_TOOLS_OPERATOR_MASK))
    return "operator";

  return "unknown";
}

inline std::string toString(const tokens::Token& token)
{
  std::string contents;
  if (token.isType(tokens::END))
    contents = "<END>";
  else if (token.isType(tokens::EMPTY))
    contents = "<empty>";
  else if (token.isType(tokens::MISSING))
    contents = "<missing>";
  else
    contents = token.contents();

  static const int N = 1024;
  if (contents.size() > N / 2)
    contents = contents.substr(0, N / 2);
  char buff[N];
  std::sprintf(buff,
               "[%4lu:%4lu]: %s",
               static_cast<unsigned long>(token.row()),
               static_cast<unsigned long>(token.column()),
               contents.c_str());
  return buff;
}

inline std::ostream& operator<<(std::ostream& os, const tokens::Token& token)
{
  return os << toString(token);
}

inline std::ostream& operator<<(std::ostream& os, const std::vector<tokens::Token>& tokens)
{
  for (std::vector<tokens::Token>::const_iterator it = tokens.begin();
       it != tokens.end();
       ++it)
  {
    os << *it << std::endl;
  }

  return os;
}

} // namespace sourcetools

#endif /* SOURCETOOLS_TOKENIZATION_TOKEN_H */
