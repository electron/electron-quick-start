# http://stackoverflow.com/questions/17481212
library(tidyr)
library(dplyr)

race <- read.table(header = TRUE, check.names = FALSE, text = "
  Name    50  100  150  200  250  300  350
  Carla  1.2  1.8  2.2  2.3  3.0  2.5  1.8
  Mace   1.5  1.1  1.9  2.0  3.6  3.0  2.5
  Lea    1.7  1.6  2.3  2.7  2.6  2.2  2.6
  Karen  1.3  1.7  1.9  2.2  3.2  1.5  1.9
")

race %>%
  gather(Time, Score, -Name, convert = TRUE) %>%
  arrange(Name, Time)
