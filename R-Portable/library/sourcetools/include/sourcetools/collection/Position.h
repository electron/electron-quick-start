#ifndef SOURCETOOLS_COLLECTION_POSITION_H
#define SOURCETOOLS_COLLECTION_POSITION_H

#include <ostream>
#include <cstddef>

namespace sourcetools {
namespace collections {

struct Position
{
  Position()
    : row(0), column(0)
  {
  }

  Position(std::size_t row, std::size_t column)
    : row(row), column(column)
  {
  }

  friend std::ostream& operator<<(std::ostream& os,
                                  const Position& position)
  {
    os << position.row << ":" << position.column;
    return os;
  }

  friend bool operator <(const Position& lhs, const Position& rhs)
  {
    return
      lhs.row < rhs.row ||
      (lhs.row == rhs.row && lhs.column < rhs.column);
  }

  friend bool operator <=(const Position& lhs, const Position& rhs)
  {
    return
      lhs.row < rhs.row ||
      (lhs.row == rhs.row && lhs.column <= rhs.column);
  }

  friend bool operator ==(const Position& lhs, const Position& rhs)
  {
    return
      lhs.row == rhs.row &&
      lhs.column == rhs.column;
  }

  friend bool operator >(const Position& lhs, const Position& rhs)
  {
    return
      lhs.row > rhs.row ||
      (lhs.row == rhs.row && lhs.column > rhs.column);
  }

  friend bool operator >=(const Position& lhs, const Position& rhs)
  {
    return
      lhs.row > rhs.row ||
      (lhs.row == rhs.row && lhs.column >= rhs.column);
  }

  friend Position operator +(const Position& lhs, std::size_t rhs)
  {
    return Position(lhs.row, lhs.column + rhs);
  }

  std::size_t row;
  std::size_t column;

};

} // namespace collections
} // namespace sourcetools

#endif /* SOURCETOOLS_COLLECTION_POSITION_H */
