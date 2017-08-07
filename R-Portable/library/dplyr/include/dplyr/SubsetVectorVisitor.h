#ifndef dplyr_SubsetVectorVisitor_H
#define dplyr_SubsetVectorVisitor_H

#include <tools/SlicingIndex.h>
#include <dplyr/DataFrameVisitorsIndexMap.h>
#include <dplyr/EmptySubset.h>

namespace dplyr {

template <typename Container>
inline int output_size(const Container& container) {
  return container.size();
}

/**
 * Subset Vector visitor base class, defines the interface
 */
class SubsetVectorVisitor {
public:
  virtual ~SubsetVectorVisitor() {}

  /** creates a new vector, of the same type as the visited vector, by
   *  copying elements at the given indices
   */
  virtual SEXP subset(const Rcpp::IntegerVector& index) const = 0;

  virtual SEXP subset(const std::vector<int>&) const = 0;

  virtual SEXP subset(const SlicingIndex&) const = 0;

  /** creates a new vector, of the same type as the visited vector, by
   *  copying elements at the given indices
   */
  virtual SEXP subset(const ChunkIndexMap& index) const = 0;

  virtual SEXP subset(EmptySubset) const = 0;

  virtual int size() const = 0;

  virtual std::string get_r_type() const = 0;

  bool is_same_typeid(SubsetVectorVisitor* other) const {
    return typeid(*other) == typeid(*this);
  }

  virtual bool is_same_type(SubsetVectorVisitor* other, std::stringstream&, const SymbolString&) const {
    return is_same_typeid(other);
  }

  virtual bool is_compatible(SubsetVectorVisitor* other, std::stringstream&, const SymbolString&) const = 0;

};

} // namespace dplyr


#endif
