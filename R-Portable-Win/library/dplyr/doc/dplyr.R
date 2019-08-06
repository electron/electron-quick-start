## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(dplyr)
library(ggplot2)
set.seed(1014)

## ------------------------------------------------------------------------
library(nycflights13)
dim(flights)
flights

## ------------------------------------------------------------------------
filter(flights, month == 1, day == 1)

## ---- eval = FALSE-------------------------------------------------------
#  flights[flights$month == 1 & flights$day == 1, ]

## ------------------------------------------------------------------------
arrange(flights, year, month, day)

## ------------------------------------------------------------------------
arrange(flights, desc(arr_delay))

## ------------------------------------------------------------------------
# Select columns by name
select(flights, year, month, day)
# Select all columns between year and day (inclusive)
select(flights, year:day)
# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

## ------------------------------------------------------------------------
select(flights, tail_num = tailnum)

## ------------------------------------------------------------------------
rename(flights, tail_num = tailnum)

## ------------------------------------------------------------------------
mutate(flights,
  gain = arr_delay - dep_delay,
  speed = distance / air_time * 60
)

## ------------------------------------------------------------------------
mutate(flights,
  gain = arr_delay - dep_delay,
  gain_per_hour = gain / (air_time / 60)
)

## ------------------------------------------------------------------------
transmute(flights,
  gain = arr_delay - dep_delay,
  gain_per_hour = gain / (air_time / 60)
)

## ------------------------------------------------------------------------
summarise(flights,
  delay = mean(dep_delay, na.rm = TRUE)
)

## ------------------------------------------------------------------------
sample_n(flights, 10)
sample_frac(flights, 0.01)

## ---- warning = FALSE, message = FALSE, fig.width = 6--------------------
by_tailnum <- group_by(flights, tailnum)
delay <- summarise(by_tailnum,
  count = n(),
  dist = mean(distance, na.rm = TRUE),
  delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)

# Interestingly, the average delay is only slightly related to the
# average distance flown by a plane.
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()

## ------------------------------------------------------------------------
destinations <- group_by(flights, dest)
summarise(destinations,
  planes = n_distinct(tailnum),
  flights = n()
)

## ------------------------------------------------------------------------
daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year  <- summarise(per_month, flights = sum(flights)))

## ------------------------------------------------------------------------
# `year` represents the integer 1
select(flights, year)
select(flights, 1)

## ------------------------------------------------------------------------
year <- "dep"
select(flights, starts_with(year))

## ------------------------------------------------------------------------
year <- 5
select(flights, year, identity(year))

## ------------------------------------------------------------------------
vars <- c("year", "month")
select(flights, vars, "day")

## ------------------------------------------------------------------------
# Let's create a new `vars` column:
flights$vars <- flights$year

# The new column won't be an issue if you evaluate `vars` in the
# context with the `!!` operator:
vars <- c("year", "month", "day")
select(flights, !! vars)

## ------------------------------------------------------------------------
df <- select(flights, year:dep_time)

## ------------------------------------------------------------------------
mutate(df, "year", 2)

## ------------------------------------------------------------------------
mutate(df, year + 10)

## ------------------------------------------------------------------------
var <- seq(1, nrow(df))
mutate(df, new = var)

## ------------------------------------------------------------------------
group_by(df, month)
group_by(df, month = as.factor(month))
group_by(df, day_binned = cut(day, 3))

## ------------------------------------------------------------------------
group_by(df, "month")

## ------------------------------------------------------------------------
group_by_at(df, vars(year:day))

## ---- eval = FALSE-------------------------------------------------------
#  a1 <- group_by(flights, year, month, day)
#  a2 <- select(a1, arr_delay, dep_delay)
#  a3 <- summarise(a2,
#    arr = mean(arr_delay, na.rm = TRUE),
#    dep = mean(dep_delay, na.rm = TRUE))
#  a4 <- filter(a3, arr > 30 | dep > 30)

## ------------------------------------------------------------------------
filter(
  summarise(
    select(
      group_by(flights, year, month, day),
      arr_delay, dep_delay
    ),
    arr = mean(arr_delay, na.rm = TRUE),
    dep = mean(dep_delay, na.rm = TRUE)
  ),
  arr > 30 | dep > 30
)

## ---- eval = FALSE-------------------------------------------------------
#  flights %>%
#    group_by(year, month, day) %>%
#    select(arr_delay, dep_delay) %>%
#    summarise(
#      arr = mean(arr_delay, na.rm = TRUE),
#      dep = mean(dep_delay, na.rm = TRUE)
#    ) %>%
#    filter(arr > 30 | dep > 30)

