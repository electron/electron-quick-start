#ifndef dplyr_Result_all_H
#define dplyr_Result_all_H

#include <dplyr/Result/is_smaller.h>
#include <dplyr/Result/GroupedSubset.h>
#include <dplyr/Result/RowwiseSubset.h>
#include <dplyr/Result/Result.h>
#include <dplyr/Result/Processor.h>
#include <dplyr/Result/Count.h>
#include <dplyr/Result/Count_Distinct.h>
#include <dplyr/Result/Mean.h>
#include <dplyr/Result/Sum.h>
#include <dplyr/Result/Var.h>
#include <dplyr/Result/Sd.h>
#include <dplyr/Result/MinMax.h>

#include <dplyr/Result/CallElementProxy.h>
#include <dplyr/Result/DelayedProcessor.h>
#include <dplyr/Result/CallbackProcessor.h>
#include <dplyr/Result/ILazySubsets.h>
#include <dplyr/Result/LazySubsets.h>
#include <dplyr/Result/LazyGroupedSubsets.h>
#include <dplyr/Result/LazyRowwiseSubsets.h>
#include <dplyr/Result/GroupedCallReducer.h>
#include <dplyr/Result/CallProxy.h>

#include <dplyr/Result/VectorSliceVisitor.h>
#include <dplyr/Result/Rank.h>
#include <dplyr/Result/ConstantResult.h>

#include <dplyr/Result/Lead.h>
#include <dplyr/Result/Lag.h>
#include <dplyr/Result/CumSum.h>
#include <dplyr/Result/CumMin.h>
#include <dplyr/Result/CumMax.h>
#include <dplyr/Result/In.h>

#endif
