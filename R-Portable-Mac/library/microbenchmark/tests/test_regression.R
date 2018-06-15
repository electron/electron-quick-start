library(microbenchmark)

test_units_argument <- function()
{
  out <- try(microbenchmark(NULL, units=a), silent = TRUE)
  stopifnot(inherits(out, "try-error"))
}
test_units_argument()

test_simple_timing <- function()
{
  set.seed(21)
  out <- microbenchmark(rnorm(1e4))
  stopifnot(all(out$time > 0))
}
test_simple_timing()

test_get_nanotime <- function()
{
  nt <- get_nanotime()
  stopifnot(nt > 0)
}
test_get_nanotime()

test_microtiming_precision <- function()
{
  mtp <- tryCatch(microtiming_precision(),
                  warning = function(w) w,
                  error = function(e) e)

  if (is(mtp, "warning") || is(mtp, "error")) {
    stop(mtp$message)
  }
}
test_microtiming_precision()
