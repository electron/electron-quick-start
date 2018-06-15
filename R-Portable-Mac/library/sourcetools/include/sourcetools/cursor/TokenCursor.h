#ifndef SOURCETOOLS_CURSOR_TOKEN_CURSOR_H
#define SOURCETOOLS_CURSOR_TOKEN_CURSOR_H

#include <cstring>
#include <algorithm>

#include <sourcetools/collection/Position.h>
#include <sourcetools/tokenization/Token.h>

namespace sourcetools {
namespace cursors {

class TokenCursor {

private:
  typedef collections::Position Position;
  typedef tokens::Token Token;

public:

  TokenCursor(const std::vector<Token>& tokens)
    : tokens_(tokens),
      offset_(0),
      n_(tokens.size()),
      noSuchToken_(tokens::END)
  {}

  bool moveToNextToken()
  {
    if (UNLIKELY(offset_ >= n_ - 1))
      return false;

    ++offset_;
    return true;
  }

  bool moveToNextSignificantToken()
  {
    if (!moveToNextToken())
      return false;

    if (!fwdOverWhitespaceAndComments())
      return false;

    return true;
  }

  bool moveToPreviousToken()
  {
    if (UNLIKELY(offset_ == 0))
      return false;

    --offset_;
    return true;
  }

  bool moveToPreviousSignificantToken()
  {
    if (!moveToPreviousToken())
      return false;

    if (!bwdOverWhitespaceAndComments())
      return false;

    return true;
  }

  const Token& peekFwd(std::size_t offset = 1) const
  {
    std::size_t index = offset_ + offset;
    if (UNLIKELY(index >= n_))
      return noSuchToken_;

    return tokens_[index];
  }

  const Token& peekBwd(std::size_t offset = 1) const
  {
    if (UNLIKELY(offset > offset_))
      return noSuchToken_;

    std::size_t index = offset_ - offset;
    return tokens_[index];
  }

  const Token& currentToken() const
  {
    if (UNLIKELY(offset_ >= n_))
      return noSuchToken_;
    return tokens_[offset_];
  }

  operator const Token&() const { return currentToken(); }

  bool fwdOverWhitespace()
  {
    while (isType(tokens::WHITESPACE))
      if (!moveToNextToken())
        return false;
    return true;
  }

  bool bwdOverWhitespace()
  {
    while (isType(tokens::WHITESPACE))
      if (!moveToPreviousToken())
        return false;
    return true;
  }

  bool fwdOverComments()
  {
    while (isType(tokens::COMMENT))
      if (!moveToNextToken())
        return false;
    return true;
  }

  bool bwdOverComments()
  {
    while (isType(tokens::COMMENT))
      if (!moveToPreviousToken())
        return false;
    return true;
  }

  bool fwdOverWhitespaceAndComments()
  {
    while (isType(tokens::COMMENT) || isType(tokens::WHITESPACE))
      if (!moveToNextToken())
        return false;
    return true;
  }

  bool bwdOverWhitespaceAndComments()
  {
    while (isType(tokens::COMMENT) || isType(tokens::WHITESPACE))
      if (!moveToPreviousToken())
        return false;
    return true;
  }

  const Token& nextSignificantToken(std::size_t times = 1) const
  {
    TokenCursor clone(*this);
    for (std::size_t i = 0; i < times; ++i)
      clone.moveToNextSignificantToken();
    return clone;
  }

  const Token& previousSignificantToken(std::size_t times = 1) const
  {
    TokenCursor clone(*this);
    for (std::size_t i = 0; i < times; ++i)
      clone.moveToPreviousSignificantToken();
    return clone;
  }

  bool moveToPosition(std::size_t row, std::size_t column)
  {
    return moveToPosition(Position(row, column));
  }

  bool moveToPosition(const Position& target)
  {
    if (UNLIKELY(n_ == 0))
      return false;

    if (UNLIKELY(tokens_[n_ - 1].position() <= target))
    {
      offset_ = n_ - 1;
      return true;
    }

    std::size_t start  = 0;
    std::size_t end    = n_;

    std::size_t offset = 0;
    while (true)
    {
      offset = (start + end) / 2;
      const Position& current = tokens_[offset].position();

      if (current == target || start == end)
        break;
      else if (current < target)
        start = offset + 1;
      else
        end = offset - 1;
    }

    offset_ = offset;
    return true;
  }

  template <typename F>
  bool findFwd(F f)
  {
    do {
      if (f(this))
        return true;
    } while (moveToNextToken());

    return false;
  }

  template <typename F>
  bool findBwd(F f)
  {
    do {
      if (f(this))
        return true;
    } while (moveToPreviousToken());

    return false;
  }

  bool findFwd(const char* contents)
  {
    return findFwd(std::string(contents, std::strlen(contents)));
  }

  bool findFwd(const std::string& contents)
  {
    do {
      if (currentToken().contentsEqual(contents))
        return true;
    } while (moveToNextToken());

    return false;
  }

  bool findBwd(const char* contents)
  {
    return findBwd(std::string(contents, std::strlen(contents)));
  }

  bool findBwd(const std::string& contents)
  {
    do {
      if (currentToken().contentsEqual(contents))
        return true;
    } while (moveToPreviousToken());

    return false;
  }

  bool fwdToMatchingBracket()
  {
    using namespace tokens;
    if (!isLeftBracket(currentToken()))
      return false;

    TokenType lhs = currentToken().type();
    TokenType rhs = complement(lhs);
    std::size_t balance = 1;

    while (moveToNextSignificantToken())
    {
      TokenType type = currentToken().type();
      balance += type == lhs;
      balance -= type == rhs;
      if (balance == 0) return true;
    }

    return false;
  }

  bool bwdToMatchingBracket()
  {
    using namespace tokens;
    if (!isRightBracket(currentToken()))
      return false;

    TokenType lhs = currentToken().type();
    TokenType rhs = complement(lhs);
    std::size_t balance = 1;

    while (moveToPreviousSignificantToken())
    {
      TokenType type = currentToken().type();
      balance += type == lhs;
      balance -= type == rhs;
      if (balance == 0) return true;
    }

    return false;
  }

  friend std::ostream& operator<<(std::ostream& os, const TokenCursor& cursor)
  {
    return os << toString(cursor.currentToken());
  }

  tokens::TokenType type() const { return currentToken().type(); }
  bool isType(tokens::TokenType type) const { return currentToken().isType(type); }
  collections::Position position() const { return currentToken().position(); }
  std::size_t offset() const { return offset_; }
  std::size_t row() const { return currentToken().row(); }
  std::size_t column() const { return currentToken().column(); }


private:

  const std::vector<Token>& tokens_;
  std::size_t offset_;
  std::size_t n_;
  Token noSuchToken_;

};

} // namespace cursors

inline std::string toString(const cursors::TokenCursor& cursor)
{
  return toString(cursor.currentToken());
}

} // namespace sourcetools

#endif /* SOURCETOOLS_CURSOR_TOKEN_CURSOR_H */
