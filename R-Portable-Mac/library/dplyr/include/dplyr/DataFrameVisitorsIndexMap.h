#ifndef dplyr_DataFrameVisitors_map_H
#define dplyr_DataFrameVisitors_map_H

#include <dplyr/DataFrameVisitors.h>
#include <dplyr/visitor_set/VisitorSetIndexMap.h>

namespace dplyr {

typedef VisitorSetIndexMap< DataFrameVisitors, std::vector<int> > ChunkIndexMap;

}

#endif
