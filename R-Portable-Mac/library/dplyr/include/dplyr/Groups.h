#ifndef dplyr_dplyr_Groups_H
#define dplyr_dplyr_Groups_H

#include <tools/Quosure.h>

#include <dplyr/GroupedDataFrame.h>
#include <dplyr/RowwiseDataFrame.h>


void check_not_groups(const QuosureList& quosures, const GroupedDataFrame& gdf);
void check_not_groups(const QuosureList& quosures, const RowwiseDataFrame& gdf);

SEXP strip_group_attributes(SEXP df);


#endif // #ifndef dplyr_dplyr_Groups_H
