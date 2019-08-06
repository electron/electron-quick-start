## ----setup, echo = FALSE, message = FALSE--------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(dplyr)
set.seed(1014)

## ------------------------------------------------------------------------
df <- tibble(x = 1:3, y = 3:1)
filter(df, x == 1)

## ---- error = TRUE-------------------------------------------------------
my_var <- x
filter(df, my_var == 1)

## ---- error = TRUE-------------------------------------------------------
my_var <- "x"
filter(df, my_var == 1)

## ---- eval = FALSE-------------------------------------------------------
#  df[df$x == df$y, ]
#  df[df$x == y, ]
#  df[x == df$y, ]
#  df[x == y, ]

## ------------------------------------------------------------------------
greet <- function(name) {
  "How do you do, name?"
}
greet("Hadley")

## ------------------------------------------------------------------------
greet <- function(name) {
  paste0("How do you do, ", name, "?")
}
greet("Hadley")

## ------------------------------------------------------------------------
greet <- function(name) {
  glue::glue("How do you do, {name}?")
}
greet("Hadley")

## ---- eval = FALSE-------------------------------------------------------
#  mutate(df1, y = a + x)
#  mutate(df2, y = a + x)
#  mutate(df3, y = a + x)
#  mutate(df4, y = a + x)

## ------------------------------------------------------------------------
mutate_y <- function(df) {
  mutate(df, y = a + x)
}

## ------------------------------------------------------------------------
df1 <- tibble(x = 1:3)
a <- 10
mutate_y(df1)

## ---- error = TRUE-------------------------------------------------------
mutate_y <- function(df) {
  mutate(df, y = .data$a + .data$x)
}

mutate_y(df1)

## ------------------------------------------------------------------------
df <- tibble(
  g1 = c(1, 1, 2, 2, 2),
  g2 = c(1, 2, 1, 2, 1),
  a = sample(5),
  b = sample(5)
)

df %>%
  group_by(g1) %>%
  summarise(a = mean(a))

df %>%
  group_by(g2) %>%
  summarise(a = mean(a))

## ---- error = TRUE-------------------------------------------------------
my_summarise <- function(df, group_var) {
  df %>%
    group_by(group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)

## ---- error = TRUE-------------------------------------------------------
my_summarise(df, "g2")

## ------------------------------------------------------------------------
quo(g1)
quo(a + b + c)
quo("a")

## ---- error = TRUE-------------------------------------------------------
my_summarise(df, quo(g1))

## ------------------------------------------------------------------------
my_summarise <- function(df, group_var) {
  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, quo(g1))

## ---- eval = FALSE-------------------------------------------------------
#  my_summarise(df, g1)

## ---- error = TRUE-------------------------------------------------------
my_summarise <- function(df, group_var) {
  quo_group_var <- quo(group_var)
  print(quo_group_var)

  df %>%
    group_by(!! quo_group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)

## ------------------------------------------------------------------------
my_summarise <- function(df, group_var) {
  group_var <- enquo(group_var)
  print(group_var)

  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)

## ------------------------------------------------------------------------
summarise(df, mean = mean(a), sum = sum(a), n = n())
summarise(df, mean = mean(a * b), sum = sum(a * b), n = n())

## ------------------------------------------------------------------------
my_var <- quo(a)
summarise(df, mean = mean(!! my_var), sum = sum(!! my_var), n = n())

## ------------------------------------------------------------------------
quo(summarise(df,
  mean = mean(!! my_var),
  sum = sum(!! my_var),
  n = n()
))

## ------------------------------------------------------------------------
my_summarise2 <- function(df, expr) {
  expr <- enquo(expr)

  summarise(df,
    mean = mean(!! expr),
    sum = sum(!! expr),
    n = n()
  )
}
my_summarise2(df, a)
my_summarise2(df, a * b)

## ------------------------------------------------------------------------
mutate(df, mean_a = mean(a), sum_a = sum(a))
mutate(df, mean_b = mean(b), sum_b = sum(b))

## ------------------------------------------------------------------------
my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))

  mutate(df,
    !! mean_name := mean(!! expr),
    !! sum_name := sum(!! expr)
  )
}

my_mutate(df, a)

## ------------------------------------------------------------------------
my_summarise <- function(df, ...) {
  group_var <- enquos(...)

  df %>%
    group_by(!!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1, g2)

## ------------------------------------------------------------------------
args <- list(na.rm = TRUE, trim = 0.25)
quo(mean(x, !!! args))

args <- list(quo(x), na.rm = TRUE, trim = 0.25)
quo(mean(!!! args))

## ------------------------------------------------------------------------
disp ~ cyl + drat

## ------------------------------------------------------------------------
# Computing the value of the expression:
toupper(letters[1:5])

# Capturing the expression:
quote(toupper(letters[1:5]))

## ------------------------------------------------------------------------
f <- function(x) {
  quo(x)
}

x1 <- f(10)
x2 <- f(100)

## ------------------------------------------------------------------------
x1
x2

## ---- message = FALSE----------------------------------------------------
library(rlang)

get_env(x1)
get_env(x2)

## ------------------------------------------------------------------------
eval_tidy(x1)
eval_tidy(x2)

## ------------------------------------------------------------------------
user_var <- 1000
mtcars %>% summarise(cyl = mean(cyl) * user_var)

## ------------------------------------------------------------------------
typeof(mean)

## ------------------------------------------------------------------------
var <- ~toupper(letters[1:5])
var

# You can extract its expression:
get_expr(var)

# Or inspect its enclosure:
get_env(var)

## ------------------------------------------------------------------------
# Here we capture `letters[1:5]` as an expression:
quo(toupper(letters[1:5]))

# Here we capture the value of `letters[1:5]`
quo(toupper(!! letters[1:5]))
quo(toupper(UQ(letters[1:5])))

## ------------------------------------------------------------------------
var1 <- quo(letters[1:5])
quo(toupper(!! var1))

## ------------------------------------------------------------------------
my_mutate <- function(x) {
  mtcars %>%
    select(cyl) %>%
    slice(1:4) %>%
    mutate(cyl2 = cyl + (!! x))
}

f <- function(x) quo(x)
expr1 <- f(100)
expr2 <- f(10)

my_mutate(expr1)
my_mutate(expr2)

## ---- error = TRUE-------------------------------------------------------
my_fun <- quo(fun)
quo(!! my_fun(x, y, z))
quo(UQ(my_fun)(x, y, z))

my_var <- quo(x)
quo(filter(df, !! my_var == 1))
quo(filter(df, UQ(my_var) == 1))

## ------------------------------------------------------------------------
quo(list(!!! letters[1:5]))

## ------------------------------------------------------------------------
x <- list(foo = 1L, bar = quo(baz))
quo(list(!!! x))

## ------------------------------------------------------------------------
args <- list(mean = quo(mean(cyl)), count = quo(n()))
mtcars %>%
  group_by(am) %>%
  summarise(!!! args)

## ------------------------------------------------------------------------
mean_nm <- "mean"
count_nm <- "count"

mtcars %>%
  group_by(am) %>%
  summarise(
    !! mean_nm := mean(cyl),
    !! count_nm := n()
  )

