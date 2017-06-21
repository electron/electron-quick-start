## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", fig.width = 3.9, fig.height = 3.5)

# Make sure vignette doesn't error on platforms where microbenchmark is not present.
if (requireNamespace("microbenchmark", quietly = TRUE)) {
  library(microbenchmark)

  # Only print 3 significant digits
  print_microbenchmark <- function (x, unit, order = NULL, ...) {
    s <- summary(x, unit = unit)
    cat("Unit: ", attr(s, "unit"), "\n", sep = "")

    timing_cols <- c("min", "lq", "median", "uq", "max")
    s[timing_cols] <- lapply(s[timing_cols], signif, digits = 3)
    s[timing_cols] <- lapply(s[timing_cols], format, big.mark = ",")

    print(s, ..., row.names = FALSE)
  }

  assignInNamespace("print.microbenchmark", print_microbenchmark,
                    "microbenchmark")

} else {
  # Some dummy functions so that the vignette doesn't throw an error.
  microbenchmark <- function(...) {
    structure(list(), class = "microbenchmark_dummy")
  }

  summary.microbenchmark_dummy <- function(object, ...) {
    data.frame(expr = "", median = 0)
  }
}

## ----eval = FALSE--------------------------------------------------------
#  library(microbenchmark)
#  options(microbenchmark.unit = "us")
#  library(pryr)  # For object_size function
#  library(R6)

## ----echo = FALSE--------------------------------------------------------
# The previous code block is just for appearances. This code block is the one
# that gets run. The loading of microbenchmark must be conditional because it is
# not available on all platforms.
if (requireNamespace("microbenchmark", quietly = TRUE)) {
  library(microbenchmark)
}
options(microbenchmark.unit = "us")
library(pryr)  # For object_size function
library(R6)

## ----echo=FALSE----------------------------------------------------------
library(ggplot2)
library(scales)

# Set up ggplot2 theme
my_theme <- theme_bw(base_size = 10) +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()
    )

## ------------------------------------------------------------------------
RC <- setRefClass("RC",
  fields = list(x = "numeric"),
  methods = list(
    initialize = function(x = 1) .self$x <- x,
    getx = function() x,
    inc = function(n = 1) x <<- x + n
  )
)

## ------------------------------------------------------------------------
RC$new()

## ------------------------------------------------------------------------
R6 <- R6Class("R6",
  public = list(
    x = NULL,
    initialize = function(x = 1) self$x <- x,
    getx = function() self$x,
    inc = function(n = 1) self$x <- x + n
  )
)

## ------------------------------------------------------------------------
R6$new()

## ------------------------------------------------------------------------
R6NoClass <- R6Class("R6NoClass",
  class = FALSE,
  public = list(
    x = NULL,
    initialize = function(x = 1) self$x <- x,
    getx = function() self$x,
    inc = function(n = 1) self$x <- self$x + n
  )
)

## ------------------------------------------------------------------------
R6NonPortable <- R6Class("R6NonPortable",
  portable = FALSE,
  public = list(
    x = NULL,
    initialize = function(value = 1) x <<- value,
    getx = function() x,
    inc = function(n = 1) x <<- x + n
  )
)

## ------------------------------------------------------------------------
R6NonCloneable <- R6Class("R6NonCloneable",
  cloneable = FALSE,
  public = list(
    x = NULL,
    initialize = function(x = 1) self$x <- x,
    getx = function() self$x,
    inc = function(n = 1) self$x <- self$x + n
  )
)

## ------------------------------------------------------------------------
R6Bare <- R6Class("R6Bare",
  portable = FALSE,
  class = FALSE,
  cloneable = FALSE,
  public = list(
    x = NULL,
    initialize = function(value = 1) x <<- value,
    getx = function() x,
    inc = function(n = 1) x <<- x + n
  )
)

## ------------------------------------------------------------------------
R6Private <- R6Class("R6Private",
  private = list(x = NULL),
  public = list(
    initialize = function(x = 1) private$x <- x,
    getx = function() private$x,
    inc = function(n = 1) private$x <- private$x + n
  )
)

## ------------------------------------------------------------------------
R6Private$new()

## ------------------------------------------------------------------------
R6PrivateBare <- R6Class("R6PrivateBare",
  portable = FALSE,
  class = FALSE,
  cloneable = FALSE,
  private = list(x = NULL),
  public = list(
    initialize = function(x = 1) private$x <- x,
    getx = function() x,
    inc = function(n = 1) x <<- x + n
  )
)

## ------------------------------------------------------------------------
FunctionEnvClass <- function(x = 1) {
  inc <- function(n = 1) x <<- x + n
  getx <- function() x
  self <- environment()
  class(self) <- "FunctionEnvClass"
  self
}

## ------------------------------------------------------------------------
ls(FunctionEnvClass())

## ------------------------------------------------------------------------
FunctionEnvNoClass <- function(x = 1) {
  inc <- function(n = 1) x <<- x + n
  getx <- function() x
  environment()
}

## ------------------------------------------------------------------------
ls(FunctionEnvNoClass())

## ----echo = FALSE--------------------------------------------------------
# Utility functions for calculating sizes
obj_size <- function(expr, .env = parent.frame()) {
  size_n <- function(n = 1) {
    objs <- lapply(1:n, function(x) eval(expr, .env))
    as.numeric(do.call(object_size, objs))
  }

  data.frame(one = size_n(1), incremental = size_n(2) - size_n(1))
}

obj_sizes <- function(..., .env = parent.frame()) {
  exprs <- as.list(match.call(expand.dots = FALSE)$...)
  names(exprs) <- lapply(1:length(exprs),
    FUN = function(n) {
      name <- names(exprs)[n]
      if (is.null(name) || name == "") paste(deparse(exprs[[n]]), collapse = " ")
      else name
    })

  sizes <- mapply(obj_size, exprs, MoreArgs = list(.env = .env), SIMPLIFY = FALSE)
  do.call(rbind, sizes)
}

## ------------------------------------------------------------------------
sizes <- obj_sizes(
  RC$new(),
  R6$new(),
  R6NoClass$new(),
  R6NonPortable$new(),
  R6NonCloneable$new(),
  R6Bare$new(),
  R6Private$new(),
  R6PrivateBare$new(),
  FunctionEnvClass(),
  FunctionEnvNoClass()
)
sizes

## ----echo = FALSE, results = 'hold'--------------------------------------
objnames <- c(
  "RC", "R6", "R6NoClass", "R6NonPortable", "R6NonCloneable",
  "R6Bare", "R6Private", "R6PrivateBare", "FunctionEnvClass",
  "FunctionEnvNoClass"
)

obj_labels <- objnames
obj_labels[1] <- "RC (off chart)"

sizes$name <- factor(objnames, levels = rev(objnames))

ggplot(sizes, aes(y = name, x = one)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  scale_x_continuous(limits = c(0, max(sizes$one[-1]) * 1.5),
                     expand = c(0, 0), oob = rescale_none) +
  scale_y_discrete(
    breaks = sizes$name,
    labels = obj_labels) +
  my_theme +
  ggtitle("First object")

ggplot(sizes, aes(y = name, x = incremental)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  scale_x_continuous(limits = c(0, max(sizes$incremental) * 1.05),
                     expand = c(0, 0)) +
  geom_point(size = 2) +
  my_theme +
  ggtitle("Additional objects")

## ------------------------------------------------------------------------
RC2 <- setRefClass("RC2",
  fields = list(x = "numeric"),
  methods = list(
    initialize = function(x = 2) .self$x <<- x,
    inc = function(n = 2) x <<- x * n
  )
)

# Calcualte the size of a new RC2 object, over and above an RC object
as.numeric(object_size(RC$new(), RC2$new()) - object_size(RC$new()))

## ------------------------------------------------------------------------
# Function to extract the medians from microbenchmark results
mb_summary <- function(x) {
  res <- summary(x, unit="us")
  data.frame(name = res$expr, median = res$median)
}

speed <- microbenchmark(
  RC$new(),
  R6$new(),
  R6NoClass$new(),
  R6NonPortable$new(),
  R6NonCloneable$new(),
  R6Bare$new(),
  R6Private$new(),
  R6PrivateBare$new(),
  FunctionEnvClass(),
  FunctionEnvNoClass()
)
speed <- mb_summary(speed)
speed

## ----echo = FALSE, results = 'hold', fig.width = 8-----------------------
speed$name <- factor(speed$name, rev(levels(speed$name)))

p <- ggplot(speed, aes(y = name, x = median)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  scale_x_continuous(limits = c(0, max(speed$median) * 1.05), expand = c(0, 0)) +
  my_theme +
  ggtitle("Median time to instantiate object (\u0b5s)")

p

## ------------------------------------------------------------------------
rc           <- RC$new()
r6           <- R6$new()
r6noclass    <- R6NoClass$new()
r6noport     <- R6NonPortable$new()
r6noclone    <- R6NonCloneable$new()
r6bare       <- R6Bare$new()
r6priv       <- R6Private$new()
r6priv_bare  <- R6PrivateBare$new()
fun_env      <- FunctionEnvClass()
fun_env_nc   <- FunctionEnvNoClass()

## ------------------------------------------------------------------------
speed <- microbenchmark(
  rc$x,
  r6$x,
  r6noclass$x,
  r6noport$x,
  r6noclone$x,
  r6bare$x,
  r6priv$x,
  r6priv_bare$x,
  fun_env$x,
  fun_env_nc$x
)
speed <- mb_summary(speed)
speed

## ----echo = FALSE, results = 'hold', fig.width = 8-----------------------
speed$name <- factor(speed$name, rev(levels(speed$name)))

p <- ggplot(speed, aes(y = name, x = median)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  scale_x_continuous(limits = c(0, max(speed$median) * 1.05), expand = c(0, 0)) +
  my_theme +
  ggtitle("Median time to access field (\u0b5s)")

p

## ------------------------------------------------------------------------
speed <- microbenchmark(
  rc$x <- 4,
  r6$x <- 4,
  r6noclass$x <- 4,
  r6noport$x <- 4,
  r6noclone$x <- 4,
  r6bare$x <- 4,
  # r6priv$x <- 4,         # Can't set private field directly,
  # r6priv_nc_np$x <- 4,   # so we'll skip these two
  fun_env$x <- 4,
  fun_env_nc$x <- 4
)
speed <- mb_summary(speed)
speed

## ----echo = FALSE, results = 'hold', fig.width = 8-----------------------
speed$name <- factor(speed$name, rev(levels(speed$name)))

p <- ggplot(speed, aes(y = name, x = median)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  scale_x_continuous(limits = c(0, max(speed$median) * 1.05), expand = c(0, 0)) +
  my_theme +
  ggtitle("Median time to set field (\u0b5s)")

p

## ------------------------------------------------------------------------
speed <- microbenchmark(
  rc$getx(),
  r6$getx(),
  r6noclass$getx(),
  r6noport$getx(),
  r6noclone$getx(),
  r6bare$getx(),
  r6priv$getx(),
  r6priv_bare$getx(),
  fun_env$getx(),
  fun_env_nc$getx()
)
speed <- mb_summary(speed)
speed

## ----echo = FALSE, results = 'hold', fig.width = 8-----------------------
speed$name <- factor(speed$name, rev(levels(speed$name)))

p <- ggplot(speed, aes(y = name, x = median)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  my_theme +
  ggtitle("Median time to call method that accesses field (\u0b5s)")

p

## ------------------------------------------------------------------------
RCself <- setRefClass("RCself",
  fields = list(x = "numeric"),
  methods = list(
    initialize = function() .self$x <- 1,
    setx = function(n = 2) .self$x <- n
  )
)

RCnoself <- setRefClass("RCnoself",
  fields = list(x = "numeric"),
  methods = list(
    initialize = function() x <<- 1,
    setx = function(n = 2) x <<- n
  )
)

## ------------------------------------------------------------------------
R6self <- R6Class("R6self",
  portable = FALSE,
  public = list(
    x = 1,
    setx = function(n = 2) self$x <- n
  )
)

R6noself <- R6Class("R6noself",
  portable = FALSE,
  public = list(
    x = 1,
    setx = function(n = 2) x <<- n
  )
)

## ------------------------------------------------------------------------
rc_self   <- RCself$new()
rc_noself <- RCnoself$new()
r6_self   <- R6self$new()
r6_noself <- R6noself$new()

speed <- microbenchmark(
  rc_self$setx(),
  rc_noself$setx(),
  r6_self$setx(),
  r6_noself$setx()
)
speed <- mb_summary(speed)
speed

## ----echo = FALSE, results = 'hold', fig.width = 8-----------------------
speed$name <- factor(speed$name, rev(levels(speed$name)))

p <- ggplot(speed, aes(y = name, x = median)) +
  geom_segment(aes(yend = name), xend = 0, colour = "gray80") +
  geom_point(size = 2) +
  my_theme +
  ggtitle("Assignment to a field using self vs <<- (\u0b5s)")

p

## ------------------------------------------------------------------------
e1 <- new.env(hash = FALSE, parent = emptyenv())
e2 <- new.env(hash = FALSE, parent = emptyenv())
e3 <- new.env(hash = FALSE, parent = emptyenv())

e1$x <- 1
e2$x <- 1
e3$x <- 1

class(e2) <- "e2"
class(e3) <- "e3"

# Define an S3 method for class e3
`$.e3` <- function(x, name) {
  NULL
}

## ------------------------------------------------------------------------
speed <- microbenchmark(
  e1$x,
  e2$x,
  e3$x
)
speed <- mb_summary(speed)
speed

## ------------------------------------------------------------------------
lst <- list(x = 10)
env <- new.env()
env$x <- 10

mb_summary(microbenchmark(
  lst = lst$x,
  env = env$x,
  lst[['x']],
  env[['x']]
))

## ----eval=FALSE----------------------------------------------------------
#  # Utility functions for calculating sizes
#  obj_size <- function(expr, .env = parent.frame()) {
#    size_n <- function(n = 1) {
#      objs <- lapply(1:n, function(x) eval(expr, .env))
#      as.numeric(do.call(object_size, objs))
#    }
#  
#    data.frame(one = size_n(1), incremental = size_n(2) - size_n(1))
#  }
#  
#  obj_sizes <- function(..., .env = parent.frame()) {
#    exprs <- as.list(match.call(expand.dots = FALSE)$...)
#    names(exprs) <- lapply(1:length(exprs),
#      FUN = function(n) {
#        name <- names(exprs)[n]
#        if (is.null(name) || name == "") paste(deparse(exprs[[n]]), collapse = " ")
#        else name
#      })
#  
#    sizes <- mapply(obj_size, exprs, MoreArgs = list(.env = .env), SIMPLIFY = FALSE)
#    do.call(rbind, sizes)
#  }

## ------------------------------------------------------------------------
sessionInfo()

