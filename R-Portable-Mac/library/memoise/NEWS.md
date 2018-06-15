# Version 1.1.0
* Caches now hash the function body along with the arguments, to ensure
  functions with identical arguments use a separate file-system cache. (#38)
* Handle missing arguments in memoised functions for simple cases not using
  non-standard-evaluation (#19).
* `memoise()` gains a `cache=` argument to specify an external cache. Two types
  of caches are available, `cache_s3()` for amazon S3 and
  `cache_filesystem()` for a file system cache (#25, @danielecook).

# Version 1.0.0
* `memoise()` now signals an error if an already memoised function is used as
  input (#4, @richierocks).
* `has_cache()` function added which returns a boolean depending on if the
  given call is cached or not (#10, @dkesh).
* Memoised functions now have a print method which displays the original
  function definition, rather than the memoisation code (#15, @jimhester).
* A memoised function now has the same interface as the original function,
  if the original function is known when `memoise` is called. (Otherwise,
  the old behavior is invoked, with a warning.) (#14, @krlmlr)
* The enclosing environment of the memoised function is specified explicitly,
  defaults to `parent.frame()`.
* `is.memoised` now checks if the argument is a function.
* Testing infrastructure, full test coverage.

# Version 0.2.1

* Update to fix outstanding R CMD check issues.

# Version 0.2 (2010-11-11)

## New features

* Memoised functions now have an attribute memoised=TRUE, and
  is.memoised() tests whether a function is memoised. (Contributed by
  Sietse Brouwer.)

## Improvements

* Documentation is now more elaborate, and hopefully more accessible to
  newcomers. Thanks to Sietse Brouwer for the verbosity.
