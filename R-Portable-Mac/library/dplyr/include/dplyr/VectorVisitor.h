#ifndef dplyr_VectorVisitor_H
#define dplyr_VectorVisitor_H

namespace dplyr {

/**
 * Vector visitor base class, defines the interface
 */
class VectorVisitor {
public:
  virtual ~VectorVisitor() {}

  /** hash the element of the visited vector at index i */
  virtual size_t hash(int i) const = 0;

  /** are the elements at indices i and j equal */
  virtual bool equal(int i, int j) const = 0;

  /** are the elements at indices i and j equal or both NA */
  virtual bool equal_or_both_na(int i, int j) const = 0;

  /** is the i element less than the j element */
  virtual bool less(int i, int j) const = 0;

  /** is the i element less than the j element */
  virtual bool greater(int i, int j) const = 0;

  virtual int size() const = 0;

  virtual std::string get_r_type() const = 0;

  virtual bool is_na(int i) const = 0;
};

} // namespace dplyr


#endif
