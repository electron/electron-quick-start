## ----echo = FALSE--------------------------------------------------------
library(pryr)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ------------------------------------------------------------------------
library(R6)

Person <- R6Class("Person",
  public = list(
    name = NULL,
    hair = NULL,
    initialize = function(name = NA, hair = NA) {
      self$name <- name
      self$hair <- hair
      self$greet()
    },
    set_hair = function(val) {
      self$hair <- val
    },
    greet = function() {
      cat(paste0("Hello, my name is ", self$name, ".\n"))
    }
  )
)

## ------------------------------------------------------------------------
ann <- Person$new("Ann", "black")
ann

## ------------------------------------------------------------------------
ann$hair
ann$greet()
ann$set_hair("red")
ann$hair

## ------------------------------------------------------------------------
Queue <- R6Class("Queue",
  public = list(
    initialize = function(...) {
      for (item in list(...)) {
        self$add(item)
      }
    },
    add = function(x) {
      private$queue <- c(private$queue, list(x))
      invisible(self)
    },
    remove = function() {
      if (private$length() == 0) return(NULL)
      # Can use private$queue for explicit access
      head <- private$queue[[1]]
      private$queue <- private$queue[-1]
      head
    }
  ),
  private = list(
    queue = list(),
    length = function() base::length(private$queue)
  )
)

q <- Queue$new(5, 6, "foo")

## ------------------------------------------------------------------------
# Add and remove items
q$add("something")
q$add("another thing")
q$add(17)
q$remove()
q$remove()

## ----eval = FALSE--------------------------------------------------------
#  q$queue
#  #> NULL
#  q$length()
#  #> Error: attempt to apply non-function

## ------------------------------------------------------------------------
q$add(10)$add(11)$add(12)

## ------------------------------------------------------------------------
q$remove()
q$remove()
q$remove()
q$remove()

## ------------------------------------------------------------------------
Numbers <- R6Class("Numbers",
  public = list(
    x = 100
  ),
  active = list(
    x2 = function(value) {
      if (missing(value)) return(self$x * 2)
      else self$x <- value/2
    },
    rand = function() rnorm(1)
  )
)

n <- Numbers$new()
n$x

## ------------------------------------------------------------------------
n$x2

## ------------------------------------------------------------------------
n$x2 <- 1000
n$x

## ----eval=FALSE----------------------------------------------------------
#  n$rand
#  #> [1] 0.2648
#  n$rand
#  #> [1] 2.171
#  n$rand <- 3
#  #> Error: unused argument (quote(3))

## ------------------------------------------------------------------------
# Note that this isn't very efficient - it's just for illustrating inheritance.
HistoryQueue <- R6Class("HistoryQueue",
  inherit = Queue,
  public = list(
    show = function() {
      cat("Next item is at index", private$head_idx + 1, "\n")
      for (i in seq_along(private$queue)) {
        cat(i, ": ", private$queue[[i]], "\n", sep = "")
      }
    },
    remove = function() {
      if (private$length() - private$head_idx == 0) return(NULL)
      private$head_idx <<- private$head_idx + 1
      private$queue[[private$head_idx]]
    }
  ),
  private = list(
    head_idx = 0
  )
)

hq <- HistoryQueue$new(5, 6, "foo")
hq$show()
hq$remove()
hq$show()
hq$remove()

## ------------------------------------------------------------------------
CountingQueue <- R6Class("CountingQueue",
  inherit = Queue,
  public = list(
    add = function(x) {
      private$total <<- private$total + 1
      super$add(x)
    },
    get_total = function() private$total
  ),
  private = list(
    total = 0
  )
)

cq <- CountingQueue$new("x", "y")
cq$get_total()
cq$add("z")
cq$remove()
cq$remove()
cq$get_total()

## ------------------------------------------------------------------------
SimpleClass <- R6Class("SimpleClass",
  public = list(x = NULL)
)

SharedField <- R6Class("SharedField",
  public = list(
    e = SimpleClass$new()
  )
)

s1 <- SharedField$new()
s1$e$x <- 1

s2 <- SharedField$new()
s2$e$x <- 2

# Changing s2$e$x has changed the value of s1$e$x
s1$e$x

## ------------------------------------------------------------------------
NonSharedField <- R6Class("NonSharedField",
  public = list(
    e = NULL,
    initialize = function() self$e <- SimpleClass$new()
  )
)

n1 <- NonSharedField$new()
n1$e$x <- 1

n2 <- NonSharedField$new()
n2$e$x <- 2

# n2$e$x does not affect n1$e$x
n1$e$x

## ------------------------------------------------------------------------
RC <- setRefClass("RC",
  fields = list(x = 'ANY'),
  methods = list(
    getx = function() x,
    setx = function(value) x <<- value
  )
)

rc <- RC$new()
rc$setx(10)
rc$getx()

## ------------------------------------------------------------------------
NP <- R6Class("NP",
  portable = FALSE,
  public = list(
    x = NA,
    getx = function() x,
    setx = function(value) x <<- value
  )
)

np <- NP$new()
np$setx(10)
np$getx()

## ------------------------------------------------------------------------
P <- R6Class("P",
  portable = TRUE,  # This is default
  public = list(
    x = NA,
    getx = function() self$x,
    setx = function(value) self$x <- value
  )
)

p <- P$new()
p$setx(10)
p$getx()

## ------------------------------------------------------------------------
Simple <- R6Class("Simple",
  public = list(
    x = 1,
    getx = function() self$x
  )
)

Simple$set("public", "getx2", function() self$x*2)

# To replace an existing member, use overwrite=TRUE
Simple$set("public", "x", 10, overwrite = TRUE)

s <- Simple$new()
s$x
s$getx2()

## ------------------------------------------------------------------------
# Create a locked class
Simple <- R6Class("Simple",
  public = list(
    x = 1,
    getx = function() self$x
  ),
  lock_class = TRUE
)

# This would result in an error
# Simple$set("public", "y", 2)

# Unlock the class
Simple$unlock()

# Now it works
Simple$set("public", "y", 2)

# Lock the class again
Simple$lock()

## ------------------------------------------------------------------------
Simple <- R6Class("Simple",
  public = list(
    x = 1,
    getx = function() self$x
  )
)

s <- Simple$new()

# Create a clone
s1 <- s$clone()
# Modify it
s1$x <- 2
s1$getx()

# Original is unaffected by changes to the clone
s$getx()

## ----clone-size, echo=FALSE----------------------------------------------
# Calculate size of clone method in this block.
Cloneable <- R6Class("Cloneable", cloneable = TRUE)
NonCloneable <- R6Class("NonCloneable", cloneable = FALSE)

c1 <- Cloneable$new()
c2 <- Cloneable$new()
# Bytes for each new cloneable object
cloneable_delta <- object_size(c1, c2) - object_size(c2)

nc1 <- NonCloneable$new()
nc2 <- NonCloneable$new()
# Bytes for each new noncloneable object
noncloneable_delta <- object_size(nc1, nc2) - object_size(nc2)

# Number of bytes used by each copy of clone method
additional_clone_method_bytes <- cloneable_delta - noncloneable_delta
additional_clone_method_bytes_str <- capture.output(print(additional_clone_method_bytes))

# Number of bytes used by first copy of a clone method
first_clone_method_bytes <- object_size(c1) - object_size(nc1)
# Need some trickery to get the nice output from pryr::print.bytes
first_clone_method_bytes_str <- capture.output(print(first_clone_method_bytes))

## ------------------------------------------------------------------------
Simple <- R6Class("Simple", public = list(x = 1))

Cloneable <- R6Class("Cloneable",
  public = list(
    s = NULL,
    initialize = function() self$s <- Simple$new()
  )
)

c1 <- Cloneable$new()
c2 <- c1$clone()

# Change c1's `s` field
c1$s$x <- 2

# c2's `s` is the same object, so it reflects the change
c2$s$x

## ------------------------------------------------------------------------
c3 <- c1$clone(deep = TRUE)

# Change c1's `s` field
c1$s$x <- 3

# c2's `s` is different
c3$s$x

## ------------------------------------------------------------------------
CloneEnv <- R6Class("CloneEnv",
  public = list(
    a = NULL,
    b = NULL,
    v = 1,
    initialize = function() {
      self$a <- new.env(parent = emptyenv())
      self$b <- new.env(parent = emptyenv())
      self$a$x <- 1
      self$b$x <- 1
    }
  ),
  private = list(
    deep_clone = function(name, value) {
      # With x$clone(deep=TRUE) is called, the deep_clone gets invoked once for
      # each field, with the name and value.
      if (name == "a") {
        # `a` is an environment, so use this quick way of copying
        list2env(as.list.environment(value, all.names = TRUE),
                 parent = emptyenv())
      } else {
        # For all other fields, just return the value
        value
      }
    }
  )
)

c1 <- CloneEnv$new()
c2 <- c1$clone(deep = TRUE)

## ------------------------------------------------------------------------
# Modifying c1$a doesn't affect c2$a, because they're separate objects
c1$a$x <- 2
c2$a$x

# Modifying c1$b does affect c2$b, because they're the same object
c1$b$x <- 3
c2$b$x

# Modifying c1$v doesn't affect c2$v, because they're not reference objects
c1$v <- 4
c2$v

## ------------------------------------------------------------------------
PrettyCountingQueue <- R6Class("PrettyCountingQueue",
  inherit = CountingQueue,
  public = list(
    print = function(...) {
      cat("<PrettyCountingQueue> of ", self$get_total(), " elements\n", sep = "")
      invisible(self)
    }
  )
)

## ------------------------------------------------------------------------
pq <- PrettyCountingQueue$new(1, 2, "foobar")
pq

## ------------------------------------------------------------------------
A <- R6Class("A", public = list(
  finalize = function() {
    print("Finalizer has been called!")
  }
))


# Instantiate an object:
obj <- A$new()

# Remove the single existing reference to it, and force garbage collection
# (normally garbage collection will happen automatically from time
# to time)
rm(obj); gc()

