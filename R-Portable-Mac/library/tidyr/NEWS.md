# tidyr 0.8.0

## Breaking changes

* There are no deliberate breaking changes in this release. However, a number 
  of packages are failing with errors related to numbers of elements in columns, 
  and row names. It is possible that these are accidental API changes or new 
  bugs. If you see such an error in your package, I would sincerely appreciate
  a minimal reprex.

* `separate()` now correctly uses -1 to refer to the far right position, 
  instead of -2. If you depended on this behaviour, you'll need to switch
  on `packageVersion("tidyr") > "0.7.2"`

## New features

* Increased test coverage from 84% to 99%.

* `uncount()` performs the inverse operation of `dplyr::count()` (#279)

## Bug fixes and minor improvements

* `complete(data)` now returns `data` rather than throwing an error (#390).
  `complete()` with zero-length completions returns original input (#331).

* `crossing()` preserves `NA`s (#364).

* `expand()` with empty input gives empty data frame instead of `NULL` (#331).

* `expand()`, `crossing()`, and `complete()` now complete empty factors instead 
  of dropping them (#270, #285)

* `extract()` has a better error message if `regex` does not contain the
  expected number of groups (#313).

* `drop_na()` no longer drops columns (@jennybryan, #245), and works with 
  list-cols (#280). Equivalent of `NA` in a list column is any empty 
  (length 0) data structure.

* `nest()` is now faster, especially when a long data frame is collapsed into 
  a nested data frame with few rows.

* `nest()` on a zero-row data frame works as expected (#320).

* `replace_na()` no longer complains if you try and replace missing values in
  variables not present in the data (#356).

* `replace_na()` now also works with vectors (#342, @flying-sheep), and
  can replace `NULL` in list-columns. It throws a better error message if
  you attempt to replace with something other than length 1.

* `separate()` now longer checks that `...` is empty, allowing methods to make
  use of it. This check was added in tidyr 0.4.0 (2016-02-02) to deprecate
  previous behaviour where `...` was passed to `strsplit()`.

* `separate()` and `extract()` now insert columns in correct position when
  `drop = TRUE` (#394).

* `separate()` now works correctly counts from RHS when using negative
  integer `sep` values (@markdly, #315).

* `separate()` gets improved warning message when pieces aren't as expected
  (#375).

* `separate_rows()` supports list columns (#321), and works with empty tibbles.

* `spread()` now consistently returns 0 row outputs for 0 row inputs (#269).

* `spread()` now works when `key` column includes `NA` and `drop` is `FALSE` 
  (#254).

* `spread()` no longer returns tibbles with row names (#322).

* `spread()`, `separate()`, `extract()` (#255), and `gather()` (#347) now 
  replace existing variables rather than creating an invalid data frame with 
  duplicated variable names (matching the semantics of mutate).

* `unite()` now works (as documented) if you don't supply any variables (#355).

* `unnest()` gains `preserve` argument which allows you to preserve list
  columns without unnesting them (#328).

* `unnest()` can unnested list-columns contains lists of lists (#278).

* `unnest(df)` now works if `df` contains no list-cols (#344)

# tidyr 0.7.2

* The SE variants `gather_()`, `spread_()` and `nest_()` now
  treat non-syntactic names in the same way as pre tidy eval versions
  of tidyr (#361).
  
* Fix tidyr bug revealed by R-devel.

# tidyr 0.7.1

This is a hotfix release to account for some tidyselect changes in the
unit tests.

Note that the upcoming version of tidyselect backtracks on some of the
changes announced for 0.7.0. The special evaluation semantics for
selection have been changed back to the old behaviour because the new
rules were causing too much trouble and confusion. From now on data
expressions (symbols and calls to `:` and `c()`) can refer to both
registered variables and to objects from the context.

However the semantics for context expressions (any calls other than to
`:` and `c()`) remain the same. Those expressions are evaluated in the
context only and cannot refer to registered variables. If you're
writing functions and refer to contextual objects, it is still a good
idea to avoid data expressions by following the advice of the 0.7.0
release notes.

# tidyr 0.7.0

This release includes important changes to tidyr internals. Tidyr now
supports the new tidy evaluation framework for quoting (NSE)
functions. It also uses the new tidyselect package as selecting
backend.


## Breaking changes

- If you see error messages about objects or functions not found, it
  is likely because the selecting functions are now stricter in their
  arguments An example of selecting function is `gather()` and its
  `...` argument. This change makes the code more robust by
  disallowing ambiguous scoping. Consider the following code:

  ```
  x <- 3
  df <- tibble(w = 1, x = 2, y = 3)
  gather(df, "variable", "value", 1:x)
  ```

  Does it select the first three columns (using the `x` defined in the
  global environment), or does it select the first two columns (using
  the column named `x`)?

  To solve this ambiguity, we now make a strict distinction between
  data and context expressions. A data expression is either a bare
  name or an expression like `x:y` or `c(x, y)`. In a data expression,
  you can only refer to columns from the data frame. Everything else
  is a context expression in which you can only refer to objects that
  you have defined with `<-`.

  In practice this means that you can no longer refer to contextual
  objects like this:

  ```
  mtcars %>% gather(var, value, 1:ncol(mtcars))

  x <- 3
  mtcars %>% gather(var, value, 1:x)
  mtcars %>% gather(var, value, -(1:x))
  ```

  You now have to be explicit about where to find objects. To do so,
  you can use the quasiquotation operator `!!` which will evaluate its
  argument early and inline the result:

  ```{r}
  mtcars %>% gather(var, value, !! 1:ncol(mtcars))
  mtcars %>% gather(var, value, !! 1:x)
  mtcars %>% gather(var, value, !! -(1:x))
  ```

  An alternative is to turn your data expression into a context
  expression by using `seq()` or `seq_len()` instead of `:`. See the
  section on tidyselect for more information about these semantics.

- Following the switch to tidy evaluation, you might see warnings
  about the "variable context not set". This is most likely caused by
  supplyng helpers like `everything()` to underscored versions of
  tidyr verbs. Helpers should be always be evaluated lazily. To fix
  this, just quote the helper with a formula: `drop_na(df,
  ~everything())`.

- The selecting functions are now stricter when you supply integer
  positions. If you see an error along the lines of

  ```
  `-0.949999999999999`, `-0.940000000000001`, ... must resolve to
  integer column positions, not a double vector
  ```

  please round the positions before supplying them to tidyr. Double
  vectors are fine as long as they are rounded.


## Switch to tidy evaluation

tidyr is now a tidy evaluation grammar. See the
[programming vignette](http://dplyr.tidyverse.org/articles/programming.html)
in dplyr for practical information about tidy evaluation.

The tidyr port is a bit special. While the philosophy of tidy
evaluation is that R code should refer to real objects (from the data
frame or from the context), we had to make some exceptions to this
rule for tidyr. The reason is that several functions accept bare
symbols to specify the names of _new_ columns to create (`gather()`
being a prime example). This is not tidy because the symbol do not
represent any actual object. Our workaround is to capture these
arguments using `rlang::quo_name()` (so they still support
quasiquotation and you can unquote symbols or strings). This type of
NSE is now discouraged in the tidyverse: symbols in R code should
represent real objects.

Following the switch to tidy eval the underscored variants are softly
deprecated. However they will remain around for some time and without
warning for backward compatibility.


## Switch to the tidyselect backend

The selecting backend of dplyr has been extracted in a standalone
package tidyselect which tidyr now uses for selecting variables. It is
used for selecting multiple variables (in `drop_na()`) as well as
single variables (the `col` argument of `extract()` and `separate()`,
and the `key` and `value` arguments of `spread()`). This implies the
following changes:

* The arguments for selecting a single variable now support all
  features from `dplyr::pull()`. You can supply a name or a position,
  including negative positions.

* Multiple variables are now selected a bit differently. We now make a
  strict distinction between data and context expressions. A data
  expression is either a bare name of an expression like `x:y` or
  `c(x, y)`. In a data expression, you can only refer to columns from
  the data frame. Everything else is a context expression in which you
  can only refer to objects that you have defined with `<-`.

  You can still refer to contextual objects in a data expression by
  being explicit. One way of being explicit is to unquote a variable
  from the environment with the tidy eval operator `!!`:

  ```r
  x <- 2
  drop_na(df, 2)     # Works fine
  drop_na(df, x)     # Object 'x' not found
  drop_na(df, !! x)  # Works as if you had supplied 2
  ```

  On the other hand, select helpers like `start_with()` are context
  expressions. It is therefore easy to refer to objects and they will
  never be ambiguous with data columns:

  ```{r}
  x <- "d"
  drop_na(df, starts_with(x))
  ```

  While these special rules is in contrast to most dplyr and tidyr
  verbs (where both the data and the context are in scope) they make
  sense for selecting functions and should provide more robust and
  helpful semantics.

# tidyr 0.6.3

* Patch tests to be compatible with dev tibble


# tidyr 0.6.2

* Register C functions

* Added package docs

* Patch tests to be compatible with dev dplyr.


# tidyr 0.6.1

* Patch test to be compatible with dev tibble

* Changed deprecation message of `extract_numeric()` to point to 
  `readr::parse_number()` rather than `readr::parse_numeric()`


# tidyr 0.6.0

## API changes

* `drop_na()` removes observations which have `NA` in the given variables. If no
  variables are given, all variables are considered (#194, @janschulz).

* `extract_numeric()` has been deprecated (#213).

* Renamed `table4` and `table5` to `table4a` and `table4b` to make their
  connection more clear. The `key` and `value` variables in `table2` have 
  been renamed to `type` and `count`.

## Bug fixes and minor improvements

* `expand()`, `crossing()`, and `nesting()` now silently drop zero-length
  inputs.
  
* `crossing_()` and `nesting_()` are versions of `crossing()` and `nesting()`
  that take a list as input.

* `full_seq()` works correctly for dates and date/times.

# tidyr 0.5.1

* Restored compatibility with R < 3.3.0 by avoiding `getS3method(envir = )` (#205, @krlmlr).

# tidyr 0.5.0

## New functions

* `separate_rows()` separates observations with multiple delimited values into
  separate rows (#69, @aaronwolen).

## Bug fixes and minor improvements

* `complete()` preserves grouping created by dplyr (#168).

* `expand()` (and hence `complete()`) preserves the ordered attribute of 
  factors (#165).

* `full_seq()` preserve attributes for dates and date/times (#156),
  and sequences no longer need to start at 0.

* `gather()` can now gather together list columns (#175), and 
  `gather_.data.frame(na.rm = TRUE)` now only removes missing values
  if they're actually present (#173).

* `nest()` returns correct output if every variable is nested (#186).

* `separate()` fills from right-to-left (not left-to-right!) when fill = "left"
  (#170, @dgrtwo).
  
* `separate()` and `unite()` now automatically drop removed variables from
  grouping (#159, #177).

* `spread()` gains a `sep` argument. If not-null, this will name columns
  as "key<sep>value". Additionally, if sep is `NULL` missing values will be
  converted to `<NA>` (#68).

* `spread()` works in the presence of list-columns (#199)

* `unnest()` works with non-syntactic names (#190).

* `unnest()` gains a `sep` argument. If non-null, this will rename the 
  columns of nested data frames to include both the original column name,
  and the nested column name, separated by `.sep` (#184).

* `unnest()` gains `.id` argument that works the same way as `bind_rows()`.
  This is useful if you have a named list of data frames or vectors (#125).

* Moved in useful sample datasets from the DSR package.

* Made compatible with both dplyr 0.4 and 0.5.

* tidyr functions that create new columns are more aggresive about re-encoding
  the column names as UTF-8. 

# tidyr 0.4.1

* Fixed bug in `nest()` where nested data was ending up in the wrong row (#158).

# tidyr 0.4.0

## Nested data frames

`nest()` and `unnest()` have been overhauled to support a useful way of structuring data frames: the __nested__ data frame. In a grouped data frame, you have one row per observation, and additional metadata define the groups. In a nested data frame, you have one __row__ per group, and the individual observations are stored in a column that is a list of data frames. This is a useful structure when you have lists of other objects (like models) with one element per group.

* `nest()` now produces a single list of data frames called "data" rather
  than a list column for each variable. Nesting variables are not included
  in nested data frames. It also works with grouped data frames made
  by `dplyr::group_by()`. You can override the default column name with `.key`.

* `unnest()` gains a `.drop` argument which controls what happens to
  other list columns. By default, they're kept if the output doesn't require
  row duplication; otherwise they're dropped.
  
* `unnest()` now has `mutate()` semantics for `...` - this allows you to
  unnest transformed columns more easily. (Previously it used select semantics).

## Expanding

* `expand()` once again allows you to evaluate arbitrary expressions like
  `full_seq(year)`. If you were previously using `c()` to created nested 
  combinations, you'll now need to use `nesting()` (#85, #121).

* `nesting()` and `crossing()` allow you to create nested and crossed data
  frames from individual vectors. `crossing()` is similar to 
  `base::expand.grid()`

* `full_seq(x, period)` creates the full sequence of values from `min(x)` to
  `max(x)` every `period` values.

## Minor bug fixes and improvements

* `fill()` fills in `NULL`s in list-columns.

* `fill()` gains a direction argument so that it can fill either upwards or 
  downwards (#114).

* `gather()` now stores the key column as character, by default. To revert to
  the previous behaviour of using a factor (which allows you to preserve the
  ordering of the columns), use `key_factor = TRUE` (#96).

* All tidyr verbs do the right thing for grouped data frames created by 
  `group_by()` (#122, #129, #81).

* `seq_range()` has been removed. It was never used or announced.

* `spread()` once again creates columns of mixed type when `convert = TRUE` 
  (#118, @jennybc). `spread()` with `drop = FALSE`  handles zero-length 
  factors (#56). `spread()`ing a data frame with only key and value columns 
  creates a one row output (#41).

* `unite()` now removes old columns before adding new (#89, @krlmlr).

* `separate()` now warns if defunct ... argument is used (#151, @krlmlr).

# tidyr 0.3.1

* Fixed bug where attributes of non-gather columns were lost (#104)

# tidyr 0.3.0

## New features

* New `complete()` provides a wrapper around `expand()`, `left_join()` and 
  `replace_na()` for a common task: completing a data frame with missing
  combinations of variables.

* `fill()` fills in missing values in a column with the last non-missing 
  value (#4).

* New `replace_na()` makes it easy to replace missing values with something
  meaningful for your data.

* `nest()` is the complement of `unnest()` (#3).

* `unnest()` can now work with multiple list-columns at the same time. 
  If you don't supply any columns names, it will unlist all 
  list-columns (#44). `unnest()` can also handle columns that are
  lists of data frames (#58).

## Bug fixes and minor improvements

* tidyr no longer depends on reshape2. This should fix issues if you also
  try to load reshape (#88).

* `%>%` is re-exported from magrittr.

* `expand()` now supports nesting and crossing (see examples for details).
  This comes at the expense of creating new variables inline (#46).

* `expand_` does SE evaluation correctly so you can pass it a character vector
  of columns names (or list of formulas etc) (#70).

* `extract()` is 10x faster because it now uses stringi instead of 
  base R regular expressions. It also returns NA instead of throwing
  an error if the regular expression doesn't match (#72).
  
* `extract()` and `separate()` preserve character vectors when
  `convert` is TRUE (#99).
  
* The internals of `spread()` have been rewritten, and now preserve all 
  attributes of the input `value` column. This means that you can now 
  spread date (#62) and factor (#35) inputs.

* `spread()` gives a more informative error message if `key` or `value` don't
  exist in the input data (#36).

* `separate()` only displays the first 20 failures (#50). It has 
  finer control over what happens if there are two few matches:
  you can fill with missing values on either the "left" or the "right" (#49).
  `separate()` no longer throws an error if the number of pieces aren't
  as expected - instead it uses drops extra values and fills on the right
  and gives a warning.

* If the input is NA `separate()` and `extract()` both return silently
  return NA outputs, rather than throwing an error. (#77)

* Experimental `unnest()` method for lists has been removed.

# tidyr 0.2.0

## New functions

* Experimental `expand()` function (#21).

* Experiment `unnest()` function for converting named lists into
  data frames. (#3, #22)

## Bug fixes and minor improvements

* `extract_numeric()` preserves negative signs (#20).

* `gather()` has better defaults if `key` and `value` are not supplied.
  If `...` is ommitted, `gather()` selects all columns (#28). Performance
  is now comparable to `reshape2::melt()` (#18).

* `separate()` gains `extra` argument which lets you control what happens
  to extra pieces. The default is to throw an "error", but you can also
  "merge" or "drop".

* `spread()` gains `drop` argument, which allows you to preserve missing
  factor levels (#25). It converts factor value variables to character vectors, 
  instead of embedding a matrix inside the data frame (#35).
