## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(tibble)
set.seed(1014)

## ------------------------------------------------------------------------
tibble(x = letters)

## ------------------------------------------------------------------------
tibble(x = 1:3, y = list(1:5, 1:10, 1:20))

## ------------------------------------------------------------------------
names(data.frame(`crazy name` = 1))
names(tibble(`crazy name` = 1))

## ------------------------------------------------------------------------
tibble(x = 1:5, y = x ^ 2)

## ------------------------------------------------------------------------
if (requireNamespace("microbenchmark", quiet = TRUE)) {
  l <- replicate(26, sample(100), simplify = FALSE)
  names(l) <- letters

  microbenchmark::microbenchmark(
    as_tibble(l),
    as.data.frame(l)
  )
}

## ------------------------------------------------------------------------
tibble(x = 1:1000)

## ------------------------------------------------------------------------
df1 <- data.frame(x = 1:3, y = 3:1)
class(df1[, 1:2])
class(df1[, 1])

df2 <- tibble(x = 1:3, y = 3:1)
class(df2[, 1:2])
class(df2[, 1])

## ------------------------------------------------------------------------
class(df2[[1]])
class(df2$x)

## ---- error = TRUE-------------------------------------------------------
df <- data.frame(abc = 1)
df$a

df2 <- tibble(abc = 1)
df2$a

## ------------------------------------------------------------------------
data.frame(a = 1:3)[, "a", drop = TRUE]
tibble(a = 1:3)[, "a", drop = TRUE]

## ---- error = TRUE-------------------------------------------------------
tibble(a = 1, b = 1:3)
tibble(a = 1:3, b = 1)
tibble(a = 1:3, c = 1:2)
tibble(a = 1, b = integer())
tibble(a = integer(), b = 1)

