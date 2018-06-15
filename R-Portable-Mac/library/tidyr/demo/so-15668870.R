# http://stackoverflow.com/questions/15668870/
library(tidyr)
library(dplyr)

grades <- tbl_df(read.table(header = TRUE, text = "
   ID   Test Year   Fall Spring Winter
    1   1   2008    15      16      19
    1   1   2009    12      13      27
    1   2   2008    22      22      24
    1   2   2009    10      14      20
    2   1   2008    12      13      25
    2   1   2009    16      14      21
    2   2   2008    13      11      29
    2   2   2009    23      20      26
    3   1   2008    11      12      22
    3   1   2009    13      11      27
    3   2   2008    17      12      23
    3   2   2009    14      9       31
"))

grades %>%
  gather(Semester, Score, Fall:Winter) %>%
  mutate(Test = paste0("Test", Test)) %>%
  spread(Test, Score) %>%
  arrange(ID, Year, Semester)
