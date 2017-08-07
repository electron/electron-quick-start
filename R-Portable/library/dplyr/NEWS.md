# dplyr 0.7.2

* Move build-time vs. run-time checks out of `.onLoad()` and into `dr_dplyr()`.

# dplyr 0.7.1

* Use new versions of bindrcpp and glue to avoid protection problems.
  Avoid wrapping arguments to internal error functions (#2877). Fix
  two protection mistakes found by rchk (#2868).

* Fix C++ error that caused compilation to fail on mac cran (#2862)

* Fix undefined behaviour in `between()`, where `NA_REAL` were
  assigned instead of `NA_LOGICAL`. (#2855, @zeehio)

* `top_n()` now executes operations lazily for compatibility with
  database backends (#2848).

* Reuse of new variables created in ungrouped `mutate()` possible
  again, regression introduced in dplyr 0.7.0 (#2869).

* Quosured symbols do not prevent hybrid handling anymore. This should
  fix many performance issues introduced with tidyeval (#2822).

# dplyr 0.7.0

## New data, functions, and features

* Five new datasets provide some interesting built-in datasets to demonstrate
  dplyr verbs (#2094):
  
  * `starwars` dataset about starwars characters; has list columns
  * `storms` has the trajectories of ~200 tropical storms
  * `band_members`, `band_instruments` and `band_instruments2` 
    has some simple data to demonstrate joins.

* New `add_count()` and `add_tally()` for adding an `n` column within groups 
  (#2078, @dgrtwo).

* `arrange()` for grouped data frames gains a `.by_group` argument so you
  can choose to sort by groups if you want to (defaults to `FALSE`) (#2318)

* New `pull()` generic for extracting a single column either by name or position
  (either from the left or the right). Thanks to @paulponcet for the idea (#2054).

  This verb is powered with the new `select_var()` internal helper,
  which is exported as well. It is like `select_vars()` but returns a
  single variable.

* `as_tibble()` is re-exported from tibble. This is the recommend way to create
  tibbles from existing data frames. `tbl_df()` has been softly deprecated.
  `tribble()` is now imported from tibble (#2336, @chrMongeau); this 
  is now prefered to `frame_data()`.

## Deprecated and defunct

* dplyr no longer messages that you need dtplyr to work with data.table (#2489).

* Long deprecated `regroup()`, `mutate_each_q()` and
  `summarise_each_q()` functions have been removed.

* Deprecated `failwith()`. I'm not even sure why it was here.

* Soft-deprecated `mutate_each()` and `summarise_each()`, these functions
  print a message which will be changed to a warning in the next release.

* The `.env` argument to `sample_n()` and `sample_frac()` is defunct,
  passing a value to this argument print a message which will be changed to a 
  warning in the next release.

## Databases

This version of dplyr includes some major changes to how database connections work. By and large, you should be able to continue using your existing dplyr database code without modification, but there are two big changes that you should be aware of:

* Almost all database related code has been moved out of dplyr and into a 
  new package, [dbplyr](http://github.com/hadley/dbplyr/). This makes dplyr 
  simpler, and will make it easier to release fixes for bugs that only affect
  databases. `src_mysql()`, `src_postgres()`, and `src_sqlite()` will still
  live dplyr so your existing code continues to work.

* It is no longer necessary to create a remote "src". Instead you can work 
  directly with the database connection returned by DBI. This reflects the
  maturity of the DBI ecosystem. Thanks largely to the work of Kirill Muller
  (funded by the R Consortium) DBI backends are now much more consistent,
  comprehensive, and easier to use. That means that there's no longer a
  need for a layer in between you and DBI.

You can continue to use `src_mysql()`, `src_postgres()`, and `src_sqlite()`, but I recommend a new style that makes the connection to DBI more clear:

```R
library(dplyr)

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
DBI::dbWriteTable(con, "mtcars", mtcars)

mtcars2 <- tbl(con, "mtcars")
mtcars2
```

This is particularly useful if you want to perform non-SELECT queries as you can do whatever you want with `DBI::dbGetQuery()` and `DBI::dbExecute()`.

If you've implemented a database backend for dplyr, please read the [backend news](https://github.com/hadley/dbplyr/blob/master/NEWS.md#backends) to see what's changed from your perspective (not much). If you want to ensure your package works with both the current and previous version of dplyr, see `wrap_dbplyr_obj()` for helpers.

## UTF-8

* Internally, column names are always represented as character vectors,
  and not as language symbols, to avoid encoding problems on Windows
  (#1950, #2387, #2388).

* Error messages and explanations of data frame inequality are now encoded in
  UTF-8, also on Windows (#2441).

* Joins now always reencode character columns to UTF-8 if necessary. This gives
  a nice speedup, because now pointer comparison can be used instead of string
  comparison, but relies on a proper encoding tag for all strings (#2514).

* Fixed problems when joining factor or character encodings with a mix of 
  native and UTF-8 encoded values (#1885, #2118, #2271, #2451).

* Fix `group_by()` for data frames that have UTF-8 encoded names (#2284, #2382).

* New `group_vars()` generic that returns the grouping as character vector, to 
  avoid the potentially lossy conversion to language symbols. The list returned 
  by `group_by_prepare()` now has a new `group_names` component (#1950, #2384).

## Colwise functions

* `rename()`, `select()`, `group_by()`, `filter()`, `arrange()` and
  `transmute()` now have scoped variants (verbs suffixed with `_if()`,
  `_at()` and `_all()`). Like `mutate_all()`, `summarise_if()`, etc,
  these variants apply an operation to a selection of variables.

* The scoped verbs taking predicates (`mutate_if()`, `summarise_if()`,
  etc) now support S3 objects and lazy tables. S3 objects should
  implement methods for `length()`, `[[` and `tbl_vars()`. For lazy
  tables, the first 100 rows are collected and the predicate is
  applied on this subset of the data. This is robust for the common
  case of checking the type of a column (#2129).
  
* Summarise and mutate colwise functions pass `...` on the the manipulation
  functions.

* The performance of colwise verbs like `mutate_all()` is now back to
  where it was in `mutate_each()`.

* `funs()` has better handling of namespaced functions (#2089).

* Fix issue with `mutate_if()` and `summarise_if()` when a predicate
  function returns a vector of `FALSE` (#1989, #2009, #2011).

## Tidyeval

dplyr has a new approach to non-standard evaluation (NSE) called tidyeval.
It is described in detail in `vignette("programming")` but, in brief, gives you
the ability to interpolate values in contexts where dplyr usually works with expressions:

```{r}
my_var <- quo(homeworld)

starwars %>%
  group_by(!!my_var) %>%
  summarise_at(vars(height:mass), mean, na.rm = TRUE)
```

This means that the underscored version of each main verb is no longer needed,
and so these functions have been deprecated (but remain around for backward compatibility).

* `order_by()`, `top_n()`, `sample_n()` and `sample_frac()` now use
  tidyeval to capture their arguments by expression. This makes it
  possible to use unquoting idioms (see `vignette("programming")`) and
  fixes scoping issues (#2297).

* Most verbs taking dots now ignore the last argument if empty. This
  makes it easier to copy lines of code without having to worry about
  deleting trailing commas (#1039).

* [API] The new `.data` and `.env` environments can be used inside 
  all verbs that operate on data: `.data$column_name` accesses the column 
  `column_name`, whereas `.env$var` accesses the external variable `var`. 
  Columns or external variables named `.data` or `.env` are shadowed, use 
  `.data$...` and/or `.env$...` to access them.  (`.data` implements strict
  matching also for the `$` operator (#2591).)
  
    The `column()` and `global()` functions have been removed. They were never 
    documented officially. Use the new `.data` and `.env` environments instead.

* Expressions in verbs are now interpreted correctly in many cases that 
  failed before (e.g., use of `$`, `case_when()`, nonstandard evaluation, ...). 
  These expressions are now evaluated in a specially constructed temporary 
  environment that retrieves column data on demand with the help of the 
  `bindrcpp` package (#2190). This temporary environment poses restrictions on 
  assignments using `<-` inside verbs. To prevent leaking of broken bindings, 
  the temporary environment is cleared after the evaluation (#2435).

## Verbs

### Joins

* [API] `xxx_join.tbl_df(na_matches = "never")` treats all `NA` values as
  different from each other (and from any other value), so that they never
  match.  This corresponds to the behavior of joins for database sources,
  and of database joins in general.  To match `NA` values, pass
  `na_matches = "na"` to the join verbs; this is only supported for data frames.
  The default is `na_matches = "na"`, kept for the sake of compatibility
  to v0.5.0. It can be tweaked by calling
  `pkgconfig::set_config("dplyr::na_matches", "na")` (#2033).

* `common_by()` gets a better error message for unexpected inputs (#2091)

* Fix groups when joining grouped data frames with duplicate columns 
  (#2330, #2334, @davidkretch).

* One of the two join suffixes can now be an empty string, dplyr no longer 
  hangs (#2228, #2445).

* Anti- and semi-joins warn if factor levels are inconsistent (#2741).

* Warnings about join column inconsistencies now contain the column names
  (#2728).

### Select

* For selecting variables, the first selector decides if it's an inclusive 
  selection (i.e., the initial column list is empty), or an exclusive selection 
  (i.e., the initial column list contains all columns). This means that 
  `select(mtcars, contains("am"), contains("FOO"), contains("vs"))` now returns 
  again both `am` and `vs` columns like in dplyr 0.4.3 (#2275, #2289, @r2evans).

* Select helpers now throw an error if called when no variables have been 
  set (#2452)

* Helper functions in `select()` (and related verbs) are now evaluated
  in a context where column names do not exist (#2184).

* `select()` (and the internal function `select_vars()`) now support
  column names in addition to column positions. As a result,
  expressions like `select(mtcars, "cyl")` are now allowed.

### Other

* `recode()`, `case_when()` and `coalesce()` now support splicing of
  arguments with rlang's `!!!` operator.

* `count()` now preserves the grouping of its input (#2021).

* `distinct()` no longer duplicates variables (#2001).

* Empty `distinct()` with a grouped data frame works the same way as
  an empty `distinct()` on an ungrouped data frame, namely it uses all
  variables (#2476).

* `copy_to()` now returns it's output invisibly (since you're often just
   calling for the side-effect).

* `filter()` and `lag()` throw informative error if used with ts objects (#2219)

* `mutate()` recycles list columns of length 1 (#2171).

* `mutate()` gives better error message when attempting to add a non-vector
  column (#2319), or attempting to remove a column with `NULL` (#2187, #2439).

* `summarise()` now correctly evaluates newly created factors (#2217), and 
  can create ordered factors (#2200).

* Ungrouped `summarise()` uses summary variables correctly (#2404, #2453).

* Grouped `summarise()` no longer converts character `NA` to empty strings (#1839).

## Combining and comparing

* `all_equal()` now reports multiple problems as a character vector (#1819, #2442).

* `all_equal()` checks that factor levels are equal (#2440, #2442).

* `bind_rows()` and `bind_cols()` give an error for database tables (#2373).

* `bind_rows()` works correctly with `NULL` arguments and an `.id` argument
  (#2056), and also for zero-column data frames (#2175).

* Breaking change: `bind_rows()` and `combine()` are more strict when coercing. 
  Logical values are no longer coerced to integer and numeric. Date, POSIXct 
  and other integer or double-based classes are no longer coerced to integer or 
  double as there is chance of attributes or information being lost 
  (#2209, @zeehio).

* `bind_cols()` now calls `tibble::repair_names()` to ensure that all
  names are unique (#2248).

* `bind_cols()` handles empty argument list (#2048).

* `bind_cols()` better handles `NULL` inputs (#2303, #2443).

* `bind_rows()` explicitly rejects columns containing data frames
  (#2015, #2446).

* `bind_rows()` and `bind_cols()` now accept vectors. They are treated
  as rows by the former and columns by the latter. Rows require inner
  names like `c(col1 = 1, col2 = 2)`, while columns require outer
  names: `col1 = c(1, 2)`. Lists are still treated as data frames but
  can be spliced explicitly with `!!!`, e.g. `bind_rows(!!! x)` (#1676).

* `rbind_list()` and `rbind_all()` now call `.Deprecated()`, they will be removed
  in the next CRAN release. Please use `bind_rows()` instead.

* `combine()` accepts `NA` values (#2203, @zeehio)

* `combine()` and `bind_rows()` with character and factor types now always warn
  about the coercion to character (#2317, @zeehio)

* `combine()` and `bind_rows()` accept `difftime` objects.

* `mutate` coerces results from grouped dataframes accepting combinable data
  types (such as `integer` and `numeric`). (#1892, @zeehio)

## Vector functions

* `%in%` gets new hybrid handler (#126).

* `between()` returns NA if `left` or `right` is `NA` (fixes #2562).

* `case_when()` supports `NA` values (#2000, @tjmahr).

* `first()`, `last()`, and `nth()` have better default values for factor,
  Dates, POSIXct, and data frame inputs (#2029).

* Fixed segmentation faults in hybrid evaluation of `first()`, `last()`,
  `nth()`,  `lead()`, and `lag()`. These functions now always fall back to the R
  implementation if called with arguments that the hybrid evaluator cannot
  handle (#948, #1980).

* `n_distinct()` gets larger hash tables given slightly better performance (#977).

* `nth()` and `ntile()` are more careful about proper data types of their return values (#2306).

* `ntile()` ignores `NA` when computing group membership (#2564).

* `lag()` enforces integer `n` (#2162, @kevinushey).

* hybrid `min()` and `max()` now always return a `numeric` and work correctly 
  in edge cases (empty input, all `NA`, ...) (#2305, #2436).

* `min_rank("string")` no longer segfaults in hybrid evaluation (#2279, #2444).

* `recode()` can now recode a factor to other types (#2268)

* `recode()` gains `.dots` argument to support passing replacements as list 
  (#2110, @jlegewie).

## Other minor changes and bug fixes

* Many error messages are more helpful by referring to a column name or a
  position in the argument list (#2448).

* New `is_grouped_df()` alias to `is.grouped_df()`.

* `tbl_vars()` now has a `group_vars` argument set to `TRUE` by
  default. If `FALSE`, group variables are not returned.

* Fixed segmentation fault after calling `rename()` on an invalid grouped
  data frame (#2031).

* `rename_vars()` gains a `strict` argument to control if an
  error is thrown when you try and rename a variable that doesn't
  exist.

* Fixed undefined behavior for `slice()` on a zero-column data frame (#2490).

* Fixed very rare case of false match during join (#2515).

* Restricted workaround for `match()` to R 3.3.0. (#1858).

* dplyr now warns on load when the version of R or Rcpp during installation is
  different to the currently installed version (#2514).

* Fixed improper reuse of attributes when creating a list column in `summarise()`
  and perhaps `mutate()` (#2231).

* `mutate()` and `summarise()` always strip the `names` attribute from new
  or updated columns, even for ungrouped operations (#1689).

* Fixed rare error that could lead to a segmentation fault in
  `all_equal(ignore_col_order = FALSE)` (#2502).

* The "dim" and "dimnames" attributes are always stripped when copying a 
  vector (#1918, #2049).

* `grouped_df` and `rowwise` are registered officially as S3 classes.
  This makes them easier to use with S4 (#2276, @joranE, #2789).

* All operations that return tibbles now include the `"tbl"` class.
  This is important for correct printing with tibble 1.3.1 (#2789).

* Makeflags uses PKG_CPPFLAGS for defining preprocessor macros.

* astyle formatting for C++ code, tested but not changed as part of the tests 
  (#2086, #2103).

* Update RStudio project settings to install tests (#1952).

* Using `Rcpp::interfaces()` to register C callable interfaces, and registering all native exported functions via `R_registerRoutines()` and `useDynLib(.registration = TRUE)` (#2146).

* Formatting of grouped data frames now works by overriding the `tbl_sum()` generic instead of `print()`. This means that the output is more consistent with tibble, and that `format()` is now supported also for SQL sources (#2781).


# dplyr 0.5.0

## Breaking changes

### Existing functions

* `arrange()` once again ignores grouping (#1206).

* `distinct()` now only keeps the distinct variables. If you want to return
  all variables (using the first row for non-distinct values) use
  `.keep_all = TRUE` (#1110). For SQL sources, `.keep_all = FALSE` is
  implemented using `GROUP BY`, and `.keep_all = TRUE` raises an error
  (#1937, #1942, @krlmlr). (The default behaviour of using all variables
  when none are specified remains - this note only applies if you select
  some variables).

* The select helper functions `starts_with()`, `ends_with()` etc are now
  real exported functions. This means that you'll need to import those
  functions if you're using from a package where dplyr is not attached.
  i.e. `dplyr::select(mtcars, starts_with("m"))` used to work, but
  now you'll need `dplyr::select(mtcars, dplyr::starts_with("m"))`.

### Deprecated and defunct functions

* The long deprecated `chain()`, `chain_q()` and `%.%` have been removed.
  Please use `%>%` instead.

* `id()` has been deprecated. Please use `group_indices()` instead
  (#808).

* `rbind_all()` and `rbind_list()` are formally deprecated. Please use
  `bind_rows()` instead (#803).

* Outdated benchmarking demos have been removed (#1487).

* Code related to starting and signalling clusters has been moved out to
  [multidplyr](http://github.com/hadley/multidplyr).

## New functions

* `coalesce()` finds the first non-missing value from a set of vectors.
  (#1666, thanks to @krlmlr for initial implementation).

* `case_when()` is a general vectorised if + else if (#631).

* `if_else()` is a vectorised if statement: it's a stricter (type-safe),
  faster, and more predictable version of `ifelse()`. In SQL it is
  translated to a `CASE` statement.

* `na_if()` makes it easy to replace a certain value with an `NA` (#1707).
  In SQL it is translated to `NULL_IF`.

* `near(x, y)` is a helper for `abs(x - y) < tol` (#1607).

* `recode()` is vectorised equivalent to `switch()` (#1710).

* `union_all()` method. Maps to `UNION ALL` for SQL sources, `bind_rows()`
  for data frames/tbl\_dfs, and `combine()` for vectors (#1045).

* A new family of functions replace `summarise_each()` and
  `mutate_each()` (which will thus be deprecated in a future release).
  `summarise_all()` and `mutate_all()` apply a function to all columns
  while `summarise_at()` and `mutate_at()` operate on a subset of
  columns. These columuns are selected with either a character vector
  of columns names, a numeric vector of column positions, or a column
  specification with `select()` semantics generated by the new
  `columns()` helper. In addition, `summarise_if()` and `mutate_if()`
  take a predicate function or a logical vector (these verbs currently
  require local sources). All these functions can now take ordinary
  functions instead of a list of functions generated by `funs()`
  (though this is only useful for local sources). (#1845, @lionel-)

* `select_if()` lets you select columns with a predicate function.
  Only compatible with local sources. (#497, #1569, @lionel-)

## Local backends

### dtplyr

All data table related code has been separated out in to a new dtplyr package. This decouples the development of the data.table interface from the development of the dplyr package. If both data.table and dplyr are loaded, you'll get a message reminding you to load dtplyr.

### Tibble

Functions related to the creation and coercion of `tbl_df`s, now live in their own package: [tibble](http://blog.rstudio.org/2016/03/24/tibble-1-0-0/). See `vignette("tibble")` for more details.

* `$` and `[[` methods that never do partial matching (#1504), and throw
  an error if the variable does not exist.

* `all_equal()` allows to compare data frames ignoring row and column order,
  and optionally ignoring minor differences in type (e.g. int vs. double)
  (#821). The test handles the case where the df has 0 columns (#1506).
  The test fails fails when convert is `FALSE` and types don't match (#1484).
  
* `all_equal()` shows better error message when comparing raw values
  or when types are incompatible and `convert = TRUE` (#1820, @krlmlr).

* `add_row()` makes it easy to add a new row to data frame (#1021)

* `as_data_frame()` is now an S3 generic with methods for lists (the old
  `as_data_frame()`), data frames (trivial), and matrices (with efficient
  C++ implementation) (#876). It no longer strips subclasses.

* The internals of `data_frame()` and `as_data_frame()` have been aligned,
  so `as_data_frame()` will now automatically recycle length-1 vectors.
  Both functions give more informative error messages if you attempting to
  create an invalid data frame. You can no longer create a data frame with
  duplicated names (#820). Both check for `POSIXlt` columns, and tell you to
  use `POSIXct` instead (#813).

* `frame_data()` properly constructs rectangular tables (#1377, @kevinushey),
  and supports list-cols.

* `glimpse()` is now a generic. The default method dispatches to `str()`
  (#1325).  It now (invisibly) returns its first argument (#1570).

*  `lst()` and `lst_()` which create lists in the same way that
  `data_frame()` and `data_frame_()` create data frames (#1290).

* `print.tbl_df()` is considerably faster if you have very wide data frames.
  It will now also only list the first 100 additional variables not already
  on screen - control this with the new `n_extra` parameter to `print()`
  (#1161). When printing a grouped data frame the number of groups is now
  printed with thousands separators (#1398). The type of list columns
  is correctly printed (#1379)

* Package includes `setOldClass(c("tbl_df", "tbl", "data.frame"))` to help
  with S4 dispatch (#969).

* `tbl_df` automatically generates column names (#1606).

### tbl_cube

* new `as_data_frame.tbl_cube()` (#1563, @krlmlr).

* `tbl_cube`s are now constructed correctly from data frames, duplicate
  dimension values are detected, missing dimension values are filled
  with `NA`. The construction from data frames now guesses the measure
  variables by default, and allows specification of dimension and/or
  measure variables (#1568, @krlmlr).

* Swap order of `dim_names` and `met_name` arguments in `as.tbl_cube`
  (for `array`, `table` and `matrix`) for consistency with `tbl_cube` and
  `as.tbl_cube.data.frame`. Also, the `met_name` argument to
  `as.tbl_cube.table` now defaults to `"Freq"` for consistency with
  `as.data.frame.table` (@krlmlr, #1374).

## Remote backends

* `as_data_frame()` on SQL sources now returns all rows (#1752, #1821,
  @krlmlr).

* `compute()` gets new parameters `indexes` and `unique_indexes` that make
  it easier to add indexes (#1499, @krlmlr).

* `db_explain()` gains a default method for DBIConnections (#1177).

* The backend testing system has been improved. This lead to the removal of
  `temp_srcs()`. In the unlikely event that you were using this function,
  you can instead use `test_register_src()`, `test_load()`, and `test_frame()`.

* You can now use `right_join()` and `full_join()` with remote tables (#1172).

### SQLite

* `src_memdb()` is a session-local in-memory SQLite database.
  `memdb_frame()` works like `data_frame()`, but creates a new table in
  that database.

* `src_sqlite()` now uses a stricter quoting character, `` ` ``, instead of
  `"`. SQLite "helpfully" will convert `"x"` into a string if there is
  no identifier called x in the current scope (#1426).

* `src_sqlite()` throws errors if you try and use it with window functions
  (#907).

### SQL translation

* `filter.tbl_sql()` now puts parens around each argument (#934).

* Unary `-` is better translated (#1002).

* `escape.POSIXt()` method makes it easier to use date times. The date is
  rendered in ISO 8601 format in UTC, which should work in most databases
  (#857).

* `is.na()` gets a missing space (#1695).

* `if`, `is.na()`, and `is.null()` get extra parens to make precendence
  more clear (#1695).

* `pmin()` and `pmax()` are translated to `MIN()` and `MAX()` (#1711).

* Window functions:

    * Work on ungrouped data (#1061).

    * Warning if order is not set on cumulative window functions.

    * Multiple partitions or ordering variables in windowed functions no
      longer generate extra parentheses, so should work for more databases
      (#1060)

### Internals

This version includes an almost total rewrite of how dplyr verbs are translated into SQL. Previously, I used a rather ad-hoc approach, which tried to guess when a new subquery was needed. Unfortunately this approach was fraught with bugs, so in this version I've implemented a much richer internal data model. Now there is a three step process:

1.  When applied to a `tbl_lazy`, each dplyr verb captures its inputs
    and stores in a `op` (short for operation) object.

2.  `sql_build()` iterates through the operations building to build up an
    object that represents a SQL query. These objects are convenient for
    testing as they are lists, and are backend agnostics.

3.  `sql_render()` iterates through the queries and generates the SQL,
    using generics (like `sql_select()`) that can vary based on the
    backend.

In the short-term, this increased abstraction is likely to lead to some minor performance decreases, but the chance of dplyr generating correct SQL is much much higher. In the long-term, these abstractions will make it possible to write a query optimiser/compiler in dplyr, which would make it possible to generate much more succinct queries.

If you have written a dplyr backend, you'll need to make some minor changes to your package:

* `sql_join()` has been considerably simplified - it is now only responsible
  for generating the join query, not for generating the intermediate selects
  that rename the variable. Similarly for `sql_semi_join()`. If you've
  provided new methods in your backend, you'll need to rewrite.

* `select_query()` gains a distinct argument which is used for generating
  queries for `distinct()`. It loses the `offset` argument which was
  never used (and hence never tested). 

* `src_translate_env()` has been replaced by `sql_translate_env()` which
  should have methods for the connection object.

There were two other tweaks to the exported API, but these are less likely to affect anyone.

* `translate_sql()` and `partial_eval()` got a new API: now use connection +
  variable names, rather than a `tbl`. This makes testing considerably easier.
  `translate_sql_q()` has been renamed to `translate_sql_()`.

* Also note that the sql generation generics now have a default method, instead
  methods for DBIConnection and NULL.

## Minor improvements and bug fixes

### Single table verbs

* Avoiding segfaults in presence of `raw` columns (#1803, #1817, @krlmlr).

* `arrange()` fails gracefully on list columns (#1489) and matrices
  (#1870, #1945, @krlmlr).

* `count()` now adds additional grouping variables, rather than overriding
  existing (#1703). `tally()` and `count()` can now count a variable
  called `n` (#1633). Weighted `count()`/`tally()` ignore `NA`s (#1145).

* The progress bar in `do()` is now updated at most 20 times per second,
  avoiding uneccessary redraws (#1734, @mkuhn)

* `distinct()` doesn't crash when given a 0-column data frame (#1437).

* `filter()` throws an error if you supply an named arguments. This is usually
  a type: `filter(df, x = 1)` instead of `filter(df, x == 1)` (#1529).

* `summarise()` correctly coerces factors with different levels (#1678),
  handles min/max of already summarised variable (#1622), and
  supports data frames as columns (#1425).

* `select()` now informs you that it adds missing grouping variables
  (#1511). It works even if the grouping variable has a non-syntactic name
  (#1138). Negating a failed match (e.g. `select(mtcars, -contains("x"))`)
  returns all columns, instead of no columns (#1176)

    The `select()` helpers are now exported and have their own
    documentation (#1410). `one_of()` gives a useful error message if
    variables names are not found in data frame (#1407).

* The naming behaviour of `summarise_each()` and `mutate_each()` has been
  tweaked so that you can force inclusion of both the function and the
  variable name: `summarise_each(mtcars, funs(mean = mean), everything())`
  (#442).

* `mutate()` handles factors that are all `NA` (#1645), or have different
  levels in different groups (#1414). It disambiguates `NA` and `NaN` (#1448),
  and silently promotes groups that only contain `NA` (#1463). It deep copies
  data in list columns (#1643), and correctly fails on incompatible columns
  (#1641). `mutate()` on a grouped data no longer droups grouping attributes
  (#1120). `rowwise()` mutate gives expected results (#1381).

* `one_of()` tolerates unknown variables in `vars`, but warns (#1848, @jennybc).

* `print.grouped_df()` passes on `...` to `print()` (#1893).

* `slice()` correctly handles grouped attributes (#1405).

* `ungroup()` generic gains `...` (#922).

### Dual table verbs
* `bind_cols()` matches the behaviour of `bind_rows()` and ignores `NULL`
  inputs (#1148). It also handles `POSIXct`s with integer base type (#1402).

* `bind_rows()` handles 0-length named lists (#1515), promotes factors to
  characters (#1538), and warns when binding factor and character (#1485).
  bind_rows()` is more flexible in the way it can accept data frames,
  lists, list of data frames, and list of lists (#1389).

* `bind_rows()` rejects `POSIXlt` columns (#1875, @krlmlr).

* Both `bind_cols()` and `bind_rows()` infer classes and grouping information
  from the first data frame (#1692).

* `rbind()` and `cbind()` get `grouped_df()` methods that make it harder to       
  create corrupt data frames (#1385). You should still prefer `bind_rows()`
  and `bind_cols()`.

* Joins now use correct class when joining on `POSIXct` columns
  (#1582, @joel23888), and consider time zones (#819). Joins handle a `by`
  that is empty (#1496), or has duplicates (#1192). Suffixes grow progressively
  to avoid creating repeated column names (#1460).  Joins on string columns
  should be substantially faster (#1386). Extra attributes are ok if they are
  identical (#1636). Joins work correct when factor levels not equal
  (#1712, #1559). Anti- and semi-joins give correct result when by variable
  is a factor (#1571), but warn if factor levels are inconsistent (#2741).
  A clear error message is given for joins where an
  explicit `by` contains unavailable columns (#1928, #1932).
  Warnings about join column inconsistencies now contain the column names
  (#2728).

* `inner_join()`, `left_join()`, `right_join()`, and `full_join()` gain a
  `suffix` argument which allows you to control what suffix duplicated variable
  names recieve (#1296).

* Set operations (`intersect()`, `union()` etc) respect coercion rules
  (#799). `setdiff()` handles factors with `NA` levels (#1526).

* There were a number of fixes to enable joining of data frames that don't 
  have the same encoding of column names (#1513), including working around 
  bug 16885 regarding `match()` in R 3.3.0 (#1806, #1810,
  @krlmlr).

### Vector functions

* `combine()` silently drops `NULL` inputs (#1596).

* Hybrid `cummean()` is more stable against floating point errors (#1387).

* Hybrid `lead()` and `lag()` received a considerable overhaul. They are more
  careful about more complicated expressions (#1588), and falls back more
  readily to pure R evaluation (#1411). They behave correctly in `summarise()`
  (#1434). and handle default values for string columns.

* Hybrid `min()` and `max()` handle empty sets (#1481).

* `n_distinct()` uses multiple arguments for data frames (#1084), falls back to R
  evaluation when needed (#1657), reverting decision made in (#567).
  Passing no arguments gives an error (#1957, #1959, @krlmlr).

* `nth()` now supports negative indices to select from end, e.g. `nth(x, -2)`
  selects the 2nd value from the end of `x` (#1584).

* `top_n()` can now also select bottom `n` values by passing a negative value
  to `n` (#1008, #1352).

* Hybrid evaluation leaves formulas untouched (#1447).


# dplyr 0.4.3

## Improved encoding support

Until now, dplyr's support for non-UTF8 encodings has been rather shaky. This release brings a number of improvement to fix these problems: it's probably not perfect, but should be a lot better than the previously version. This includes fixes to `arrange()` (#1280), `bind_rows()` (#1265), `distinct()` (#1179), and joins (#1315). `print.tbl_df()` also recieved a fix for strings with invalid encodings (#851).

## Other minor improvements and bug fixes

* `frame_data()` provides a means for constructing `data_frame`s using
  a simple row-wise language. (#1358, @kevinushey)

* `all.equal()` no longer runs all outputs together (#1130).

* `as_data_frame()` gives better error message with NA column names (#1101).

* `[.tbl_df` is more careful about subsetting column names (#1245).

* `arrange()` and `mutate()` work on empty data frames (#1142).

* `arrange()`, `filter()`, `slice()`, and `summarise()` preserve data frame
  meta attributes (#1064).

* `bind_rows()` and `bind_cols()` accept lists (#1104): during initial data
  cleaning you no longer need to convert lists to data frames, but can
  instead feed them to `bind_rows()` directly.

* `bind_rows()` gains a `.id` argument. When supplied, it creates a
  new column that gives the name of each data frame (#1337, @lionel-).

* `bind_rows()` respects the `ordered` attribute of factors (#1112), and
  does better at comparing `POSIXct`s (#1125). The `tz` attribute is ignored
  when determining if two `POSIXct` vectors are comparable. If the `tz` of
  all inputs is the same, it's used, otherwise its set to `UTC`.

* `data_frame()` always produces a `tbl_df` (#1151, @kevinushey)

* `filter(x, TRUE, TRUE)` now just returns `x` (#1210),
  it doesn't internally modify the first argument (#971), and
  it now works with rowwise data (#1099). It once again works with
  data tables (#906).

* `glimpse()` also prints out the number of variables in addition to the number
  of observations (@ilarischeinin, #988).

* Joins handles matrix columns better (#1230), and can join `Date` objects
  with heterogenous representations (some `Date`s are integers, while other
  are numeric). This also improves `all.equal()` (#1204).

* Fixed `percent_rank()` and `cume_dist()` so that missing values no longer
  affect denominator (#1132).

* `print.tbl_df()` now displays the class for all variables, not just those
  that don't fit on the screen (#1276). It also displays duplicated column
  names correctly (#1159).

* `print.grouped_df()` now tells you how many groups there are.

* `mutate()` can set to `NULL` the first column (used to segfault, #1329) and
  it better protects intermediary results (avoiding random segfaults, #1231).

* `mutate()` on grouped data handles the special case where for the first few
  groups, the result consists of a `logical` vector with only `NA`. This can
  happen when the condition of an `ifelse` is an all `NA` logical vector (#958).

* `mutate.rowwise_df()` handles factors (#886) and correctly handles
  0-row inputs (#1300).

* `n_distinct()` gains an `na_rm` argument (#1052).

* The `Progress` bar used by `do()` now respects global option
  `dplyr.show_progress` (default is TRUE) so you can turn it off globally
  (@jimhester #1264, #1226).

* `summarise()` handles expressions that returning heterogenous outputs,
  e.g. `median()`, which that sometimes returns an integer, and other times a
  numeric (#893).

* `slice()` silently drops columns corresponding to an NA (#1235).

* `ungroup.rowwise_df()` gives a `tbl_df` (#936).

* More explicit duplicated column name error message (#996).

* When "," is already being used as the decimal point (`getOption("OutDec")`),
  use "." as the thousands separator when printing out formatted numbers
  (@ilarischeinin, #988).

## Databases

* `db_query_fields.SQLiteConnection` uses `build_sql` rather than `paste0`
  (#926, @NikNakk)

* Improved handling of `log()` (#1330).

* `n_distinct(x)` is translated to `COUNT(DISTINCT(x))` (@skparkes, #873).

* `print(n = Inf)` now works for remote sources (#1310).

## Hybrid evaluation

* Hybrid evaluation does not take place for objects with a class (#1237).

* Improved `$` handling (#1134).

* Simplified code for `lead()` and `lag()` and make sure they work properly on
  factors (#955). Both repsect the `default` argument (#915).

* `mutate` can set to `NULL` the first column (used to segfault, #1329).

* `filter` on grouped data handles indices correctly (#880).  

* `sum()` issues a warning about integer overflow (#1108).

# dplyr 0.4.2

This is a minor release containing fixes for a number of crashes and issues identified by R CMD CHECK. There is one new "feature": dplyr no longer complains about unrecognised attributes, and instead just copies them over to the output.

* `lag()` and `lead()` for grouped data were confused about indices and therefore
  produced wrong results (#925, #937). `lag()` once again overrides `lag()`
  instead of just the default method `lag.default()`. This is necesary due to
  changes in R CMD check. To use the lag function provided by another package,
  use `pkg::lag`.

* Fixed a number of memory issues identified by valgrind.

* Improved performance when working with large number of columns (#879).

* Lists-cols that contain data frames now print a slightly nicer summary
  (#1147)

* Set operations give more useful error message on incompatible data frames
  (#903).

* `all.equal()` gives the correct result when `ignore_row_order` is `TRUE`
  (#1065) and `all.equal()` correctly handles character missing values (#1095).

* `bind_cols()` always produces a `tbl_df` (#779).

* `bind_rows()` gains a test for a form of data frame corruption (#1074).

* `bind_rows()` and `summarise()` now handles complex columns (#933).

* Workaround for using the constructor of `DataFrame` on an unprotected object
  (#998)

* Improved performance when working with large number of columns (#879).

# dplyr 0.4.1

* Don't assume that RPostgreSQL is available.

# dplyr 0.4.0

## New features

* `add_rownames()` turns row names into an explicit variable (#639).

* `as_data_frame()` efficiently coerces a list into a data frame (#749).

* `bind_rows()` and `bind_cols()` efficiently bind a list of data frames by
  row or column. `combine()` applies the same coercion rules to vectors
  (it works like `c()` or `unlist()` but is consistent with the `bind_rows()`
  rules).

* `right_join()` (include all rows in `y`, and matching rows in `x`) and
  `full_join()` (include all rows in `x` and `y`) complete the family of
  mutating joins (#96).

* `group_indices()` computes a unique integer id for each group (#771). It
  can be called on a grouped_df without any arguments or on a data frame
  with same arguments as `group_by()`.

## New vignettes

* `vignette("data_frames")` describes dplyr functions that make it easier
  and faster to create and coerce data frames. It subsumes the old `memory`
  vignette.

* `vignette("two-table")` describes how two-table verbs work in dplyr.

## Minor improvements

* `data_frame()` (and `as_data_frame()` & `tbl_df()`) now explicitly
  forbid columns that are data frames or matrices (#775). All columns
  must be either a 1d atomic vector or a 1d list.

* `do()` uses lazyeval to correctly evaluate its arguments in the correct
  environment (#744), and new `do_()` is the SE equivalent of `do()` (#718).
  You can modify grouped data in place: this is probably a bad idea but it's
  sometimes convenient (#737). `do()` on grouped data tables now passes in all
  columns (not all columns except grouping vars) (#735, thanks to @kismsu).
  `do()` with database tables no longer potentially includes grouping
  variables twice (#673). Finally, `do()` gives more consistent outputs when
  there are no rows or no groups (#625).

* `first()` and `last()` preserve factors, dates and times (#509).

* Overhaul of single table verbs for data.table backend. They now all use
  a consistent (and simpler) code base. This ensures that (e.g.) `n()`
  now works in all verbs (#579).

* In `*_join()`, you can now name only those variables that are different between
  the two tables, e.g. `inner_join(x, y, c("a", "b", "c" = "d"))` (#682).
  If non-join colums are the same, dplyr will add `.x` and `.y`
  suffixes to distinguish the source (#655).

* `mutate()` handles complex vectors (#436) and forbids `POSIXlt` results
  (instead of crashing) (#670).

* `select()` now implements a more sophisticated algorithm so if you're
  doing multiples includes and excludes with and without names, you're more
  likely to get what you expect (#644). You'll also get a better error
  message if you supply an input that doesn't resolve to an integer
  column position (#643).

* Printing has recieved a number of small tweaks. All `print()` method methods
  invisibly return their input so you can interleave `print()` statements into a
  pipeline to see interim results. `print()` will column names of 0 row data
  frames (#652), and will never print more 20 rows (i.e.
  `options(dplyr.print_max)` is now 20), not 100 (#710). Row names are no
  never printed since no dplyr method is guaranteed to preserve them (#669).

    `glimpse()` prints the number of observations (#692)

    `type_sum()` gains a data frame method.

* `summarise()` handles list output columns (#832)

* `slice()` works for data tables (#717). Documentation clarifies that
  slice can't work with relational databases, and the examples show
  how to achieve the same results using `filter()` (#720).

* dplyr now requires RSQLite >= 1.0. This shouldn't affect your code
  in any way (except that RSQLite now doesn't need to be attached) but does
  simplify the internals (#622).

* Functions that need to combine multiple results into a single column
  (e.g. `join()`, `bind_rows()` and `summarise()`) are more careful about
  coercion.

    Joining factors with the same levels in the same order preserves the
    original levels (#675). Joining factors with non-identical levels
    generates a warning and coerces to character (#684). Joining a character
    to a factor (or vice versa) generates a warning and coerces to character.
    Avoid these warnings by ensuring your data is compatible before joining.

    `rbind_list()` will throw an error if you attempt to combine an integer and
    factor (#751). `rbind()`ing a column full of `NA`s is allowed and just
    collects the appropriate missing value for the column type being collected
    (#493).

    `summarise()` is more careful about `NA`, e.g. the decision on the result
    type will be delayed until the first non NA value is returned (#599).
    It will complain about loss of precision coercions, which can happen for
    expressions that return integers for some groups and a doubles for others
    (#599).

* A number of functions gained new or improved hybrid handlers: `first()`,
  `last()`, `nth()` (#626), `lead()` & `lag()` (#683), `%in%` (#126). That means
  when you use these functions in a dplyr verb, we handle them in C++, rather
  than calling back to R, and hence improving performance.

    Hybrid `min_rank()` correctly handles `NaN` values (#726). Hybrid
    implementation of `nth()` falls back to R evaluation when `n` is not
    a length one integer or numeric, e.g. when it's an expression (#734).

    Hybrid `dense_rank()`, `min_rank()`, `cume_dist()`, `ntile()`, `row_number()`
    and `percent_rank()` now preserve NAs (#774)

* `filter` returns its input when it has no rows or no columns (#782).

* Join functions keep attributes (e.g. time zone information) from the
  left argument for `POSIXct` and `Date` objects (#819), and only
  only warn once about each incompatibility (#798).

## Bug fixes

* `[.tbl_df` correctly computes row names for 0-column data frames, avoiding
  problems with xtable (#656). `[.grouped_df` will silently drop grouping
  if you don't include the grouping columns (#733).

* `data_frame()` now acts correctly if the first argument is a vector to be
  recycled. (#680 thanks @jimhester)

* `filter.data.table()` works if the table has a variable called "V1" (#615).

* `*_join()` keeps columns in original order (#684).
  Joining a factor to a character vector doesn't segfault (#688).
  `*_join` functions can now deal with multiple encodings (#769),
  and correctly name results (#855).

* `*_join.data.table()` works when data.table isn't attached (#786).

* `group_by()` on a data table preserves original order of the rows (#623).
  `group_by()` supports variables with more than 39 characters thanks to
  a fix in lazyeval (#705). It gives meaninful error message when a variable
  is not found in the data frame (#716).

* `grouped_df()` requires `vars` to be a list of symbols (#665).

* `min(.,na.rm = TRUE)` works with `Date`s built on numeric vectors (#755).

* `rename_()` generic gets missing `.dots` argument (#708).

* `row_number()`, `min_rank()`, `percent_rank()`, `dense_rank()`, `ntile()` and
  `cume_dist()` handle data frames with 0 rows (#762). They all preserve
  missing values (#774). `row_number()` doesn't segfault when giving an external
  variable with the wrong number of variables (#781).

* `group_indices` handles the edge case when there are no variables (#867).

* Removed bogus `NAs introduced by coercion to integer range` on 32-bit Windows (#2708).

# dplyr 0.3.0.1

* Fixed problem with test script on Windows.

# dplyr 0.3

## New functions

* `between()` vector function efficiently determines if numeric values fall
  in a range, and is translated to special form for SQL (#503).

* `count()` makes it even easier to do (weighted) counts (#358).

* `data_frame()` by @kevinushey is a nicer way of creating data frames.
  It never coerces column types (no more `stringsAsFactors = FALSE`!),
  never munges column names, and never adds row names. You can use previously
  defined columns to compute new columns (#376).

* `distinct()` returns distinct (unique) rows of a tbl (#97). Supply
  additional variables to return the first row for each unique combination
  of variables.

* Set operations, `intersect()`, `union()` and `setdiff()` now have methods
  for data frames, data tables and SQL database tables (#93). They pass their
  arguments down to the base functions, which will ensure they raise errors if
  you pass in two many arguments.

* Joins (e.g. `left_join()`, `inner_join()`, `semi_join()`, `anti_join()`)
  now allow you to join on different variables in `x` and `y` tables by
  supplying a named vector to `by`. For example, `by = c("a" = "b")` joins
  `x.a` to `y.b`.

* `n_groups()` function tells you how many groups in a tbl. It returns
  1 for ungrouped data. (#477)

* `transmute()` works like `mutate()` but drops all variables that you didn't
  explicitly refer to (#302).

* `rename()` makes it easy to rename variables - it works similarly to
  `select()` but it preserves columns that you didn't otherwise touch.

* `slice()` allows you to selecting rows by position (#226). It includes
  positive integers, drops negative integers and you can use expression like
  `n()`.

## Programming with dplyr (non-standard evaluation)

* You can now program with dplyr - every function that does non-standard
  evaluation (NSE) has a standard evaluation (SE) version ending in `_`.
  This is powered by the new lazyeval package which provides all the tools
  needed to implement NSE consistently and correctly.

* See `vignette("nse")` for full details.

* `regroup()` is deprecated. Please use the more flexible `group_by_()`
  instead.

* `summarise_each_q()` and `mutate_each_q()` are deprecated. Please use
  `summarise_each_()` and `mutate_each_()` instead.

* `funs_q` has been replaced with `funs_`.

## Removed and deprecated features

* `%.%` has been deprecated: please use `%>%` instead. `chain()` is
  defunct. (#518)

* `filter.numeric()` removed. Need to figure out how to reimplement with
  new lazy eval system.

* The `Progress` refclass is no longer exported to avoid conflicts with shiny.
  Instead use `progress_estimated()` (#535).

* `src_monetdb()` is now implemented in MonetDB.R, not dplyr.

* `show_sql()` and `explain_sql()` and matching global options `dplyr.show_sql`
  and `dplyr.explain_sql` have been removed. Instead use `show_query()` and
  `explain()`.

## Minor improvements and bug fixes

* Main verbs now have individual documentation pages (#519).

* `%>%` is simply re-exported from magrittr, instead of creating a local copy
  (#496, thanks to @jimhester)

* Examples now use `nycflights13` instead of `hflights` because it the variables
  have better names and there are a few interlinked tables (#562). `Lahman` and
  `nycflights13` are (once again) suggested packages. This means many examples
  will not work unless you explicitly install them with
  `install.packages(c("Lahman", "nycflights13"))` (#508). dplyr now depends on
  Lahman 3.0.1. A number of examples have been updated to reflect modified
  field names (#586).

* `do()` now displays the progress bar only when used in interactive prompts
  and not when knitting (#428, @jimhester).

* `glimpse()` now prints a trailing new line (#590).

* `group_by()` has more consistent behaviour when grouping by constants:
  it creates a new column with that value (#410). It renames grouping
  variables (#410). The first argument is now `.data` so you can create
  new groups with name x (#534).

* Now instead of overriding `lag()`, dplyr overrides `lag.default()`,
  which should avoid clobbering lag methods added by other packages.
  (#277).

* `mutate(data, a = NULL)` removes the variable `a` from the returned
  dataset (#462).

* `trunc_mat()` and hence `print.tbl_df()` and friends gets a `width` argument
  to control the deafult output width. Set `options(dplyr.width = Inf)` to
  always show all columns (#589).

* `select()` gains `one_of()` selector: this allows you to select variables
  provided by a character vector (#396). It fails immediately if you give an
  empty pattern to `starts_with()`,  `ends_with()`, `contains()` or `matches()`
  (#481, @leondutoit). Fixed buglet in `select()` so that you can now create
  variables called `val` (#564).

* Switched from RC to R6.

* `tally()` and `top_n()` work consistently: neither accidentally
  evaluates the the `wt` param. (#426, @mnel)

* `rename` handles grouped data (#640).

## Minor improvements and bug fixes by backend

### Databases

* Correct SQL generation for `paste()` when used with the collapse parameter
  targeting a Postgres database. (@rbdixon, #1357)

* The db backend system has been completely overhauled in order to make
  it possible to add backends in other packages, and to support a much
  wider range of databases. See `vignette("new-sql-backend")` for instruction
  on how to create your own (#568).

* `src_mysql()` gains a method for `explain()`.

* When `mutate()` creates a new variable that uses a window function,
  automatically wrap the result in a subquery (#484).

* Correct SQL generation for `first()` and `last()` (#531).

* `order_by()` now works in conjunction with window functions in databases
  that support them.

### Data frames/`tbl_df`

* All verbs now understand how to work with `difftime()` (#390) and
  `AsIs` (#453) objects. They all check that colnames are unique (#483), and
  are more robust when columns are not present (#348, #569, #600).

* Hybrid evaluation bugs fixed:

    * Call substitution stopped too early when a sub expression contained a
      `$` (#502).

    * Handle `::` and `:::` (#412).

    * `cumany()` and `cumall()` properly handle `NA` (#408).

    * `nth()` now correctly preserve the class when using dates, times and
      factors (#509).

    * no longer substitutes within `order_by()` because `order_by()` needs to do
      its own NSE (#169).

* `[.tbl_df` always returns a tbl_df (i.e. `drop = FALSE` is the default)
  (#587, #610). `[.grouped_df` preserves important output attributes (#398).

* `arrange()` keeps the grouping structure of grouped data (#491, #605),
  and preserves input classes (#563).

* `contains()` accidentally matched regular expressions, now it passes
  `fixed = TRUE` to `grep()` (#608).

* `filter()` asserts all variables are white listed (#566).

* `mutate()` makes a `rowwise_df` when given a `rowwise_df` (#463).

* `rbind_all()` creates `tbl_df` objects instead of raw `data.frame`s.

* If `select()` doesn't match any variables, it returns a 0-column data frame,
  instead of the original (#498). It no longer fails when if some columns
  are not named (#492)

* `sample_n()` and `sample_frac()` methods for data.frames exported.
  (#405, @alyst)

* A grouped data frame may have 0 groups (#486). Grouped df objects
  gain some basic validity checking, which should prevent some crashes
  related to corrupt `grouped_df` objects made by `rbind()` (#606).

* More coherence when joining columns of compatible but different types,
  e.g. when joining a character vector and a factor (#455),
  or a numeric and integer (#450)

* `mutate()` works for on zero-row grouped data frame, and
  with list columns (#555).

* `LazySubset` was confused about input data size (#452).

* Internal `n_distinct()` is stricter about it's inputs: it requires one symbol
  which must be from the data frame (#567).

* `rbind_*()` handle data frames with 0 rows (#597). They fill character
  vector columns with `NA` instead of blanks (#595).  They work with
  list columns (#463).

* Improved handling of encoding for column names (#636).

* Improved handling of hybrid evaluation re $ and @ (#645).

### Data tables

* Fix major omission in `tbl_dt()` and `grouped_dt()` methods - I was
  accidentally doing a deep copy on every result :(

* `summarise()` and `group_by()` now retain over-allocation when working with
  data.tables (#475, @arunsrinivasan).

* joining two data.tables now correctly dispatches to data table methods,
  and result is a data table (#470)

### Cubes

* `summarise.tbl_cube()` works with single grouping variable (#480).

# dplyr 0.2

## Piping

dplyr now imports `%>%` from magrittr (#330). I recommend that you use this instead of `%.%` because it is easier to type (since you can hold down the shift key) and is more flexible. With you `%>%`, you can control which argument on the RHS recieves the LHS by using the pronoun `.`. This makes `%>%` more useful with base R functions because they don't always take the data frame as the first argument. For example you could pipe `mtcars` to `xtabs()` with:

    mtcars %>% xtabs( ~ cyl + vs, data = .)

Thanks to @smbache for the excellent magrittr package. dplyr only provides `%>%` from magrittr, but it contains many other useful functions. To use them, load `magrittr` explicitly: `library(magrittr)`. For more details, see `vignette("magrittr")`.

`%.%` will be deprecated in a future version of dplyr, but it won't happen for a while. I've also deprecated `chain()` to encourage a single style of dplyr usage: please use `%>%` instead.

## Do

`do()` has been completely overhauled. There are now two ways to use it, either with multiple named arguments or a single unnamed arguments. `group_by()` + `do()` is equivalent to `plyr::dlply`, except it always returns a data frame.

If you use named arguments, each argument becomes a list-variable in the output. A list-variable can contain any arbitrary R object so it's particularly well suited for storing models.

    library(dplyr)
    models <- mtcars %>% group_by(cyl) %>% do(lm = lm(mpg ~ wt, data = .))
    models %>% summarise(rsq = summary(lm)$r.squared)

If you use an unnamed argument, the result should be a data frame. This allows you to apply arbitrary functions to each group.

    mtcars %>% group_by(cyl) %>% do(head(., 1))

Note the use of the `.` pronoun to refer to the data in the current group.

`do()` also has an automatic progress bar. It appears if the computation takes longer than 5 seconds and lets you know (approximately) how much longer the job will take to complete.

## New verbs

dplyr 0.2 adds three new verbs:

* `glimpse()` makes it possible to see all the columns in a tbl,
  displaying as much data for each variable as can be fit on a single line.

* `sample_n()` randomly samples a fixed number of rows from a tbl;
  `sample_frac()` randomly samples a fixed fraction of rows. Only works
  for local data frames and data tables (#202).

* `summarise_each()` and `mutate_each()` make it easy to apply one or more
  functions to multiple columns in a tbl (#178).

## Minor improvements

* If you load plyr after dplyr, you'll get a message suggesting that you
  load plyr first (#347).

* `as.tbl_cube()` gains a method for matrices (#359, @paulstaab)

* `compute()` gains `temporary` argument so you can control whether the
  results are temporary or permanent (#382, @cpsievert)

* `group_by()` now defaults to `add = FALSE` so that it sets the grouping
  variables rather than adding to the existing list. I think this is how
  most people expected `group_by` to work anyway, so it's unlikely to
  cause problems (#385).

* Support for [MonetDB](http://www.monetdb.org) tables with `src_monetdb()`
  (#8, thanks to @hannesmuehleisen).

* New vignettes:

    * `memory` vignette which discusses how dplyr minimises memory usage
      for local data frames (#198).

    *  `new-sql-backend` vignette which discusses how to add a new
       SQL backend/source to dplyr.

* `changes()` output more clearly distinguishes which columns were added or
  deleted.

* `explain()` is now generic.

* dplyr is more careful when setting the keys of data tables, so it never
  accidentally modifies an object that it doesn't own. It also avoids
  unnecessary key setting which negatively affected performance.
  (#193, #255).

* `print()` methods for `tbl_df`, `tbl_dt` and `tbl_sql` gain `n` argument to
  control the number of rows printed (#362). They also works better when you have
  columns containing lists of complex objects.

* `row_number()` can be called without arguments, in which case it returns
  the same as `1:n()` (#303).

* `"comment"` attribute is allowed (white listed) as well as names (#346).

* hybrid versions of `min`, `max`, `mean`, `var`, `sd` and `sum`
  handle the `na.rm` argument (#168). This should yield substantial
  performance improvements for those functions.

* Special case for call to `arrange()` on a grouped data frame with no arguments. (#369)  

## Bug fixes

* Code adapted to Rcpp > 0.11.1

* internal `DataDots` class protects against missing variables in verbs (#314),
  including the case where `...` is missing. (#338)

* `all.equal.data.frame` from base is no longer bypassed. we now have
  `all.equal.tbl_df` and `all.equal.tbl_dt` methods (#332).

* `arrange()` correctly handles NA in numeric vectors (#331) and 0 row
  data frames (#289).

* `copy_to.src_mysql()` now works on windows (#323)

* `*_join()` doesn't reorder column names (#324).

* `rbind_all()` is stricter and only accepts list of data frames (#288)

* `rbind_*` propagates time zone information for `POSIXct` columns (#298).

* `rbind_*` is less strict about type promotion. The numeric `Collecter` allows
  collection of integer and logical vectors. The integer `Collecter` also collects
  logical values (#321).

* internal `sum` correctly handles integer (under/over)flow (#308).

* `summarise()` checks consistency of outputs (#300) and drops `names`
  attribute of output columns (#357).

* join functions throw error instead of crashing when there are no common
  variables between the data frames, and also give a better error message when
  only one data frame has a by variable (#371).

* `top_n()` returns `n` rows instead of `n - 1` (@leondutoit, #367).

* SQL translation always evaluates subsetting operators (`$`, `[`, `[[`)
  locally. (#318).

* `select()` now renames variables in remote sql tbls (#317) and  
  implicitly adds grouping variables (#170).

* internal `grouped_df_impl` function errors if there are no variables to group by (#398).

* `n_distinct` did not treat NA correctly in the numeric case #384.

* Some compiler warnings triggered by -Wall or -pedantic have been eliminated.

* `group_by` only creates one group for NA (#401).

* Hybrid evaluator did not evaluate expression in correct environment (#403).

# dplyr 0.1.3

## Bug fixes

* `select()` actually renames columns in a data table (#284).

* `rbind_all()` and `rbind_list()` now handle missing values in factors (#279).

* SQL joins now work better if names duplicated in both x and y tables (#310).

* Builds against Rcpp 0.11.1

* `select()` correctly works with the vars attribute (#309).

* Internal code is stricter when deciding if a data frame is grouped (#308):
  this avoids a number of situations which previously causedd .

* More data frame joins work with missing values in keys (#306).

# dplyr 0.1.2

## New features

* `select()` is substantially more powerful. You can use named arguments to
  rename existing variables, and new functions `starts_with()`, `ends_with()`,
  `contains()`, `matches()` and `num_range()` to select variables based on
  their names. It now also makes a shallow copy, substantially reducing its
  memory impact (#158, #172, #192, #232).

* `summarize()` added as alias for `summarise()` for people from countries
  that don't don't spell things correctly ;) (#245)

## Bug fixes

* `filter()` now fails when given anything other than a logical vector, and
  correctly handles missing values (#249). `filter.numeric()` proxies
  `stats::filter()` so you can continue to use `filter()` function with
  numeric inputs (#264).

* `summarise()` correctly uses newly created variables (#259).

* `mutate()` correctly propagates attributes (#265) and `mutate.data.frame()`
  correctly mutates the same variable repeatedly (#243).

* `lead()` and `lag()` preserve attributes, so they now work with
  dates, times and factors (#166).

* `n()` never accepts arguments (#223).

* `row_number()` gives correct results (#227).

* `rbind_all()` silently ignores data frames with 0 rows or 0 columns (#274).

* `group_by()` orders the result (#242). It also checks that columns
  are of supported types (#233, #276).

* The hybrid evaluator did not handle some expressions correctly, for
  example in `if(n() > 5) 1 else 2` the subexpression `n()` was not
  substituted correctly. It also correctly processes `$` (#278).

* `arrange()` checks that all columns are of supported types (#266). It also
  handles list columns (#282).

* Working towards Solaris compatibility.

* Benchmarking vignette temporarily disabled due to microbenchmark
  problems reported by BDR.

# dplyr 0.1.1

## Improvements

* new `location()` and `changes()` functions which provide more information
  about how data frames are stored in memory so that you can see what
  gets copied.

* renamed `explain_tbl()` to `explain()` (#182).

* `tally()` gains `sort` argument to sort output so highest counts
  come first (#173).

* `ungroup.grouped_df()`, `tbl_df()`, `as.data.frame.tbl_df()` now only
  make shallow copies of their inputs (#191).

* The `benchmark-baseball` vignette now contains fairer (including grouping
  times) comparisons with `data.table`. (#222)

## Bug fixes

* `filter()` (#221) and `summarise()` (#194) correctly propagate attributes.

* `summarise()` throws an error when asked to summarise an unknown variable
  instead of crashing (#208).

* `group_by()` handles factors with missing values (#183).

* `filter()` handles scalar results (#217) and better handles scoping, e.g.
  `filter(., variable)` where `variable` is defined in the function that calls
  `filter`. It also handles `T` and `F` as aliases to `TRUE` and `FALSE`
  if there are no `T` or `F` variables in the data or in the scope.

* `select.grouped_df` fails when the grouping variables are not included
  in the selected variables (#170)

* `all.equal.data.frame()` handles a corner case where the data frame has
  `NULL` names (#217)

* `mutate()` gives informative error message on unsupported types (#179)

* dplyr source package no longer includes pandas benchmark, reducing
  download size from 2.8 MB to 0.5 MB.
