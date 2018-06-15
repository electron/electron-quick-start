# glue 1.2.0

* The implementation has been tweaked to be slightly faster in most cases.

* `glue()` now has a `.transformer` argument, which allows you to use custom
  logic on how to evaluate the code within glue blocks. See
  `vignettes("transformers")` for more details and example transformer
  functions.

* `glue()` now returns `NA` if any of the results are `NA` and `.na` is `NULL`.
  Otherwise `NA` values are replaced by the value of `.na`.

* `trim()` to use the trimming logic from glue is now exported.

* `glue_sql()` and `glue_data_sql()` functions added to make constructing SQL
  statements with glue safer and easier.

* `glue()` is now easier to use when used within helper functions such as
  `lapply`.

* Fix when last expression in `glue()` is NULL.

# glue 1.1.1

* Another fix for PROTECT / REPROTECT found by the rchk static analyzer.

# glue 1.1.0

* Fix for PROTECT errors when resizing output strings.

* `glue()` always returns 'UTF-8' strings, converting inputs if in other
encodings if needed.

* `to()` and `to_data()` have been removed.

* `glue()` and `glue_data()` can now take alternative delimiters to `{` and `}`.
This is useful if you are writing to a format that uses a lot of braces, such
as LaTeX. (#23)

* `collapse()` now returns 0 length output if given 0 length input (#28).

# glue 0.0.0.9000

* Fix `glue()` to admit `.` as an embedded expression in a string (#15, @egnha).

* Added a `NEWS.md` file to track changes to the package.
