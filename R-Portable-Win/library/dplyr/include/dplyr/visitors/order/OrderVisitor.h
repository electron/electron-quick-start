#ifndef dplyr_OrderVisitor_H
#define dplyr_OrderVisitor_H

namespace dplyr {

class OrderVisitor {
public:
  virtual ~OrderVisitor() {}

  /** are the elements at indices i and j equal */
  virtual bool equal(int i, int j) const  = 0;

  /** is the i element less than the j element */
  virtual bool before(int i, int j) const = 0;

};

} // namespace dplyr


#endif
