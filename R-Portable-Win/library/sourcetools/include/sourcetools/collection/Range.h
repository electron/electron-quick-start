#ifndef SOURCETOOLS_COLLECTION_RANGE_H
#define SOURCETOOLS_COLLECTION_RANGE_H

#include <ostream>
#include <sourcetools/collection/Position.h>

namespace sourcetools {
namespace collections {

class Range
{
public:
  Range(const Position& start, const Position& end)
    : start_(start), end_(end)
  {
  }

  friend std::ostream& operator <<(std::ostream& os, const Range& range)
  {
    os << "[" << range.start() << "-" << range.end() << "]";
    return os;
  }

  const Position start() const { return start_; }
  const Position end() const { return end_; }

private:
  Position start_;
  Position end_;
};
} // namespace collections
} // namespace sourcetools

#endif /* SOURCETOOLS_COLLECTION_RANGE_H */
