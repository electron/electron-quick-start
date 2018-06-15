#ifndef SOURCETOOLS_TOKENIZATION_TOKENIZER_H
#define SOURCETOOLS_TOKENIZATION_TOKENIZER_H

#include <sourcetools/core/core.h>
#include <sourcetools/tokenization/Token.h>
#include <sourcetools/cursor/TextCursor.h>

#include <vector>
#include <stack>
#include <sstream>

namespace sourcetools {
namespace tokenizer {

class Tokenizer
{
private:
  typedef tokens::Token Token;
  typedef cursors::TextCursor TextCursor;
  typedef tokens::TokenType TokenType;

private:

  // Tokenization ----

  void consumeToken(TokenType type,
                    std::size_t length,
                    Token* pToken)
  {
    *pToken = Token(cursor_, type, length);
    cursor_.advance(length);
  }

  template <bool SkipEscaped, bool InvalidOnError>
  void consumeUntil(char ch,
                    TokenType type,
                    Token* pToken)
  {
    TextCursor lookahead = cursor_;

    bool success = false;
    std::size_t distance = 0;

    while (lookahead != lookahead.end()) {
      lookahead.advance();
      ++distance;

      if (SkipEscaped && lookahead.peek() == '\\') {
        lookahead.advance();
        ++distance;
        continue;
      }

      if (lookahead.peek() == ch) {
        success = true;
        break;
      }
    }

    if (success) {
      consumeToken(type, distance + 1, pToken);
    } else {
      consumeToken(
        InvalidOnError ? tokens::INVALID : type,
        distance,
        pToken
      );
    }
  }

  void consumeUserOperator(Token* pToken)
  {
    consumeUntil<false, true>('%', tokens::OPERATOR_USER, pToken);
  }

  void consumeComment(Token* pToken)
  {
    consumeUntil<false, false>('\n', tokens::COMMENT, pToken);
  }

  void consumeQuotedSymbol(Token* pToken)
  {
    consumeUntil<true, true>('`', tokens::SYMBOL, pToken);
  }

  void consumeQString(Token* pToken)
  {
    consumeUntil<true, true>('\'', tokens::STRING, pToken);
  }

  void consumeQQString(Token* pToken)
  {
    consumeUntil<true, true>('"', tokens::STRING, pToken);
  }

  // NOTE: Don't tokenize '-' or '+' as part of number; instead
  // it's parsed as a unary operator.
  bool isStartOfNumber()
  {
    char ch = cursor_.peek();
    if (utils::isDigit(ch))
      return true;
    if (ch == '.')
      return utils::isDigit(cursor_.peek(1));
    return false;
  }

  bool isStartOfSymbol()
  {
    return utils::isValidForStartOfRSymbol(cursor_.peek());
  }

  bool consumeHexadecimalNumber(Token* pToken)
  {
    std::size_t distance = 0;

    // Detect the leading '0'.
    if (cursor_.peek(distance) != '0')
      return false;
    ++distance;

    // Detect a 'x' or 'X'.
    if (!(cursor_.peek(distance) == 'x' || cursor_.peek(distance) == 'X'))
      return false;
    ++distance;

    // Check and consume all alphanumeric characters.
    // The number is valid if the characters are valid
    // hexadecimal characters (0-9, a-f, A-F). The number
    // can also end with an 'i' (for an imaginary number)
    // or with an 'L' for an integer.
    if (!utils::isHexDigit(cursor_.peek(distance)))
    {
      consumeToken(tokens::INVALID, distance, pToken);
      return false;
    }

    bool success = true;
    char peek = cursor_.peek(distance);
    while (utils::isAlphaNumeric(peek) && peek != '\0') {

      // If we encounter an 'i' or an 'L', assume
      // that this ends the identifier.
      if (peek == 'i' || peek == 'L')
      {
        ++distance;
        break;
      }

      if (!utils::isHexDigit(peek))
        success = false;

      ++distance;
      peek = cursor_.peek(distance);
    }

    consumeToken(success ? tokens::NUMBER : tokens::INVALID, distance, pToken);
    return true;
  }

  void consumeNumber(Token* pToken)
  {
    bool success = true;
    std::size_t distance = 0;

    // NOTE: A leading '-' or '+' is not consumed as part of
    // the number.

    // Try parsing this as a hexadecimal number first (e.g. '0xabc').
    if (consumeHexadecimalNumber(pToken))
      return;

    // Consume digits
    while (utils::isDigit(cursor_.peek(distance)))
      ++distance;

    // Consume a dot for decimals
    // Note: '.5' is a valid specification for a number
    // So is '100.'; ie, with a trailing decimal.
    if (cursor_.peek(distance) == '.') {
      ++distance;
      while (utils::isDigit(cursor_.peek(distance)))
        ++distance;
    }

    // Consume 'e', 'E' for exponential notation
    if (cursor_.peek(distance) == 'e' || cursor_.peek(distance) == 'E') {
      ++distance;

      // Consume a '-' or a '+' for a negative number
      if (cursor_.peek(distance) == '-' || cursor_.peek(distance) == '+')
        ++distance;

      // Parse another set of numbers following the E
      success = utils::isDigit(cursor_.peek(distance));
      while (utils::isDigit(cursor_.peek(distance)))
        ++distance;

      // Consume '.' and following numbers. Note that this is
      // not really a valid number for R but it's better to tokenize
      // this is a single entity (and then report failure later)
      if (cursor_.peek(distance) == '.') {
        success = false;
        ++distance;
        while (utils::isDigit(cursor_.peek(distance)))
          ++distance;
      }
    }

    // Consume a final 'L' for integer literals
    if (cursor_.peek(distance) == 'L')
      ++distance;

    consumeToken(success ? tokens::NUMBER : tokens::INVALID, distance, pToken);
  }

  void consumeSymbol(Token* pToken)
  {
    std::size_t distance = 1;
    char ch = cursor_.peek(distance);
    while (utils::isValidForRSymbol(ch)) {
      ++distance;
      ch = cursor_.peek(distance);
    }

    const char* ptr = &*(cursor_.begin() + cursor_.offset());
    consumeToken(tokens::symbolType(ptr, distance), distance, pToken);
  }

public:

  Tokenizer(const char* code, std::size_t n)
    : cursor_(code, n)
  {
  }

  bool tokenize(Token* pToken)
  {
    if (cursor_ >= cursor_.end())
    {
      *pToken = Token(tokens::END);
      return false;
    }

    char ch = cursor_.peek();
    int n = 0;

    // Block-related tokens
    if (ch == '{')
      consumeToken(tokens::LBRACE, 1, pToken);
    else if (ch == '}')
      consumeToken(tokens::RBRACE, 1, pToken);
    else if (ch == '(')
      consumeToken(tokens::LPAREN, 1, pToken);
    else if (ch == ')')
      consumeToken(tokens::RPAREN, 1, pToken);
    else if (ch == '[') {
      if (cursor_.peek(1) == '[') {
        tokenStack_.push(tokens::LDBRACKET);
        consumeToken(tokens::LDBRACKET, 2, pToken);
      } else {
        tokenStack_.push(tokens::LBRACKET);
        consumeToken(tokens::LBRACKET, 1, pToken);
      }
    } else if (ch == ']') {
      if (tokenStack_.empty()) {
        consumeToken(tokens::INVALID, 1, pToken);
      } else if (tokenStack_.top() == tokens::LDBRACKET) {
        tokenStack_.pop();
        if (cursor_.peek(1) == ']')
          consumeToken(tokens::RDBRACKET, 2, pToken);
        else
          consumeToken(tokens::INVALID, 1, pToken);
      } else {
        tokenStack_.pop();
        consumeToken(tokens::RBRACKET, 1, pToken);
      }
    }

    // Operators
    else if (ch == '<')  // <<-, <=, <-, <
    {
      char next = cursor_.peek(1);
      if (next == '-') // <-
        consumeToken(tokens::OPERATOR_ASSIGN_LEFT, 2, pToken);
      else if (next == '=') // <=
        consumeToken(tokens::OPERATOR_LESS_OR_EQUAL, 2, pToken);
      else if (next == '<' && cursor_.peek(2) == '-')
        consumeToken(tokens::OPERATOR_ASSIGN_LEFT_PARENT, 3, pToken);
      else
        consumeToken(tokens::OPERATOR_LESS, 1, pToken);
    }

    else if (ch == '>')  // >=, >
    {
      if (cursor_.peek(1) == '=')
        consumeToken(tokens::OPERATOR_GREATER_OR_EQUAL, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_GREATER, 1, pToken);
    }
    else if (ch == '=')  // '==', '='
    {
      if (cursor_.peek(1) == '=')
        consumeToken(tokens::OPERATOR_EQUAL, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_ASSIGN_LEFT_EQUALS, 1, pToken);
    }
    else if (ch == '|')  // '||', '|'
    {
      if (cursor_.peek(1) == '|')
        consumeToken(tokens::OPERATOR_OR_SCALAR, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_OR_VECTOR, 1, pToken);
    }
    else if (ch == '&')  // '&&', '&'
    {
      if (cursor_.peek(1) == '&')
        consumeToken(tokens::OPERATOR_AND_SCALAR, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_AND_VECTOR, 1, pToken);
    }
    else if (ch == '*')  // **, *
    {
      if (cursor_.peek(1) == '*')
        consumeToken(tokens::OPERATOR_EXPONENTATION_STARS, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_MULTIPLY, 1, pToken);
    }
    else if (ch == ':')  // ':::', '::', ':=', ':'
    {
      if (cursor_.peek(1) == ':')
      {
        if (cursor_.peek(2) == ':')
          consumeToken(tokens::OPERATOR_NAMESPACE_ALL, 3, pToken);
        else
          consumeToken(tokens::OPERATOR_NAMESPACE_EXPORTS, 2, pToken);
      }
      else if (cursor_.peek(1) == '=')
        consumeToken(tokens::OPERATOR_ASSIGN_LEFT_COLON, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_SEQUENCE, 1, pToken);
    }
    else if (ch == '!')
    {
      if (cursor_.peek(1) == '=')
        consumeToken(tokens::OPERATOR_NOT_EQUAL, 2, pToken);
      else
        consumeToken(tokens::OPERATOR_NEGATION, 1, pToken);
    }
    else if (ch == '-') // '->>', '->', '-'
    {
      if (cursor_.peek(1) == '>')
      {
        if (cursor_.peek(2) == '>')
          consumeToken(tokens::OPERATOR_ASSIGN_RIGHT_PARENT, 3, pToken);
        else
          consumeToken(tokens::OPERATOR_ASSIGN_RIGHT, 2, pToken);
      }
      else
        consumeToken(tokens::OPERATOR_MINUS, 1, pToken);
    }
    else if (ch == '+')
      consumeToken(tokens::OPERATOR_PLUS, 1, pToken);
    else if (ch == '~')
      consumeToken(tokens::OPERATOR_FORMULA, 1, pToken);
    else if (ch == '?')
      consumeToken(tokens::OPERATOR_HELP, 1, pToken);
    else if (ch == '/')
      consumeToken(tokens::OPERATOR_DIVIDE, 1, pToken);
    else if (ch == '@')
      consumeToken(tokens::OPERATOR_AT, 1, pToken);
    else if (ch == '$')
      consumeToken(tokens::OPERATOR_DOLLAR, 1, pToken);
    else if (ch == '^')
      consumeToken(tokens::OPERATOR_HAT, 1, pToken);

    // User operators
    else if (ch == '%')
      consumeUserOperator(pToken);

    // Punctuation-related tokens
    else if (ch == ',')
      consumeToken(tokens::COMMA, 1, pToken);
    else if (ch == ';')
      consumeToken(tokens::SEMI, 1, pToken);

    // Whitespace
    else if (utils::countWhitespaceBytes(cursor_, &n))
      consumeToken(tokens::WHITESPACE, n, pToken);

    // Strings and symbols
    else if (ch == '\'')
      consumeQString(pToken);
    else if (ch == '"')
      consumeQQString(pToken);
    else if (ch == '`')
      consumeQuotedSymbol(pToken);

    // Comments
    else if (ch == '#')
      consumeComment(pToken);

    // Number
    else if (isStartOfNumber())
      consumeNumber(pToken);

    // Symbol
    else if (isStartOfSymbol())
      consumeSymbol(pToken);

    // Nothing matched -- error
    else
      consumeToken(tokens::INVALID, 1, pToken);

    return true;
  }

  Token peek(std::size_t lookahead = 1)
  {
    Tokenizer clone(*this);

    Token result(tokens::END);
    for (std::size_t i = 0; i < lookahead; ++i) {
      if (!clone.tokenize(&result)) {
        break;
      }
    }

    return result;
  }

private:
  TextCursor cursor_;
  std::stack<TokenType, std::vector<TokenType> > tokenStack_;
};

} // namespace tokenizer

inline std::vector<tokens::Token> tokenize(const char* code, std::size_t n)
{
  typedef tokenizer::Tokenizer Tokenizer;
  typedef tokens::Token Token;

  std::vector<Token> tokens;
  if (n == 0)
    return tokens;

  Token token;
  Tokenizer tokenizer(code, n);
  while (tokenizer.tokenize(&token))
    tokens.push_back(token);

  return tokens;
}

inline std::vector<tokens::Token> tokenize(const std::string& code)
{
  return tokenize(code.data(), code.size());
}

} // namespace sourcetools

#endif /* SOURCETOOLS_TOKENIZATION_TOKENIZER_H */
