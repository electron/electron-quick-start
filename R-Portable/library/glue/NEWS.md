# glue 1.1.1

Another fix for PROTECT / REPROTECT found by the rchk static analyzer.

# glue 1.1.0

Fix for PROTECT errors when resizing output strings.

`glue()` always returns 'UTF-8' strings, converting inputs if in other
encodings if needed.

`to()` and `to_data()` have been removed.

`glue()` and `glue_data()` can now take alternative delimiters to `{` and `}`.
This is useful if you are writing to a format that uses a lot of braces, such
as LaTeX. (#23)

`collapse()` now returns 0 length output if given 0 length input (#28).

# glue 0.0.0.9000

* Fix `glue()` to admit `.` as an embedded expression in a string (#15, @egnha).

* Added a `NEWS.md` file to track changes to the package.
