# purrr 0.2.4

* Fixes for R 3.1.

* Fix PROTECTion problems in C code revealed by rchk.

# purrr 0.2.3

## Breaking changes

We noticed the following issues during reverse dependencies checks:

* If `reduce()` fails with this message: ``Error: `.x` is empty, and
  no `.init` supplied``, this is because `reduce()` now returns
  `.init` when `.x` is empty. Fix the problem by supplying an
  appropriate argument to `.init`, or by providing special behaviour
  when `.x` has length 0.

* The type predicates have been migrated to rlang. Consequently the
  `bare-type-predicates` documentation topic is no longer in purrr,
  which might cause a warning if you cross-reference it.


## Dependencies

purrr no longer depends on lazyeval or Rcpp (or dplyr, as of the
previous version). This makes the dependency graph of the tidyverse
simpler, and makes purrr more suitable as a dependency of lower-level
packages.

There have also been two changes to eliminate name conflicts between
purrr and dplyr:

* `order_by()`, `sort_by()` and `split_by()` have been removed. `order_by()`
  conflicted with `dplyr::order_by()` and the complete family doesn't feel that
  useful. Use tibbles instead (#217).

* `contains()` has been renamed to `has_element()` to avoid conflicts with
  dplyr (#217).


## pluck()

The plucking mechanism used for indexing into data structures with
`map()` has been extracted into the function `pluck()`. Plucking is
often more readable to extract an element buried in a deep data
structure. Compare this syntax-heavy extraction which reads
non-linearly:

```
accessor(x[[1]])$foo
```

to the equivalent pluck:

```
x %>% pluck(1, accessor, "foo")
```


## Map helpers

* `as_function()` is now `as_mapper()` because it is a tranformation that
  makes sense primarily for mapping functions, not in general (#298).
  `.null` has been renamed to `.default` to better reflect its intent (#298).
  `.default` is returned whenever an element is absent or empty (#231, #254).

  `as_mapper()` sanitises primitive functions by transforming them to
  closures with standardised argument names (using `rlang::as_closure()`).
  For instance `+` is transformed to `function(.x, .y) .x + .y`. This
  results in proper argument matching so that `map(1:10, partial(`-`,
  .x = 5))` produces `list(5 - 1, 5 - 2, ...)`.

* Recursive indexing can now extract objects out of environments (#213) and
  S4 objects (#200), as well as lists.

* `attr_getter()` makes it possible to extract from attributes
  like `map(list(iris, mtcars), attr_getter("row.names"))`.

* The argument list for formula-functions has been tweaked so that you can
  refer to arguments by position with `..1`, `..2`, and so on. This makes it
  possible to use the formula shorthand for functions with more than two
  arguments (#289).

* `possibly()`, `safely()` and friends no longer capture interrupts: this
  means that you can now terminate a mapper using one of these with
  Escape or Ctrl + C (#314)


## Map functions

* All map functions now treat `NULL` the same way as an empty vector (#199),
  and return an empty vector if any input is an empty vector.

* All `map()` functions now force their arguments in the same way that base R
  does for `lapply()` (#191). This makes `map()` etc easier to use when
  generating functions.

* A new family of "indexed" map functions, `imap()`, `imap_lgl()` etc,
  provide a short-hand for `map2(x, names(x))` or `map2(x, seq_along(x))`
  (#240).

* The data frame suffix `_df` has been (soft) deprecated in favour of
  `_dfr` to more clearly indicate that it's a row-bind. All variants now
  also have a `_dfc` for column binding (#167). (These will not be terribly
  useful until `dplyr::bind_rows()`/`dplyr::bind_cols()` have better
  semantics for vectors.)


## Modify functions

A new `modify()` family returns the same output of the type as the
input `.x`. This is in contrast to the `map()` family which always
returns a list, regardless of the input type.

The modify functions are S3 generics. However their default methods
should be sufficient for most classes since they rely on the semantics
of `[<-`.  `modify.default()` is thus a shorthand for `x[] <- map(x, f)`.

* `at_depth()` has been renamed to `modify_depth()`.

* `modify_depth()` gains new `.ragged` argument, and negative depths are
  now computed relative to the deepest component of the list (#236).


## New functions

* `auto_browse(f)` returns a new function that automatically calls `browser()`
  if `f` throws an error (#281).

* `vec_depth()` computes the depth (i.e. the number of levels of indexing)
  or a vector (#243).

* `reduce2()` and `reduce2_right()` make it possible to reduce with a
  3 argument function where the first argument is the accumulated value, the
  second argument is `.x`, and the third argument is `.y` (#163).

* `list_modify()` extends `stats::modifyList()` to replace by position
  if the list is not named.(#201). `list_merge()` operates similarly
  to `list_modify()` but combines instead of replacing (#322).

* The legacy function `update_list()` is basically a version of
  `list_modify` that evaluates formulas within the list. It is likely
  to be deprecated in the future in favour of a tidyeval interface
  such as a list method for `dplyr::mutate()`.


## Minor improvements and bug fixes

* Thanks to @dchiu911, the unit test coverage of purrr is now much greater.

* All predicate functions are re-exported from rlang (#124).

* `compact()` now works with standard mapper conventions (#282).

* `cross_n()` has been renamed to `cross()`. The `_n` suffix was
  removed for consistency with `pmap()` (originally called `map_n()`
  at the start of the project) and `transpose()` (originally called
  `zip_n()`). Similarly, `cross_d()` has been renamed to `cross_df()`
  for consistency with `map_df()`.

* `every()` and `some()` now return `NA` if present in the input (#174).

* `invoke()` uses a more robust approach to generate the argument list (#249)
  It no longer uses lazyeval to figure out which enviroment a character `f`
  comes from.

* `is_numeric()` and `is_scalar_numeric()` are deprecated because they
  don't test for what you might expect at first sight.

* `reduce()` now throws an error if `.x` is empty and `.init` is not
  supplied.

* Deprecated functions `flatmap()`, `map3()`, `map_n()`, `walk3()`,
  `walk_n()`, `zip2()`, `zip3()`, `zip_n()` have been removed.

* `pmap()` coerces data frames to lists to avoid the expensive `[.data.frame`
  which provides security that is unneeded here (#220).

* `rdunif()` checks its inputs for validity (#211).

* `set_names()` can now take a function to tranform the names programmatically
  (#276), and you can supply names in `...` to reduce typing even more
  more (#316). `set_names()` is now powered by `rlang::set_names()`.

* `safely()` now actually uses the `quiet` argument (#296).

* `transpose()` now matches by name if available (#164). You can
  override the default choice with the new `.names` argument.

* The function argument of `detect()` and `detect_index()` have been
  renamed from `.p` to `.f`. This is because they have mapper
  semantics rather than predicate semantics.


# purrr 0.2.2.1

This is a compatibility release with dplyr 0.6.0.

* All data-frame based mappers have been removed in favour of new
  functions and idioms in the tidyverse. `dmap()`, `dmap_at()`,
  `dmap_if()`, `invoke_rows()`, `slice_rows()`, `map_rows()`,
  `by_slice()`, `by_row()`, and `unslice()` have been moved to
  purrrlyr. This is a bit of an aggresive change but it allows us to
  make the dependencies much lighter.


# purrr 0.2.2

* Fix for dev tibble support.

* `as_function()` now supports list arguments which allow recursive indexing
   using either names or positions. They now always stop when encountering
   the first NULL (#173).

* `accumulate` and `reduce` correctly pass extra arguments to the
   worker function.


# purrr 0.2.1

* `as_function()` gains a `.null` argument that for character and numeric
  values allows you to specify what to return for null/absent elements (#110).
  This can be used with any map function, e.g. `map_int(x, 1, .null = NA)`

* `as_function()` is now generic.

* New `is_function()` that returns `TRUE` only for regular functions.

* Fix crash on GCC triggered by `invoke_rows()`.


# purrr 0.2.0

## New functions

* There are two handy infix functions:

    * `x %||% y` is shorthand for `if (is.null(x)) y else x` (#109).
    * `x %@% "a"` is shorthand for `attr(x, "a", exact = TRUE)` (#69).

* `accumulate()` has been added to handle recursive folding. It is shortand
  for `Reduce(f, .x, accumulate = TRUE)` and follows a similar syntax to
  `reduce()` (#145). A right-hand version `accumulate_right()` was also added.

* `map_df()` row-binds output together. It's the equivalent of `plyr::ldply()`
  (#127)

* `flatten()` is now type-stable and always returns a list. To return a simpler
  vector, use `flatten_lgl()`, `flatten_int()`, `flatten_dbl()`,
  `flatten_chr()`, or `flatten_df()`.

* `invoke()` has been overhauled to be more useful: it now works similarly
  to `map_call()` when `.x` is NULL, and hence `map_call()` has been
  deprecated. `invoke_map()` is a vectorised complement to `invoke()` (#125),
  and comes with typed variants `invoke_map_lgl()`, `invoke_map_int()`,
  `invoke_map_dbl()`, `invoke_map_chr()`, and `invoke_map_df()`.

* `transpose()` replaces `zip2()`, `zip3()`, and `zip_n()` (#128).
  The name more clearly reflects the intent (transposing the first and second
  levels of list). It no longer has fields argument or the `.simplify` argument;
  instead use the new `simplify_all()` function.

* `safely()`, `quietly()`, and `possibly()` are experimental functions
  for working with functions with side-effects (e.g. printed output,
  messages, warnings, and errors) (#120). `safely()` is a version of `try()`
  that modifies a function (rather than an expression), and always returns a
  list with two components, `result` and `error`.

* `list_along()` and `rep_along()` generalise the idea of `seq_along()`.
  (#122).

* `is_null()` is the snake-case version of `is.null()`.

* `pmap()` (parallel map) replaces `map_n()` (#132), and has typed-variants
  suffixed `pmap_lgl()`, `pmap_int()`, `pmap_dbl()`, `pmap_chr()`, and
  `pmap_df()`.

* `set_names()` is a snake-case alternative to `setNames()` with stricter
  equality checking, and more convenient defaults for pipes:
  `x %>% set_names()` is equivalent to `setNames(x, x)` (#119).


## Row based functionals

We are still figuring out what belongs in dplyr and what belongs in
purrr. Expect much experimentation and many changes with these
functions.

* `map()` now always returns a list. Data frame support has been moved
  to `map_df()` and `dmap()`. The latter supports sliced data frames
  as a shortcut for the combination of `by_slice()` and `dmap()`:
  `x %>% by_slice(dmap, fun, .collate = "rows")`. The conditional
  variants `dmap_at()` and `dmap_if()` also support sliced data frames
  and will recycle scalar results to the slice size.

* `map_rows()` has been renamed to `invoke_rows()`. As other
  rows-based functionals, it collates results inside lists by default,
  but with column collation this function is equivalent to
  `plyr::mdply()`.

* The rows-based functionals gain a `.to` option to name the output
  column as well as a `.collate` argument. The latter allows to
  collate the output in lists (by default), on columns or on
  rows. This makes these functions more flexible and more predictable.

## Bug fixes and minor changes

* `as_function()`, which converts formulas etc to functions, is now
  exported (#123).

* `rerun()` is correctly scoped (#95)

* `update_list()` can now modify an element called `x` (#98).

* `map*()` now use custom C code, rather than relying on `lapply()`, `mapply()`
  etc. The performance characteristcs are very similar, but it allows us greater
  control over the output (#118).

* `map_lgl()` now has second argument `.f`, not `.p` (#134).


## Deprecated functions

* `flatmap()` -> use `map()` followed by the appropriate `flatten()`.

* `map_call()` -> `invoke()`.

* `map_n()` -> `pmap()`; `walk_n()` -> `pwalk()`.

* `map3(x, y, z)` -> `map_n(list(x, y, z))`; `walk3(x, y, z) -> `pwalk(list(x, y, z))`
