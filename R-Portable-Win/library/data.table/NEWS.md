
### Changes in v1.10.4  (on CRAN 01 Feb 2017)

#### BUG FIXES

1. The new specialized `nanotime` writer in `fwrite()` type punned using `*(long long *)&REAL(column)[i]` which, strictly, is undefined behavour under C standards. It passed a plethora of tests on linux (gcc 5.4 and clang 3.8), win-builder and 6 out 10 CRAN flavours using gcc. But failed (wrong data written) with the newest version of clang (3.9.1) as used by CRAN on the failing flavors, and solaris-sparc. Replaced with the union method and added a grep to CRAN_Release.cmd.


### Changes in v1.10.2  (on CRAN 31 Jan 2017)

#### NEW FEATURES

1. When `j` is a symbol prefixed with `..` it will be looked up in calling scope and its value taken to be column names or numbers.
   ```R
     myCols = c("colA","colB")
     DT[, myCols, with=FALSE]
     DT[, ..myCols]              # same
   ```
   When you see the `..` prefix think _one-level-up_ like the directory `..` in all operating systems meaning the parent directory. In future the `..` prefix could be made to work on all symbols apearing anywhere inside `DT[...]`. It is intended to be a convenient way to protect your code from accidentally picking up a column name. Similar to how `x.` and `i.` prefixes (analogous to SQL table aliases) can already be used to disambiguate the same column name present in both `x` and `i`. A symbol prefix rather than a `..()` _function_ will be easier for us to optimize internally and more convenient if you have many variables in calling scope that you wish to use in your expressions safely. This feature was first raised in 2012 and long wished for, [#633](https://github.com/Rdatatable/data.table/issues/633). It is experimental.

2. When `fread()` or `print()` see `integer64` columns are present, `bit64`'s namespace is now automatically loaded for convenience.

3. `fwrite()` now supports the new [`nanotime`](https://cran.r-project.org/package=nanotime) type by Dirk Eddelbuettel, [#1982](https://github.com/Rdatatable/data.table/issues/1982). Aside: `data.table` already automatically supported `nanotime` in grouping and joining operations via longstanding support of its underlying `integer64` type.

4. `indices()` gains a new argument `vectors`, default `FALSE`. This strsplits the index names by `__` for you, [#1589](https://github.com/Rdatatable/data.table/issues/1589).
   ```R
     DT = data.table(A=1:3, B=6:4)
     setindex(DT, B)
     setindex(DT, B, A)
     indices(DT)
     [1] "B"    "B__A"
     indices(DT, vectors=TRUE)
     [[1]]
     [1] "B"
     [[2]]
     [1] "B" "A"
   ```

#### BUG FIXES

1. Some long-standing potential instability has been discovered and resolved many thanks to a detailed report from Bill Dunlap and Michael Sannella. At C level any call of the form `setAttrib(x, install(), allocVector())` can be unstable in any R package. Despite `setAttrib()` PROTECTing its inputs, the 3rd argument (`allocVector`) can be executed first only for its result to to be released by `install()`'s potential GC before reaching `setAttrib`'s PROTECTion of its inputs. Fixed by either PROTECTing or pre-`install()`ing. Added to CRAN_Release.cmd procedures: i) `grep`s to prevent usage of this idiom in future and ii) running data.table's test suite with `gctorture(TRUE)`.

2. A new potential instability introduced in the last release (v1.10.0) in GForce optimized grouping has been fixed by reverting one change from malloc to R_alloc. Thanks again to Michael Sannella for the detailed report.

3. `fwrite()` could write floating point values incorrectly, [#1968](https://github.com/Rdatatable/data.table/issues/1968). A thread-local variable was incorrectly thread-global. This variable's usage lifetime is only a few clock cycles so it needed large data and many threads for several threads to overlap their usage of it and cause the problem. Many thanks to @mgahan and @jmosser for finding and reporting.

#### NOTES

1. `fwrite()`'s `..turbo` option has been removed as the warning message warned. If you've found a problem, please [report it](https://github.com/Rdatatable/data.table/issues).

2. No known issues have arisen due to `DT[,1]` and `DT[,c("colA","colB")]` now returning columns as introduced in v1.9.8. However, as we've moved forward by setting `options('datatable.WhenJisSymbolThenCallingScope'=TRUE)` introduced then too, it has become clear a better solution is needed. All 340 CRAN and Bioconductor packages that use data.table have been checked with this option on. 331 lines would need to be changed in 59 packages. Their usage is elegant, correct and recommended, though. Examples are `DT[1, encoding]` in quanteda and `DT[winner=="first", freq]` in xgboost. These are looking up the columns `encoding` and `freq` respectively and returning them as vectors. But if, for some reason, those columns are removed from `DT` and `encoding` or `freq` are still variables in calling scope, their values in calling scope would be returned. Which cannot be what was intended and could lead to silent bugs. That was the risk we were trying to avoid. <br>
`options('datatable.WhenJisSymbolThenCallingScope')` is now removed. A migration timeline is no longer needed. The new strategy needs no code changes and has no breakage. It was proposed and discussed in point 2 [here](https://github.com/Rdatatable/data.table/issues/1188#issuecomment-127824969), as follows.<br>
When `j` is a symbol (as in the quanteda and xgboost examples above) it will continue to be looked up as a column name and returned as a vector, as has always been the case.  If it's not a column name however, it is now a helpful error explaining that data.table is different to data.frame and what to do instead (use `..` prefix or `with=FALSE`).  The old behaviour of returning the symbol's value in calling scope can never have been useful to anybody and therefore not depended on. Just as the `DT[,1]` change could be made in v1.9.8, this change can be made now. This change increases robustness with no downside. Rerunning all 340 CRAN and Bioconductor package checks reveal 2 packages throwing the new error: partools and simcausal. Their maintainers have been informed that there is a likely bug on those lines due to data.table's (now remedied) weakness. This is exactly what we wanted to reveal and improve.

3. As before, and as we can see is in common use in CRAN and Bioconductor packages using data.table, `DT[,myCols,with=FALSE]` continues to lookup `myCols` in calling scope and take its value as column names or numbers.  You can move to the new experimental convenience feature `DT[, ..myCols]` if you wish at leisure.


### Changes in v1.10.0  (on CRAN 3 Dec 2016)

#### BUG FIXES

1. `fwrite(..., quote='auto')` already quoted a field if it contained a `sep` or `\n`, or `sep2[2]` when `list` columns are present. Now it also quotes a field if it contains a double quote (`"`) as documented, [#1925](https://github.com/Rdatatable/data.table/issues/1925). Thanks to Aki Matsuo for reporting. Tests added. The `qmethod` tests did test escaping embedded double quotes, but only when `sep` or `\n` was present in the field as well to trigger the quoting of the field.

2. Fixed 3 test failures on Solaris only, [#1934](https://github.com/Rdatatable/data.table/issues/1934). Two were on both sparc and x86 and related to a `tzone` attribute difference between `as.POSIXct` and `as.POSIXlt` even when passed the default `tz=""`. The third was on sparc only: a minor rounding issue in `fwrite()` of 1e-305.

3. Regression crash fixed when 0's occur at the end of a non-empty subset of an empty table, [#1937](https://github.com/Rdatatable/data.table/issues/1937). Thanks Arun for tracking down. Tests added. For example, subsetting the empty `DT=data.table(a=character())` with `DT[c(1,0)]` should return a 1 row result with one `NA` since 1 is past the end of `nrow(DT)==0`, the same result as `DT[1]`.

4. Fixed newly reported crash that also occurred in old v1.9.6 when `by=.EACHI`, `nomatch=0`, the first item in `i` has no match AND `j` has a function call that is passed a key column, [#1933](https://github.com/Rdatatable/data.table/issues/1933). Many thanks to Reino Bruner for finding and reporting with a reproducible example. Tests added.

5. Fixed `fread()` error occurring for a subset of Windows users: `showProgress is not type integer but type 'logical'.`, [#1944](https://github.com/Rdatatable/data.table/issues/1944) and [#1111](https://github.com/Rdatatable/data.table/issues/1111). Our tests cover this usage (it is just default usage), pass on AppVeyor (Windows), win-builder (Windows) and CRAN's Windows so perhaps it only occurs on a specific and different version of Windows to all those. Thanks to @demydd for reporting. Fixed by using strictly `logical` type at R level and `Rboolean` at C level, consistently throughout.

6. Combining `on=` (new in v1.9.6) with `by=` or `keyby=` gave incorrect results, [#1943](https://github.com/Rdatatable/data.table/issues/1943). Many thanks to Henrik-P for the detailed and reproducible report. Tests added.

7. New function `rleidv` was ignoring its `cols` argument, [#1942](https://github.com/Rdatatable/data.table/issues/1942). Thanks Josh O'Brien for reporting. Tests added.

#### NOTES

1. It seems OpenMP is not available on CRAN's Mac platform; NOTEs appeared in [CRAN checks](https://cran.r-project.org/web/checks/check_results_data.table.html) for v1.9.8. Moved `Rprintf` from `init.c` to `packageStartupMessage` to avoid the NOTE as requested urgently by Professor Ripley. Also fixed the bad grammar of the message: 'single threaded' now 'single-threaded'. If you have a Mac and run macOS or OS X on it (I run Ubuntu on mine) please contact CRAN maintainers and/or Apple if you'd like CRAN's Mac binary to support OpenMP. Otherwise, please follow [these instructions for OpenMP on Mac](https://github.com/Rdatatable/data.table/wiki/Installation) which people have reported success with.

2. Just to state explicitly: data.table does not now depend on or require OpenMP. If you don't have it (as on CRAN's Mac it appears but not in general on Mac) then data.table should build, run and pass all tests just fine.

3. There are now 5,910 raw tests as reported by `test.data.table()`. Tests cover 91% of the 4k lines of R and 89% of the 7k lines of C. These stats are now known thanks to Jim Hester's [Covr](https://CRAN.R-project.org/package=covr) package and [Codecov.io](https://codecov.io/). If anyone is looking for something to help with, creating tests to hit the missed lines shown by clicking the `R` and `src` folders at the bottom [here](https://codecov.io/github/Rdatatable/data.table?branch=master) would be very much appreciated.

4. The FAQ vignette has been revised given the changes in v1.9.8. In particular, the very first FAQ.

5. With hindsight, the last release v1.9.8 should have been named v1.10.0 to convey it wasn't just a patch release from .6 to .8 owing to the 'potentially breaking changes' items. Thanks to @neomantic for correctly pointing out. The best we can do now is now bump to 1.10.0.


### Changes in v1.9.8  (on CRAN 25 Nov 2016)

#### POTENTIALLY BREAKING CHANGES

  1. By default all columns are now used by `unique()`, `duplicated()` and `uniqueN()` data.table methods, [#1284](https://github.com/Rdatatable/data.table/issues/1284) and [#1841](https://github.com/Rdatatable/data.table/issues/1841). To restore old behaviour: `options(datatable.old.unique.by.key=TRUE)`. In 1 year this option to restore the old default will be deprecated with warning. In 2 years the option will be removed. Please explicitly pass `by=key(DT)` for clarity. Only code that relies on the default is affected. 266 CRAN and Bioconductor packages using data.table were checked before release. 9 needed to change and were notified. Any lines of code without test coverage will have been missed by these checks. Any packages not on CRAN or Bioconductor were not checked.

  2. A new column is guaranteed with `:=` even when there are no matches or when its RHS is length 0 (e.g. `integer()`, `numeric()`) but not `NULL`. The NA column is created with the same type as the empty RHS. This is for consistency so that whether a new column is added or not does not depend on whether `i` matched to 1 or more rows or not. See [#759](https://github.com/Rdatatable/data.table/issues/759) for further details and examples.

  3. When `j` contains no unquoted variable names (whether column names or not), `with=` is now automatically set to `FALSE`. Thus, `DT[,1]`, `DT[,"someCol"]`, `DT[,c("colA","colB")]` and `DT[,100:109]` now work as we all expect them to; i.e., returning columns, [#1188](https://github.com/Rdatatable/data.table/issues/1188), [#1149](https://github.com/Rdatatable/data.table/issues/1149). Since there are no variable names there is no ambiguity as to what was intended. `DT[,colName1:colName2]` no longer needs `with=FALSE` either since that is also unambiguous. That is a single call to the `:` function so `with=TRUE` could make no sense, despite the presence of unquoted variable names. These changes can be made since nobody can be using the existing behaviour of returning back the literal `j` value since that can never be useful. This provides a new ability and should not break any existing code. Selecting a single column still returns a 1-column data.table (not a vector, unlike `data.frame` by default) for type consistency for code (e.g. within `DT[...][...]` chains) that can sometimes select several columns and sometime one, as has always been the case in data.table. In future, `DT[,myCols]` (i.e. a single variable name) will look for `myCols` in calling scope without needing to set `with=FALSE` too, just as a single symbol appearing in `i` does already. The new behaviour can be turned on now by setting the tersely named option: `options(datatable.WhenJisSymbolThenCallingScope=TRUE)`. The default is currently `FALSE` to give you time to change your code. In this future state, one way (i.e. `DT[,theColName]`) to select the column as a vector rather than a 1-column data.table will no longer work leaving the two other ways that have always worked remaining (since data.table is still just a `list` after all): `DT[["someCol"]]` and `DT$someCol`. Those base R methods are faster too (when iterated many times) by avoiding the small argument checking overhead inside the more flexible `DT[...]` syntax as has been highlighted in `example(data.table)` for many years. In the next release, `DT[,someCol]` will continue with old current behaviour but start to warn if the new option is not set. Then the default will change to TRUE to nudge you to move forward whilst still retaining a way for you to restore old behaviour for this feature only, whilst still allowing you to benefit from other new features of the latest release without changing your code. Then finally after an estimated 2 years from now, the option will be removed.

#### NEW FEATURES

  1. `fwrite()` - parallel .csv writer:
    * Thanks to Otto Seiskari for the initial pull request [#580](https://github.com/Rdatatable/data.table/issues/580) that provided C code, R wrapper, manual page and extensive tests.
    * From there Matt parallelized and specialized C functions for writing integer/numeric exactly matching `write.csv` between 2.225074e-308 and 1.797693e+308 to 15 significant figures, dates (between 0000-03-01 and 9999-12-31), times down to microseconds in POSIXct, automatic quoting, `bit64::integer64`, `row.names` and `sep2` for `list` columns where each cell can itself be a vector. See [this blog post](http://blog.h2o.ai/2016/04/fast-csv-writing-for-r/) for implementation details and benchmarks.
    * Accepts any `list` of same length vectors; e.g. `data.frame` and `data.table`.
    * Caught in development before release to CRAN: thanks to Francesco Grossetti for [#1725](https://github.com/Rdatatable/data.table/issues/1725) (NA handling), Torsten Betz for [#1847](https://github.com/Rdatatable/data.table/issues/1847) (rounding of 9.999999999999998) and @ambils for [#1903](https://github.com/Rdatatable/data.table/issues/1903) (> 1 million columns).
    * `fwrite` status was tracked here: [#1664](https://github.com/Rdatatable/data.table/issues/1664)

  2. `fread()`:
    * gains `quote` argument. `quote = ""` disables quoting altogether which reads each field *as is*, [#1367](https://github.com/Rdatatable/data.table/issues/1367). Thanks @manimal.
    * With [#1462](https://github.com/Rdatatable/data.table/issues/1462) fix, quotes are handled slightly better. Thanks  @Pascal for [posting on SO](http://stackoverflow.com/q/34144314/559784).
    * gains `blank.lines.skip` argument that continues reading by skipping empty lines. Default is `FALSE` for backwards compatibility, [#530](https://github.com/Rdatatable/data.table/issues/530). Thanks @DirkJonker. Also closes [#1575](https://github.com/Rdatatable/data.table/issues/1575).
    * gains `fill` argument with default `FALSE` for backwards compatibility. Closes [#536](https://github.com/Rdatatable/data.table/issues/536). Also, `fill=TRUE` prioritises maximum cols instead of longest run with identical columns when `fill=TRUE` which allows handle missing columns slightly more robustly, [#1573](https://github.com/Rdatatable/data.table/issues/1573).
    * gains `key` argument, [#590](https://github.com/Rdatatable/data.table/issues/590).
    * gains `file` argument which expects existing file on input, to ensure no shell commands will be executed when reading file. Closes [#1702](https://github.com/Rdatatable/data.table/issues/1702).
    * Column type guessing is improved by testing 100 rows at 10 points rather than 5 rows at 3 points. See point 3 of [convenience features of fread for small data](https://github.com/Rdatatable/data.table/wiki/Convenience-features-of-fread).

  3. Joins:
    * Non-equi (or conditional) joins are now possible using the familiar `on=` syntax. Possible binary operators include `>=`, `>`, `<=`, `<` and `==`. For e.g., `X[Y, on=.(a, b>b)]` looks for `X.a == Y.a` first and within those matching rows for rows where`X.b > Y.b`, [#1452](https://github.com/Rdatatable/data.table/issues/1452).
    * x's columns can be referred to in `j` using the prefix `x.` at all times. This is particularly useful when it is necessary to x's column that is *also a join column*, [#1615](https://github.com/Rdatatable/data.table/issues/1615). Also closes [#1705](https://github.com/Rdatatable/data.table/issues/1705) (thanks @dbetebenner) and [#1761](https://github.com/Rdatatable/data.table/issues/1761).
    * `on=.()` syntax is now posible, e.g., `X[Y, on=.(x==a, y==b)]`, [#1257](https://github.com/Rdatatable/data.table/issues/1257). Thanks @dselivanov.
    * Joins using `on=` accepts unnamed columns on ad hoc joins, e.g., X[.(5), on="b"] joins "b" from `X` to "V1" from `i`, partly closes [#1375](https://github.com/Rdatatable/data.table/issues/1375).
    * When joining with `on=`, `X[Y, on=c(A="A", b="c")]` can be now specified as `X[Y, on=c("A", b="c")]`, fully closes [#1375](https://github.com/Rdatatable/data.table/issues/1375).
    * `on=` joins now provides more friendly error messages when columns aren't found, [#1376](https://github.com/Rdatatable/data.table/issues/1376).
    * Joins (and binary search based subsets) using `on=` argument now reuses existing (secondary) indices, [#1439](https://github.com/Rdatatable/data.table/issues/1439). Thanks @jangorecki.

  4. `merge.data.table` by default also checks for common key columns between the two `data.table`s before resulting in error when `by` or `by.x, by.y` arguments are not provided, [#1517](https://github.com/Rdatatable/data.table/issues/1517). Thanks @DavidArenburg.

  5. Fast set operations `fsetdiff`, `fintersect`, `funion` and `fsetequal` for data.tables are now implemented, [#547](https://github.com/Rdatatable/data.table/issues/547).

  6. Added `setDTthreads()` and `getDTthreads()` to control the threads used in data.table functions that are now parallelized with OpenMP on all architectures including Windows (`fwrite()`, `fsort()` and subsetting). Extra code was required internally to ensure these control data.table only and not other packages using OpenMP. When data.table is used from the parallel package (e.g. `mclapply` as done by 3 CRAN and Bioconductor packages) data.table automatically switches down to one thread to avoid a [deadlock/hang](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58378) when OpenMP is used with fork(); [#1745](https://github.com/Rdatatable/data.table/issues/1745) and [#1727](https://github.com/Rdatatable/data.table/issues/1727). Thanks to Kontstantinos Tsardounis, Ramon Diaz-Uriarte and Jan Gorecki for testing before release and providing reproducible examples. After `parallel::mclapply` has finished, data.table reverts to the prior `getDTthreads()` state. Tests added which will therefore will run every day thanks to CRAN (limited to 2 threads on CRAN which is enough to test).

  7. `GForce` (See ?\`datatable-optimize\` for more):
    * `dt[, .N, by=cols]` is optimised internally as well, [#1251](https://github.com/Rdatatable/data.table/issues/1251).
    * is now also optimised for `median`. Partly addresses [#523](https://github.com/Rdatatable/data.table/issues/523). Check that issue for benchmarks.
    * GForce kicks in along with subsets in `i` as well, e.g., `DT[x > 2, mean(y), by=z]`. Partly addresses [#971](https://github.com/Rdatatable/data.table/issues/971).
    * GForce is optimised for `head(., 1)` and `tail(., 1)`, where `.` is a column name or `.SD`. Partly addresses [#523](https://github.com/Rdatatable/data.table/issues/523). Check the link for benchmarks.
    * GForce is optimised for length-1 subsets, e.g., `.SD[2]`, `col[2]`. Partly addresses [#523](https://github.com/Rdatatable/data.table/issues/523).
    * `var`, `sd` and `prod` are all GForce optimised for speed and memory. Partly addresses [#523](https://github.com/Rdatatable/data.table/issues/523). See that post for benchmarks.

  8. Reshaping:
    * `dcast.data.table` now allows `drop = c(FALSE, TRUE)` and `drop = c(TRUE, FALSE)`. The former only fills all missing combinations of formula LHS, where as the latter fills only all missing combinations of formula RHS. Thanks to Ananda Mahto for [this SO post](http://stackoverflow.com/q/34830908/559784) and to Jaap for filing [#1512](https://github.com/Rdatatable/data.table/issues/1512).
    * `melt.data.table` finds variables provided to `patterns()` when called from within user defined functions, [#1749](https://github.com/Rdatatable/data.table/issues/1749). Thanks to @kendonB for the report.

  9. We can now refer to the columns that are not mentioned in `.SD` / `.SDcols` in `j` as well. For example, `DT[, .(sum(v1), lapply(.SD, mean)), by=grp, .SDcols=v2:v3]` works as expected, [#495](https://github.com/Rdatatable/data.table/issues/495). Thanks to @MattWeller for report and to others for linking various SO posts to be updated. Also closes [#484](https://github.com/Rdatatable/data.table/issues/484).

  10. New functions `inrange()` and `%inrange%` are exported. It performs a range join making use of the recently implemented *non-equi* joins ([#1452](https://github.com/Rdatatable/data.table/issues/1452)) [#679](https://github.com/Rdatatable/data.table/issues/679). Also thanks to @DavidArenburg for [#1819](https://github.com/Rdatatable/data.table/issues/1819).

  11. `%between%` is vectorised which means we can now do: `DT[x %between% list(y,z)]` where `y` and `z` are vectors, [#534](https://github.com/Rdatatable/data.table/issues/534). Thanks @MicheleCarriero for filing the issue and the idea.

  12. Most common use case for `between()`, i.e., `lower` and `upper` are length=1, is now implemented in C and parallelised. This results in ~7-10x speed improvement on vectors of length >= 1e6.

  13. Row subset operations of data.table is now parallelised with OpenMP, [#1660](https://github.com/Rdatatable/data.table/issues/1660). See the linked issue page for a rough benchmark on speedup.

  14. `tstrsplit` gains argument `names`, [#1379](https://github.com/Rdatatable/data.table/issues/1379). A character vector of column names can be provided as well. Thanks @franknarf1.

  15. `tstrsplit` gains argument `keep` which corresponds to the indices of list elements to return from the transposed list.

  16. `rowid()` and `rowidv()` - convenience functions for generating a unique row ids within each group, are implemented. `rowid()` is particularly useful along with `dcast()`. See `?rowid` for more, [#1353](https://github.com/Rdatatable/data.table/issues/1353).

  17. `rleid()` gains `prefix` argument, similar to `rowid()`.

  18. `shift()` understands and operates on list-of-list inputs as well, [#1595](https://github.com/Rdatatable/data.table/issues/1595). Thanks to @enfascination and to @chris for [asking on SO](http://stackoverflow.com/q/38900293/559784).

  19. `uniqueN` gains `na.rm` argument, [#1455](https://github.com/Rdatatable/data.table/issues/1455).

  20. `first()` is now exported to return the first element of vectors, data.frames and data.tables.

  21. New `split.data.table` method. Faster, more flexible and consistent with data.frame method. Closes [#1389](https://github.com/Rdatatable/data.table/issues/1389). Now also properly preallocate columns, thanks @maverickg for reporting, closes [#1908](https://github.com/Rdatatable/data.table/issues/1908).

  22. `rbindlist` supports columns of type `complex`, [#1659](https://github.com/Rdatatable/data.table/issues/1659).

  23. Added `second` and `minute` extraction functions which, like extant `hour`/`yday`/`week`/etc, always return an integer, [#874](https://github.com/Rdatatable/data.table/issues/874). Also added ISO 8601-consistent weeks in `isoweek`, [#1765](https://github.com/Rdatatable/data.table/issues/1765). Thanks to @bthieurmel and @STATWORX for the FRs and @MichaelChirico for the PRs. 

  24. `setnames` accepts negative indices in `old` argument, [#1443](https://github.com/Rdatatable/data.table/issues/1443). Thanks @richierocks.

  25. `by` understands `colA:colB` syntax now, like `.SDcols` does, [#1395](https://github.com/Rdatatable/data.table/issues/1395). Thanks @franknarf1.

  26. `data.table()` function gains `stringsAsFactors` argument with default `FALSE`, [#643](https://github.com/Rdatatable/data.table/issues/643). Thanks to @jangorecki for reviving this issue.
  
  27. `print.data.table` now warns when `bit64` package isn't loaded but the `data.table` contains `integer64` columns, [#975](https://github.com/Rdatatable/data.table/issues/975). Thanks to @StephenMcInerney.

  28. New argument `print.class` for `print.data.table` allows for including column class under column names (as inspired by `tbl_df` in `dplyr`); default (adjustable via `"datatable.print.class"` option) is `FALSE`, the inherited behavior. Part of [#1523](https://github.com/Rdatatable/data.table/issues/1523); thanks to @MichaelChirico for the FR & PR.
  
  29. `all.equal.data.table` gains `check.attributes`, `ignore.col.order`, `ignore.row.order` and `tolerance` arguments.
  
  30. `keyby=` is now much faster by not doing not needed work; e.g. 25s down to 13s for a 1.5GB DT with 200m rows and 86m groups. With more groups or bigger data, larger speedup factors are possible. Please always use `keyby=` unless you really need `by=`. `by=` returns the groups in first appearance order and takes longer to do that. See [#1880](https://github.com/Rdatatable/data.table/issues/1880) for more info and please register your views there on changing the default.

#### BUG FIXES

  1. Now compiles and runs on IBM AIX gcc. Thanks to Vinh Nguyen for investigation and testing, [#1351](https://github.com/Rdatatable/data.table/issues/1351).

  2. `as.ITime(NA)` works as intended, [#1354](https://github.com/Rdatatable/data.table/issues/1354). Thanks @geneorama.

  3. `last()` dispatches `xts::last()` properly again, [#1347](https://github.com/Rdatatable/data.table/issues/1347). Thanks to @JoshuaUlrich for spotting and suggesting the fix.

  4. `merge.data.table` ignores names when `by` argument is a named vector, [#1352](https://github.com/Rdatatable/data.table/issues/1352). Thanks @sebastian-c.

  5. `melt.data.table` names `value` column correctly when `patterns()` of length=1 is provided to `measure.vars()`, [#1346](https://github.com/Rdatatable/data.table/issues/1346). Thanks @jaapwalhout.

  6. Fixed a rare case in `melt.data.table` not setting `variable` factor column properly when `na.rm=TRUE`, [#1359](https://github.com/Rdatatable/data.table/issues/1359). Thanks @mplatzer.

  7. `dt[i, .SD]` unlocks `.SD` and overallocates correctly now, [#1341](https://github.com/Rdatatable/data.table/issues/1341). Thanks @marc-outins.

  8. Querying a list column with `get()`, e.g., `dt[, get("c")]` is handled properly, [#1212](https://github.com/Rdatatable/data.table/issues/1212). Thanks @DavidArenburg.

  9. Grouping on empty data.table with list col in `j` works as expected, [#1207](https://github.com/Rdatatable/data.table/issues/1207). Thanks @jangorecki.

  10. Unnamed `by/keyby` expressions ensure now that the auto generated names are unique, [#1334](https://github.com/Rdatatable/data.table/issues/1334). Thanks @caneff.

  11. `melt` errors correctly when `id.vars` or `measure.vars` are negative values, [#1372](https://github.com/Rdatatable/data.table/issues/1372).

  12. `merge.data.table` always resets class to `c("data.table", "data.frame")` in result to be consistent with `merge.data.frame`, [#1378](https://github.com/Rdatatable/data.table/issues/1378). Thanks @ladida771.

  13. `fread` reads text input with empty newline but with just spaces properly, for e.g., fread('a,b\n1,2\n   '), [#1384](https://github.com/Rdatatable/data.table/issues/1384). Thanks to @ladida771.

  14. `fread` with `stringsAsFactors = TRUE` no longer produces factors with NA as a factor level, [#1408](https://github.com/Rdatatable/data.table/pull/1408). Thanks to @DexGroves.

  15. `test.data.table` no longer raises warning if suggested packages are not available. Thanks to @jangorecki for PR [#1403](https://github.com/Rdatatable/data.table/pull/1403). Closes [#1193](https://github.com/Rdatatable/data.table/issues/1193).

  16. `rleid()` does not affect attributes of input vector, [#1419](https://github.com/Rdatatable/data.table/issues/1419). Thanks @JanGorecki.

  17. `uniqueN()` now handles NULL properly, [#1429](https://github.com/Rdatatable/data.table/issues/1429). Thanks @JanGorecki.

  18. GForce `min` and `max` functions handle `NaN` correctly, [#1461](https://github.com/Rdatatable/data.table/issues/1461). Thanks to @LyssBucks for [asking on SO](http://stackoverflow.com/q/34081848/559784).

  19. Warnings on unable to detect column types from middle/last 5 lines are now moved to messages when `verbose=TRUE`. Closes [#1124](https://github.com/Rdatatable/data.table/issues/1124).

  20. `fread` converts columns to `factor` type when used along with `colClasses` argument, [#721](https://github.com/Rdatatable/data.table/issues/721). Thanks @AmyMikhail.

  21. Auto indexing handles logical subset of factor column using numeric value properly, [#1361](https://github.com/Rdatatable/data.table/issues/1361). Thanks @mplatzer.
  
  22. `as.data.table.xts` handles single row `xts` object properly, [#1484](https://github.com/Rdatatable/data.table/issues/1484). Thanks Michael Smith and @jangorecki.

  23. data.table now solves the issue of mixed encodings by comparing character columns with marked encodings under `UTF8` locale. This resolves issues [#66](https://github.com/Rdatatable/data.table/issues/66), [#69](https://github.com/Rdatatable/data.table/issues/69), [#469](https://github.com/Rdatatable/data.table/issues/469) and [#1293](https://github.com/Rdatatable/data.table/issues/1293). Thanks to @StefanFritsch and @Arthur.

  24. `rbindlist` handles `idcol` construction correctly and more efficiently now (logic moved to C), [#1432](https://github.com/Rdatatable/data.table/issues/1432). Thanks to @franknarf1 and @Chris.

  25. `CJ` sorts correctly when duplicates are found in input values and `sorted=TRUE`, [#1513](https://github.com/Rdatatable/data.table/issues/1513). Thanks @alexdeng.

  26. Auto indexing returns order of subset properly when input `data.table` is already sorted, [#1495](https://github.com/Rdatatable/data.table/issues/1495). Thanks @huashan for the nice reproducible example.

  27. `[.data.table` handles column subsets based on conditions that result in `NULL` as list elements correctly, [#1477](https://github.com/Rdatatable/data.table/issues/1477). Thanks @MichaelChirico. Also thanks to @Max from DSR for spotting a bug as a result of this fix. Now fixed.

  28. Providing the first argument to `.Call`, for e.g., `.Call("Crbindlist", ...)` seems to result in *"not resolved in current namespace"* error. A potential fix is to simply remove the quotes like so many other calls in data.table. Potentially fixes [#1467](https://github.com/Rdatatable/data.table/issues/1467). Thanks to @rBatt, @rsaporta and @damienchallet.

  29. `last` function will now properly redirect method if `xts` is not installed or not attached on search path. Closes [#1560](https://github.com/Rdatatable/data.table/issues/1560).

  30. `rbindlist` (and `rbind`) works as expected when `fill = TRUE` and the first element of input list doesn't have columns present in other elements of the list, [#1549](https://github.com/Rdatatable/data.table/issues/1549). Thanks to @alexkowa.

  31. `DT[, .(col), with=FALSE]` now returns a meaningful error message, [#1440](https://github.com/Rdatatable/data.table/issues/1440). Thanks to @VasilyA for [posting on SO](http://stackoverflow.com/q/33851742/559784).

  32. Fixed a segault in `forder` when elements of input list are not of same length, [#1531](https://github.com/Rdatatable/data.table/issues/1531). Thanks to @MichaelChirico.
  
  33. Reverted support of *list-of-lists* made in [#1224](https://github.com/Rdatatable/data.table/issues/1224) for consistency.

  34. Fixed an edge case in fread's `fill` argument, [#1503](https://github.com/Rdatatable/data.table/issues/1503). Thanks to @AnandaMahto.

  35. `copy()` overallocates properly when input is a *list-of-data.tables*, [#1476](https://github.com/Rdatatable/data.table/issues/1476). Thanks to @kimiylilammi and @AmitaiPerlstein for the report.

  36. `fread()` handles embedded double quotes in json fields as expected, [#1164](https://github.com/Rdatatable/data.table/issues/1164). Thanks @richardtessier.

  37. `as.data.table.list` handles list elements that are matrices/data.frames/data.tables properly, [#833](https://github.com/Rdatatable/data.table/issues/833). Thanks to @talexand.

  38. `data.table()`, `as.data.table()` and `[.data.table` warn on `POSIXlt` type column and converts to `POSIXct` type. `setDT()` errors when input is list and any column is of type `POSIXlt`, [#646](https://github.com/Rdatatable/data.table/issues/646). Thanks to @tdhock.

  39. `roll` argument handles -ve integer64 values correctly, [#1405](https://github.com/Rdatatable/data.table/issues/1405). Thanks @bryan4887. Also closes [#1650](https://github.com/Rdatatable/data.table/issues/1650), a segfault due to this fix. Thanks @Franknarf1 for filing the issue.

  40. Not join along with `mult="first"` and `mult="last"` is handled correctly, [#1571](https://github.com/Rdatatable/data.table/issues/1571).

  41. `by=.EACHI` works as expected along with `mult="first"` and `mult="last"`, [#1287](https://github.com/Rdatatable/data.table/issues/1287) and [#1271](https://github.com/Rdatatable/data.table/issues/1271).

  42. Subsets using logical expressions in `i` (e.g. `DT[someCol==3]`) no longer return an unintended all-NA row when `DT` consists of a single row and `someCol` contains `NA`, fixing [#1252](https://github.com/Rdatatable/data.table/issues/1252). Thanks to @sergiizaskaleta for reporting. If `i` is the reserved symbol `NA` though (i.e. `DT[NA]`) it is still auto converted to `DT[NA_integer_]` so that a single `NA` row is returned as almost surely expected. For consistency with past behaviour and to save confusion when comparing to `DT[c(NA,1)]`.

  43. `setattr()` catches logical input that points to R's global TRUE value and sets attributes on a copy instead, along with a warning, [#1281](https://github.com/Rdatatable/data.table/issues/1281). Thanks to @tdeenes.

  44. `fread` respects order of columns provided to argument `select` in result, and also warns if the column(s) provided is not present, [#1445](https://github.com/Rdatatable/data.table/issues/1445). 

  45. `DT[, .BY, by=x]` and other variants of adding a column using `.BY` are now handled correctly, [#1270](https://github.com/Rdatatable/data.table/issues/1270).

  46. `as.data.table.data.table()` method checks and restores over-allocation, [#473](https://github.com/Rdatatable/data.table/issues/473). 

  47. When the number of rows read are less than the number of guessed rows (or allocated), `fread()` doesn't warn anymore; rather restricts to a verbose message, [#1116](https://github.com/Rdatatable/data.table/issues/1116) and [#1239](https://github.com/Rdatatable/data.table/issues/1239). Thanks to @slowteetoe and @hshipper.

  48. `fread()` throws an error if input is a *directory*, [#989](https://github.com/Rdatatable/data.table/issues/989). Thanks @vlsi.

  49. UTF8 BOM header is excluded properly in `fread()`, [#1087](https://github.com/Rdatatable/data.table/issues/1087) and [#1465](https://github.com/Rdatatable/data.table/issues/1465). Thanks to @nigmastar and @MichaelChirico.

  50. Joins using `on=` retains (and discards) keys properly, [#1268](https://github.com/Rdatatable/data.table/issues/1268). Thanks @DouglasClark for [this SO post](http://stackoverflow.com/q/29918595/559784) that helped discover the issue.

  51. Secondary keys are properly removed when those columns get updated, [#1479](https://github.com/Rdatatable/data.table/issues/1479). Thanks @fabiangehring for the report, and also @ChristK for the MRE.
  
  52. `dcast` no longer errors on tables with duplicate columns that are unused in the call, [#1654](https://github.com/Rdatatable/data.table/issues/1654). Thanks @MichaelChirico for FR&PR.
  
  53. `fread` won't use `wget` for file:// input, [#1668](https://github.com/Rdatatable/data.table/issues/1668); thanks @MichaelChirico for FR&PR.

  54. `chmatch()` handles `nomatch = integer(0)` properly, [#1672](https://github.com/Rdatatable/data.table/issues/1672).
  
  55. `dimnames.data.table` no longer errors in `data.table`-unaware environments when a `data.table` has, e.g., been churned through some `dplyr` functions and acquired extra classes, [#1678](https://github.com/Rdatatable/data.table/issues/1678). Thanks Daisy Lee on SO for pointing this out and @MichaelChirico for the fix.

  55. `fread()` did not respect encoding on header column. Now fixed, [#1680](https://github.com/Rdatatable/data.table/issues/1680). Thanks @nachti.

  56. as.data.table's `data.table` method returns a copy as it should, [#1681](https://github.com/Rdatatable/data.table/issues/1681).

  57. Grouped update operations, e.g., `DT[, y := val, by=x]` where `val` is an unsupported type errors *without adding an unnamed column*, [#1676](https://github.com/Rdatatable/data.table/issues/1676). Thanks @wligtenberg.
  
  58. Handled use of `.I` in some `GForce` operations, [#1683](https://github.com/Rdatatable/data.table/issues/1683). Thanks gibbz00 from SO and @franknarf1 for reporting and @MichaelChirico for the PR.
  
  59. Added `+.IDate` method so that IDate + integer retains the `IDate` class, [#1528](https://github.com/Rdatatable/data.table/issues/1528); thanks @MichaelChirico for FR&PR. Similarly, added `-.IDate` so that IDate - IDate returns a plain integer rather than difftime.
  
  60. Radix ordering an integer vector containing INTMAX (2147483647) with decreasing=TRUE and na.last=FALSE failed ASAN check and seg faulted some systems. As reported for base R [#16925](https://bugs.r-project.org/bugzilla/show_bug.cgi?id=16925) whose new code comes from data.table. Simplified code, added test and proposed change to base R.

  60. Fixed test in `onAttach()` for when `Packaged` field is missing from `DESCRIPTION`, [#1706](https://github.com/Rdatatable/data.table/issues/1706); thanks @restonslacker for BR&PR.

  61. Adding missing factor levels are handled correctly in case of NAs. This affected a case of join+update operation as shown in [#1718](https://github.com/Rdatatable/data.table/issues/1718). Thanks to @daniellemccool.

  63. `foverlaps` now raise a meaningful error for duplicate column names, closes [#1730](https://github.com/Rdatatable/data.table/issues/1730). Thanks @rodonn.

  64. `na.omit` and `unique` methods now removes indices, closes [#1734](https://github.com/Rdatatable/data.table/issues/1734) and [#1760](https://github.com/Rdatatable/data.table/issues/1760). Thanks @m-dz and @fc9.30.

  65. List of data.tables with custom class is printed properly, [#1758](https://github.com/Rdatatable/data.table/issues/1758). Thanks @fruce-ki.

  66. `uniqueN` handles `na.rm=TRUE` argument on sorted inputs correctly, [#1771](https://github.com/Rdatatable/data.table/issues/1771). Thanks @ywhuofu.

  67. `get()` / `mget()` play nicely with `.SD` / `.SDcols`, [#1744](https://github.com/Rdatatable/data.table/issues/1753). Thanks @franknarf1.

  68. Joins on integer64 columns assigns `NA` correctly for no matching rows, [#1385](https://github.com/Rdatatable/data.table/issues/1385) and partly [#1459](https://github.com/Rdatatable/data.table/issues/1459). Thanks @dlithio and @abielr.
  
  69. Added `as.IDate.POSIXct` to prevent loss of timezone information, [#1498](https://github.com/Rdatatable/data.table/issues/1498). Thanks @dougedmunds for reporting and @MichaelChirico for the investigating & fixing.

  70. Retaining / removing keys is handled better when join is performed on non-key columns using `on` argument, [#1766](https://github.com/Rdatatable/data.table/issues/1766), [#1704](https://github.com/Rdatatable/data.table/issues/1704) and [#1823](https://github.com/Rdatatable/data.table/issues/1823). Thanks @mllg, @DavidArenburg and @mllg.

  71. `rbind` for data.tables now coerces non-list inputs to data.tables first before calling `rbindlist` so that binding list of data.tables and matrices work as expected to be consistent with base's rbind, [#1626](https://github.com/Rdatatable/data.table/issues/1626). Thanks @ems for reporting [here](http://stackoverflow.com/q/34426957/559784) on SO.

  72. Subassigning a factor column with `NA` works as expected. Also, the warning message on coercion is suppressed when RHS is singleton NA, [#1740](https://github.com/Rdatatable/data.table/issues/1740). Thanks @Zus.

  73. Joins on key columns in the presence of `on=` argument were slightly slower as it was unnecesarily running a check to ensure orderedness. This is now fixed, [#1825](https://github.com/Rdatatable/data.table/issues/1825). Thanks @sz-cgt. See that post for updated benchmark.
  
  74. `keyby=` now runs j in the order that the groups appear in the sorted result rather than first appearance order, [#606](https://github.com/Rdatatable/data.table/issues/606). This only makes a difference in very rare usage where j does something depending on an earlier group's result, perhaps by using `<<-`. If j is required to be run in first appearance order, then use `by=` whose behaviour is unchanged. Now we have this option. No existing tests affected. New tests added.
  
  75. `:=` verbose messages have been corrected and improved, [#1808](https://github.com/Rdatatable/data.table/issues/1808). Thanks to @franknarf1 for reproducible examples. Tests added.
  
  76. `DT[order(colA,na.last=NA)]` on a 2-row `DT` with one NA in `colA` and `na.last=NA` (meaning to remove NA) could return a randomly wrong result due to using uninitialized memory. Tests added.

  77. `fread` is now consistent to `read.table` on `colClasses` vector containing NA, also fixes mixed character and factor in `colClasses` vector. Closes [#1910](https://github.com/Rdatatable/data.table/issues/1910).

#### NOTES

  1. Updated error message on invalid joins to reflect the new `on=` syntax, [#1368](https://github.com/Rdatatable/data.table/issues/1368). Thanks @MichaelChirico.

  2. Fixed test 842 to account for `gdata::last` as well, [#1402](https://github.com/Rdatatable/data.table/issues/1402). Thanks @JanGorecki. 

  3. Fixed tests for `fread` 1378.2 and 1378.3 with `showProgress = FALSE`, closes [#1397](https://github.com/Rdatatable/data.table/issues/1397). Thanks to @JanGorecki for the PR.

  4. Worked around auto index error in `v1.9.6` to account for indices created with `v1.9.4`, [#1396](https://github.com/Rdatatable/data.table/issues/1396). Thanks @GRandom.

  5. `test.data.table` gets new argument `silent`, if set to TRUE then it will not raise exception but returns TRUE/FALSE based on the test results.

  6. `dim.data.table` is now implemented in C. Thanks to Andrey Riabushenko.

  7. Better fix to `fread`'s `check.names` argument using `make.names()`, [#1027](https://github.com/Rdatatable/data.table/issues/1027). Thanks to @DavidArenberg for spotting the issue with the previous fix using `make.unique()`.

  8. Fixed explanation of `skip` argument in `?fread` as spotted by @aushev, [#1425](https://github.com/Rdatatable/data.table/issues/1425).

  9. Run `install_name_tool` when building on OS X to ensure that the install name for datatable.so matches its filename. Fixes [#1144](https://github.com/Rdatatable/data.table/issues/1144). Thanks to @chenghlee for the PR.
  
  10. Updated documentation of `i` in `[.data.table` to emphasize the emergence of the new `on` option as an alternative to keyed joins, [#1488](https://github.com/Rdatatable/data.table/issues/1488). Thanks @MichaelChirico.
  
  11. Improvements and fixes to `?like` [#1515](https://github.com/Rdatatable/data.table/issues/1515). Thanks to @MichaelChirico for the PR.

  12. Several improvements and fixes to `?between` [#1521](https://github.com/Rdatatable/data.table/issues/1521). Thanks @MichaelChirico for the PR.

  13. `?shift.Rd` is fixed so that it does not get misconstrued to be in a time series sense. Closes [#1530](https://github.com/Rdatatable/data.table/issues/1530). Thanks to @pstoyanov.

  14. `?truelength.Rd` is fixed to reflect that over-allocation happens on data.tables loaded from disk only during column additions and not deletions, [#1536](https://github.com/Rdatatable/data.table/issues/1536). Thanks to @Roland and @rajkrpan.

  15. Added `\n` to message displayed in `melt.data.table` when duplicate names are found, [#1538](https://github.com/Rdatatable/data.table/issues/1538). Thanks @Franknarf1.

  16. `merge.data.table` will raise warning if any of data.tables to join has 0 columns. Closes [#597](https://github.com/Rdatatable/data.table/issues/597).

  17. Travis-CI will now automatically deploy package to drat repository hosted on [data.table@gh-pages](https://github.com/Rdatatable/data.table/tree/gh-pages) branch allowing to install latest devel from **source** via `install.packages("data.table", repos = "https://Rdatatable.github.io/data.table", type = "source")`. Closes [#1505](https://github.com/Rdatatable/data.table/issues/1505).

  18. Dependency on `chron` package has been changed to *suggested*. Closes [#1558](https://github.com/Rdatatable/data.table/issues/1558).

  19. Rnw vignettes are converted to Rmd. The *10 minute quick introduction* Rnw vignette has been removed, since almost all of its contents are consolidated into the new intro Rmd vignette. Thanks to @MichaelChirico and @jangorecki. 

  A *quick tour of data.table* HTML vignette is in the works in the spirit of the previous *10 minute quick intro* PDF guide.
  
  20. `row.names` argument to `print.data.table` can now be changed by default via `options("datatable.print.rownames")` (`TRUE` by default, the inherited standard), [#1097](https://github.com/Rdatatable/data.table/issues/1097). Thanks to @smcinerney for the suggestion and @MichaelChirico for the PR.
  
  21. `data.table`s with `NULL` or blank column names now print with blank column names, [#545](https://github.com/Rdatatable/data.table/issues/545), with minor revision to [#97](https://github.com/Rdatatable/data.table/issues/97). Thanks to @arunsrinivasan for reporting and @MichaelChirico for the PR.

  21. Added a FAQ entry for the new update to `:=` which sometimes doesn't print the result on the first time, [#939](https://github.com/Rdatatable/data.table/issues/939).

  22. Added `Note` section and examples to `?":="` for [#905](https://github.com/Rdatatable/data.table/issues/905).

  23. Fixed example in `?as.data.table.Rd`, [#1576](https://github.com/Rdatatable/data.table/issues/1576). Thanks @MichaelChirico.

  24. Fixed an edge case and added tests for columns of type `function`, [#518](https://github.com/Rdatatable/data.table/issues/518).
  
  25. `data.table`'s dependency has been moved forward from R 2.14.1 to R 3.0.0 (Apr 2013; i.e. 3 years old). We keep this dependency as old as possible for as long as possible as requested by users in managed environments. This bump allows `data.table` internals to use `paste0()` for the first time and also allows `fsort()` to accept vectors of length over 2 billion items. Before release to CRAN [our procedures](https://github.com/Rdatatable/data.table/blob/master/CRAN_Release.cmd) include running the test suite using this stated dependency.

  26. New option `options(datatable.use.index = TRUE)` (default) gives better control over usage of indices, when combined with `options(datatable.auto.index = FALSE)` it allows to use only indices created manually with `setindex` or `setindexv`. Closes [#1422](https://github.com/Rdatatable/data.table/issues/1422).
  
  27. The default number of over-allocated spare column pointer slots has been increased from 64 to 1024. The wasted memory overhead (if never used) is insignificant (0.008 MB). The advantage is that adding a large number of columns by reference using := or set() inside a loop will not now saturate as quickly and need reallocating. An alleviation to issue [#1633](https://github.com/Rdatatable/data.table/issues/1633). See `?alloc.col` for how to change this default yourself. Accordingly, the warning 'attempt to reduce allocation has been ignored' has been downgraded to a message in verbose mode. That typically occurs when using (not recommended) `[<-` and `$<-` methods on data.table. The `n=` argument to `alloc.col()` is now simply the number of spare column slots to over-allocate (on creation and reallocation). An expression using `ncol(DT)` is still ok but now deprecated.

  28. `?IDateTime` now makes clear that `wday`, `yday` and `month` are all 1- (not 0- as in `POSIXlt`) based, [#1658](https://github.com/Rdatatable/data.table/issues/1658); thanks @MichaelChirico.

  29. Fixed misleading documentation of `?uniqueN`, [#1746](https://github.com/Rdatatable/data.table/issues/1746). Thanks @SymbolixAU.

  30. `melt.data.table` restricts column names printed during warning messages to a maximum of five, [#1752](https://github.com/Rdatatable/data.table/issues/1752). Thanks @franknarf1.

  31. data.table's `setNumericRounding` has a default value of 0, which means ordering, joining and grouping of numeric values will be done at *full precision* by default. Handles [#1642](https://github.com/Rdatatable/data.table/issues/1642), [#1728](https://github.com/Rdatatable/data.table/issues/1728), [#1463](https://github.com/Rdatatable/data.table/issues/1463), [#485](https://github.com/Rdatatable/data.table/issues/485).

  32. Subsets with S4 objects in `i` are now faster, [#1438](https://github.com/Rdatatable/data.table/issues/1438). Thanks @DCEmilberg.

  33. When formula RHS is `.` and multiple functions are provided to `fun.aggregate`, column names of the cast data.table columns don't have the `.` in them, as it doesn't add any useful information really, [#1821](https://github.com/Rdatatable/data.table/issues/1821). Thanks @franknarf1.

  34. Function names are added to column names on cast data.tables only when more than one function is provided, [#1810](https://github.com/Rdatatable/data.table/issues/1810). Thanks @franknarf1.
  
  35. The option `datatable.old.bywithoutby` to restore the old default has been removed. As warned 2 years ago in release notes and explicitly warned about for 1 year when used. Search down this file for the text 'bywithoutby' to see previous notes on this topic.
  
  36. Using `with=FALSE` together with `:=` was deprecated in v1.9.4 released 2 years ago (Oct 2014). As warned then in release notes (see below) this is now a warning with advice to wrap the LHS of `:=` with parenthesis; e.g. `myCols=c("colA","colB"); DT[,(myCols):=1]`. In the next release, this warning message will be an error message.

  37. Using `nomatch` together with `:=` now warns that it is ignored.
  
  38. Logical `i` is no longer recycled. Instead an error message if it isn't either length 1 or `nrow(DT)`. This was hiding more bugs than was worth the rare convenience. The error message suggests to recycle explcitly; i.e. `DT[rep(<logical>,length=.N),...]`.
  
  39. Thanks to Mark Landry and Michael Chirico for finding and reporting a problem in dev before release with auto `with=FALSE` (item 3 above) when `j` starts with with `!` or `-`, [#1864](https://github.com/Rdatatable/data.table/issues/1864). Fixed and tests added.
  
  40. Following latest recommended testthat practices and to avoid a warning that it now issues, `inst/tests/testthat` has been moved to `/tests/testthat`. This means that testthat tests won't be installed for use by users by default and that `test_package("data.table")` will now fail with error `No matching test file in dir` and also a warning `Placing tests in inst/tests/ is deprecated. Please use tests/testthat/ instead`. (That warning seems to be misleading since we already have made that move.) To install testthat tests (and this applies to all packages using testthat not just data.table) you need to follow the [deleted instructions](https://github.com/hadley/testthat/commit/0a7d27bb9ea545be7da1a10e511962928d888302) in testthat's README; i.e., reinstall data.table either with `--install-tests` passed to `R CMD INSTALL` or `INSTALL_opts = "--install-tests"` passed to `install.packages()`. After that, `test_package("data.table")` will work. However, the main test suite of data.table (5,000+ tests) doesn't use testthat at all. Those tests are always installed so that `test.data.table()` can always be run by users at any time to confirm your installation on your platform is working correctly. Sometimes when supporting you, you may be asked to run `test.data.table()` and provide the output. Particularly now that data.table uses OpenMP. The file `/tests/tests.R` (which just calls `test.data.table()`) has been renamed to `/tests/main.R` to make this clearer to those looking at the GitHub repository and a comment has been added to `/tests/main.R` pointing to `/inst/tests/tests.Rraw` where those tests live. Some of these tests test data.table's compability with other packages and that is the reason those packages are listed in `DESCRIPTION:Suggests`. If you don't have some of those packages installed, `test.data.table()` will print output that it has skipped tests of compatibility with those packages. On CRAN all Suggests packages are available and data.table's tests of compatibility with them are tested by CRAN every day.
  
  41. The license field is changed from "GPL (>= 2)" to "GPL-3 | file LICENSE" due to independent communication from two users of data.table at Google. The lack of an explicit license file was preventing them from contributing patches to data.table. Further, Google lawyers require the full text of the license and not a URL to the license. Since this requirement appears to require the choice of one license, we opted for GPL-3 and we checked the GPL-3 is fine by Google for them to use and contribute to. Accordingly, data.table's LICENSE file is an exact duplicate copy of the canonical GPL-3.
  
  42. Thanks to @rrichmond for finding and reporting a regression in dev before release with `roll` not respecting fractions in type double, [#1904](https://github.com/Rdatatable/data.table/issues/1904). For example dates like `zoo::as.yearmon("2016-11")` which is stored as `double` value 2016.833. Fixed and test added.


### Changes in v1.9.6  (on CRAN 19 Sep 2015)

#### NEW FEATURES

  1. `fread`
      * passes `showProgress=FALSE` through to `download.file()` (as `quiet=TRUE`). Thanks to a pull request from Karl Broman and Richard Scriven for filing the issue, [#741](https://github.com/Rdatatable/data.table/issues/741).
      * accepts `dec=','` (and other non-'.' decimal separators), [#917](https://github.com/Rdatatable/data.table/issues/917). A new paragraph has been added to `?fread`. On Windows this should just-work. On Unix it may just-work but if not you will need to read the paragraph for an extra step. In case it somehow breaks `dec='.'`, this new feature can be turned off with `options(datatable.fread.dec.experiment=FALSE)`.
      * Implemented `stringsAsFactors` argument for `fread()`. When `TRUE`, character columns are converted to factors. Default is `FALSE`. Thanks to Artem Klevtsov for filing [#501](https://github.com/Rdatatable/data.table/issues/501), and to @hmi2015 for [this SO post](http://stackoverflow.com/q/31350209/559784).
      * gains `check.names` argument, with default value `FALSE`. When `TRUE`, it uses the base function `make.unique()` to ensure that the column names of the data.table read in are all unique. Thanks to David Arenburg for filing [#1027](https://github.com/Rdatatable/data.table/issues/1027).
      * gains `encoding` argument. Acceptable values are "unknown", "UTF-8" and "Latin-1" with default value of "unknown". Closes [#563](https://github.com/Rdatatable/data.table/issues/563). Thanks to @BenMarwick for the original report and to the many requests from others, and Q on SO.
      * gains `col.names` argument, and is similar to `base::read.table()`. Closes [#768](https://github.com/Rdatatable/data.table/issues/768). Thanks to @dardesta for filing the FR.

  2. `DT[column == value]` no longer recycles `value` except in the length 1 case (when it still uses DT's key or an automatic secondary key, as introduced in v1.9.4). If `length(value)==length(column)` then it works element-wise as standard in R. Otherwise, a length error is issued to avoid common user errors. `DT[column %in% values]` still uses DT's key (or an an automatic secondary key) as before.  Automatic indexing (i.e., optimization of `==` and `%in%`) may still be turned off with `options(datatable.auto.index=FALSE)`.

  3. `na.omit` method for data.table is rewritten in C, for speed. It's ~11x faster on bigger data; see examples under `?na.omit`. It also gains two additional arguments a) `cols` accepts column names (or numbers) on which to check for missing values. 2) `invert` when `TRUE` returns the rows with any missing values instead. Thanks to the suggestion and PR from @matthieugomez.

  4. New function `shift()` implements fast `lead/lag` of *vector*, *list*, *data.frames* or *data.tables*. It takes a `type` argument which can be either *"lag"* (default) or *"lead"*. It enables very convenient usage along with `:=` or `set()`. For example: `DT[, (cols) := shift(.SD, 1L), by=id]`. Please have a look at `?shift` for more info.

  5. `frank()` is now implemented. It's much faster than `base::rank` and does more. It accepts *vectors*, *lists* with all elements of equal lengths, *data.frames* and *data.tables*, and optionally takes a `cols` argument. In addition to implementing all the `ties.method` methods available from `base::rank`, it also implements *dense rank*. It is also capable of calculating ranks by ordering column(s) in ascending or descending order. See `?frank` for more. Closes [#760](https://github.com/Rdatatable/data.table/issues/760) and [#771](https://github.com/Rdatatable/data.table/issues/771)

  6. `rleid()`, a convenience function for generating a run-length type id column to be used in grouping operations is now implemented. Closes [#686](https://github.com/Rdatatable/data.table/issues/686). Check `?rleid` examples section for usage scenarios.
  
  7. Efficient convertion of `xts` to data.table. Closes [#882](https://github.com/Rdatatable/data.table/issues/882). Check examples in `?as.xts.data.table` and `?as.data.table.xts`. Thanks to @jangorecki for the PR.

  8. `rbindlist` gains `idcol` argument which can be used to generate an index column. If `idcol=TRUE`, the column is automatically named `.id`. Instead you can also provide a column name directly. If the input list has no names, indices are automatically generated. Closes [#591](https://github.com/Rdatatable/data.table/issues/591). Also thanks to @KevinUshey for filing [#356](https://github.com/Rdatatable/data.table/issues/356).

  9. A new helper function `uniqueN` is now implemented. It is equivalent to `length(unique(x))` but much faster. It handles `atomic vectors`, `lists`, `data.frames` and `data.tables` as input and returns the number of unique rows. Closes [#884](https://github.com/Rdatatable/data.table/issues/884). Gains by argument. Closes [#1080](https://github.com/Rdatatable/data.table/issues/1080). Closes [#1224](https://github.com/Rdatatable/data.table/issues/1224). Thanks to @DavidArenburg, @kevinmistry and @jangorecki. 

  10. Implemented `transpose()` to transpose a list and `tstrsplit` which is a wrapper for `transpose(strsplit(...))`. This is particularly useful in scenarios where a column has to be split and the resulting list has to be assigned to multiple columns. See `?transpose` and `?tstrsplit`, [#1025](https://github.com/Rdatatable/data.table/issues/1025) and [#1026](https://github.com/Rdatatable/data.table/issues/1026) for usage scenarios. Closes both #1025 and #1026 issues.
    * Implemented `type.convert` as suggested by Richard Scriven. Closes [#1094](https://github.com/Rdatatable/data.table/issues/1094).

  11. `melt.data.table` 
      * can now melt into multiple columns by providing a list of columns to `measure.vars` argument. Closes [#828](https://github.com/Rdatatable/data.table/issues/828). Thanks to Ananda Mahto for the extended email discussions and ideas on generating the `variable` column.
      * also retains attributes wherever possible. Closes [#702](https://github.com/Rdatatable/data.table/issues/702) and [#993](https://github.com/Rdatatable/data.table/issues/993). Thanks to @richierocks for the report.
      * Added `patterns.Rd`. Closes [#1294](https://github.com/Rdatatable/data.table/issues/1294). Thanks to @MichaelChirico.

  12. `.SDcols`
      * understands `!` now, i.e., `DT[, .SD, .SDcols=!"a"]` now works, and is equivalent to `DT[, .SD, .SDcols = -c("a")]`. Closes [#1066](https://github.com/Rdatatable/data.table/issues/1066). 
      * accepts logical vectors as well. If length is smaller than number of columns, the vector is recycled. Closes [#1060](https://github.com/Rdatatable/data.table/issues/1060). Thanks to @StefanFritsch.

  13. `dcast` can now:
      * cast multiple `value.var` columns simultaneously. Closes [#739](https://github.com/Rdatatable/data.table/issues/739).
      * accept multiple functions under `fun.aggregate`. Closes [#716](https://github.com/Rdatatable/data.table/issues/716).
      * supports optional column prefixes as mentioned under [this SO post](http://stackoverflow.com/q/26225206/559784). Closes [#862](https://github.com/Rdatatable/data.table/issues/862). Thanks to @JohnAndrews.
      * works with undefined variables directly in formula. Closes [#1037](https://github.com/Rdatatable/data.table/issues/1037). Thanks to @DavidArenburg for the MRE.
      * Naming conventions on multiple columns changed according to [#1153](https://github.com/Rdatatable/data.table/issues/1153). Thanks to @MichaelChirico for the FR.
      * also has a `sep` argument with default `_` for backwards compatibility. [#1210](https://github.com/Rdatatable/data.table/issues/1210). Thanks to @dbetebenner for the FR.

  14. `.SDcols` and `with=FALSE` understand `colA:colB` form now. That is, `DT[, lapply(.SD, sum), by=V1, .SDcols=V4:V6]` and `DT[, V5:V7, with=FALSE]` works as intended. This is quite useful for interactive use. Closes [#748](https://github.com/Rdatatable/data.table/issues/748) and [#1216](https://github.com/Rdatatable/data.table/issues/1216). Thanks to @carbonmetrics, @jangorecki and @mtennekes.

  15. `setcolorder()` and `setorder()` work with `data.frame`s too. Closes [#1018](https://github.com/Rdatatable/data.table/issues/1018).

  16. `as.data.table.*` and `setDT` argument `keep.rownames` can take a column name as well. When `keep.rownames=TRUE`, the column will still automatically named `rn`. Closes [#575](https://github.com/Rdatatable/data.table/issues/575). 

  17. `setDT` gains a `key` argument so that `setDT(X, key="a")` would convert `X` to a `data.table` by reference *and* key by the columns specified. Closes [#1121](https://github.com/Rdatatable/data.table/issues/1121).

  18. `setDF` also converts `list` of equal length to `data.frame` by reference now. Closes [#1132](https://github.com/Rdatatable/data.table/issues/1132).

  19. `CJ` gains logical `unique` argument with default `FALSE`. If `TRUE`, unique values of vectors are automatically computed and used. This is convenient, for example, `DT[CJ(a, b, c, unique=TRUE)]` instead of  doing `DT[CJ(unique(a), unique(b), unique(c))]`. Ultimately, `unique = TRUE` will be default. Closes [#1148](https://github.com/Rdatatable/data.table/issues/1148). 

  20. `on=` syntax: data.tables can join now without having to set keys by using the new `on` argument. For example: `DT1[DT2, on=c(x = "y")]` would join column 'y' of `DT2` with 'x' of `DT1`. `DT1[DT2, on="y"]` would join on column 'y' on both data.tables. Closes [#1130](https://github.com/Rdatatable/data.table/issues/1130) partly.

  21. `merge.data.table` gains arguments `by.x` and `by.y`. Closes [#637](https://github.com/Rdatatable/data.table/issues/637) and [#1130](https://github.com/Rdatatable/data.table/issues/1130). No copies are made even when the specified columns aren't key columns in data.tables, and therefore much more fast and memory efficient. Thanks to @blasern for the initial PRs. Also gains logical argument `sort` (like base R). Closes [#1282](https://github.com/Rdatatable/data.table/issues/1282).

  22. `setDF()` gains `rownames` argument for ready conversion to a `data.frame` with user-specified rows. Closes [#1320](https://github.com/Rdatatable/data.table/issues/1320). Thanks to @MichaelChirico for the FR and PR.

  23. `print.data.table` gains `quote` argument (defaul=`FALSE`). This option surrounds all printed elements with quotes, helps make whitespace(s) more evident. Closes [#1177](https://github.com/Rdatatable/data.table/issues/1177); thanks to @MichaelChirico for the PR.

  24. `[.data.table` now accepts single column numeric matrix in `i` argument the same way as `data.frame`. Closes [#826](https://github.com/Rdatatable/data.table/issues/826). Thanks to @jangorecki for the PR.

  25. `setDT()` gains `check.names` argument paralleling that of `fread`, `data.table`, and `base` functionality, allowing poorly declared objects to be converted to tidy `data.table`s by reference. Closes [#1338](https://github.com/Rdatatable/data.table/issues/1338); thanks to @MichaelChirico for the FR/PR.

#### BUG FIXES

  1. `if (TRUE) DT[,LHS:=RHS]` no longer prints, [#869](https://github.com/Rdatatable/data.table/issues/869) and [#1122](https://github.com/Rdatatable/data.table/issues/1122). Tests added. To get this to work we've had to live with one downside: if a `:=` is used inside a function with no `DT[]` before the end of the function, then the next time `DT` or `print(DT)` is typed at the prompt, nothing will be printed. A repeated `DT` or `print(DT)` will print. To avoid this: include a `DT[]` after the last `:=` in your function. If that is not possible (e.g., it's not a function you can change) then `DT[]` at the prompt is guaranteed to print. As before, adding an extra `[]` on the end of a `:=` query is a recommended idiom to update and then print; e.g. `> DT[,foo:=3L][]`. Thanks to Jureiss and Jan Gorecki for reporting.
  
  2. `DT[FALSE,LHS:=RHS]` no longer prints either, [#887](https://github.com/Rdatatable/data.table/issues/887). Thanks to Jureiss for reporting.
  
  3. `:=` no longer prints in knitr for consistency with behaviour at the prompt, [#505](https://github.com/Rdatatable/data.table/issues/505). Output of a test `knit("knitr.Rmd")` is now in data.table's unit tests. Thanks to Corone for the illustrated report.
  
  4. `knitr::kable()` works again without needing to upgrade from knitr v1.6 to v1.7, [#809](https://github.com/Rdatatable/data.table/issues/809). Packages which evaluate user code and don't wish to import data.table need to be added to `data.table:::cedta.pkgEvalsUserCode` and now only the `eval` part is made data.table-aware (the rest of such package's code is left data.table-unaware). `data.table:::cedta.override` is now empty and will be deprecated if no need for it arises. Thanks to badbye and Stephanie Locke for reporting.
  
  5. `fread()`:
      * doubled quotes ("") inside quoted fields including if immediately followed by an embedded newline. Thanks to James Sams for reporting, [#489](https://github.com/Rdatatable/data.table/issues/489). 
      * quoted fields with embedded newlines in the lines used to detect types, [#810](https://github.com/Rdatatable/data.table/issues/810). Thanks to Vladimir Sitnikov for the scrambled data file which is now included in the test suite.
      * when detecting types in the middle and end of the file, if the jump lands inside a quoted field with (possibly many) embedded newlines, this is now detected.
      * if the file doesn't exist the error message is clearer ([#486](https://github.com/Rdatatable/data.table/issues/486))
      * system commands are now checked to contain at least one space
      * sep="." now works (when dec!="."), [#502](https://github.com/Rdatatable/data.table/issues/502). Thanks to Ananda Mahto for reporting.
      * better error message if quoted field is missing an end quote, [#802](https://github.com/Rdatatable/data.table/issues/802). Thanks to Vladimir Sitnikov for the sample file which is now included in the test suite.
      * providing sep which is not present in the file now reads as if sep="\n" rather than 'sep not found', #738. Thanks to Adam Kennedy for explaining the use-case.
      * seg fault with errors over 1,000 characters (when long lines are included) is fixed, [#802](https://github.com/Rdatatable/data.table/issues/802). Thanks again to Vladimir Sitnikov.
      * Missing `integer64` values are properly assigned `NA`s. Closes [#488](https://github.com/Rdatatable/data.table/issues/488). Thanks to @PeterStoyanov and @richierocks for the report.
      * Column headers with empty strings aren't skipped anymore. [Closes #483](https://github.com/Rdatatable/data.table/issues/483). Thanks to @RobyJoehanes and @kforner.
      * Detects separator correctly when commas also exist in text fields. Closes [#923](https://github.com/Rdatatable/data.table/issues/923). Thanks to @raymondben for the report.
      * `NA` values in NA inflated file are read properly. [Closes #737](https://github.com/Rdatatable/data.table/issues/737). Thanks to Adam Kennedy.  
      * correctly handles `na.strings` argument for all types of columns - it detect possible `NA` values without coercion to character, like in base `read.table`. [fixes #504](https://github.com/Rdatatable/data.table/issues/504). Thanks to @dselivanov for the PR. Also closes [#1314](https://github.com/Rdatatable/data.table/issues/1314), which closes this issue completely, i.e., `na.strings = c("-999", "FALSE")` etc. also work.
      * deals with quotes more robustly. When reading quoted fields fail, it re-attemps to read the field as if it wasn't quoted. This helps read in those fields that might have unbalanced quotes without erroring immediately, thereby closing issues [#568](https://github.com/Rdatatable/data.table/issues/568), [#1256](https://github.com/Rdatatable/data.table/issues/1256), [#1077](https://github.com/Rdatatable/data.table/issues/1077), [#1079](https://github.com/Rdatatable/data.table/issues/1079) and [#1095](https://github.com/Rdatatable/data.table/issues/1095). Thanks to @Synergist, @daroczig, @geotheory and @rsaporta for the reports.
      * gains argument `strip.white` which is `TRUE` by default (unlike `base::read.table`). All unquoted columns' leading and trailing white spaces are automatically removed. If \code{FALSE}, only trailing spaces of header is removed. Closes [#1113](https://github.com/Rdatatable/data.table/issues/1113), [#1035](https://github.com/Rdatatable/data.table/issues/1035), [#1000](https://github.com/Rdatatable/data.table/issues/1000), [#785](https://github.com/Rdatatable/data.table/issues/785), [#529](https://github.com/Rdatatable/data.table/issues/529) and [#956](https://github.com/Rdatatable/data.table/issues/956). Thanks to @dmenne, @dpastoor, @GHarmata, @gkalnytskyi, @renqian, @MatthewForrest, @fxi and @heraldb.
      * doesn't warn about empty lines when 'nrow' argument is specified and that many rows are read properly. Thanks to @richierocks for the report. Closes [#1330](https://github.com/Rdatatable/data.table/issues/1330).
      * doesn't error/warn about not being able to read last 5 lines when 'nrow' argument is specified. Thanks to @robbig2871. Closes [#773](https://github.com/Rdatatable/data.table/issues/773).

  6. Auto indexing:
      * `DT[colA == max(colA)]` now works again without needing `options(datatable.auto.index=FALSE)`. Thanks to Jan Gorecki and kaybenleroll, [#858](https://github.com/Rdatatable/data.table/issues/858). Test added.
      * `DT[colA %in% c("id1","id2","id2","id3")]` now ignores the RHS duplicates (as before, consistent with base R) without needing `options(datatable.auto.index=FALSE)`. Thanks to Dayne Filer for reporting.
      * If `DT` contains a column `class` (happens to be a reserved attribute name in R) then `DT[class=='a']` now works again without needing `options(datatable.auto.index=FALSE)`. Thanks to sunnyghkm for reporting, [#871](https://github.com/Rdatatable/data.table/issues/871).
      * `:=` and `set*` now drop secondary keys (new in v1.9.4) so that `DT[x==y]` works again after a `:=` or `set*` without needing `options(datatable.auto.index=FALSE)`. Only `setkey()` was dropping secondary keys correctly. 23 tests added. Thanks to user36312 for reporting, [#885](https://github.com/Rdatatable/data.table/issues/885).
      * Automatic indices are not created on `.SD` so that `dt[, .SD[b == "B"], by=a]` works correctly. Fixes [#958](https://github.com/Rdatatable/data.table/issues/958). Thanks to @azag0 for the nice reproducible example.
      * `i`-operations resulting in 0-length rows ignore `j` on subsets using auto indexing. Closes [#1001](https://github.com/Rdatatable/data.table/issues/1001). Thanks to @Gsee.
      * `POSIXct` type columns work as expected with auto indexing. Closes [#955](https://github.com/Rdatatable/data.table/issues/955). Thanks to @GSee for the minimal report.
      * Auto indexing with `!` operator, for e.g., `DT[!x == 1]` works as intended. Closes [#932](https://github.com/Rdatatable/data.table/issues/932). Thanks to @matthieugomez for the minimal example.
      * While fixing `#932`, issues on subsetting `NA` were also spotted and fixed, for e.g., `DT[x==NA]` or `DT[!x==NA]`. 
      * Works fine when RHS is of `list` type - quite unusual operation but could happen. Closes [#961](https://github.com/Rdatatable/data.table/issues/961). Thanks to @Gsee for the minimal report.
      * Auto indexing errored in some cases when LHS and RHS were not of same type. This is fixed now. Closes [#957](https://github.com/Rdatatable/data.table/issues/957). Thanks to @GSee for the minimal report.
      * `DT[x == 2.5]` where `x` is integer type resulted in `val` being coerced to integer (for binary search) and therefore returned incorrect result. This is now identified using the function `isReallyReal()` and if so, auto indexing is turned off. Closes [#1050](https://github.com/Rdatatable/data.table/issues/1050).
      * Auto indexing errored during `DT[x %in% val]` when `val` has some values not present in `x`. Closes [#1072](https://github.com/Rdatatable/data.table/issues/1072). Thanks to @CarlosCinelli for asking on [StackOverflow](http://stackoverflow.com/q/28932742/559784).

  7. `as.data.table.list` with list input having 0-length items, e.g. `x = list(a=integer(0), b=3:4)`. `as.data.table(x)` recycles item `a` with `NA`s to fit the length of the longer column `b` (length=2), as before now, but with an additional warning message that the item has been recycled with `NA`. Closes [#847](https://github.com/Rdatatable/data.table/issues/847). Thanks to @tvinodr for the report. This was a regression from 1.9.2.

  8. `DT[i, j]` when `i` returns all `FALSE` and `j` contains some length-0 values (ex: `integer(0)`) now returns an empty data.table as it should. Closes [#758](https://github.com/Rdatatable/data.table/issues/758) and [#813](https://github.com/Rdatatable/data.table/issues/813). Thanks to @tunaaa and @nigmastar for the nice reproducible reports. 

  9. `allow.cartesian` is ignored during joins when:  
      * `i` has no duplicates and `mult="all"`. Closes [#742](https://github.com/Rdatatable/data.table/issues/742). Thanks to @nigmastar for the report.  
      * assigning by reference, i.e., `j` has `:=`. Closes [#800](https://github.com/Rdatatable/data.table/issues/800). Thanks to @matthieugomez for the report.

  In both these cases (and during a `not-join` which was already fixed in [1.9.4](https://github.com/Rdatatable/data.table/blob/master/README.md#bug-fixes-1)), `allow.cartesian` can be safely ignored.

  10. `names<-.data.table` works as intended on data.table unaware packages with Rv3.1.0+. Closes [#476](https://github.com/Rdatatable/data.table/issues/476) and [#825](https://github.com/Rdatatable/data.table/issues/825). Thanks to ezbentley for reporting [here](http://stackoverflow.com/q/23256177/559784) on SO and to @narrenfrei.
  
  11. `.EACHI` is now an exported symbol (just like `.SD`,`.N`,`.I`,`.GRP` and `.BY` already were) so that packages using `data.table` and `.EACHI` pass `R CMD check` with no NOTE that this symbol is undefined. Thanks to Matt Bannert for highlighting.
  
  12. Some optimisations of `.SD` in `j` was done in 1.9.4, refer to [#735](https://github.com/Rdatatable/data.table/issues/735). Due to an oversight, j-expressions of the form c(lapply(.SD, ...), list(...)) were optimised improperly. This is now fixed. Thanks to @mmeierer for filing [#861](https://github.com/Rdatatable/data.table/issues/861).

  13. `j`-expressions in `DT[, col := x$y()]` (or) `DT[, col := x[[1]]()]` are now (re)constructed properly. Thanks to @ihaddad-md for reporting. Closes [#774](https://github.com/Rdatatable/data.table/issues/774).

  14. `format.ITime` now handles negative values properly. Closes [#811](https://github.com/Rdatatable/data.table/issues/811). Thanks to @StefanFritsch for the report along with the fix!

  15. Compatibility with big endian machines (e.g., SPARC and PowerPC) is restored. Most Windows, Linux and Mac systems are little endian; type `.Platform$endian` to confirm. Thanks to Gerhard Nachtmann for reporting and the [QEMU project](http://qemu.org/) for their PowerPC emulator.

  16. `DT[, LHS := RHS]` with RHS is of the form `eval(parse(text = foo[1]))` referring to columns in `DT` is now handled properly. Closes [#880](https://github.com/Rdatatable/data.table/issues/880). Thanks to tyner.

  17. `subset` handles extracting duplicate columns in consistency with data.table's rule - if a column name is duplicated, then accessing that column using column number should return that column, whereas accessing by column name (due to ambiguity) will always extract the first column. Closes [#891](https://github.com/Rdatatable/data.table/issues/891). Thanks to @jjzz.

  18. `rbindlist` handles combining levels of data.tables with both ordered and unordered factor columns properly. Closes [#899](https://github.com/Rdatatable/data.table/issues/899). Thanks to @ChristK.

  19. Updating `.SD` by reference using `set` also errors appropriately now; similar to `:=`. Closes [#927](https://github.com/Rdatatable/data.table/issues/927). Thanks to @jrowen for the minimal example.

  20. `X[Y, .N]` returned the same result as `X[Y, .N, nomatch=0L]`) when `Y` contained rows that has no matches in `X`. Fixed now. Closes [#963](https://github.com/Rdatatable/data.table/issues/963). Thanks to [this SO post](http://stackoverflow.com/q/27004002/559784) from @Alex which helped discover the bug.

  21. `data.table::dcast` handles levels in factor columns properly when `drop = FALSE`. Closes [#893](https://github.com/Rdatatable/data.table/issues/893). Thanks to @matthieugomez for the great minimal example.

  22. `[.data.table` subsets complex and raw type objects again. Thanks to @richierocks for the nice minimal example. Closes [#982](https://github.com/Rdatatable/data.table/issues/982).

  23. Fixed a bug in the internal optimisation of `j-expression` with more than one `lapply(.SD, function(..) ..)` as illustrated [here on SO](http://stackoverflow.com/a/27495844/559784). Closes #985. Thanks to @jadaliha for the report and to @BrodieG for the debugging on SO.

  24. `mget` fetches columns from the default environment `.SD` when called from within the frame of `DT`. That is, `DT[, mget(cols)]`, `DT[, lapply(mget(cols), sum), by=.]` etc.. work as intended. Thanks to @Roland for filing this issue. Closes [#994](https://github.com/Rdatatable/data.table/issues/994).

  25. `foverlaps()` did not find overlapping intervals correctly *on numeric ranges* in a special case where both `start` and `end` intervals had *0.0*. This is now fixed. Thanks to @tdhock for the reproducible example. Closes [#1006](https://github.com/Rdatatable/data.table/issues/1006) partly.

  26. When performing rolling joins, keys are set only when we can be absolutely sure. Closes [#1010](https://github.com/Rdatatable/data.table/issues/1010), which explains cases where keys should not be retained.

  27. Rolling joins with `-Inf` and `Inf` are handled properly. Closes [#1007](https://github.com/Rdatatable/data.table/issues/1007). Thanks to @tdhock for filing [#1006](https://github.com/Rdatatable/data.table/issues/1006) which lead to the discovery of this issue.

  28. Overlapping range joins with `-Inf` and `Inf` and 0.0 in them are handled properly now. Closes [#1006](https://github.com/Rdatatable/data.table/issues/1006). Thanks to @tdhock for filing the issue with a nice reproducible example.

  29. Fixed two segfaults in `shift()` when number of rows in `x` is lesser than value for `n`. Closes [#1009](https://github.com/Rdatatable/data.table/issues/1009) and [#1014](https://github.com/Rdatatable/data.table/issues/1014). Thanks to @jangorecki and @ashinm for the reproducible reports.

  30. Attributes are preserved for `sum()` and `mean()` when fast internal (GForce) implementations are used. Closes [#1023](https://github.com/Rdatatable/data.table/issues/1023). Thanks to @DavidArenburg for the nice reproducible example.

  31. `lapply(l, setDT)` is handled properly now; over-allocation isn't lost. Similarly, `for (i in 1:k) setDT(l[[i]])` is handled properly as well. Closes [#480](https://github.com/Rdatatable/data.table/issues/480). 

  32. `rbindlist` stack imbalance on all `NULL` list elements is now fixed. Closes [#980](https://github.com/Rdatatable/data.table/issues/980). Thanks to @ttuggle.

  33. List columns can be assigned to columns of `factor` type by reference. Closes [#936](https://github.com/Rdatatable/data.table/issues/936). Thanks to @richierocks for the minimal example.

  34. After setting the `datatable.alloccol` option, creating a data.table with more than the set `truelength` resulted in error or segfault. This is now fixed. Closes [#970](https://github.com/Rdatatable/data.table/issues/970). Thanks to @caneff for the nice minimal example.

  35. Update by reference using `:=` after loading from disk where the `data.table` exists within a local environment now works as intended. Closes [#479](https://github.com/Rdatatable/data.table/issues/479). Thanks to @ChongWang for the minimal reproducible example.

  36. Issues on merges involving `factor` columns with `NA` and merging `factor` with `character` type with non-identical levels are both fixed. Closes [#499](https://github.com/Rdatatable/data.table/issues/499) and [#945](https://github.com/Rdatatable/data.table/issues/945). Thanks to @AbielReinhart and @stewbasic for the minimal examples.

  37. `as.data.table(ll)` returned a `data.table` with 0-rows when the first element of the list has 0-length, for e.g., `ll = list(NULL, 1:2, 3:4)`. This is now fixed by removing those 0-length elements. Closes [#842](https://github.com/Rdatatable/data.table/issues/842). Thanks to @Rick for the nice minimal example.

  38. `as.datat.able.factor` redirects to `as.data.table.matrix` when input is a `matrix`, but also of type `factor`. Closes [#868](https://github.com/Rdatatable/data.table/issues/868). Thanks to @mgahan for the example.

  39. `setattr` now returns an error when trying to set `data.table` and/or `data.frame` as class to a *non-list* type object (ex: `matrix`). Closes [#832](https://github.com/Rdatatable/data.table/issues/832). Thanks to @Rick for the minimal example.

  40. data.table(table) works as expected. Closes [#1043](https://github.com/Rdatatable/data.table/issues/1043). Thanks to @rnso for the [SO post](http://stackoverflow.com/q/28499359/559784).

  41. Joins and binary search based subsets of the form `x[i]` where `x`'s key column is integer and `i` a logical column threw an error before. This is now fixed by converting the logical column to integer type and then performing the join, so that it works as expected. 

  42. When `by` expression is, for example, `by = x %% 2`, `data.table` tries to automatically extracts meaningful column names from the expression. In this case it would be `x`. However, if the `j-expression` also contains `x`, for example, `DT[, last(x), by= x %% 2]`, the original `x` got masked by the expression in `by`. This is now fixed; by-expressions are not simplified in column names for these cases. Closes [#497](https://github.com/Rdatatable/data.table/issues/497). Thanks to @GSee for the report.

  43. `rbindlist` now errors when columns have non-identical class attributes and are not `factor`s, e.g., binding column of class `Date` with `POSIXct`. Previously this returned incorrect results. Closes [#705](https://github.com/Rdatatable/data.table/issues/705). Thanks to @ecoRoland for the minimal report.

  44. Fixed a segfault in `melt.data.table` when `measure.vars` have duplicate names. Closes [#1055](https://github.com/Rdatatable/data.table/issues/1055). Thanks to @ChristK for the minimal report.

  45. Fixed another segfault in `melt.data.table` issue that was caught due to issue in Windows. Closes [#1059](https://github.com/Rdatatable/data.table/issues/1059). Thanks again to @ChristK for the minimal report. 

  46. `DT[rows, newcol := NULL]` resulted in a segfault on the next assignment by reference. Closes [#1082](https://github.com/Rdatatable/data.table/issues/1082). Thanks to @stevenbagley for the MRE.

  47. `as.matrix(DT)` handles cases where `DT` contains both numeric and logical columns correctly (doesn't coerce to character columns anymore). Closes [#1083](https://github.com/Rdatatable/data.table/issues/1083). Thanks to @bramvisser for the [SO post](http://stackoverflow.com/questions/29068328/correlation-between-numeric-and-logical-variable-gives-intended-error).

  48. Coercion is handled properly on subsets/joins on `integer64` key columns. Closes [#1108](https://github.com/Rdatatable/data.table/issues/1108). Thanks to @vspinu.

  49. `setDT()` and `as.data.table()` both strip *all classes* preceding *data.table*/*data.frame*, to be consistent with base R. Closes [#1078](https://github.com/Rdatatable/data.table/issues/1078) and [#1128](https://github.com/Rdatatable/data.table/issues/1128). Thanks to Jan and @helix123 for the reports.

  50. `setattr(x, 'levels', value)` handles duplicate levels in `value`
 appropriately. Thanks to Jeffrey Horner for pointing it out [here](http://jeffreyhorner.tumblr.com/post/118297392563/tidyr-challenge-help-me-do-my-job). Closes [#1142](https://github.com/Rdatatable/data.table/issues/1142).

  51. `x[J(vals), .N, nomatch=0L]` also included no matches in result, [#1074](https://github.com/Rdatatable/data.table/issues/1074). And `x[J(...), col := val, nomatch=0L]` returned a warning with incorrect results when join resulted in no matches as well, even though `nomatch=0L` should have no effect in `:=`, [#1092](https://github.com/Rdatatable/data.table/issues/1092). Both issues are fixed now. Thanks to @riabusan and @cguill95 for #1092.

  52. `.data.table.locked` attributes set to NULL in internal function `subsetDT`. Closes [#1154](https://github.com/Rdatatable/data.table/issues/1154). Thanks to @jangorecki.

  53. Internal function `fastmean()` retains column attributes. Closes [#1160](https://github.com/Rdatatable/data.table/issues/1160). Thanks to @renkun-ken.

  54. Using `.N` in `i`, for e.g., `DT[, head(.SD, 3)[1:(.N-1L)]]`  accessed incorrect value of `.N`. This is now fixed. Closes [#1145](https://github.com/Rdatatable/data.table/issues/1145). Thanks to @claytonstanley.
  
  55. `setDT` handles `key=` argument properly when input is already a `data.table`. Closes [#1169](https://github.com/Rdatatable/data.table/issues/1169). Thanks to @DavidArenburg for the PR.

  56. Key is retained properly when joining on factor type columns. Closes [#477](https://github.com/Rdatatable/data.table/issues/477). Thanks to @nachti for the report.
  
  57. Over-allocated memory is released more robustly thanks to Karl Millar's investigation and suggested fix.
  
  58. `DT[TRUE, colA:=colA*2]` no longer churns through 4 unnecessary allocations as large as one column. This was caused by `i=TRUE` being recycled. Thanks to Nathan Kurz for reporting and investigating. Added provided test to test suite. Only a single vector is allocated now for the RHS (`colA*2`). Closes [#1249](https://github.com/Rdatatable/data.table/issues/1249).
  
  59. Thanks to @and3k for the excellent bug report [#1258](https://github.com/Rdatatable/data.table/issues/1258). This was a result of shallow copy retaining keys when it shouldn't. It affected some cases of joins using `on=`. Fixed now.

  60. `set()` and `:=` handle RHS value `NA_integer_` on factor types properly. Closes [#1234](https://github.com/Rdatatable/data.table/issues/1234). Thanks to @DavidArenburg.

  61. `merge.data.table()` didn't set column order (and therefore names) properly in some cases. Fixed now. Closes [#1290](https://github.com/Rdatatable/data.table/issues/1290). Thanks to @ChristK for the minimal example.

  62. print.data.table now works for 100+ rows as intended when `row.names=FALSE`. Closes [#1307](https://github.com/Rdatatable/data.table/issues/1307). Thanks to @jangorecki for the PR.

  63. Row numbers are not printed in scientific format. Closes [#1167](https://github.com/Rdatatable/data.table/issues/1167). Thanks to @jangorecki for the PR.

  64. Using `.GRP` unnamed in `j` now returns a variable named `GRP` instead of `.GRP` as the period was causing issues. Same for `.BY`. Closes [#1243](https://github.com/Rdatatable/data.table/issues/1243); thanks to @MichaelChirico for the PR.

  65. `DT[, 0, with=FALSE]` returns null data.table to be consistent with `data.frame`'s behaviour. Closes [#1140](https://github.com/Rdatatable/data.table/issues/1140). Thanks to @franknarf1.

  66. Evaluating quoted expressions with `.` in `by` works as intended. That is, `dt = data.table(a=c(1,1,2,2), b=1:4); expr=quote(.(a)); dt[, sum(b), eval(expr)]` works now. Closes [#1298](https://github.com/Rdatatable/data.table/issues/1298). Thanks @eddi.

  67. `as.list` method for `IDate` object works properly. Closes [#1315](https://github.com/Rdatatable/data.table/issues/1315). Thanks to @gwerbin.

#### NOTES

  1. Clearer explanation of what `duplicated()` does (borrowed from base). Thanks to @matthieugomez for pointing out. Closes [#872](https://github.com/Rdatatable/data.table/issues/872).
  
  2. `?setnames` has been updated now that `names<-` and `colnames<-` shallow (rather than deep) copy from R >= 3.1.0, [#853](https://github.com/Rdatatable/data.table/issues/872).
  
  3. [FAQ 1.6](https://github.com/Rdatatable/data.table/wiki/vignettes/datatable-faq.pdf) has been embellished, [#517](https://github.com/Rdatatable/data.table/issues/517). Thanks to a discussion with Vivi and Josh O'Brien.
  
  4. `data.table` redefines `melt` generic and *suggests* `reshape2` instead of *import*. As a result we don't have to load `reshape2` package to use `melt.data.table` anymore. The reason for this change is that `data.table` requires R >=2.14, whereas `reshape2` R v3.0.0+. Reshape2's melt methods can be used without any issues by loading the package normally.

  5. `DT[, j, ]` at times made an additional (unnecessary) copy. This is now fixed. This fix also avoids allocating `.I` when `j` doesn't use it. As a result `:=` and other subset operations should be faster (and use less memory). Thanks to @szilard for the nice report. Closes [#921](https://github.com/Rdatatable/data.table/issues/921).

  6. Because `reshape2` requires R >3.0.0, and `data.table` works with R >= 2.14.1, we can not import `reshape2` anymore. Therefore we define a `melt` generic and `melt.data.table` method for data.tables and redirect to `reshape2`'s `melt` for other objects. This is to ensure that existing code works fine. 

  7. `dcast` is also a generic now in data.table. So we can use `dcast(...)` directly, and don't have to spell it out as `dcast.data.table(...)` like before. The `dcast` generic in data.table redirects to `reshape2::dcast` if the input object is not a data.table. But for that you have to load `reshape2` before loading `data.table`. If not,  reshape2's `dcast` overwrites data.table's `dcast` generic, in which case you will need the `::` operator - ex: `data.table::dcast(...)`. 

  NB: Ideal situation would be for `dcast` to be a generic in reshape2 as well, but it is not. We have issued a [pull request](https://github.com/hadley/reshape/pull/62) to make `dcast` in reshape2 a generic, but that has not yet been accepted. 

  8. Clarified the use of `bit64::integer4` in `merge.data.table()` and `setNumericRounding()`. Closes [#1093](https://github.com/Rdatatable/data.table/issues/1093). Thanks to @sfischme for the report.

  9. Removed an unnecessary (and silly) `giveNames` argument from `setDT()`. Not sure why I added this in the first place!

  10. `options(datatable.prettyprint.char=5L)` restricts the number of characters to be printed for character columns. For example:
    
        options(datatable.prettyprint.char = 5L)
        DT = data.table(x=1:2, y=c("abcdefghij", "klmnopqrstuv"))
        DT
        #    x        y
        # 1: 1 abcde...
        # 2: 2 klmno...

  11. `rolltolast` argument in `[.data.table` is now defunct. It was deprecated in 1.9.4.
  
  12. `data.table`'s dependency has been moved forward from R 2.14.0 to R 2.14.1, now nearly 4 years old (Dec 2011). As usual before release to CRAN we ensure data.table passes the test suite on the stated dependency and keep this as old as possible for as long as possible. As requested by users in managed environments. For this reason we still don't use `paste0()` internally, since that was added to R 2.15.0.

  13. Warning about `datatable.old.bywithoutby` option (for grouping on join without providing `by`) being deprecated in the next release is in place now. Thanks to @jangorecki for the PR.

  14. Fixed `allow.cartesian` documentation to `nrow(x)+nrow(i)` instead of `max(nrow(x), nrow(i))`. Closes [#1123](https://github.com/Rdatatable/data.table/issues/1123). 

### Changes in v1.9.4  (on CRAN 2 Oct 2014)

#### NEW FEATURES

  1. `by=.EACHI` runs `j` for each group in `DT` that each row of `i` joins to.
    ```R
    setkey(DT, ID)
    DT[c("id1", "id2"), sum(val)]                # single total across both id1 and id2
    DT[c("id1", "id2"), sum(val), by = .EACHI]   # sum(val) for each id
    DT[c("id1", "id2"), sum(val), by = key(DT)]  # same
    ```
    In other words, `by-without-by` is now explicit, as requested by users, [#371](https://github.com/Rdatatable/data.table/issues/371). When `i` contains duplicates, `by=.EACHI` is different to `by=key(DT)`; e.g.,
    ```R
    setkey(DT, ID)
    ids = c("id1", "id2", "id1")     # NB: id1 appears twice
    DT[ids, sum(val), by = ID]       # 2 rows returned
    DT[ids, sum(val), by = .EACHI]   # 3 rows in the order of ids (result 1 and 3 are not merged)
    ```
    `by=.EACHI` can be useful when `i` is event data, where you don't want the events aggregated by common join values but wish the output to be ordered with repeats, or simply just using join inherited columns as parameters; e.g.;
    ```R
    X[Y, head(.SD, i.top), by = .EACHI]
    ```
    where `top` is a non-join column in `Y`; i.e., join inherited column. Thanks to many, especially eddi, Sadao Milberg and Gabor Grothendieck for extended discussions. Closes [#538](https://github.com/Rdatatable/data.table/issues/538).

  2. Accordingly, `X[Y, j]` now does what `X[Y][, j]` did. To return the old behaviour: `options(datatable.old.bywithoutby=TRUE)`. This is a temporary option to aid migration and will be removed in future. See [this](http://r.789695.n4.nabble.com/changing-data-table-by-without-by-syntax-to-require-a-quot-by-quot-td4664770.html), [this](http://stackoverflow.com/questions/16093289/data-table-join-and-j-expression-unexpected-behavior) and [this](http://stackoverflow.com/a/16222108/403310) post for discussions and motivation.
  
  3. `Overlap joins` ([#528](https://github.com/Rdatatable/data.table/issues/528)) is now here, finally!! Except for `type="equal"` and `maxgap` and `minoverlap` arguments, everything else is implemented. Check out `?foverlaps` and the examples there on its usage. This is a major feature addition to `data.table`.

  4. `DT[column==value]` and `DT[column %in% values]` are now optimized to use `DT`'s key when `key(DT)[1]=="column"`, otherwise a secondary key (a.k.a. _index_) is automatically added so the next `DT[column==value]` is much faster. No code changes are needed; existing code should automatically benefit. Secondary keys can be added manually using `set2key()` and existence checked using `key2()`. These optimizations and function names/arguments are experimental and may be turned off with `options(datatable.auto.index=FALSE)`.

  5. `fread()`:
      * accepts line breaks inside quoted fields. Thanks to Clayton Stanley for highlighting [here](http://stackoverflow.com/questions/21006661/fread-and-a-quoted-multi-line-column-value).
      * accepts trailing backslash in quoted fields. Thanks to user2970844 for highlighting [here](http://stackoverflow.com/questions/24375832/fread-and-column-with-a-trailing-backslash).
      * Blank and `"NA"` values in logical columns (`T`,`True`,`TRUE`) no longer cause them to be read as character, [#567](https://github.com/Rdatatable/data.table/issues/567). Thanks to Adam November for reporting.
      * URLs now work on Windows. R's `download.file()` converts `\r\n` to `\r\r\n` on Windows. Now avoided by downloading in binary mode. Thanks to Steve Miller and Dean MacGregor for reporting, [#492](https://github.com/Rdatatable/data.table/issues/492).
      * Fixed seg fault in sparse data files when bumping to character, [#796](https://github.com/Rdatatable/data.table/issues/796) and [#722](https://github.com/Rdatatable/data.table/issues/722). Thanks to Adam Kennedy and Richard Cotton for the detailed reproducible reports.
      * New argument `fread(...,data.table=FALSE)` returns a `data.frame` instead of a `data.table`. This can be set globally: `options(datatable.fread.datatable=FALSE)`.

  6. `.()` can now be used in `j` and is identical to `list()`, for consistency with `i`.
    ```R
    DT[,list(MySum=sum(B)),by=...]
    DT[,.(MySum=sum(B)),by=...]     # same
    DT[,list(colB,colC,colD)]
    DT[,.(colB,colC,colD)]          # same
    ```
    Similarly, `by=.()` is now a shortcut for `by=list()`, for consistency with `i` and `j`.
    
  7. `rbindlist` gains `use.names` and `fill` arguments and is now implemented entirely in C. Closes [#345](https://github.com/Rdatatable/data.table/issues/345):
      * `use.names` by default is FALSE for backwards compatibility (does not bind by names by default)
      * `rbind(...)` now just calls `rbindlist()` internally, except that `use.names` is TRUE by default, for compatibility with base (and backwards compatibility).
      * `fill=FALSE` by default. If `fill=TRUE`, `use.names` has to be TRUE. 
      * When use.names=TRUE, at least one item of the input list has to have non-null column names.
      * When fill=TRUE, all items of the input list has to have non-null column names.
      * Duplicate columns are bound in the order of occurrence, like base.
      * Attributes that might exist in individual items would be lost in the bound result.
      * Columns are coerced to the highest SEXPTYPE when they are different, if possible.
      * And incredibly fast ;).
      * Documentation updated in much detail. Closes [#333](https://github.com/Rdatatable/data.table/issues/333).
    
  8. `bit64::integer64` now works in grouping and joins, [#342](https://github.com/Rdatatable/data.table/issues/342). Thanks to James Sams for highlighting UPCs and Clayton Stanley for [this SO post](http://stackoverflow.com/questions/22273321/large-integers-in-data-table-grouping-results-different-in-1-9-2-compared-to-1). `fread()` has been detecting and reading `integer64` for a while.

  9. `setNumericRounding()` may be used to reduce to 1 byte or 0 byte rounding when joining to or grouping columns of type 'numeric', [#342](https://github.com/Rdatatable/data.table/issues/342). See example in `?setNumericRounding` and NEWS item below for v1.9.2. `getNumericRounding()` returns the current setting.

  10. `X[Y]` now names non-join columns from `i` that have the same name as a column in `x`, with an `i.` prefix for consistency with the `i.` prefix that has been available in `j` for some time. This is now documented.

  11. For a keyed table `X` where the key columns are not at the beginning in order, `X[Y]` now retains the original order of columns in X rather than moving the join columns to the beginning of the result.

  12. It is no longer an error to assign to row 0 or row NA.
    ```R
    DT[0, colA := 1L]             # now does nothing, silently (was error)
    DT[NA, colA := 1L]            # now does nothing, silently (was error)
    DT[c(1, NA, 0, 2), colA:=1L]  # now ignores the NA and 0 silently (was error)
    DT[nrow(DT) + 1, colA := 1L]  # error (out-of-range) as before
    ```
    This is for convenience to avoid the need for a switch in user code that evals various `i` conditions in a loop passing in `i` as an integer vector which may containing `0` or `NA`.

  13. A new function `setorder` is now implemented which uses data.table's internal fast order to reorder rows *by reference*. It returns the result invisibly (like `setkey`) that allows for compound statements; e.g., `setorder(DT, a, -b)[, cumsum(c), by=list(a,b)]`. Check `?setorder` for more info.

  14. `DT[order(x, -y)]` is now by default optimised to use data.table's internal fast order as `DT[forder(DT, x, -y)]`. It can be turned off by setting `datatable.optimize` to < 1L or just calling `base:::order` explicitly. It results in 20x speedup on data.table of 10 million rows with 2 integer columns, for example. To order character vectors in descending order it's sufficient to do `DT[order(x, -y)]` as opposed to `DT[order(x, -xtfrm(y))]` in base. This closes [#603](https://github.com/Rdatatable/data.table/issues/603).
     
  15. `mult="all"` -vs- `mult="first"|"last"` now return consistent types and columns, [#340](https://github.com/Rdatatable/data.table/issues/340). Thanks to Michele Carriero for highlighting.

  16. `duplicated.data.table` and `unique.data.table` gains `fromLast = TRUE/FALSE` argument, similar to base. Default value is FALSE. Closes [#347](https://github.com/Rdatatable/data.table/issues/347).

  17. `anyDuplicated.data.table` is now implemented. Closes [#350](https://github.com/Rdatatable/data.table/issues/350). Thanks to M C (bluemagister) for reporting.

  18. Complex j-expressions of the form `DT[, c(..., lapply(.SD, fun)), by=grp]`are now optimised as long as `.SD` is of the form `lapply(.SD, fun)` or `.SD`, `.SD[1]` or `.SD[1L]`. This resolves [#370](https://github.com/Rdatatable/data.table/issues/370). Thanks to Sam Steingold for reporting. 
      This also completes the first two task lists in [#735](https://github.com/Rdatatable/data.table/issues/735).
    ```R
    ## example:
    DT[, c(.I, lapply(.SD, sum), mean(x), lapply(.SD, log)), by=grp]
    ## is optimised to
    DT[, list(.I, x=sum(x), y=sum(y), ..., mean(x), log(x), log(y), ...), by=grp]
    ## and now... these variations are also optimised internally for speed
    DT[, c(..., .SD, lapply(.SD, sum), ...), by=grp]
    DT[, c(..., .SD[1], lapply(.SD, sum), ...), by=grp]
    DT[, .SD, by=grp]
    DT[, c(.SD), by=grp]
    DT[, .SD[1], by=grp] # Note: but not yet DT[, .SD[1,], by=grp]
    DT[, c(.SD[1]), by=grp]
    DT[, head(.SD, 1), by=grp] # Note: but not yet DT[, head(.SD, -1), by=grp]
    # but not yet optimised
    DT[, c(.SD[a], .SD[x>1], lapply(.SD, sum)), by=grp] # where 'a' is, say, a numeric or a data.table, and also for expressions like x>1
    ```
    The underlying message is that `.SD` is being slowly optimised internally wherever possible, for speed, without compromising in the nice readable syntax it provides.

  19. `setDT` gains `keep.rownames = TRUE/FALSE` argument, which works only on `data.frame`s. TRUE retains the data.frame's row names as a new column named `rn`.

  20. The output of `tables()` now includes `NCOL`. Thanks to @dnlbrky for the suggestion.

  21. `DT[, LHS := RHS]` (or its equivalent in `set`) now provides a warning and returns `DT` as it was, instead of an error, when `length(LHS) = 0L`, [#343](https://github.com/Rdatatable/data.table/issues/343). For example:
    ```R
    DT[, grep("^b", names(DT)) := NULL] # where no columns start with b
    # warns now and returns DT instead of error
    ```

  22. GForce now is also optimised for j-expression with `.N`. Closes [#334](https://github.com/Rdatatable/data.table/issues/334) and part of [#523](https://github.com/Rdatatable/data.table/issues/523).
    ```R
    DT[, list(.N, mean(y), sum(y)), by=x] # 1.9.2 - doesn't know to use GForce - will be (relatively) slower
    DT[, list(.N, mean(y), sum(y)), by=x] # 1.9.3+ - will use GForce.
    ```

  23. `setDF` is now implemented. It accepts a data.table and converts it to data.frame by reference, [#338](https://github.com/Rdatatable/data.table/issues/338). Thanks to canneff for the discussion [here](http://r.789695.n4.nabble.com/Is-there-any-overhead-to-converting-back-and-forth-from-a-data-table-to-a-data-frame-td4688332.html) on data.table mailing list.

  24. `.I` gets named as `I` (instead of `.I`) wherever possible, similar to `.N`, [#344](https://github.com/Rdatatable/data.table/issues/344).
  
  25. `setkey` on `.SD` is now an error, rather than warnings for each group about rebuilding the key. The new error is similar to when attempting to use `:=` in a `.SD` subquery: `".SD is locked. Using set*() functions on .SD is reserved for possible future use; a tortuously flexible way to modify the original data by group."`  Thanks to Ron Hylton for highlighting the issue on datatable-help [here](http://r.789695.n4.nabble.com/data-table-is-asking-for-help-tp4692080.html).
  
  26. Looping calls to `unique(DT)` such as in `DT[,unique(.SD),by=group]` is now faster by avoiding internal overhead of calling `[.data.table`. Thanks again to Ron Hylton for highlighting in the [same thread](http://r.789695.n4.nabble.com/data-table-is-asking-for-help-tp4692080.html). His example is reduced from 28 sec to 9 sec, with identical results.
  
  27. Following `gsum` and `gmean`, now `gmin` and `gmax` from GForce are also implemented. Closes part of [#523](https://github.com/Rdatatable/data.table/issues/523). Benchmarks are also provided.
    ```R
    DT[, list(sum(x), min(y), max(z), .N), by=...] # runs by default using GForce
    ```
    
  28. `setorder()` and `DT[order(.)]` handles `integer64` type in descending order as well. Closes [#703](https://github.com/Rdatatable/data.table/issues/703).
  
  29. `setorder()` and `setorderv()` gain `na.last = TRUE/FALSE`. Closes [#706](https://github.com/Rdatatable/data.table/issues/706).

  30. `.N` is now available in `i`, [FR#724](https://github.com/Rdatatable/data.table/issues/724). Thanks to newbie indirectly [here](http://stackoverflow.com/a/24649115/403310) and Farrel directly [here](http://stackoverflow.com/questions/24685421/how-do-you-extract-a-few-random-rows-from-a-data-table-on-the-fly).

  31. `by=.EACHI` is now implemented for *not-joins* as well. Closes [#604](https://github.com/Rdatatable/data.table/issues/604). Thanks to Garrett See for filing the FR. As an example:
    ```R
    DT = data.table(x=c(1,1,1,1,2,2,3,4,4,4), y=1:10, key="x")
    DT[!J(c(1,4)), sum(y), by=.EACHI] # is equivalent to DT[J(c(2,3)), sum(y), by=.EACHI]
    ```


#### BUG FIXES

  
  1.  When joining to fewer columns than the key has, using one of the later key columns explicitly in j repeated the first value. A problem introduced by v1.9.2 and not caught bythe 1,220 tests, or tests in 37 dependent packages. Test added. Many thanks to Michele Carriero for reporting.
    ```R
    DT = data.table(a=1:2, b=letters[1:6], key="a,b")    # keyed by a and b
    DT[.(1), list(b,...)]    # correct result again (joining just to a not b but using b)
    ```
    
  2.  `setkey` works again when a non-key column is type list (e.g. each cell can itself be a vector), [#54](https://github.com/Rdatatable/data.table/issues/54). Test added. Thanks to James Sams, Michael Nelson and Musx [for the reproducible examples](http://stackoverflow.com/questions/22186798/r-data-table-1-9-2-issue-on-setkey).

  3.  The warning "internal TRUE value has been modified" with recently released R 3.1 when grouping a table containing a logical column *and* where all groups are just 1 row is now fixed and tests added. Thanks to James Sams for the reproducible example. The warning is issued by R and we have asked if it can be upgraded to error (UPDATE: change now made for R 3.1.1 thanks to Luke Tierney).

  4.  `data.table(list())`, `data.table(data.table())` and `data.table(data.frame())` now return a null data.table (no columns) rather than one empty column, [#48](https://github.com/Rdatatable/data.table/issues/48). Test added. Thanks to Shubh Bansal for reporting.

  5.  `unique(<NULL data.table>)` now returns a null data.table, [#44](https://github.com/Rdatatable/data.table/issues/44). Thanks to agstudy for reporting.

  6.  `data.table()` converted POSIXlt to POSIXct, consistent with `base:::data.frame()`, but now also provides a helpful warning instead of coercing silently, [#59](https://github.com/Rdatatable/data.table/issues/59). Thanks to Brodie Gaslam, Patrick and Ragy Isaac for reporting [here](http://stackoverflow.com/questions/21487614/error-creating-r-data-table-with-date-time-posixlt) and [here](http://stackoverflow.com/questions/21320215/converting-from-data-frame-to-data-table-i-get-an-error-with-head).

  7.  If another class inherits from data.table; e.g. `class(DT) == c("UserClass","data.table","data.frame")` then `DT[...]` now retains `UserClass` in the result. Thanks to Daniel Krizian for reporting, [#64](https://github.com/Rdatatable/data.table/issues/44). Test added.

  8.  An error `object '<name>' not found` could occur in some circumstances, particularly after a previous error. [Reported on SO](http://stackoverflow.com/questions/22128047/how-to-avoid-weird-umlaute-error-when-using-data-table) with non-ASCII characters in a column name, a red herring we hope since non-ASCII characters are fully supported in data.table including in column names. Fix implemented and tests added.

  9.  Column order was reversed in some cases by `as.data.table.table()`, [#43](https://github.com/Rdatatable/data.table/issues/43). Test added. Thanks to Benjamin Barnes for reporting.
     
  10.  `DT[, !"missingcol", with=FALSE]` now returns `DT` (rather than a NULL data.table) with warning that "missingcol" is not present.

  11.  `DT[,y := y * eval(parse(text="1*2"))]` resulted in error unless `eval()` was wrapped with paranthesis. That is, `DT[,y := y * (eval(parse(text="1*2")))]`, **#5423**. Thanks to Wet Feet for reporting and to Simon O'Hanlon for identifying the issue [here on SO](http://stackoverflow.com/questions/22375404/unable-to-use-evalparse-in-data-table-function/22375557#22375557).

  12.  Using `by` columns with attributes (ex: factor, Date) in `j` did not retain the attributes, also in case of `:=`. This was partially a regression from an earlier fix ([#155](https://github.com/Rdatatable/data.table/issues/155)) due to recent changes for R3.1.0. Now fixed and clearer tests added. Thanks to Christophe Dervieux for reporting and to Adam B for reporting [here on SO](http://stackoverflow.com/questions/22536586/by-seems-to-not-retain-attribute-of-date-type-columns-in-data-table-possibl). Closes [#36](https://github.com/Rdatatable/data.table/issues/36).

  13.  `.BY` special variable did not retain names of the grouping columns which resulted in not being able to access `.BY$grpcol` in `j`. Ex: `DT[, .BY$x, by=x]`. This is now fixed. Closes **#5415**. Thanks to Stephane Vernede for the bug report.

  14.  Fixed another issue with `eval(parse(...))` in `j` along with assignment by reference `:=`. Closes [#30](https://github.com/Rdatatable/data.table/issues/30). Thanks to Michele Carriero for reporting. 

  15.  `get()` in `j` did not see `i`'s columns when `i` is a data.table which lead to errors while doing operations like: `DT1[DT2, list(get('c'))]`. Now, use of `get` makes *all* x's and i's columns visible (fetches all columns). Still, as the verbose message states, using `.SDcols` or `eval(macro)` would be able to select just the columns used, which is better for efficiency. Closes [#34](https://github.com/Rdatatable/data.table/issues/34). Thanks to Eddi for reporting.

  16.  Fixed an edge case with `unique` and `duplicated`, which on empty data.tables returned a 1-row data.table with all NAs. Closes [#28](https://github.com/Rdatatable/data.table/issues/28). Thanks to Shubh Bansal for reporting.

  17.  `dcast.data.table` resuled in error (because function `CJ()` was not visible) in packages that "import" data.table. This did not happen if the package "depends" on data.table. Closes bug [#31](https://github.com/Rdatatable/data.table/issues/31). Thanks to K Davis for the excellent report. 

  18.  `merge(x, y, all=TRUE)` error when `x` is empty data.table is now fixed. Closes [#24](https://github.com/Rdatatable/data.table/issues/24). Thanks to Garrett See for filing the report.

  19.  Implementing #5249 closes bug [#26](https://github.com/Rdatatable/data.table/issues/26), a case where rbind gave error when binding with empty data.tables. Thanks to Roger for [reporting on SO](http://stackoverflow.com/q/23216033/559784).

  20.  Fixed a segfault during grouping with assignment by reference, ex: `DT[, LHS := RHS, by=.]`, where length(RHS) > group size (.N). Closes [#25](https://github.com/Rdatatable/data.table/issues/25). Thanks to Zachary Long for reporting on datatable-help mailing list.

  21.  Consistent subset rules on datat.tables with duplicate columns. In short, if indices are directly provided, 'j', or in .SDcols, then just those columns are either returned (or deleted if you provide -.SDcols or !j). If instead, column names are given and there are more than one occurrence of that column, then it's hard to decide which to keep and which to remove on a subset. Therefore, to remove, all occurrences of that column are removed, and to keep, always the first column is returned each time. Also closes [#22](https://github.com/Rdatatable/data.table/issues/22) and [#86](https://github.com/Rdatatable/data.table/issues/86).

       Note that using `by=` to aggregate on duplicate columns may not give intended result still, as it may not operate on the proper column.

  22.  When DT is empty, `DT[, newcol:=max(b), by=a]` now properly adds the column, [#49](https://github.com/Rdatatable/data.table/issues/49). Thanks to Shubh bansal for filing the report.

  23.  When `j` evaluates to `integer(0)/character(0)`, `DT[, j, with=FALSE]` resulted in error, [#21](https://github.com/Rdatatable/data.table/issues/21). Thanks indirectly to Malcolm Cook for [#52](https://github.com/Rdatatable/data.table/issues/52), through which this (recent) regression (from 1.9.3) was found.

  24.  `print(DT)` now respects `digits` argument on list type columns, [#37](https://github.com/Rdatatable/data.table/issues/37). Thanks to Frank for the discussion on the mailing list and to Matthew Beckers for filing the bug report.

  25.  FR # 2551 implemented leniance in warning messages when columns are coerced with `DT[, LHS := RHS]`, when `length(RHS)==1`. But this was very lenient; e.g., `DT[, a := "bla"]`, where `a` is a logical column should get a warning. This is now fixed such that only very obvious cases coerces silently; e.g., `DT[, a := 1]` where `a` is `integer`. Closes [#35](https://github.com/Rdatatable/data.table/issues/35). Thanks to Michele Carriero and John Laing for reporting.

  26.  `dcast.data.table` provides better error message when `fun.aggregate` is specified but it returns length != 1. Closes [#693](https://github.com/Rdatatable/data.table/issues/693). Thanks to Trevor Alexander for reporting [here on SO](http://stackoverflow.com/questions/24152733/undocumented-error-in-dcast-data-table).

  27.  `dcast.data.table` tries to preserve attributes whereever possible, except when `value.var` is a `factor` (or ordered factor). For `factor` types, the casted columns will be coerced to type `character` thereby losing the `levels` attribute. Closes [#688](https://github.com/Rdatatable/data.table/issues/688). Thanks to juancentro for reporting.

  28.  `melt` now returns friendly error when `meaure.vars` are not in data instead of segfault. Closes [#699](https://github.com/Rdatatable/data.table/issues/688). Thanks to vsalmendra for [this post on SO](http://stackoverflow.com/q/24326797/559784) and the subsequent bug report.

  29.  `DT[, list(m1 = eval(expr1), m2=eval(expr2)), by=val]` where `expr1` and `expr2` are constructed using `parse(text=.)` now works instead of resulting in error. Closes [#472](https://github.com/Rdatatable/data.table/issues/472). Thanks to Benjamin Barnes for reporting with a nice reproducible example.

  30.  A join of the form `X[Y, roll=TRUE, nomatch=0L]` where some of Y's key columns occur more than once (duplicated keys) might at times return incorrect join. This was introduced only in 1.9.2 and is fixed now. Closes [#700](https://github.com/Rdatatable/data.table/issues/472). Thanks to Michael Smith for the very nice reproducible example and nice spotting of such a tricky case.

  31.  Fixed an edge case in `DT[order(.)]` internal optimisation to be consistent with base. Closes [#696](https://github.com/Rdatatable/data.table/issues/696). Thanks to Michael Smith and Garrett See for reporting.

  32.  `DT[, list(list(.)), by=.]` and `DT[, col := list(list(.)), by=.]` now return correct results in R >= 3.1.0. The bug was due to a welcome change in R 3.1.0 where `list(.)` no longer copies. Closes [#481](https://github.com/Rdatatable/data.table/issues/481). Also thanks to KrishnaPG for filing [#728](https://github.com/Rdatatable/data.table/issues/728).

  33.  `dcast.data.table` handles `fun.aggregate` argument properly when called from within a function that accepts `fun.aggregate` argument and passes to `dcast.data.table()`. Closes [#713](https://github.com/Rdatatable/data.table/issues/713). Thanks to mathematicalcoffee for reporting [here](http://stackoverflow.com/q/24542976/559784) on SO.

  34.  `dcast.data.table` now returns a friendly error when fun.aggregate value for missing combinations is 0-length, and 'fill' argument is not provided. Closes [#715](https://github.com/Rdatatable/data.table/issues/715)

  35.  `rbind/rbindlist` binds in the same order of occurrence also when binding tables with duplicate names along with 'fill=TRUE' (previously, it grouped all duplicate columns together). This was the underlying reason for [#725](https://github.com/Rdatatable/data.table/issues/715). Thanks to Stefan Fritsch for the report with a nice reproducible example and discussion.

  36.  `setDT` now provides a friendly error when attempted to change a variable to data.table by reference whose binding is locked (usually when the variable is within a package, ex: CO2). Closes [#475](https://github.com/Rdatatable/data.table/issues/475). Thanks to David Arenburg for filing the report [here](http://stackoverflow.com/questions/23361080/error-in-setdt-from-data-table-package) on SO.

  37.  `X[!Y]` where `X` and `Y` are both data.tables ignores 'allow.cartesian' argument, and rightly so because a not-join (or anti-join) cannot exceed nrow(x). Thanks to @fedyakov for spotting this. Closes [#698](https://github.com/Rdatatable/data.table/issues/698).

  38.  `as.data.table.matrix` does not convert strings to factors by default. `data.table` likes and prefers using character vectors to factors. Closes [#745](https://github.com/Rdatatable/data.table/issues/698). Thanks to @fpinter for reporting the issue on the github issue tracker and to vijay for reporting [here](http://stackoverflow.com/questions/17691050/data-table-still-converts-strings-to-factors) on SO.

  39.  Joins of the form `x[y[z]]` resulted in duplicate names when all `x`, `y` and `z` had the same column names as non-key columns. This is now fixed. Closes [#471](https://github.com/Rdatatable/data.table/issues/471). Thanks to Christian Sigg for the nice reproducible example.

  40. `DT[where, someCol:=NULL]` is now an error that `i` is provided since it makes no sense to delete a column for only a subset of rows. Closes [#506](https://github.com/Rdatatable/data.table/issues/506).

  41. `forder` did not identify `-0` as `0` for numeric types. This is fixed now. Thanks to @arcosdium for nice minimal example. Closes [#743](https://github.com/Rdatatable/data.table/issues/743).

  42. Segfault on joins of the form `X[Y, c(..), by=.EACHI]` is now fixed. Closes [#744](https://github.com/Rdatatable/data.table/issues/744). Thanks to @nigmastar (Michele Carriero) for the excellent minimal example. 

  43. Subset on data.table using `lapply` of the form `lapply(L, "[", Time == 3L)` works now without error due to `[.data.frame` redirection. Closes [#500](https://github.com/Rdatatable/data.table/issues/500). Thanks to Garrett See for reporting.

  44. `id.vars` and `measure.vars` default value of `NULL` was removed to be consistent in behaviour with `reshape2:::melt.data.frame`. Closes [#780](https://github.com/Rdatatable/data.table/issues/780). Thanks to @dardesta for reporting.

  45. Grouping using external variables on keyed data.tables did not return correct results at times. Thanks to @colinfang for reporting. Closes [#762](https://github.com/Rdatatable/data.table/issues/762).

#### NOTES

  1.  Reminder: using `rolltolast` still works but since v1.9.2 now issues the following warning:
     > 'rolltolast' has been marked 'deprecated' in ?data.table since v1.8.8 on CRAN 3 Mar 2013, see NEWS. Please change to the more flexible 'rollends' instead. 'rolltolast' will be removed in the next version."

  2.  Using `with=FALSE` with `:=` is now deprecated in all cases, given that wrapping the LHS of `:=` with parentheses has been preferred for some time.
    ```R
    colVar = "col1"
    DT[, colVar:=1, with=FALSE]                   # deprecated, still works silently as before
    DT[, (colVar):=1]                             # please change to this
    DT[, c("col1","col2"):=1]                     # no change
    DT[, 2:4 := 1]                                # no change
    DT[, c("col1","col2"):=list(sum(a),mean(b)]   # no change
    DT[, `:=`(...), by=...]                       # no change
    ```
    The next release will issue a warning when `with=FALSE` is used with `:=`.

  3.  `?duplicated.data.table` explained that `by=NULL` or `by=FALSE` would use all columns, however `by=FALSE` resulted in error. `by=FALSE` is removed from help and `duplicated` returns an error when `by=TRUE/FALSE` now. Closes [#38](https://github.com/Rdatatable/data.table/issues/38).
     
  4.  More info about distinguishing small numbers from 0.0 in v1.9.2+ is [here](http://stackoverflow.com/questions/22290544/grouping-very-small-numbers-e-g-1e-28-and-0-0-in-data-table-v1-8-10-vs-v1-9-2).

  5.  `?dcast.data.table` now explains how the names are generated for the columns that are being casted. Closes **#5676**.
  
  6.  `dcast.data.table(dt, a ~ ... + b)` now generates the column names with values from `b` coming last. Closes **#5675**.

  7.  Added `x[order(.)]` internal optimisation, and how to go back to `base:::order(.)` if one wants to sort by session locale to 
     `?setorder` (with alias `?order` and `?forder`). Closes [#478](https://github.com/Rdatatable/data.table/issues/478) and 
     also [#704](https://github.com/Rdatatable/data.table/issues/704). Thanks to Christian Wolf for the report.

  8.  Added tests (1351.1 and 1351.2) to catch any future regressions on particular case of binary search based subset reported [here](http://stackoverflow.com/q/24729001/559784) on SO. Thanks to Scott for the post. The regression was contained to v1.9.2 AFAICT. Closes [#734](https://github.com/Rdatatable/data.table/issues/704).

  9.  Added an `.onUnload` method to unload `data.table`'s shared object properly. Since the name of the shared object is 'datatable.so' and not 'data.table.so', 'detach' fails to unload correctly. This was the reason for the issue reported [here](http://stackoverflow.com/questions/23498804/load-detach-re-load-anomaly) on SO. Closes [#474](https://github.com/Rdatatable/data.table/issues/474). Thanks to Matthew Plourde for reporting.

  10.  Updated `BugReports` link in DESCRIPTION. Thanks to @chrsigg for reporting. Closes [#754](https://github.com/Rdatatable/data.table/issues/754).

  11. Added `shiny`, `rmarkdown` and `knitr` to the data.table whitelist. Packages which take user code as input and run it in their own environment (so do not `Depend` or `Import` `data.table` themselves) either need to be added here, or they can define a variable `.datatable.aware <- TRUE` in their namepace, so that data.table can work correctly in those packages. Users can also add to `data.table`'s whitelist themselves using `assignInNamespace()` but these additions upstream remove the need to do that for these packages.

  12. Clarified `with=FALSE` as suggested in [#513](https://github.com/Rdatatable/data.table/issues/513).

  13. Clarified `.I` in `?data.table`. Closes [#510](https://github.com/Rdatatable/data.table/issues/510). Thanks to Gabor for reporting.

  14. Moved `?copy` to its own help page, and documented that `dt_names <- copy(names(DT))` is necessary for `dt_names` to be not modified by reference as a result of updating `DT` by reference (e.g. adding a new column by reference). Closes [#512](https://github.com/Rdatatable/data.table/issues/512). Thanks to Zach for [this SO question](http://stackoverflow.com/q/15913417/559784) and user1971988 for [this SO question](http://stackoverflow.com/q/18662715/559784).
  
  15. `address(x)` doesn't increment `NAM()` value when `x` is a vector. Using the object as argument to a non-primitive function is sufficient to increment its reference. Closes #824. Thanks to @tarakc02 for the [question on twitter](https://twitter.com/tarakc02/status/513796515026837504) and hint from Hadley.
  
---

### Changes in v1.9.2 (on CRAN 27 Feb 2014)

#### NEW FEATURES

  1.  Fast methods of `reshape2`'s `melt` and `dcast` have been implemented for `data.table`, **FR #2627**. Most settings are identical to `reshape2`, see `?melt.data.table.`
    > `melt`: 10 million rows and 5 columns, 61.3 seconds reduced to 1.2 seconds.  
    > `dcast`: 1 million rows and 4 columns, 192 seconds reduced to 3.6 seconds.  
     
      * `melt.data.table` is also capable of melting on columns of type `list`.
      * `melt.data.table` gains `variable.factor` and `value.factor` which by default are TRUE and FALSE respectively for compatibility with `reshape2`. This allows for directly controlling the output type of "variable" and "value" columns (as factors or not).
      * `melt.data.table`'s `na.rm = TRUE` parameter is optimised to remove NAs directly during melt and therefore avoids the overhead of subsetting using `!is.na` afterwards on the molten data. 
      * except for `margins` argument from `reshape2:::dcast`, all features of dcast are intact. `dcast.data.table` can also accept `value.var` columns of type list.
    
    > Reminder of Cologne (Dec 2013) presentation **slide 32** : ["Why not submit a dcast pull request to reshape2?"](https://github.com/Rdatatable/data.table/wiki/talks/CologneR_2013.pdf).
  
  2.  Joins scale better as the number of rows increases. The binary merge used to start on row 1 of i; it now starts on the middle row of i. Many thanks to Mike Crowe for the suggestion. This has been done within column so scales much better as the number of join columns increase, too. 

    > Reminder: bmerge allows the rolling join feature: forwards, backwards, limited and nearest.  

  3.  Sorting (`setkey` and ad-hoc `by=`) is faster and scales better on randomly ordered data and now also adapts to almost sorted data. The remaining comparison sorts have been removed. We use a combination of counting sort and forwards radix (MSD) for all types including double, character and integers with range>100,000; forwards not backwards through columns. This was inspired by [Terdiman](http://codercorner.com/RadixSortRevisited.htm) and [Herf's](http://stereopsis.com/radix.html) (LSD) radix approach for floating point :

  4.  `unique` and `duplicated` methods for `data.table` are significantly faster especially for type numeric (i.e. double), and type integer where range > 100,000 or contains negatives.
     
  5.  `NA`, `NaN`, `+Inf` and `-Inf` are now considered distinct values, may be in keys, can be joined to and can be grouped. `data.table` defines: `NA` < `NaN` < `-Inf`. Thanks to Martin Liberts for the suggestions, #4684, #4815 and #4883. 
  
  6.  Numeric data is still joined and grouped within tolerance as before but instead of tolerance being `sqrt(.Machine$double.eps) == 1.490116e-08` (the same as `base::all.equal`'s default) the significand is now rounded to the last 2 bytes, apx 11 s.f. This is more appropriate for large (1.23e20) and small (1.23e-20) numerics and is faster via a simple bit twiddle. A few functions provided a 'tolerance' argument but this wasn't being passed through so has been removed. We aim to add a global option (e.g. 2, 1 or 0 byte rounding) in a future release.
     
  7.  New optimization: **GForce**. Rather than grouping the data, the group locations are passed into grouped versions of sum and mean (`gsum` and `gmean`) which then compute the result for all groups in a single sequential pass through the column for cache efficiency. Further, since the g* function is called just once, we don't need to find ways to speed up calling sum or mean repetitively for each group. Plan is to add `gmin`, `gmax`, `gsd`, `gprod`, `gwhich.min` and `gwhich.max`. Examples where GForce applies now:
    ```R
    DT[,sum(x,na.rm=),by=...]                       # yes
    DT[,list(sum(x,na.rm=),mean(y,na.rm=)),by=...]  # yes
    DT[,lapply(.SD,sum,na.rm=),by=...]              # yes
    DT[,list(sum(x),min(y)),by=...]                 # no. gmin not yet available, only sum and mean so far.
    ```
    GForce is a level 2 optimization. To turn it off: `options(datatable.optimize=1)`. Reminder: to see the optimizations and other info, set `verbose=TRUE`

  8.  fread's `integer64` argument implemented. Allows reading of `integer64` data as 'double' or 'character' instead of `bit64::integer64` (which remains the default as before). Thanks to Chris Neff for the suggestion. The default can be changed globally; e.g, `options(datatable.integer64="character")`
     
  9.  fread's `drop`, `select` and `NULL` in `colClasses` are implemented. To drop or select columns by name or by number. See examples in `?fread`.
     
  10.  fread now detects `T`, `F`, `True`, `False`, `TRUE` and `FALSE` as type logical, consistent with `read.csv`, #4766. Thanks to Adam November for highlighting.
  
  11.  fread now accepts quotes (both `'` and `"`) in the middle of fields, whether the field starts with `"` or not, rather than the 'unbalanced quotes' error, #2694. Thanks to baidao for reporting. It was known and documented at the top of `?fread` (now removed). If a field starts with `"` it must end with `"` (necessary to include the field separator itself in the field contents). Embedded quotes can be in column names, too. Newlines (`\n`) still can't be in quoted fields or quoted column names, yet.
     
  12.  fread gains `showProgress`, default TRUE. The global option is `datatable.showProgress`.
     
  13.  `fread("1.46761e-313\n")` detected the **ERANGE** error, so read as `character`. It now reads as numeric but with a detailed warning. Thanks to Heather Turner for the detailed report, #4879.
     
  14.  fread now understand system commands; e.g., `fread("grep blah file.txt")`.

  15.  `as.data.table` method for `table()` implemented, #4848. Thanks to Frank Pinter for suggesting [here on SO](http://stackoverflow.com/questions/18390947/data-table-of-table-is-very-different-from-data-frame-of-table).
  
  16.  `as.data.table` methods added for integer, numeric, character, logical, factor, ordered and Date.
	 
  17.  `DT[i,:=,]` now accepts negative indices in `i`. Thanks to Eduard Antonyan. See also bug fix #2697.

  18.  `set()` is now able to add new columns by reference, #2077.
    ```R
    DT[3:5, newCol := 5L]
    set(DT, i=3:5, j="newCol", 5L)   # same
    ```

  19.  eval will now be evaluated anywhere in a `j`-expression as long as it has just one argument, #4677. Will still need to use `.SD` as environment in complex cases. Also fixes bug [here on SO](http://stackoverflow.com/a/19054962/817778).

  20.  `!` at the head of the expression will no longer trigger a not-join if the expression is logical, #4650. Thanks to Arunkumar Srinivasan for reporting.

  21.  `rbindlist` now chooses the highest type per column, not the first, #2456. Up-conversion follows R defaults, with the addition of factors being the highest type. Also fixes #4981 for the specific case of `NA`'s.

  22.  `cbind(x,y,z,...)` now creates a data.table if `x` isn't a `data.table` but `y` or `z` is, unless `x` is a `data.frame` in which case a `data.frame` is returned (use `data.table(DF,DT)` instead for that). 
  
  23.  `cbind(x,y,z,...)` and `data.table(x,y,z,...)` now retain keys of any `data.table` inputs directly (no sort needed, for speed). The result's key is `c(key(x), key(y), key(z), ...)`, provided, that the data.table inputs that have keys are not recycled and there are no ambiguities (i.e. duplicates) in column names.

  24.  `rbind/rbindlist` will preserve ordered factors if it's possible to do so; i.e., if a compatible global order exists, #4856 & #5019. Otherwise the result will be a `factor` and a *warning*.

  25.  `rbind` now has a `fill` argument, #4790. When `fill=TRUE` it will behave in a manner similar to plyr's `rbind.fill`. This option is incompatible with `use.names=FALSE`. Thanks to Arunkumar Srinivasan for the base code.

  26.  `rbind` now relies exclusively on `rbindlist` to bind `data.tables` together. This makes rbind'ing factors faster, #2115.

  27.  `DT[, as.factor('x'), with=FALSE]` where `x` is a column in `DT` is now equivalent to `DT[, "x", with=FALSE]` instead of ending up with an error, #4867. Thanks to tresbot for reporting [here on SO](http://stackoverflow.com/questions/18525976/converting-multiple-data-table-columns-to-factors-in-r).

  28.  `format.data.table` now understands 'formula' and displays embedded formulas as expected, FR #2591.

  29.  `{}` around `:=` in `j` now obtain desired result, but with a warning #2496. Now, 
    ```R
    DT[, { `:=`(...)}]             # now works
    DT[, {`:=`(...)}, by=(...)]    # now works
    ```
    Thanks to Alex for reporting [here on SO](http://stackoverflow.com/questions/14541959/expression-syntax-for-data-table-in-r).

  30.  `x[J(2), a]`, where `a` is the key column sees `a` in `j`, #2693 and FAQ 2.8. Also, `x[J(2)]` automatically names the columns from `i` using the key columns of `x`. In cases where the key columns of `x` and `i` are identical, i's columns can be referred to by using `i.name`; e.g., `x[J(2), i.a]`. Thanks to mnel and Gabor for the discussion [here](http://r.789695.n4.nabble.com/Problem-with-FAQ-2-8-tt4668878.html).

  31.  `print.data.table` gains `row.names`, default=TRUE. When FALSE, the row names (along with the :) are not printed, #5020. Thanks to Frank Erickson.

  32.  `.SDcols` now is also able to de-select columns. This works both with column names and column numbers.
    ```R
    DT[, lapply(.SD,...), by=..., .SDcols=-c(1,3)]       # .SD all but columns 1 and 3
    DT[, lapply(.SD,...), by=..., .SDcols=-c("x", "z")]  # .SD all but columns 'x' and 'z'
    DT[..., .SDcols=c(1, -3)]           # can't mix signs, error
    DT[, .SD, .SDcols=c("x", -"z")]     # can't mix signs, error
    ```
    Thanks to Tonny Peterson for filing FR #4979.

  33.  `as.data.table.list` now issues a warning for those items/columns that result in a remainder due to recycling, #4813. `data.table()` also now issues a warning (instead of an error previously) when recycling leaves a remainder; e.g., `data.table(x=1:2, y=1:3)`.

  34.  `:=` now coerces without warning when precision is not lost and `length(RHS) == 1`, #2551.
    ```R
    DT = data.table(x=1:2, y=c(TRUE, FALSE))
    DT[1, x:=1]   # ok, now silent
    DT[1, y:=0]   # ok, now silent
    DT[1, y:=0L]  # ok, now silent
    ```

  35.  `as.data.table.*(x, keep.rownames=TRUE)`, where `x` is a named vector now adds names of `x` into a new column with default name `rn`. Thanks to Garrett See for FR #2356.

  36.  `X[Y, col:=value]` when no match exists in the join is now caught early and X is simply returned. Also a message when `datatable.verbose` is TRUE is provided. In addition, if `col` is an existing column, since no update actually takes place, the key is now retained. Thanks to Frank Erickson for suggesting, #4996.

  37.  New function `setDT()` takes a `list` (named and/or unnamed) or `data.frame` and changes its type by reference to `data.table`, *without any copy*. It also has a logical argument `giveNames` which is used for a list inputs. See `?setDT` examples for more. Based on [this FR on SO](http://stackoverflow.com/questions/20345022/convert-a-data-frame-to-a-data-table-without-copy/20346697#20346697).
     
  38.  `setnames(DT,"oldname","newname")` no longer complains about any duplicated column names in `DT` so long as oldname is unique and unambiguous. Thanks to Wet Feet for highlighting [here on SO](http://stackoverflow.com/questions/20942905/ignore-safety-check-when-using-setnames).

  39.  `last(x)` where `length(x)=0` now returns 'x' instead of an error, #5152. Thanks to Garrett See for reporting.

  40.  `as.ITime.character` no longer complains when given vector input, and will accept mixed format time entries; e.g., c("12:00", "13:12:25")
     
  41.  Key is now retained in `NA` subsets; e.g.,
    ```R
    DT = data.table(a=1:3,b=4:6,key="a")
    DT[NA]   # 1-row of NA now keyed by 'a'
    DT[5]    # 1-row of NA now keyed by 'a'
    DT[2:4]  # not keyed as before because NA (last row of result) sorts first in keyed data.table
    ```

  42.  Each column in the result for each group has always been recycled (if necessary) to match the longest column in that group's result. If it doesn't recycle exactly, though, it was caught gracefully as an error. Now, it is recycled, with remainder with warning.
    ```R  
    DT = data.table(a=1:2,b=1:6)
    DT[, list(b,1:2), by=a]        # now recycles the 1:2 with warning to length 3
    ```

#### BUG FIXES

  1.  Long outstanding (usually small) memory leak in grouping fixed, #2648. When the last group is smaller than the largest group, the difference in those sizes was not being released. Also evident in non-trivial aggregations where each group returns a different number of rows. Most users run a grouping
     query once and will never have noticed these, but anyone looping calls to grouping (such as when running in parallel, or benchmarking) may have suffered. Tests added. Thanks to many including vc273 and Y T for reporting [here](http://stackoverflow.com/questions/20349159/memory-leak-in-data-table-grouped-assignment-by-reference) and [here](http://stackoverflow.com/questions/15651515/slow-memory-leak-in-data-table-when-returning-named-lists-in-j-trying-to-reshap) on SO.

  2.  In long running computations where data.table is called many times repetitively the following error could sometimes occur, #2647: *"Internal error: .internal.selfref prot is not itself an extptr"*. Now fixed. Thanks to theEricStone, StevieP and JasonB for (difficult) reproducible examples [here](http://stackoverflow.com/questions/15342227/getting-a-random-internal-selfref-error-in-data-table-for-r).
       
  3.  If `fread` returns a data error (such as no closing quote on a quoted field) it now closes the file first rather than holding a lock open, a Windows only problem.
     Thanks to nigmastar for reporting [here](http://stackoverflow.com/questions/18597123/fread-data-table-locks-files) and Carl Witthoft for the hint. Tests added.
       
  4.  `DT[0,col:=value]` is now a helpful error rather than crash, #2754. Thanks to Ricardo Saporta for reporting. `DT[NA,col:=value]`'s error message has also been improved. Tests added.
     
  5.  Assigning to the same column twice in the same query is now an error rather than a crash in some circumstances; e.g., `DT[,c("B","B"):=NULL]` (delete by reference the same column twice). Thanks to Ricardo (#2751) and matt_k (#2791) for reporting [here](http://stackoverflow.com/questions/16638484/remove-multiple-columns-from-data-table). Tests added.
  
  6.  Crash and/or incorrect aggregate results with negative indexing in `i` is fixed, with a warning when the `abs(negative index) > nrow(DT)`, #2697. Thanks to Eduard Antonyan (eddi) for reporting [here](http://stackoverflow.com/questions/16046696/data-table-bug-causing-a-segfault-in-r). Tests added.
  
  7.  `head()` and `tail()` handle negative `n` values correctly now, #2375. Thanks to Garrett See for reporting. Also it results in an error when `length(n) != 1`. Tests added.
     
  8.  Crash when assigning empty data.table to multiple columns is fixed, #4731. Thanks to Andrew Tinka for reporting. Tests added.
     
  9.  `print(DT, digits=2)` now heeds digits and other parameters, #2535. Thanks to Heather Turner for reporting. Tests added.
     
  10.  `print(data.table(table(1:101)))` is now an 'invalid column' error and suggests `print(as.data.table(table(1:101)))` instead, #4847. Thanks to Frank Pinter for reporting. Test added.

  11.  Crash when grouping by character column where `i` is `integer(0)` is now fixed. It now returns an appropriate empty data.table. This fixes bug #2440. Thanks to Malcolm Cook for reporting. Tests added.

  12.  Grouping when i has value '0' and `length(i) > 1` resulted in crash; it is now fixed. It returns a friendly error instead. This fixes bug #2758. Thanks to Garrett See for reporting. Tests added.

  13.  `:=` failed while subsetting yielded NA and `with=FALSE`, #2445. Thanks to Damian Betebenner for reporting.

  14.  `by=month(date)` gave incorrect results if `key(DT)=="date"`, #2670. Tests added. 
    ```R
    DT[,,by=month(date)]         # now ok if key(DT)=="date"
    DT[,,by=list(month(date))]   # ok before whether or not key(DT)=="date"
    ```
         
  15.  `rbind` and `rbindlist` could crash if input columns themselves had hidden names, #4890 & #4912. Thanks to Chris Neff and Stefan Fritsch for reporting. Tests added.
     
  16.  `data.table()`, `as.data.table()` and other paths to create a data.table now detect and drop hidden names, the root cause of #4890. It was never intended that columns could have hidden names attached.

  17.  Cartesian Join (`allow.cartesian = TRUE`) when both `x` and `i` are keyed and `length(key(x)) > length(key(i))` set resulting key incorrectly. This is now fixed, #2677. Tests added. Thanks to Shir Levkowitz for reporting.

  18.  `:=` (assignment by reference) loses POSIXct or ITime attribute *while grouping* is now fixed, #2531. Tests added. Thanks to stat quant for reporting [here](http://stackoverflow.com/questions/14604820/why-does-this-posixct-or-itime-loses-its-format-attribute) and to Paul Murray for reporting [here](http://stackoverflow.com/questions/15996692/cannot-assign-columns-as-date-by-reference-in-data-table) on SO.

  19.  `chmatch()` didn't always match non-ascii characters, #2538 and #4818. chmatch is used internally so `DT[is.na(päs), päs := 99L]` now works. Thanks to Benjamin Barnes and Stefan Fritsch for reporting. Tests added.

  20.  `unname(DT)` threw an error when `20 < nrow(DT) <= 100`, bug #4934. This is now fixed. Tests added. Thanks to Ricardo Saporta.

  21.  A special case of not-join and logical TRUE, `DT[!TRUE]`, gave an error whereas it should be identical to `DT[FALSE]`. Now fixed and tests added. Thanks once again to Ricardo Saporta for filing #4930.
     
  22.  `X[Y,roll=-Inf,rollends=FALSE]` didn't roll the middle correctly if `Y` was keyed. It was ok if `Y` was unkeyed or rollends left as the default [c(TRUE,FALSE) when roll < 0]. Thanks to user338714 for reporting [here](http://stackoverflow.com/questions/18984179/roll-data-table-with-rollends). Tests added.

  23.  Key is now retained after an order-preserving subset, #295.

  24.  Fixed bug #2584. Now columns that had function names, in particular "list" do not pose problems in `.SD`. Thanks to Zachary Mayer for reporting.

  25.  Fixed bug #4927. Unusual column names in normal quotes, ex: `by=".Col"`, now works as expected in `by`. Thanks to Ricardo Saporta for reporting.

  26.  `setkey` resulted in error when column names contained ",". This is now fixed. Thanks to Corone for reporting [here](http://stackoverflow.com/a/19166273/817778) on SO.

  27.  `rbind` when at least one argument was a data.table, but not the first, returned the rbind'd data.table with key. This is now fixed, #4995. Thanks to Frank Erickson for reporting.
 
  28.  That `.SD` doesn't retain column's class is now fixed (#2530). Thanks to Corone for reporting [here](http://stackoverflow.com/questions/14753411/why-does-data-table-lose-class-definition-in-sd-after-group-by).

  29.  `eval(quote())` returned error when the quoted expression is a not-join, #4994. This is now fixed. Tests added.

  30.  `DT[, lapply(.SD, function(), by=]` did not see columns of DT when optimisation is "on". This is now fixed, #2381. Tests added. Thanks to David F for reporting [here](http://stackoverflow.com/questions/13441868/data-table-and-stratified-means) on SO.

  31.  #4959 - rbind'ing empty data.tables now works

  32.  #5005 - some function expressions were not being correctly evaluated in j-expression. Thanks to Tonny Petersen for reporting.

  33.  Fixed bug #5007, `j` did not see variables declared within a local (function) environment properly. Now, `DT[, lapply(.SD, function(x) fun_const), by=x]` where "fun_const" is a local variable within a function works as expected. Thanks to Ricardo Saporta for catching this and providing a very nice reproducible      example.

  34.  Fixing #5007 also fixes #4957, where `.N` was not visible during `lapply(.SD, function(x) ...)` in `j`. Thanks to juba for noticing it [here](http://stackoverflow.com/questions/19094771/replace-values-in-each-column-based-on-conditions-according-to-groups-by-rows) on SO.
  
  35.  Fixed another case where function expressions were not constructed properly in `j`, while fixing #5007. `DT[, lapply(.SD, function(x) my_const), by=x]` now works as expected instead of ending up in an error.

  36.  Fixed #4990, where `:=` did not generate a recycling warning during `by`, when `length(RHS) < group` size but not an integer multiple of group size. Now, 
    ```R
    DT <- data.table(a=rep(1:2, c(5,2)))
    DT[, b := c(1:2), by=a]
    ``` 
       will generate a warning (here for first group as RHS length (2) is not an integer multiple of group size (=5)). 

  37.  Fixed #5069 where `gdata:::write.fwf` returned an error with data.table.

  38.  Fixed #5098 where construction of `j`-expression with a function with no-argument returned the function definition instead of returning the result from executing the function.

  39.  Fixed #5106 where `DT[, .N, by=y]` where `y` is a vector with `length(y) = nrow(DT)`, but `y` is not a column in `DT`. Thanks to colinfang for reporting.

  40.  Fixed #5104 which popped out as a side-effect of fixing #2531. `:=` while grouping and assigning columns that are factors resulted in wrong results (and the column not being added). This is now fixed. Thanks to Jonathen Owen for reporting.

  41.  Fixed bug #5114 where modifying columns in particular cases resulted in ".SD is locked" error. Thanks to GSee for the bug report.

  42.  Implementing FR #4979 lead to a bug when grouping with .SDcols, where .SDcols argument was variable name. This bug #5190 is now fixed.

  43.  Fixed #5171 - where setting the attribute name to a non-character type resulted in a segfault. Ex: `setattr(x, FALSE, FALSE); x`. Now ends up with a friendly error.
     
  44.  Dependent packages using `cbind` may now *Import* data.table as intended rather than needing to *Depend*. There was a missing `data.table::` prefix on a call to `key()`. Thanks to Maarten-Jan Kallen for reporting.
     
  45.  'chmatch' didn't handle character encodings properly when the string was identical but the encoding were different. For ex: `UTF8` and `Latin1`. This is now fixed (a part of bug #5159). Thanks to Stefan Fritsch for reporting.

  46.  Joins (`X[Y]`) on character columns with different encodings now issue a warning that join may result in unexpected results for those indices with different encodings. That is, when "ä" in X's key column and "ä" in Y's key column are of different encodings, a warning is issued. This takes care of bugs #5266 and other part of #5159 for the moment. Thanks to Stefan Fritsch once again for reporting.

  47.  Fixed #5117 - segfault when `rbindlist` on empty data.tables. Thanks to Garrett See for reporting.

  48.  Fixed a rare segfault that occurred on >250m rows (integer overflow during memory allocation); closes #5305. Thanks to Guenter J. Hitsch for reporting.

  49.  `rbindlist` with at least one factor column along with the presence of at least one empty data.table resulted in segfault (or in linux/mac reported an error related to hash tables). This is now fixed, #5355. Thanks to Trevor Alexander for [reporting on SO](http://stackoverflow.com/questions/21591433/merging-really-not-that-large-data-tables-immediately-results-in-r-being-killed) (and mnel for filing the bug report): 
     
  50.  `CJ()` now orders character vectors in a locale consistent with `setkey`, #5375. Typically this affected whether upper case letters were ordered before lower case letters; they were by `setkey()` but not by `CJ()`. This difference started in v1.8.10 with the change "CJ() is 90% faster...", see NEWS below. Test added and avenues for differences closed off and nailed down, with no loss in performance. Many thanks to Malcolm Hawkes for reporting.

#### THANKS FOR BETA TESTING TO :

  1.  Zach Mayer for a reproducible segfault related to radix sorting character strings longer than 20. Test added.
     
  2.  Simon Biggs for reporting a bug in fread'ing logicals. Test added.
  
  3.  Jakub Szewczyk for reporting that where "." is used in formula interface of `dcast.data.table` along with an aggregate function, it did not result in aggregated result, #5149. Test added.
    ```R
    dcast.data.table(x, a ~ ., mean, value.var="b")
    ```
     
  4.  Jonathan Owen for reporting that `DT[,sum(.SD),by=]` failed with GForce optimization, #5380. Added test and error message redirecting to use `DT[,lapply(.SD,sum),by=]` or `base::sum` and how to turn off GForce.
     
  5.  Luke Tierney for guidance in finding a corruption of `R_TrueValue` which needed `--enable-strict-barier`, `gctorture2` and a hardware watchpoint to ferret out. Started after a change in Rdevel on 11 Feb 2014, r64973.
     
  6.  Minkoo Seo for a new test on rbindlist, #4648.
  
  7.  Gsee for reporting that `set()` and `:=` could no longer add columns by reference to an object that inherits from data.table; e.g., `class = c("myclass", data.table", "data.frame"))`, #5115.
  
  8.  Clayton Stanley for reporting #5307 [here on SO](http://stackoverflow.com/questions/21437546/data-table-1-8-11-and-aggregation-issues). Aggregating logical types could give wrong results.

  9.  New and very welcome ASAN and UBSAN checks on CRAN detected :
      * integer64 overflow in test 899 reading integers longer than apx 18 digits  
        ```R
        fread("Col1\n12345678901234567890")`   # works as before, bumped to character
        ```
      * a memory fault in rbindlist when binding ordered factors, and, some items in the list of data.table/list are empty or NULL. In both cases we had anticipated and added tests for these cases, which is why ASAN and UBSAN were able to detect a problem for us.
  
  10.  Karl Millar for reporting a similar fault that ASAN detected, #5042. Also fixed.
     
  11.  Ricardo Saporta for finding a crash when i is empty and a join column is character, #5387. Test added.

#### NOTES

  1.  If `fread` detects data which would be lost if the column was read according to type supplied in `colClasses`, e.g. a numeric column specified as integer in `colClasses`, the message that it has ignored colClasses is upgraded to warning instead of just a line in `verbose=TRUE` mode.
  
  2.  `?last` has been improved and if `xts` is needed but not installed the error message is more helpful, #2728. Thanks to Sam Steingold for reporting.
     
  3.  `?between corrected`. It returns a logical not integer vector, #2671. Thanks to Michael Nelson for reporting.
  
  4.  `.SD`, `.N`, `.I`, `.GRP` and `.BY` are now exported (as NULL). So that NOTEs aren't produced for them by `R CMD check` or `codetools::checkUsage` via compiler. `utils::globalVariables()` was considered, but exporting chosen. Thanks to Sam Steingold for raising, #2723.
     
  5.  When `DT` is empty, `DT[,col:=""]` is no longer a warning. The warning was:
      > "Supplied 1 items to be assigned to 0 items of column (1 unused)"  

  6.  Using `rolltolast` still works but now issues the following warning :  
      > "'rolltolast' has been marked 'deprecated' in ?data.table since v1.8.8 on CRAN 3 Mar 2013, see NEWS. Please
        change to the more flexible 'rollends' instead. 'rolltolast' will be removed in the next version."

  7.  There are now 1,220 raw tests, as reported by `test.data.table()`.

  8.  `data.table`'s dependency has been moved forward from R 2.12.0 to R 2.14.0, now over 2 years old (Oct 2011). As usual before release to CRAN, we ensure data.table passes `R CMD check` on the stated dependency and keep this as old as possible for as long as possible. As requested by users in managed environments. For this reason we still don't use `paste0()` internally, since that was added to R 2.15.0. 
  
---

### Changes in v1.8.10 (on CRAN 03 Sep 2013)

#### NEW FEATURES

  *  fread :
     * If some column names are blank they are now given default names rather than causing
       the header row to be read as a data row. Thanks to Simon Judes for suggesting.

     * "+" and "-" are now read as character rather than integer 0. Thanks to Alvaro Gonzalez and
       Roby Joehanes for reporting, #4814.
       http://stackoverflow.com/questions/15388714/reading-strand-column-with-fread-data-table-package

     * % progress console meter has been removed. The ouput was inconvenient in batch mode, log files and
       reports which don't handle \r. It was too difficult to detect where fread is being called from, plus,
       removing it speeds up fread a little by saving code inside the C for loop (which is why it wasn't
       made optional instead). Use your operating system's system monitor to confirm fread is progressing.
       Thanks to Baptiste for highlighting :
       http://stackoverflow.com/questions/15370993/strange-output-from-fread-when-called-from-knitr

     * colClasses has been added. Same character vector format as read.csv (may be named or unnamed), but
       additionally may be type list. Type list enables setting ranges of columns by numeric position.
       NOTE: colClasses is intended for rare overrides, not routine use.

     * fread now supports files larger than 4GB on 64bit Windows (#2767 thanks to Paul Harding) and files
       between 2GB and 4GB on 32bit Windows (#2655 thanks to Vishal). A C call to GetFileSize() needed to
       be GetFileSizeEx().

     * When input is the data as a character string, it is no longer truncated to your system's maximum
       path length, #2649. It was being passed through path.expand() even when it wasn't a filename.
       Many thanks to Timothee Carayol for the reproducible report. The limit should now be R's character
       string length limit (2^31-1 bytes = 2GB). Test added.

     * New argument 'skip' overrides automatic banner skipping. When skip>=0, 'autostart' is ignored and
       line skip+1 will be taken as the first data row, or column names according to header="auto"|TRUE|FALSE
       as usual. Or, skip="string" uses the first line containing "string" (chosen to be a substring of the
       column name row unlikely to appear earlier), inspired by read.xls in package gdata.
       Thanks to Gabor Grothendieck for these suggestions.

     * fread now stops reading if an empty line is encountered, with warning if any text exists after that
       such as a footer (the first line of which will be included in the warning message).

     * Now reads files that are open in Excel without having to close them first, #2661. And up to 5 attempts
       are made every 250ms on Windows as recommended here : http://support.microsoft.com/kb/316609.

     * "nan%" observed in output of fread(...,verbose=TRUE) timings are now 0% when fread takes 0.000 seconds.

     * An unintended 50,000 column limit in fread has been removed. Thanks to mpmorley for reporting. Test added.
       http://stackoverflow.com/questions/18449997/fread-protection-stack-overflow-error

  *  unique() and duplicated() methods gain 'by' to allow testing for uniqueness using any subset of columns,
     not just the keyed columns (if keyed) or all columns (if not). By default by=key(dt) for backwards
     compatibility. ?duplicated has been revised and tests added.
     Thanks to Arunkumar Srinivasan, Ricardo Saporta, and Frank Erickson for useful discussions.

  *  CJ() is 90% faster on 1e6 rows (for example), #4849. The inputs are now sorted first before combining
     rather than after combining and uses rep.int instead of rep (thanks to Sean Garborg for the ideas,
     code and benchmark) and only sorted if is.unsorted(), #2321.
     Reminder: CJ = Cross Join; i.e., joins to all combinations of its inputs. 
     
  *  CJ() gains 'sorted' argument, by default TRUE for backwards compatibility. FALSE retains input order and is faster
     to create the result of CJ() but then slower to join from since unkeyed.
     
  *  New function address() returns the address in RAM of its argument. Sometimes useful in determining whether a value
     has been copied or not by R, programatically.
       http://stackoverflow.com/a/10913296/403310

#### BUG FIXES

  *  merge no longer returns spurious NA row(s) when y is empty and all.y=TRUE (or all=TRUE), #2633. Thanks
     to Vinicius Almendra for reporting. Test added.
       http://stackoverflow.com/questions/15566250/merge-data-table-with-all-true-introduces-na-row-is-this-correct

  *  rbind'ing data.tables containing duplicate, "" or NA column names now works, #2726 & #2384.
     Thanks to Garrett See and Arun Srinivasan for reporting. This also affected the printing of data.tables
     with duplicate column names since the head and tail are rbind-ed together internally.

  *  rbind, cbind and merge on data.table should now work in packages that Import but do not
     Depend on data.table. Many thanks to a patch to .onLoad from Ken Williams, and related
     posts from Victor Kryukov :
	   http://r.789695.n4.nabble.com/Import-problem-with-data-table-in-packages-tp4665958.html

  *  Mixing adding and updating into one DT[, `:=`(existingCol=...,newCol=...), by=...] now works
     without error or segfault, #2778 and #2528. Many thanks to Arunkumar Srinivasan for reporting
     and for the nice reproducible examples. Tests added.

  *  rbindlist() now binds factor columns correctly, #2650. Thanks to many for reporting. Tests added.

  *  Deleting a (0-length) factor column using :=NULL on an empty data.table now works, #4809. Thanks
     to Frank Pinter for reporting. Test added.
       http://stackoverflow.com/questions/18089587/error-deleting-factor-column-in-empty-data-table

  *  Writing FUN= in DT[,lapply(.SD,FUN=...),] now works, #4893. Thanks to Jan Wijffels for
     reporting and Arun for suggesting and testing a fix. Committed and test added.
       http://stackoverflow.com/questions/18314757/why-cant-i-used-fun-in-lapply-when-grouping-by-using-data-table
	
  *  The slowness of transform() on data.table has been fixed, #2599. But, please use :=.
  
  *  setkey(DT,`Colname with spaces`) now works, #2452.
     setkey(DT,"Colname with spaces") worked already.
     
  *  mean() in j has been optimized since v1.8.2 (see NEWS below) but wasn't respecting na.rm=TRUE (the default).
     Many thanks to Colin Fang for reporting. Test added.
       http://stackoverflow.com/questions/18571774/data-table-auto-remove-na-in-by-for-mean-function
     

USER VISIBLE CHANGES

  *  := on a null data.table now gives a clearer error message :
       "Cannot use := to add columns to a null data.table (no columns), currently. You can use :=
        to add (empty) columns to an empty data.table (1 or more columns, all 0 length), though."
     rather than the untrue :
       "Cannot use := to add columns to an empty data.table, currently"

  *  Misuse of := and `:=`() is now caught in more circumstances and gives a clearer and shorter error message :
       ":= and `:=`(...) are defined for use in j, once only and in particular ways. See
        help(":="). Check is.data.table(DT) is TRUE."

  *  data.table(NULL) now prints "Null data.table (0 rows and 0 cols)" and FAQ 2.5 has been
     improved. Thanks to:
       http://stackoverflow.com/questions/15317536/is-null-does-not-work-on-null-data-table-in-r-possible-bug

  *  The braces {} have been removed from rollends's default, to solve a trace() problem. Thanks
	 to Josh O'Brien's investigation :
	   http://stackoverflow.com/questions/15931801/why-does-trace-edit-true-not-work-when-data-table

#### NOTES

  *  Tests 617,646 and 647 could sometimes fail (e.g. r-prerel-solaris-sparc on 7 Mar 2013)
     due to machine tolerance. Fixed.

  *  The default for datatable.alloccol has changed from max(100L, 2L*ncol(DT)) to max(100L, ncol(DT)+64L).
     And a pointer to ?truelength has been added to an error message as suggested and thanks to Roland :
       http://stackoverflow.com/questions/15436356/potential-problems-from-over-allocating-truelength-more-than-1000-times
       
  *  For packages wishing to use data.table optionally (e.g. according to user of that package) and therefore
     not wishing to Depend on data.table (which is the normal determination of data.table-awareness via .Depends),
     `.datatable.aware` may be set to TRUE in such packages which cedta() will look for, as before. But now it doesn't
     need to be exported. Thanks to Hadley Wickham for the suggestion and solution.

  *  There are now 1,009 raw tests, as reported by test.data.table().
  
  *  Welcome to Arunkumar Srinivasan and Ricardo Saporta who have joined the project and contributed directly
     by way of commits above.
     
  *  v1.8.9 was on R-Forge only. v1.8.10 was released to CRAN.
     Odd numbers are development, evens on CRAN.


### Changes in v1.8.8 (on CRAN 06 Mar 2013)

#### NEW FEATURES

    *   New function fread(), a fast and friendly file reader.
        *  header, skip, nrows, sep and colClasses are all auto detected.
        *  integers>2^31 are detected and read natively as bit64::integer64.
        *  accepts filenames, URLs and "A,B\n1,2\n3,4" directly
        *  new implementation entirely in C
        *  with a 50MB .csv, 1 million rows x 6 columns :
             read.csv("test.csv")                                        # 30-60 sec (varies)
             read.table("test.csv",<all known tricks and known nrows>)   #    10 sec
             fread("test.csv")                                           #     3 sec
        * airline data: 658MB csv (7 million rows x 29 columns)
             read.table("2008.csv",<all known tricks and known nrows>)   #   360 sec
             fread("2008.csv")                                           #    40 sec
        See ?fread. Many thanks to Chris Neff, Garrett See, Hideyoshi Maeda, Patrick
        Nic, Akhil Behl and Aykut Firat for ideas, discussions and beta testing.
        ** The fread function is still under development; e.g., dates are read as
        ** character and embedded quotes ("\"" and """") cause problems.

    *   New argument 'allow.cartesian' (default FALSE) added to X[Y] and merge(X,Y), #2464.
        Prevents large allocations due to misspecified joins; e.g., duplicate key values in Y
        joining to the same group in X over and over again. The word 'cartesian' is used loosely
        for when more than max(nrow(X),nrow(Y)) rows would be returned. The error message is
        verbose and includes advice. Thanks to a question by Nick Clark, help from user1935457
        and a detailed reproducible crash report from JR.
          http://stackoverflow.com/questions/14231737/greatest-n-per-group-reference-with-intervals-in-r-or-sql
        If the new option affects existing code you can set :
            options(datatable.allow.cartesian=TRUE)
        to restore the previous behaviour until you have time to address.

    *   In addition to TRUE/FALSE, 'roll' may now be a positive number (roll forwards/LOCF) or
        negative number (roll backwards/NOCB). A finite number limits the distance a value is
        rolled (limited staleness). roll=TRUE and roll=+Inf are equivalent.
        'rollends' is a new parameter holding two logicals. The first observation is rolled
        backwards if rollends[1] is TRUE. The last observation is rolled forwards if rollends[2]
        is TRUE. If roll is a finite number, the same limit applies to the ends.
        New value roll='nearest' joins to the nearest value (either backwards or forwards) when
        the value falls in a gap, and to the end value according to 'rollends'.
        'rolltolast' has been deprecated. For backwards compatibility it is converted to
        {roll=TRUE;rollends=c(FALSE,FALSE)}.
        This implements [r-forge FR#2300](https://github.com/Rdatatable/data.table/issues/615) & [r-forge FR#206](https://github.com/Rdatatable/data.table/issues/459) and helps several recent S.O. questions.

#### BUG FIXES

    *   setnames(DT,c(NA,NA)) is now a type error rather than a segfault, #2393.
        Thanks to Damian Betebenner for reporting.

    *   rbind() no longers warns about inputs having columns in a different order
        if use.names has been explicitly set TRUE, #2385. Thanks to Simon Judes
        for reporting.

    *   := by group with 0 length RHS could crash in some circumstances. Thanks to
        Damien Challet for the reproducible example using obfuscated data and
        pinpointing the version that regressed. Fixed and test added.

    *   Error 'attempting to roll join on a factor column' could occur when a non last
        join column was a factor column, #2450. Thanks to Blue Magister for
        highlighting.

    *   NA in a join column of type double could cause both X[Y] and merge(X,Y)
        to return incorrect results, #2453. Due to an errant x==NA_REAL in the C source
        which should have been ISNA(x). Support for double in keyed joins is a relatively
        recent addition to data.table, but embarrassing all the same. Fixed and tests added.
        Many thanks to statquant for the thorough and reproducible report :
        http://stackoverflow.com/questions/14076065/data-table-inner-outer-join-to-merge-with-na

    *   setnames() of all column names (such as setnames(DT,toupper(names(DT)))) failed on a
        keyed table where columns 1:length(key) were not the key. Fixed and test added.

    *   setkey could sort 'double' columns (such as POSIXct) incorrectly when not the
        last column of the key, #2484. In data.table's C code :
            x[a] > x[b]-tol
        should have been :
            x[a]-x[b] > -tol  [or  x[b]-x[a] < tol ]
        The difference may have been machine/compiler dependent. Many thanks to statquant
        for the short reproducible example. Test added.

    *   cbind(DT,1:n) returned an invalid data.table (some columns were empty) when DT
        had one row, #2478. Grouping now warns if j evaluates to an invalid data.table,
        to aid tracing root causes like this in future. Tests added. Many thanks to
        statquant for the reproducible example revealed by his interesting solution
        and to user1935457 for the assistance :
            http://stackoverflow.com/a/14359701/403310

    *   merge(...,all.y=TRUE) was 'setcolorder' error if a y column name included a space
        and there were rows in y not in x, #2555. The non syntactically valid column names
        are now preserved as intended. Thanks to Simon Judes for reporting. Tests added.

    *   An error in := no longer suppresses the next print, #2376; i.e.,
            > DT[,foo:=colnameTypo+1]
            Error: object 'colnameTypo' not found
            > DT    # now prints DT ok
            > DT    # used to have to type DT a second time to see it
        Many thanks to Charles, Joris Meys, and, Spacedman whose solution is now used
        by data.table internally (http://stackoverflow.com/a/13606880/403310).

#### NOTES

    *   print(DT,topn=2), where topn is provided explicitly, now prints the top and bottom 2 rows
        even when nrow(x)<100 [options()$datatable.print.nrows]. And the 'topn' argument is now first
        for easier interactive use: print(DT,2), head(DT,2) and tail(DT,2).

    *   The J() alias is now removed *outside* DT[...], but will still work inside DT[...];
        i.e., DT[J(...)] is fine. As warned in v1.8.2 (see below in this file) and deprecated
        with warning() in v1.8.4. This resolves the conflict with function J() in package
        XLConnect (#1747) and rJava (#2045).
        Please use data.table() directly instead of J(), outside DT[...].

    *   ?merge.data.table and FAQ 1.12 have been improved (#2457), and FAQ 2.24 added.
        Thanks to dnlbrky for highlighting : http://stackoverflow.com/a/14164411/403310.

    *   There are now 943 raw tests, as reported by test.data.table().

    *   v1.8.7 was on R-Forge only. v1.8.8 was released to CRAN.
        Odd numbers are development, evens on CRAN.


### Changes in v1.8.6 (on CRAN 13 Nov 2012)

#### BUG FIXES

    *   A variable in calling scope was not found when combining i, j and by in
        one query, i used that local variable, and that query occurred inside a
        function, #2368. This worked in 1.8.2, a regression. Test added.

#### COMPATIBILITY FOR R 2.12.0-2.15.0

    *   setnames used paste0() to construct its error messages, a function
        added to R 2.15.0. Reverted to use paste(). Tests added.

    *   X[Y] where Y is empty (test 764) failed due to reliance on a pmin()
        enhancement in R 2.15.1. Removed reliance.

#### NOTES

    *   test.data.table() now passes in 2.12.0, the stated dependency, as well as
        2.14.0, 2.15.0, 2.15.1, 2.15.2 and R-devel.

    *   Full R CMD check (i.e. including compatibility tests with the 9 Suggest-ed
        packages and S4 tests run using testthat which in turn depends on packages
        which depend on R >= 2.14.0) passes ok in 2.14.0 onwards.

    *   There are now 876 raw tests, as reported by test.data.table().

    *   v1.8.5 was on R-Forge only. v1.8.6 was released to CRAN.
        Odd numbers are development, evens on CRAN.


### Changes in v1.8.4 (on CRAN 9 Nov 2012)

#### NEW FEATURES

    *   New printing options have been added :
            options(datatable.print.nrows=100)
            options(datatable.print.topn=10)
        If the table to be printed has more than nrows, the top and bottom topn rows
        are printed. Otherwise, below nrows, the entire table is printed.
        Thanks to Allan Engelhardt and Melanie Bacou for useful discussions :
        http://lists.r-forge.r-project.org/pipermail/datatable-help/2012-September/001303.html
        and see FAQs 2.11 and 2.22.

    *   When one or more rows in i have no match to x and i is unkeyed, i is now
        tested to see if it is sorted. If so, the key is retained. As before, when all rows of
        i match to x, the key is retained if i matches to an ordered subset of keyed x without
        needing to test i, even if i is unkeyed.

    *   by on a keyed empty table is now keyed by the by columns, for consistency with
        the non empty case when an ordered grouping is detected.

    *   DT[,`:=`(col1=val1, col2=val2, ...)] is now valid syntax rather than a crash, #2254.
        Many thanks to Thell Fowler for the suggestion.

    *   with=FALSE is no longer needed to use column names or positions on the LHS of :=, #2120.
            DT[,c("newcol","existingcol"):=list(1L,NULL)]   # with=FALSE not needed
            DT[,`:=`(newcol=1L, existingcol:=NULL)]         # same
        If the LHS is held in a variable, the followed equivalent options are retained :
            mycols = c("existingcol","newcol")
            DT[,get("mycols"):=1L]
            DT[,eval(mycols):=1L]                # same
            DT[,mycols:=1L,with=FALSE]           # same
            DT[,c("existingcol","newcol"):=1L]   # same (with=FALSE not needed)

    *   Multiple LHS:= and `:=`(...) now work by group, and by without by. Implementing
        or fixing, and thanks to, #2215 (Florian Oswald), #1710 (Farrel Buchinsky) and
        others.
            DT[,c("newcol1","newcol2"):=list(mean(col1),sd(col1)), by=grp]
            DT[,`:=`(newcol1=mean(col1),
                     newcol2=sd(col1),
                     ...),  by=grp]                        # same but easier to read
            DT[c("grp1","grp2"), `:=`(newcol1=mean(col1),
                                      newcol2=sd(col1))]   # same using by-without-by

    *   with=FALSE now works with a symbol LHS of :=, by group (#2120) :
            colname = "newcol"
            DT[,colname:=f(),by=grp,with=FALSE]
        Thanks to Alex Chernyakov :
            http://stackoverflow.com/questions/11745169/dynamic-column-names-in-data-table-r
            http://stackoverflow.com/questions/11680579/assign-multiple-columns-using-in-data-table-by-group

    *   .GRP is a new symbol available to j. Value 1 for the first group, 2 for the 2nd, etc. Thanks
        to Josh O'Brien for the suggestion :
            http://stackoverflow.com/questions/13018696/data-table-key-indices-or-group-counter

    *   .I is a new symbol available to j. An integer vector length .N. It contains the group's row
        locations in DT. This implements FR#1962.
            DT[,.I[which.max(colB)],by=colA]      # row numbers of maxima by group

    *   A new "!" prefix on i signals 'not-join' (a.k.a. 'not-where'), #1384i.
            DT[-DT["a", which=TRUE, nomatch=0]]   # old not-join idiom, still works
            DT[!"a"]                              # same result, now preferred.
            DT[!J(6),...]                         # !J == not-join
            DT[!2:3,...]                          # ! on all types of i
            DT[colA!=6L | colB!=23L,...]          # multiple vector scanning approach (slow)
            DT[!J(6L,23L)]                        # same result, faster binary search
        '!' has been used rather than '-' :
            * to match the 'not-join'/'not-where' nomenclature
            * with '-', DT[-0] would return DT rather than DT[0] and not be backwards
              compatible. With '!', DT[!0] returns DT both before (since !0 is TRUE in
              base R) and after this new feature.
            * to leave DT[+J...] and DT[-J...] available for future use

    *   When with=FALSE, "!" may also be a prefix on j, #1384ii. This selects all but the named columns.
            DF[,-match("somecol",names(DF))]              # works when somecol exists. If not, NA causes an error.
            DF[,-match("somecol",names(DF),nomatch=0)]    # works when somecol exists. Empty data.frame when it doesn't, silently.
            DT[,-match("somecol",names(DT)),with=FALSE]   # same issues.
            DT[,setdiff(names(DT),"somecol"),with=FALSE]  # works but you have to know order of arguments, and no warning if doesn't exist
            - vs -
            DT[,!"somecol",with=FALSE]                    # works and easy to read. With (helpful) warning if somecol isn't there.
        Strictly speaking, this (!j) is a "not-select" (!i is 'not-where'). This has no analogy in SQL.
        Reminder: i is analogous to WHERE, j is analogous to SELECT and `:=` in j changes SELECT to UPDATE.
        !j when j is column positions is very similar to -j.
            DF[,-(2:3),drop=FALSE]           # all but columns 2 and 3. Careful, brackets and drop=FALSE are required.
            DT[,-(2:3),with=FALSE]           # same
            DT[,!2:3,with=FALSE]             # same
            copy(DT)[,2:3:=NULL,with=FALSE]  # same
        !j was introduced for column names really, not positions. It works for both, for consistency :
            toremove = c("somecol","anothercol")
            DT[,!toremove,with=FALSE]
            toremove = 2:3
            DT[,!toremove,with=FALSE]        # same code works without change

    *   'which' now accepts NA. This means return the row numbers in i that don't match, #1384iii.
        Thanks to Santosh Srinivas for the suggestion.
            X[Y,which=TRUE]   # row numbers of X that do match, as before
            X[!Y,which=TRUE]  # row numbers of X that don't match
            X[Y,which=NA]     # row numbers of Y that don't match
            X[!Y,which=NA]    # row numbers of Y that do match (for completeness)

    *   setnames() now works on data.frame, #2273. Thanks to Christian Hudon for the suggestion.

#### BUG FIXES

    *   A large slowdown (many minutes instead of a few secs) in X[Y] joins has been fixed, #2216.
        This occurred where the number of rows in i was large, and at least one row joined to
        more than one row in x. Possibly in other similar circumstances too. The workaround was
        to set mult="first" which is no longer required. Test added.
        Thanks to a question and report from Alex Chernyakov :
            http://stackoverflow.com/questions/12042779/time-of-data-table-join

    *   Indexing columns of data.table with a logical vector and `with=FALSE` now works as
        expected, fixing #1797. Thanks to Mani Narayanan for reporting. Test added.

    *   In X[Y,cols,with=FALSE], NA matches are now handled correctly. And if cols
        includes join columns, NA matches (if any) are now populated from i. For
        consistency with X[Y] and X[Y,list(...)]. Tests added.

    *   "Internal error" when combining join containing missing groups and group by
        is fixed, #2162. For example :
            X[Y,.N,by=NonJoinColumn]
        where Y contains some rows that don't match to X. This bug could also result in a segfault.
        Thanks to Andrey Riabushenko and Michael Schermerhorn for reporting. Tests added.

    *   On empty tables, := now changes column type and adds new 0 length columns ok, fixing
        #2274. Tests added.

    *   Deleting multiple columns out-of-order is no longer a segfault, #2223. Test added.
            DT[,c(9,2,6):=NULL]
        Reminder: deleting columns by reference is relatively instant, regardless of table size.

    *   Mixing column adds and deletes in one := gave incorrect results, #2251. Thanks to
        Michael Nelson for reporting. Test added.
            DT[,c("newcol","col1"):=list(col1+1L,NULL)]
            DT[,`:=`(newcol=col1+1L,col1=NULL)]             # same

    *   Out of bound positions in the LHS of := are now caught. Root cause of crash in #2254.
        Thanks to Thell Fowler for reporting. Tests added.
            DT[,(ncol(DT)+1):=1L]   # out of bounds error (add new columns by name only)
            DT[,ncol(DT):=1L]       # ok

    *   A recycled column plonk RHS of := no longer messes up setkey and := when used on that
        object afterwards, #2298. For example,
            DT = data.table(a=letters[3:1],x=1:3)
            DT[,c("x1","x2"):=x]  # ok (x1 and x2 are now copies of x)
            setkey(DT,a)          # now ok rather than wrong result
        Thanks to Timothee Carayol for reporting. Tests added.

    *   Join columns are now named correctly when j is .SD, a subset of .SD, or similar, #2281.
            DT[c("a","b"),.SD[...]]    # result's first column now named key(DT)[1] rather than 'V1'

    *   Joining an empty i table now works without error (#2194). It also retains key and has a consistent
        number and type of empty columns as the non empty by-without-by case. Tests added.

    *   by-without-by with keyed i where key isn't the 1:n columns of i could crash, #2314. Many thanks
        to Garrett See for reporting with reproducible example data file. Tests added.

    *   DT[,col1:=X[Y,col2]] was a crash, #2311. Due to RHS being a data.table. mult="first"
        (or drop=TRUE in future) was likely intended. Thanks to Anoop Shah for reporting with
        reproducible example. Root cause (recycling of list columns) fixed and tests added.

    *   Grouping by a column which somehow has names, no longer causes an error, #2307.
          DT = data.table(a=1:3,b=c("a","a","b"))
          setattr(DT$b, "names", c("a","b","c"))  # not recommended, just to illustrate
          DT[,sum(a),by=b]  # now ok

    *   gWidgetsWWW wasn't known as data.table aware, even though it mimicks executing
        code in .GlobalEnv, #2340. So, data.table is now gWidgetsWWW-aware. Further packages
        can be added if required by changing a new variable :
            data.table:::cedta.override
        by using assignInNamespace(). Thanks to Zach Waite and Yihui Xie for investigating and
        providing reproducible examples :
            http://stackoverflow.com/questions/13106018/data-table-error-when-used-through-knitr-gwidgetswww

    *   Optimization of lapply when FUN is a character function name now works, #2212.
            DT[,lapply(.SD, "+", 1), by=id]  # no longer an error
            DT[,lapply(.SD, `+`, 1), by=id]  # same, worked before
        Thanks to Michael Nelson for highlighting. Tests added.

    *   Syntactically invalid column names (such as "Some rate (%)") are now preserved in X[Y] joins and
        merge(), as intended. Thanks to George Kaupas (#2193i) and Yang Zhang (#2090) for reporting.
        Tests added.

    *   merge() and setcolorder() now check for duplicate column names first rather than a less helpful
        error later, #2193ii. Thanks to Peter Fine for reporting. Tests added.

    *   Column attributes (such as 'comment') are now retained by X[Y] and merge(), #2270. Thanks to
        Allan Engelhardt for reporting. Tests added.

    *   A matrix RHS of := is now treated as vector, with warning if it has more than 1 column, #2333.
        Thanks to Alex Chernyakov for highlighting. Tests added.
            DT[,b:=scale(a)]   # now works rather than creating an invalid column of type matrix
        http://stackoverflow.com/questions/13076509/why-error-from-na-omit-after-running-scale-in-r-in-data-table

    *   last() is now S3 generic for compatibility with xts::last, #2312. Strictly speaking, for speed,
        last(x) deals with vector, list and data.table inputs directly before falling back to
        S3 dispatch. Thanks to Garrett See for reporting. Tests added.

    *   DT[,lapply(.SD,sum)] in the case of no grouping now returns a data.table for consistency, rather
        than list, #2263. Thanks to Justin and mnel for highlighting. Existing test changed.
            http://stackoverflow.com/a/12290443/403310

    *   L[[2L]][,newcol:=] now works, where L is a list of data.table objects, #2204. Thanks to Melanie Bacou
        for reporting. Tests added. A warning is issued when the first column is added if L was created with
        list(DT1,DT2) since R's list() copies named inputs. Until reflist() is implemented, this warning can be
        ignored or suppressed.
            http://lists.r-forge.r-project.org/pipermail/datatable-help/2012-August/001265.html

    *   DT[J(data.frame(...))] now works again, giving the same result as DT[data.frame(...)], #2265.
        Thanks to Christian Hudon for reporting. Tests added.

    *   A memory leak has been fixed, #2191 and #2284. All data.table objects leaked the over allocated column
        pointer slots; i.e., when a data.table went out of scope or was rm()'d this memory wasn't released and
        gc() would report growing Vcells. For a 3 column data.table with a 100 allocation, the growth was
        1.5Kb per data.table on 64bit (97*8*2 bytes) and 0.75Kb on 32bit (97*4*2 bytes).
        Many thanks to Xavier Saint-Mleux and Sasha Goodman for the reproducible examples and
        assistance. Tests added.

    *   rbindlist now skips empty (0 row) items as well as NULL items. So the column types of the result are
        now taken from the first non-empty data.table. Thanks to Garrett See for reporting. Test added.

    *   setnames did not update column names correctly when passed integer column positions and those
        column names contained duplicates, fixed. This affected the column names of queries involving
        two or more by expressions with a named list inside {}. Thanks to Steve Lianoglou for finding and
        fixing. Tests added.
            DT[, {list(name1=sum(v),name2=sum(w))}, by="a,b"]  # now ok, no blank column names in result
            DT[, list(name1=sum(v),name2=sum(w)), by="a,b"]    # ok before

#### USER VISIBLE CHANGES

    *   J() now issues a warning (when used *outside* DT[...]) that using it
        outside DT[...] is deprecated. See item below in v1.8.2.
        Use data.table() directly instead of J(), outside DT[...]. Or, define
        an alias yourself. J() will continue to work *inside* DT[...] as documented.

    *   DT[,LHS:=RHS,...] no longer prints DT. This implements #2128 "Try again to get
        DT[i,j:=value] to return invisibly". Thanks to discussions here :
            http://stackoverflow.com/questions/11359553/how-to-suppress-output-when-using-in-r-data-table
            http://r.789695.n4.nabble.com/Avoiding-print-when-using-tp4643076.html
        FAQs 2.21 and 2.22 have been updated.

    *   DT[] now returns DT rather than an error that either i or j must be supplied.
        So, ending with [] at the console is a convenience to print the result of :=, rather
        than wrapping with print(); e.g.,
            DT[i,j:=value]...oops forgot print...[]
        is the same as :
            print(DT[i,j:=value])

    *   A warning is now issued when by is set equal to the by-without-by join columns,
        causing x to be subset and then grouped again. The warning suggests removing by or
        changing it, #2282. This can be turned off using options(datatable.warnredundantby=FALSE)
        in case it occurs after upgrading, until those lines can be modified.
        Thanks to Ben Barnes for highlighting :
            http://stackoverflow.com/a/12474211/403310

    *   Description of how join columns are determined in X[Y] syntax has been further clarified
        in ?data.table. Thanks to Alex :
            http://stackoverflow.com/questions/12920803/merge-data-table-when-the-number-of-key-columns-are-different

    *   ?transform and example(transform) has been fixed and embelished, #2316.
        Thanks to Garrett See's suggestion.

    *   ?setattr has been updated to document that it takes any input, not just data.table, and
        can be used on columns of a data.frame, for example.

    *   Efficiency warnings when joining between a factor column and a character column are now downgraded
        to messages when verbosity is on, #2265i. Thanks to Christian Hudon for the suggestion.

#### THANKS TO BETA TESTING (bugs caught in 1.8.3 before release to CRAN)

    *   Combining a join with mult="first"|"last" followed by by inside the same [...] gave incorrect
        results or a crash, #2303. Many thanks to Garrett See for the reproducible example and
        pinpointing in advance which commit had caused the problem. Tests added.

    *   Examples in ?data.table have been updated now that := no longer prints. Thanks to Garrett See.

#### NOTES

    *   There are now 869 raw tests. test.data.table() should return precisely this number of
        tests passed. If not, then somehow, a slightly stale version from R-Forge is likely
        installed; please reinstall from CRAN.

    *   v1.8.3 was an R-Forge only beta release. v1.8.4 was released to CRAN.


### Changes in v1.8.2

#### NEW FEATURES

    *   Numeric columns (type 'double') are now allowed in keys and ad hoc
        by. J() and SJ() no longer coerce 'double' to 'integer'. i join columns
        which mismatch on numeric type are coerced silently to match
        the type of x's join column. Two floating point values
        are considered equal (by grouping and binary search joins) if their
        difference is within sqrt(.Machine$double.eps), by default. See example
        in ?unique.data.table. Completes FRs #951, #1609 and #1075. This paves the
        way for other atomic types which use 'double' (such as POSIXct and bit64).
        Thanks to Chris Neff for beta testing and finding problems with keys
        of two numeric columns (bug #2004), fixed and tests added.

    *   := by group is now implemented (FR#1491) and sub-assigning to a new column
        by reference now adds the column automatically (initialized with NA where
        the sub-assign doesn't touch) (FR#1997). := by group can be combined with all
        types of i, so ":= by group" includes grouping by `i` as well as by `by`.
        Since := by group is by reference, it should be significantly faster than any
        method that (directly or indirectly) `cbind`s the grouped results to DT, since
        no copy of the (large) DT is made at all. It's a short and natural syntax that
        can be compounded with other queries.
            DT[,newcol:=sum(colB),by=colA]

    *   Prettier printing of list columns. The first 6 items of atomic vectors
        are collapsed with "," followed by a trailing "," if there are more than
        6, FR#1608. This difference to data.frame has been added to FAQ 2.17.
        Embedded objects (such as a data.table) print their class name only to avoid
        seemingly mangled output, bug #1803. Thanks to Yike Lu for reporting.
        For example:
        > data.table(x=letters[1:3],
                     y=list( 1:10, letters[1:4], data.table(a=1:3,b=4:6) ))
           x            y
        1: a 1,2,3,4,5,6,
        2: b      a,b,c,d
        3: c <data.table>

    *   Warnings added when joining character to factor, and factor to character.
        Character to character is now preferred in joins and needs no coercion.
        Even so, these coercions have been made much more efficient by taking
        a shallow copy of i internally, avoiding a full deep copy of i.

    *   Ordered subsets now retain x's key. Always for logical and keyed i, using
        base::is.unsorted() for integer and unkeyed i. Implements FR#295.

    *   mean() is now automatically optimized, #1231. This can speed up grouping
        by 20 times when there are a large number of groups. See wiki point 3, which
        is no longer needed to know. Turn off optimization by setting
        options(datatable.optimize=0).

    *   DT[,lapply(.SD,...),by=...] is now automatically optimized, #2067. This can speed
        up applying a function by column by group, by over 20 times. See wiki point 5
        which is no longer needed to know. In other words:
             DT[,lapply(.SD,sum),by=grp]
        is now just as fast as :
             DT[,list(x=sum(x),y=sum(y)),by=grp]
        Don't forget to use .SDcols when a subset of columns is needed.

    *   The package is now Byte Compiled (when installed in R 2.14.0 or later). Several
        internal speed improvements were made in this version too, such as avoiding
        internal copies. If you find 1.8.2 is faster, before attributing that to Byte
        Compilation, please install the package without Byte Compilation and compare
        ceteris paribus. If you find cases where speed has slowed, please let us know.

    *   sapply(DT,class) gets a significant speed boost by avoiding a call to unclass()
        in as.list.data.table() called by lapply(DT,...), which copied the entire object.
        Thanks to a question by user1393348 on Stack Overflow, implementing #2000.
        http://stackoverflow.com/questions/10584993/r-loop-over-columns-in-data-table

    *   The J() alias is now deprecated outside DT[...], but will still work inside
        DT[...], as in DT[J(...)].
        J() is conflicting with function J() in package XLConnect (#1747)
        and rJava (#2045). For data.table to change is easier, with some efficiency
        advantages too. The next version of data.table will issue a warning from J()
        when used outside DT[...]. The version after will remove it. Only then will
        the conflict with rJava and XLConnect be resolved.
        Please use data.table() directly instead of J(), outside DT[...].

    *   New DT[.(...)] syntax (in the style of package plyr) is identical to
        DT[list(...)], DT[J(...)] and DT[data.table(...)]. We plan to add ..(), too, so
        that .() and ..() are analogous to the file system's ./ and ../; i.e., .()
        evaluates within the frame of DT and ..() in the parent scope.

    *   New function rbindlist(l). This does the same as do.call("rbind",l), but much
        faster.

#### BUG FIXES

    *   DT[,f(.SD),by=colA] where f(x)=x[,colB:=1L] was a segfault, bug#1727.
        This is now a graceful error to say that using := in .SD's j is
        reserved for future use. This was already caught in most circumstances,
        other than via f(.SD). Thanks to Leon Baum for reporting. Test added.

    *   If .N is selected by j it is now renamed "N" (no dot) in the output, to
        avoid a potential conflict in subsequent grouping between a column called
        ".N" and the special .N variable, fixing #1720. ?data.table updated and
        FAQ 4.6 added with detailed examples. Tests added.

    *   Moved data.table setup code from .onAttach to .onLoad so that it
        is also run when data.table is simply `import`ed from within a package,
        fixing #1916 related to missing data.table options.

    *   Typos fixed in ?":=", thanks to Michael Weylandt for reporting.

    *   base::unname(DT) now works again, as needed by plyr::melt(). Thanks to
        Christoph Jaeckel for reporting. Test added.

    *   CJ(x=...,y=...) now retains the column names x and y, useful when CJ
        is used independently (since x[CJ(...)] takes join column names from x).
        Restores behaviour lost somewhere between 1.7.1 and 1.8.0, thanks
        to Muhammad Waliji for reporting. Tests added.

    *   A column plonk via set() was only possible by passing NULL as i. The default
        for i is now NULL so that missing i invokes a column plonk, too (when length(value)
        == nrow(DT)). A column plonk is much more efficient than creating 1:nrow(DT) and
        passing that as i to set() or DT[i,:=] (almost infinitely faster). Thanks to
        testing by Josh O'Brien in comments on Stack Overflow. Test added.

    *   Joining a factor column with unsorted and unused levels to a character column
        now matches properly, fixing #1922. Thanks to Christoph Jäckel for the reproducible
        example. Test added.

    *   'by' on an empty table now returns an empty table (#1945) and .N, .SD and .BY are
        now available in the empty case (also #1945). The column names and types of
        the returned empty table are consistent with the non empty case. Thanks to
        Malcolm Cook for reporting. Tests added.

    *   DT[NULL] now returns the NULL data.table, rather than an error. Test added.
        Use DT[0] to return an empty copy of DT.

    *   .N, .SD and .BY are now available to j when 'by' is missing, "", character()
        and NULL, fixing #1732. For consistency so that j works unchanged when by is
        dynamic and passed one of those values all meaning 'don't group'. Thanks
        to Joseph Voelkel reporting and Chris Neff for further use cases. Tests added.

    *   chorder(character()) was a seg fault, #2026. Fixed and test added.

    *   When grouping by i, if the first row of i had no match, .N was 1 rather than 0.
        Fixed and tests added. Thanks to a question by user1165199 on Stack Overflow :
        http://stackoverflow.com/questions/10721517/count-number-of-times-data-is-in-another-dataframe-in-r

    *   All object attributes are now retained by grouping; e.g., tzone of POSIXct is no
        longer lost, fixing #1704. Test added. Thanks to Karl Ove Hufthammer for reporting.

    *   All object attributes are now retained by recycling assign to a new column (both
        <- and :=); e.g., POSIXct class is no longer lost, fixing #1712. Test added. Thanks
        to Leon Baum for reporting.

    *   unique() of ITime no longer coerces to integer, fixing #1719. Test added.

    *   rbind() of DT with an irregular list() now recycles the list items correctly,
        #2003. Test added.

    *   setcolorder() now produces correct error when passed missing column names. Test added.

    *   merge() with common names, and, all.y=TRUE (or all=TRUE) no longer returns an error, #2011.
        Tests added. Thanks to a question by Ina on Stack Overflow :
        http://stackoverflow.com/questions/10618837/joining-two-partial-data-tables-keeping-all-x-and-all-y

    *   Removing or setting datatable.alloccol to NULL is no longer a memory leak, #2014.
        Tests added. Thanks to a question by Vanja on Stack Overflow :
        http://stackoverflow.com/questions/10628371/r-importing-data-table-package-namespace-unexplainable-jump-in-memory-consumpt

    *   DT[,2:=someval,with=FALSE] now changes column 2 even if column 1 has the same (duplicate)
        name, #2025. Thanks to Sean Creighton for reporting. Tests added.

    *   merge() is now correct when all=TRUE but there are no common values in the two
        data.tables, fixing #2114. Thanks to Karl Ove Hufthammer for reporting.  Tests added.

    *   An as.data.frame method has been added for ITime, so that ITime can be passed to ggplot2
        without error, #1713. Thanks to Farrel Buchinsky for reporting. Tests added.
        ITime axis labels are still displayed as integer seconds from midnight; we don't know why ggplot2
        doesn't invoke ITime's as.character method. Convert ITime to POSIXct for ggplot2, is one approach.

    *   setnames(DT,newnames) now works when DT contains duplicate column names, #2103.
        Thanks to Timothee Carayol for reporting. Tests added.

    *   subset() would crash on a keyed table with non-character 'select', #2131. Thanks
        to Benjamin Barnes for reporting. The root cause was non character inputs to chmatch
        and %chin%. Tests added.

    *   Non-ascii column names now work when passed as character 'by', #2134. Thanks to
        Karl Ove Hufthammer for reporting. Tests added.
            DT[, mean(foo), by=ÆØÅ]      # worked before
            DT[, mean(foo), by="ÆØÅ"]    # now works too
            DT[, mean(foo), by=colA]     # worked before
            DT[, mean(foo), by="colA"]   # worked before

#### USER VISIBLE CHANGES

    *   Incorrect syntax error message for := now includes advice to check that
        DT is a data.table rather than a data.frame. Thanks to a comment by
        gkaupas on Stack Overflow.

    *   When set() is passed a logical i, the error message now includes advice to
        wrap with which() and take the which() outside the loop (if any) if possible.

    *   An empty data.table (0 rows, 1+ cols) now print as "Empty data.table" rather
        than "NULL data.table". A NULL data.table, returned by data.table(NULL) has
        0 rows and 0 cols.  DT[0] returns an empty data.table.

    *   0 length by (such as NULL and character(0)) now return a data.table when j
        is vector, rather than vector, for consistency of return types when by
        is dynamic and 'dont group' needs to be represented. Bug fix #1599 in
        v1.7.0 was fixing an error in this case (0 length by).

    *   Default column names for unnamed columns are now consistent between 'by' and
        non-'by'; e.g. these two queries now name the columns "V1" and "V2" :
            DT[,list("a","b"),by=x]
            DT[,list("a","b")]      # used to name the columns 'a' and 'b', oddly.

    *   Typing ?merge now asks whether to display ?merge.data.frame or ?merge.data.table,
        and ?merge.data.table works directly. Thanks to Chris Neff for suggesting.

    *   Description of how join columns are determined in X[Y] syntax has been clarified
        in ?data.table. Thanks to Juliet Hannah and Yike Lu.

    *   DT now prints consistent row numbers when the column names are reprinted at the
        bottom of the output (saves scrolling up). Thanks to Yike Lu for reporting #2015.
        The tail as well as the head of large tables is now printed.


#### THANKS TO BETA TESTING (i.e. bugs caught in 1.8.1 before release to CRAN) :

    *   Florian Oswald for #2094: DT[,newcol:=NA] now adds a new logical column ok.
        Test added.

    *   A large slow down (2s went up to 40s) when iterating calls to DT[...] in a
        for loop, such as in example(":="), was caught and fixed in beta, #2027.
        Speed regression test added.

    *   Christoph Jäckel for #2078: by=c(...) with i clause broke. Tests added.

    *   Chris Neff for #2065: keyby := now keys, unless, i clause is present or
        keyby is not straightforward column names (in any format). Tests added.

    *   :=NULL to delete, following by := by group to add, didn't add the column,
        #2117. Test added.

    *   Combining i subset with by gave incorrect results, #2118. Tests added.

    *   Benjamin Barnes for #2133: rbindlist not supporting type 'logical'.
        Tests added.

    *   Chris Neff for #2146: using := to add a column to the result of a simple
        column subset such as DT[,list(x)], or after changing all column names
        with setnames(), was an error. Fixed and tests added.

#### NOTES

    *   There are now 717 raw tests, plus S4 tests.

    *   v1.8.1 was an R-Forge only beta release. v1.8.2 was released to CRAN.


### Changes in v1.8.0

#### NEW FEATURES

    *   character columns are now allowed in keys and are preferred to
        factor. data.table() and setkey() no longer coerce character to
        factor. Factors are still supported. Implements FR#1493, FR#1224
        and (partially) FR#951.

    *   setkey() no longer sorts factor levels. This should be more convenient
        and compatible with ordered factors where the levels are 'labels', in
        some order other than alphabetical. The established advice to paste each
        level with an ordinal prefix, or use another table to hold the factor
        labels instead of a factor column, is no longer needed. Solves FR#1420.
        Thanks to Damian Betebenner and Allan Engelhardt raising on datatable-help
        and their tests have been added verbatim to the test suite.

    *   unique(DT) and duplicated(DT) are now faster with character columns,
        on unkeyed tables as well as keyed tables, FR#1724.

    *   New function set(DT,i,j,value) allows fast assignment to elements
        of DT. Similar to := but avoids the overhead of [.data.table, so is
        much faster inside a loop. Less flexible than :=, but as flexible
        as matrix subassignment. Similar in spirit to setnames(), setcolorder(),
        setkey() and setattr(); i.e., assigns by reference with no copy at all.

            M = matrix(1,nrow=100000,ncol=100)
            DF = as.data.frame(M)
            DT = as.data.table(M)
            system.time(for (i in 1:1000) DF[i,1L] <- i)   # 591.000s
            system.time(for (i in 1:1000) DT[i,V1:=i])     #   1.158s
            system.time(for (i in 1:1000) M[i,1L] <- i)    #   0.016s
            system.time(for (i in 1:1000) set(DT,i,1L,i))  #   0.027s

    *   New functions chmatch() and %chin%, faster versions of match()
        and %in% for character vectors. R's internal string cache is
        utilised (no hash table is built). They are about 4 times faster
        than match() on the example in ?chmatch.

    *   Internal function sortedmatch() removed and replaced with chmatch()
        when matching i levels to x levels for columns of type 'factor'. This
        preliminary step was causing a (known) significant slowdown when the number
        of levels of a factor column was large (e.g. >10,000). Exacerbated in
        tests of joining four such columns, as demonstrated by Wes McKinney
        (author of Python package Pandas). Matching 1 million strings of which
        of which 600,000 are unique is now reduced from 16s to 0.5s, for example.
        Background here :
        http://stackoverflow.com/questions/8991709/why-are-pandas-merges-in-python-faster-than-data-table-merges-in-r

    *   rbind.data.table() gains a use.names argument, by default TRUE.
        Set to FALSE to combine columns in order rather than by name. Thanks to
        a question by Zach on Stack Overflow :
        http://stackoverflow.com/questions/9315258/aggregating-sub-totals-and-grand-totals-with-data-table

    *   New argument 'keyby'. An ad hoc by just as 'by' but with an additional setkey()
        on the by columns of the result, for convenience. Not to be confused with a
        'keyed by' such as DT[...,by=key(DT)] which can be more efficient as explained
        by FAQ 3.3.  Thanks to Yike Lu for the suggestion and discussion (FR#1780).

    *   Single by (or keyby) expressions no longer need to be wrapped in list(),
        for convenience, implementing FR#1743; e.g., these now works :
            DT[,sum(v),by=a%%2L]
            DT[,sum(v),by=month(date)]
        instead of needing :
            DT[,sum(v),by=list(a%%2L)]
            DT[,sum(v),by=list(month(date))]

    *   Unnamed 'by' expressions have always been inspected using all.vars() to make
        a guess at a sensible column name for the result. This guess now includes
        function names via all.vars(functions=TRUE), for convenience; e.g.,
            DT[,sum(v),by=month(date)]
        now returns a column called 'month' rather than 'date'. It is more robust to
        explicitly name columns, though; e.g.,
            DT[,sum(v),by=list("Guaranteed name"=month(date))]

    *   For a surprising speed boost in some circumstances, default options such as
        'datatable.verbose' are now set when the package loads (unless they are already
        set, by user's profile for example). The 'default' argument of base::getOption()
        was the culprit and has been removed internally from all 11 calls.


#### BUG FIXES

    *   Fixed a `suffixes` handling bug in merge.data.table that was
        only recently introduced during the recent "fast-merge"-ing reboot.
        Briefly, the bug was only triggered in scenarios where both
        tables had identical column names that were not part of `by` and
        ended with *.1. cf. "merge and auto-increment columns in y[x]"
        test in tests/test-data.frame-like.R for more information.

    *   Adding a column using := on a data.table just loaded from disk was
        correctly detected and over allocated, but incorrectly warning about
        a previous copy. Test 462 tested loading from disk, but suppressed
        warnings (sadly). Fixed.

    *   data.table unaware packages that use DF[i] and DF[i]<-value syntax
        were not compatible with data.table, fixed. Many thanks to Prasad Chalasani
        for providing a reproducible example with base::droplevels(), and
        Helge Liebert for providing a reproducible example (#1794) with stats::reshape().
        Tests added.

    *   as.data.table(DF) already preserved DF's attributes but not any inherited
        classes such as nlme's groupedData, so nlme was incompatible with
        data.table. Fixed. Thanks to Dieter Menne for providing a reproducible
        example. Test added.

    *   The internal row.names attribute of .SD (which exists for compatibility with
        data.frame only) was not being updated for each group. This caused length errors
        when calling any non-data.table-aware package from j, by group, when that package
        used length of row.names. Such as the recent update to ggplot2. Fixed.

    *   When grouped j consists of a print of an object (such as ggplot2), the print is now
        masked to return NULL rather than the object that ggplot2 returns since the
        recent update v0.9.0. Otherwise data.table tries to accumulate the (albeit
        invisible) print object. The print mask is local to grouping, not generally.

    *   'by' was failing (bug #1880) when passed character column names where one or more
        included a space. So, this now works :
            DT[,sum(v),by="column 1"]
        and j retains spaces in column names rather than replacing spaces with "."; e.g.,
            DT[,list("a b"=1)]
        Thanks to Yang Zhang for reporting. Tests added. As before, column names may be
        back ticked in the usual R way (in i, j and by); e.g.,
            DT[,sum(`nicely named var`+1),by=month(`long name for date column`)]

    *   unique() on an unkeyed table including character columns now works correctly, fixing
        #1725. Thanks to Steven Bagley for reporting. Test added.

    *   %like% now returns logical (rather than integer locations) so that it can be
        combined with other i clauses, fixing #1726. Thanks to Ivan Zhang for reporting. Test
        added.


#### THANKS TO

    *   Joshua Ulrich for spotting a missing PACKAGE="data.table"
        in .Call in setkey.R, and suggesting as.list.default() and
        unique.default() to avoid dispatch for speed, all implemented.


#### USER-VISIBLE CHANGES

    *   Providing .SDcols when j doesn't use .SD is downgraded from error to warning,
        and verbosity now reports which columns have been detected as used by j.

    *   check.names is now FALSE by default, for convenience when working with column
        names with spaces and other special characters, which are now fully supported.
        This difference to data.frame has been added to FAQ 2.17.


### Changes in v1.7.10

#### NEW FEATURES

    *   New function setcolorder() reorders the columns by name
        or by number, by reference with no copy. This is (almost)
        infinitely faster than DT[,neworder,with=FALSE].

    *   The prefix i. can now be used in j to refer to join inherited
        columns of i that are otherwise masked by columns in x with
        the same name.


#### BUG FIXES

    *   tracemem() in example(setkey) was causing CRAN check errors
        on machines where R is compiled without memory profiling available,
        for efficiency. Notably, R for Windows, Ubuntu and Mac have memory
        profiling enabled which may slow down R on those architectures even
        when memory profiling is not being requested by the user. The call to
        tracemem() is now wrapped with try().

    *   merge of unkeyed tables now works correctly after breaking in 1.7.8 and
        1.7.9. Thanks to Eric and DM for reporting. Tests added.

    *   nomatch=0 was ignored for the first group when j used join inherited
        scope. Fixed and tests added.


#### USER-VISIBLE CHANGES

    *   Updating an existing column using := after a key<- now works without warning
        or error. This can be useful in interactive use when you forget to use setkey()
        but don't mind about the inefficiency of key<-. Thanks to Chris Neff for
        providing a convincing use case. Adding a new column uing := after key<-
        issues a warning, shallow copies and proceeds, as before.

    *   The 'datatable.pre.suffixes' option has been removed. It was available to
        obtain deprecated merge() suffixes pre v1.5.4.


### Changes in v1.7.9

#### NEW FEATURES

   *    New function setnames(), referred to in 1.7.8 warning messages.
        It makes no copy of the whole data object, unlike names<- and
        colnames<-. It may be more convenient as well since it allows changing
        a column name, by name; e.g.,

          setnames(DT,"oldcolname","newcolname")  # by name; no match() needed
          setnames(DT,3,"newcolname")             # by position
          setnames(DT,2:3,c("A","B"))             # multiple
          setnames(DT,c("a","b"),c("A","B"))      # multiple by name
          setnames(DT,toupper(names(DT)))         # replace all

        setnames() maintains truelength of the over-allocated names vector. This
        allows := to add columns fully by reference without growing the names
        vector. As before with names<-, if a key column's name is changed,
        the "sorted" attribute is updated with the new column name.

#### BUG FIXES

   *    Incompatibility with reshape() of 3 column tables fixed
        (introduced by 1.7.8) :
          Error in setkey(ans, NULL) : x is not a data.table
        Thanks to Damian Betebenner for reporting and
        reproducible example. Tests added to catch in future.

   *    setattr(DT,...) still returns DT, but now invisibly. It returns
        DT back again for compound syntax to work; e.g.,
            setattr(DT,...)[i,j,by]
        Again, thanks to Damian Betebenner for reporting.


### Changes in v1.7.8

#### BUG FIXES

   *    unique(DT) now works when DT is keyed and a key
        column is called 'x' (an internal scoping conflict
        introduced in v1.6.1). Thanks to Steven Bagley for
        reporting.

   *    Errors and seg faults could occur in grouping when
        j contained character or list columns. Many thanks
        to Jim Holtman for providing a reproducible example.

   *    Setting a key on a table with over 268 million rows
        (2^31/8) now works (again), #1714. Bug introduced in
        v1.7.2. setkey works up to the regular R vector limit
        of 2^31 rows (2 billion). Thanks to Leon Baum
        for reporting.

   *    Checks in := are now made up front (before starting to
        modify the data.table) so that the data.table isn't
        left in an invalid state should an error occur, #1711.
        Thanks to Chris Neff for reporting.

   *    The 'Chris crash' is fixed. The root cause was that key<-
        always copies the whole table. The problem with that copy
        (other than being slower) is that R doesn't maintain the
        over allocated truelength, but it looks as though it has.
        key<- was used internally, in particular in merge(). So,
        adding a column using := after merge() was a memory overwrite,
        since the over allocated memory wasn't really there after
        key<-'s copy.

        data.tables now have a new attribute '.internal.selfref' to
        catch and warn about such copies in future. All internal
        use of key<- has been replaced with setkey(), or new function
        setkeyv() which accepts a vector, and do not copy.

        Many thanks to Chris Neff for extended dialogue, providing a
        reproducible example and his patience. This problem was not just
        in pre 2.14.0, but post 2.14.0 as well. Thanks also to Christoph
        Jäckel, Timothée Carayol and DM for investigations and suggestions,
        which in combination led to the solution.

   *    An example in ?":=" fixed, and j and by descriptions
        improved in ?data.table. Thanks to Joseph Voelkel for
        reporting.

#### NEW FEATURES

   *    Multiple new columns can be added by reference using
        := and with=FALSE; e.g.,
            DT[,c("foo","bar"):=1L,with=FALSE]
            DT[,c("foo","bar"):=list(1L,2L),with=FALSE]

   *    := now recycles vectors of non divisible length, with
        a warning (previously an error).

   *    When setkey coerces a numeric or character column, it
        no longer makes a copy of the whole table, FR#1744. Thanks
        to an investigation by DM.

   *    New function setkeyv(DT,v) (v stands for vector) replaces
        key(DT)<-v syntax. Also added setattr(). See ?copy.

   *    merge() now uses (manual) secondary keys, for speed.


#### USER VISIBLE CHANGES

   *    The loc argument of setkey has been removed. This wasn't very
        useful and didn't warrant a period of deprecation.

   *    datatable.alloccol has been removed. That warning is now
        controlled by datatable.verbose=TRUE. One option is easer.

   *    If i is a keyed data.table, it is no longer an error if its
        key is longer than x's key; the first length(key(x)) columns
        of i's key are used to join.


### Changes in v1.7.7

#### BUG FIXES

   *    Previous bug fix for random crash in R <= 2.13.2
        related to truelength and over-allocation didn't
        work, 3rd attempt. Thanks to Chris Neff for his
        patience and testing. This has shown up consistently
        as error status on CRAN old-rel checks (windows and
        mac). So if they pass, this issue is fixed.


### Changes in v1.7.6

#### NEW FEATURES

   *    An empty list column can now be added with :=, and
        data.table() accepts empty list().
            DT[,newcol:=list()]
            data.table(a=1:3,b=list())
        Empty list columns contain NULL for all rows.

#### BUG FIXES

   *    Adding a column to a data.table loaded from disk could
        result in a memory corruption in R <= 2.13.2, revealed
        and thanks to CRAN checks on windows old-rel.

   *    Adding a factor column with a RHS to be recycled no longer
        loses its factor attribute, #1691. Thanks to Damian
        Betebenner for reporting.


### Changes in v1.7.5

#### BUG FIXES

   *    merge()-ing a data.table where its key is not the first
        few columns in order now works correctly and without
        warning, fixing #1645. Thanks to Timothee Carayol for
        reporting.

   *    Mixing nomatch=0 and mult="last" (or "first") now works,
        #1661. Thanks to Johann Hibschman for reporting.

   *    Join Inherited Scope now respects nomatch=0, #1663. Thanks
        to Johann Hibschman for reporting.

   *    by= could generate a keyed result table with invalid key;
        e.g., when by= expressions return NA, #1631. Thanks to
        Muhammad Waliji for reporting.

   *    Adding a column to a data.table loaded from disk resulted
        in an error that truelength(DT)<length(DT).

   *    CJ() bogus values and logical error fixed, #1689. Thanks to
        Damian Betebenner and Chris Neff for reporting.

   *    j=list(.SD,newcol=...) now gives friendly error suggesting cbind
        or merge afterwards until := by group is implemented, rather than
        treating .SD as a list column, #1647. Thanks to a question by
        Christoph_J on Stack Overflow.


#### USER VISIBLE CHANGES

   *    rbind now cross-refs colnames as data.frame does, rather
        than always binding by column order, FR#1634. A warning is
        produced when the colnames are not in a consistent order.
        Thanks to Damian Betebenner for highlighting. rbind an
        unnamed list to bind columns by position.

   *    The 'bysameorder' argument has been removed, as intended and
        warned in ?data.table.

   *    New option datatable.allocwarn. See ?truelength.

#### NOTES

   *    There are now 472 raw tests, plus S4 tests.


### Changes in v1.7.4

#### BUG FIXES

   *    v1.7.3 failed CRAN checks (and could crash) in R pre-2.14.0.
        Over-allocation in v1.7.3 uses truelength which is initialized
        to 0 by R 2.14.0, but not initialized pre-2.14.0. This was
        known and coded for but only tested in 2.14.0 before previous
        release to CRAN.

#### NOTES

   *    Two unused C variables removed to pass warning from one CRAN
        check machine (r-devel-fedora). -Wno-unused removed from
        Makevars to catch this in future before submitting to CRAN.


### Changes in v1.7.3

#### NEW FEATURES

    *   data.table now over-allocates its vector of column pointer slots
        (100 by default). This allows := to add columns fully by
        reference as suggested by Muhammad Waliji, #1646. When the 100
        slots are used up, more space is automatically allocated.

        Over allocation has negligible overhead. It's just the vector
        of column pointers, not the columns themselves.

    *   New function alloc.col() pre-allocates column slots. Use
        this before a loop to add many more than 100 columns, for example,
        to avoid the warning as data.table grows its column pointer vector
        every additional 100 columns; e.g.,
            alloc.col(DT,10000)  # reserve 10,000 column slots

    *   New function truelength() returns the number of column pointer
        slots allocated, always >= length() other than just after a table
        has been loaded from disk.

    *   New option 'datatable.nomatch' allows the default for nomatch
        to be changed from NA to 0, as wished for by Branson Owen.

    *   cbind(DT,...) now retains DT's key, as wished for by Chris Neff
        and partly implementing FR#295.

#### BUG FIXES

    *   Assignment to factor columns (using :=, [<- or $<-) could cause
        'variable not found' errors and a seg fault in some circumstances
        due to a new feature in v1.7.0: "Factor columns on LHS of :=, [<-
        and $<- can now be assigned new levels", fixing #1664. Thanks to
        Daniele Signori for reporting.

    *   DT[i,j]<-value no longer crashes when j is a factor column and value
        is numeric, fixing #1656.

    *   An unnecessarily strict machine tolerance test failed CRAN checks
        on Mac preventing v1.7.2 availability for Mac (only).

#### USER VISIBLE CHANGES

    *   := now has its own help page in addition to the examples in ?data.table,
        see help(":=").

    *   The error message from X[Y] when X is unkeyed has been lengthened to
        including advice to call setkey first and see ?setkey. Thanks to a
        comment by ilprincipe on Stack Overflow.

    *   Deleting a missing column is now a warning rather than error. Thanks
        to Chris Neff for suggesting, #1642.


### Changes in v1.7.2

#### NEW FEATURES

    *   unique and duplicated methods now work on unkeyed tables (comparing
        all columns in that case) and both now respect machine tolerance for
        double precision columns, implementing FR#1626 and fixing bug #1632.
        Their help page has been updated accordingly with detailed examples.
        Thanks to questions by Iterator and comments by Allan Engelhardt on
        Stack Overflow.

    *   A new method as.data.table.list has been added, since passing a (pure)
        list to data.table() now creates a single list column.


#### BUG FIXES

    *   Assigning to a column variable using <- or = in j now
        works (creating a local copy within j), rather than
        persisting from group to group and sometimes causing a crash.
        Non column variables still persist from group to group; e.g.,
        a group counter. This fixes the remainder of #1624 thanks to
        Steve Lianoglou for reporting.

    *   A crash bug is fixed when j returns a (strictly) NULL column next
        to a non-empty column, #1633. This case was anticipated and coded
        for but an errant LENGTH() should have been length(). Thanks
        to Dennis Murphy for reporting.

    *   The first column of data.table() can now be a list column, fixing
        #1640. Thanks to Stavros Macrakis for reporting.


### Changes in v1.7.1

#### BUG FIXES

    *   .SD is now locked, partially fixing #1624. It was never
        the intention to allow assignment to .SD. Take a 'copy(.SD)'
        first if needed. Now documented in ?data.table and new FAQ 4.5
        including example. Thanks to Steve Lianoglou for reporting.

    *   := now works with a logical i subset; e.g.,
            DT[x==1,y:=x]
        Thanks to Muhammad Waliji for reporting.

#### USER VISIBLE CHANGES

    *   Error message "column <name> of i is not internally type integer"
        is now more helpful adding "i doesn't need to be keyed, just
        convert the (likely) character column to factor". Thanks to
        Christoph_J for his SO question.


### Changes in v1.7.0

#### NEW FEATURES

    *   data.table() now accepts list columns directly rather than
        needing to add list columns to an existing data.table; e.g.,

            DT = data.table(x=1:3,y=list(4:6,3.14,matrix(1:12,3)))

        Thanks to Branson Owen for reminding. As before, list columns
        can be created via grouping; e.g.,

            DT = data.table(x=c(1,1,2,2,2,3,3),y=1:7)
            DT2 = DT[,list(list(unique(y))),by=x]
            DT2
                 x      V1
            [1,] 1    1, 2
            [2,] 2 3, 4, 5
            [3,] 3    6, 7

        and list columns can be grouped; e.g.,

            DT2[,sum(unlist(V1)),by=list(x%%2)]
                 x V1
            [1,] 1 16
            [2,] 0 12

        Accordingly, one item has been added to FAQ 2.17 (differences
        between data.frame and data.table): data.frame(list(1:2,"k",1:4))
        creates 3 columns, data.table creates one list column.

    *   subset, transform and within now retain keys when the expression
        does not 'touch' key columns, implemeting FR #1341.

    *   Recycling list() items on RHS of := now works; e.g.,

            DT[,1:4:=list(1L,NULL),with=FALSE]
            # set columns 1 and 3 to 1L and remove columns 2 and 4

    *   Factor columns on LHS of :=, [<- and $<- can now be assigned
        new levels; e.g.,

            DT = data.table(A=c("a","b"))
            DT[2,"A"] <- "c"  # adds new level automatically
            DT[2,A:="c"]      # same (faster)
            DT$A = "newlevel" # adds new level and recycles it

        Thanks to Damian Betebenner and Chris Neff for highlighting.
        To change the type of a column, provide a full length RHS (i.e.
        'replace' the column).

#### BUG FIXES

    *   := with i all FALSE no longer sets the whole column, fixing
        bug #1570. Thanks to Chris Neff for reporting.

    *   0 length by (such as NULL and character(0)) now behave as
        if by is missing, fixing bug #1599. This is useful when by
        is dynamic and a 'dont group' needs to be represented.
        Thanks to Chris Neff for reporting.

    *   NULL j no longer results in 'inconsistent types' error, but
        instead returns no rows for that group, fixing bug #1576.

    *   matrix i is now an error rather than using i as if it were a
        vector and obtaining incorrect results. It was undocumented that
        matrix might have been an acceptable type. matrix i is
        still acceptable in [<-; e.g.,
            DT[is.na(DT)] <- 1L
        and this now works rather than assigning to non-NA items in some
        cases.

    *   Inconsistent [<- behaviour is now fixed (#1593) so these examples
        now work :
            DT[x == "a", ]$y <- 0L
            DT["a", ]$y <- 0L
        But, := is highly encouraged instead for speed; i.e.,
            DT[x == "a", y:=0L]
            DT["a", y:=0L]
        Thanks to Leon Baum for reporting.

    *   unique on an unsorted table now works, fixing bug #1601.
        Thanks to a question by Iterator on Stack Overflow.

    *   Bug fix #1534 in v1.6.5 (see NEWS below) only worked if data.table
        was higher than IRanges on the search() path, despite the item in
        NEWS stating otherwise. Fixed.

    *   Compatibility with package sqldf (which can call do.call("rbind",...)
        on an empty "...") is fixed and test added. data.table was switching
        on list(...)[[1]] rather than ..1. Thanks to RYogi for reporting #1623.

#### USER VISIBLE CHANGES

    *   cbind and rbind are no longer masked. But, please do read FAQ 2.23,
        4.4 and 5.1.


### Changes in v1.6.6

#### BUG FIXES

    *   Tests using .Call("Rf_setAttrib",...) passed CRAN acceptance
        checks but failed on many (but not all) platforms. Fixed.
        Thanks to Prof Brian Ripley for investigating the issue.

### Changes in v1.6.5

#### NEW FEATURES

    *   The LHS of := may now be column names or positions
        when with=FALSE; e.g.,

            DT[,c("d","e"):=NULL,with=FALSE]
            DT[,4:5:=NULL,with=FALSE]
            newcolname="myname"
            DT[,newcolname:=3.14,with=FALSE]

        This implements FR#1499 'Ability to efficiently remove a
        vector of column names' by Timothee Carayol in addition to
        creating and assigning to multiple columns. We still plan
        to allow multiple := without needing with=FALSE, in future.

    *   setkey(DT,...) now returns DT (invisibly) rather than NULL.
        This is to allow compound statements; e.g.,
            setkey(DT,x)["a"]

    *   setkey (and key<-) are now more efficient when the data happens
        to be already sorted by the key columns; e.g., when data is
        loaded from ordered files.

    *   If DT is already keyed by the columns passed to setkey (or
        key<-), the key is now rebuilt and checked rather than skipping
        for efficiency. This is to save needing to know to drop the key
        first to rebuild an invalid key. Invalid keys can arise by going
        'under the hood'; e.g., attr(DT,"sorted")="z", or somehow ending
        up with unordered factor levels. A warning is issued so the root
        cause can be fixed. Thanks to Timothee Carayol for highlighting.

    *   A new copy() function has been added, FR#1501. This copies a
        data.table (retaining its key, if any) and should now be used to
        copy rather than data.table(). Reminder: data.tables are not
        copied on write by setkey, key<- or :=.


#### BUG FIXES

    *   DT[,z:=a/b] and DT[a>3,z:=a/b] work again, where a and
        b are columns of DT. Thanks to Chris Neff for reporting,
        and his patience.

    *   Numeric columns with class attributes are now correctly
        coerced to integer by setkey and ad hoc by. The error
        similar to 'fractional data cannot be truncated' should now
        only occur when that really is true. A side effect of
        this is that ad hoc by and setkey now work on IDate columns
        which have somehow become numeric; e.g., via rbind(DF,DF)
        as reported by Chris Neff.

    *   .N is now 0 (rather than 1) when no rows in x match the
        row in i, fixing bug #1532. Thanks to Yang Zhang for
        reporting.

    *   Compatibility with package IRanges has been restored. Both
        data.table and IRanges mask cbind and rbind. When data.table's
        cbind is found first (if it is loaded after IRanges) and the
        first argument is not data.table, it now delegates to the next
        package on the search path (and above that), one or more of which
        may also mask cbind (such as IRanges), rather than skipping
        straight to base::cbind. So, it no longer matters which way around
        data.table and IRanges are loaded, fixing #1534. Thanks to Steve
        Lianoglou for reporting.


#### USER VISIBLE CHANGES

    *   setkey's verbose messages expanded.


### Changes in v1.6.4

#### NEW FEATURES

    *   DT[colA>3,which=TRUE] now returns row numbers rather
        than a logical vector, for consistency.

#### BUG FIXES

    *   Changing a keyed column name now updates the key, too,
        so an invalid key no longer arises, fixing #1495.
        Thanks to Chris Neff for reporting.

    *   := already warned when a numeric RHS is coerced to
        match an integer column's type. Now it also warns when
        numeric is coerced to logical, and integer is coerced
        to logical, fixing #1500. Thanks to Chris Neff for
        reporting.

    *   The result of DT[,newcol:=3.14] now includes the new
        column correctly, as well as changing DT by reference,
        fixing #1496. Thanks to Chris Neff for reporting.

    *   :=NULL to remove a column (instantly, regardless of table
        size) now works rather than causing a segfault in some
        circumstances, fixing #1497. Thanks to Timothee Carayol
        for reporting.

    *   Previous within() and transform() behaviour restored; e.g.,
        can handle multiple columns again. Thanks to Timothee Carayol
        for reporting.

    *   cbind(DT,DF) now works, as does rbind(DT,DF), fixing #1512.
        Thanks to Chris Neff for reporting. This was tricky to fix due
        to nuances of the .Internal dispatch code in cbind and rbind,
        preventing S3 methods from working in all cases.
        R will now warn that cbind and rbind have been masked when
        the data.table package is loaded. These revert to base::cbind
        and base::rbind when the first argument is not data.table.

    *   Removing multiple columns now works (again) using
        DT[,c("a","b")]=NULL, or within(DT,rm(a,b)), fixing #1510.
        Thanks to Timothee Carayol for reporting.


#### NOTES

    *   The package uses two features (packageVersion() and \href in Rd)
        added to R 2.12.0 and is therefore dependent on that release.
        A 'spurious warning' when checking a package using \href was
        fixed in R 2.12.2 patched but we believe that warning can safely
        be ignored in versions >= 2.12.0 and < 2.12.2 patched.


### Changes in v1.6.3

#### NEW FEATURES

    *   Ad hoc grouping now returns results in the same order each
        group first appears in the table, rather than sorting the
        groups. Thanks to Steve Lianoglou for highlighting. The order
        of the rows within each group always has and always will be
        preserved. For larger datasets a 'keyed by' is still faster;
        e.g., by=key(DT).

    *   The 'key' argument of data.table() now accepts a vector of
        column names in addition to a single comma separated string
        of column names, for consistency. Thanks to Steve Lianoglou
        for highlighting.

    *   A new argument '.SDcols' has been added to [.data.table. This
        may be character column names or numeric positions and
        specifies the columns of x included in .SD. This is useful
        for speed when applying a function through a subset of
        (possibly very many) columns; e.g.,
            DT[,lapply(.SD,sum),by="x,y",.SDcols=301:350]

    *   as(character, "IDate") and as(character, "ITime") coercion
        functions have been added. Enables the user to declaring colClasses
        as "IDate" and "ITime" in the various read.table (and sister)
        functions. Thanks to Chris Neff for the suggestion.

    *   DT[i,j]<-value is now handled by data.table in C rather
        than falling through to data.frame methods, FR#200. Thanks to
        Ivo Welch for raising speed issues on r-devel, to Simon Urbanek
        for the suggestion, and Luke Tierney and Simon for information
        on R internals.

        [<- syntax still incurs one working copy of the whole
        table (as of R 2.13.1) due to R's [<- dispatch mechanism
        copying to `*tmp*`, so, for ultimate speed and brevity,
        the operator := may now be used in j as follows.

    *   := is now available to j and means assign to the column by
        reference; e.g.,

            DT[i,colname:=value]

        This syntax makes no copies of any part of memory at all.

        m = matrix(1,nrow=100000,ncol=100)
        DF = as.data.frame(m)
        DT = as.data.table(m)

        system.time(for (i in 1:1000) DF[i,1] <- i)
             user  system elapsed
          287.062 302.627 591.984

        system.time(for (i in 1:1000) DT[i,V1:=i])
             user  system elapsed
            1.148   0.000   1.158     ( 511 times faster )

        := in j can be combined with all types of i, such as binary
        search, and used to add and remove columns efficiently.
        Fast assigning within groups will be implemented in future.

        Reminder that data.frame and data.table both allow columns
        of mixed types, including columns which themselves may be
        type list; matrix may be one (atomic) type only.

        *Please note*, := is new and experimental.


#### BUG FIXES

    *   merge()ing two data.table's with user-defined `suffixes`
        was getting tripped up when column names in x ended in
        '.1'. This resulted in the `suffixes` parameter being
        ignored.

    *   Mistakenly wrapping a j expression inside quotes; e.g.,
            DT[,list("sum(a),sum(b)"),by=grp]
        was appearing to work, but with wrong column names. This
        now returns a character column (the quotes should not
        be used). Thanks to Joseph Voelkel for reporting.

    *   setkey has been made robust in several ways to fix issues
        introduced in 1.6.2: #1465 ('R crashes after setkey')
        reported by Eugene Tyurin and similar bug #1387 ('paste()
        by group to create long comma separated strings can crash')
        reported by Nicolas Servant and Jean-Francois Rami. This
        bug was not reproducible so we are especially grateful for
        the patience of these people in helping us find, fix and
        test it.

    *   Combining a join, j and by together in one query now works
        rather than giving an error, fixing bug #1468. Discovered
        indirectly thanks to a post from Jelmer Ypma.

    *   Invalid keys no longer arise when a non-data.table-aware
        package reorders the data; e.g.,
            setkey(DT,x,y)
            plyr::arrange(DT,y)       # same as DT[order(y)]
        This now drops the key to avoid incorrect results being
        returned the next time the invalid key is joined to. Thanks
        to Chris Neff for reporting.


#### USER-VISIBLE CHANGES

    *   The startup banner has been shortened to one line.

    *   data.table does not support POSIXlt. Almost unbelievably
        POSIXlt uses 40 bytes to store a single datetime. If it worked
        before, that was unintentional. Please see ?IDateTime, or any
        other date class that uses a single atomic vector. This is
        regardless of whether the POSIXlt is a key column, or not. This
        resolves bug #1481 by documenting non support in ?data.table.


#### DEPRECATED & DEFUNCT

   *    Use of the DT() alias in j is no longer caught for backwards
        compatibility and is now fully removed. As warned in NEWS
        for v1.5.3, v1.4, and FAQs 2.6 and 2.7.


### Changes in v1.6.2

#### NEW FEATURES

   *    setkey no longer copies the whole table and should be
        faster for large tables. Each column is reordered by reference
        (in C) using one column of working memory, FR#1006. User
        defined attributes on the original table are now also
        retained (thanks to Thell Fowler for reporting).

   *    A new symbol .N is now available to j, containing the
        number of rows in the group. This may be useful when
        the column names are not known in advance, for
        convenience generally, and for efficiency.


### Changes in v1.6.1

#### NEW FEATURES

   *    j's environment is now consistently reused so
        that local variables may be set which persist
        from group to group; e.g., incrementing a group
        counter :
            DT[,list(z,groupInd<-groupInd+1),by=x]
        Thanks to Andreas Borg for reporting.

   *    A new symbol .BY is now available to j, containing 1 row
        of the current 'by' variables, type list. 'by' variables
        may also be used by name, and are now length 1 too. This
        implements FR#1313. FAQ 2.10 has been updated accordingly.
        Some examples :
            DT[,sum(x)*.BY[[1]],by=eval(byexp)]
            DT[,sum(x)*mylookuptable[J(y),z],by=y]
            DT[,list(sum(unlist(.BY)),sum(z)),by=list(x,y%%2)]

   *    i may now be type list, and works the same as when i
        is type data.table. This saves needing J() in as many
        situations and may be a little more efficient. One
        application is using .BY directly in j to join to a
        relatively small lookup table, once per group, for space
        and time efficiency. For example :
            DT[,list(GROUPDATA[.BY]$name,sum(v)),by=grp]


#### BUG FIXES

   *    A 'by' character vector of column names now
        works when there are less rows than columns; e.g.,
            DT[,sum(x),by=key(DT)]  where nrow(DT)==1.
        Many thanks to Andreas Borg for report, proposed
        fix and tests.

   *    Zero length columns in j no longer cause a crash in
        some circumstances. Empty columns are filled with NA
        to match the length of the longest column in j.
        Thanks to Johann Hibschman for bug report #1431.

   *    unique.data.table now calls the same internal code
        (in C) that grouping calls. This fixes a bug when
        unique is called directly by user, and, NA exist
        in the key (which might be quite rare). Thanks to
        Damian Betebenner for bug report. unique should also
        now be faster.

   *    Variables in calling scope can now be used in j when
        i is logical or integer, fixing bug #1421. Thanks
        to Alexander Peterhansl for reporting.


#### USER-VISIBLE CHANGES

    *   ?data.table now documents that logical i is not quite
        the same as i in [.data.frame. NA are treated as FALSE,
        and DT[NA] returns 1 row of NA, unlike [.data.frame.
        Three points have been added to FAQ 2.17. Thanks to
        Johann Hibschman for highlighting.

    *   Startup banner now uses packageStartupMessage() so the
        banner can be suppressed by those annoyed by banners,
        whilst still being helpful to new users.



### Changes in v1.6

#### NEW FEATURES

   *    data.table now plays nicely with S4 classes. Slots can be
        defined to be S4 objects, S4 classes can inherit from data.table,
        and S4 function dispatch works on data.table objects. See the
        tests in inst/tests/test-S4.R, and from the R prompt:
        ?"data.table-class"

   *    merge.data.table now works more like merge.data.frame:
        (i) suffixes are consistent with merge.data.frame; existing users
        may set options(datatable.pre.suffixes=TRUE) for backwards
        compatibility.
        (ii) support for 'by' argument added (FR #1315).
        However, X[Y] syntax is preferred; some users never use merge.


#### BUG FIXES

   *    by=key(DT) now works when the number of rows is not
        divisible by the number of groups (#1298, an odd bug).
        Thanks to Steve Lianoglou for reporting.

   *    Combining i and by where i is logical or integer subset now
        works, fixing bug #1294. Thanks to Johann Hibschman for
        contributing a new test.

   *    Variable scope inside [[...]] now works without a workaround
        required. This can be useful for looking up which function
        to call based on the data e.g. DT[,fns[[fn]](colA),by=ID].
        Thanks to Damian Betebenner for reporting.

   *    Column names in self joins such as DT[DT] are no longer
        duplicated, fixing bug #1340. Thanks to Andreas Borg for
        reporting.


#### USER-VISIBLE CHANGES

   *    Additions and updates to FAQ vignette. Thanks to Dennis
        Murphy for his thorough proof reading.

   *    Welcome to Steve Lianoglou who joins the project
        contributing S4-ization, testing using testthat, and more.

   *    IDateTime is now linked from ?data.table. data.table users
        unaware of IDateTime, please do take a look. Tom added
        IDateTime in v1.5 (see below).


### Changes in v1.5.3

#### NEW FEATURES

   *    .SD no longer includes 'by' columns, FR#978. This resolves
        the long standing annoyance of duplicated 'by' columns
        when the j expression returns a subset of rows from .SD.
        For example, the following query no longer contains
        a redundant 'colA.1' duplicate.
            DT[,.SD[2],by=colA] #  2nd row of each group
        Any existing code that uses .SD may require simple
        changes to remove workarounds.

   *    'by' may now be a character vector of column names.
        This allows syntax such as DT[,sum(x),by=key(DT)].

   *    X[Y] now includes Y's non-join columns, as most users
        naturally expect, FR#746. Please do use j in one step
        (i.e. X[Y,j]) since that merges just the columns j uses and
        is much more efficient than X[Y][,j] or merge(X,Y)[,j].

   *    The 'Join Inherited Scope' feature is back on, FR#1095. This
        is consistent with X[Y] including Y's non-join columns, enabling
        natural progression from X[Y] to X[Y,j]. j sees columns in X
        first then Y.
        If the same column name exists in both X and Y, the data in
        Y can be accessed via a prefix "i." (not yet implemented).

   *    Ad hoc by now coerces double to integer (provided they are
        all.equal) and character to factor, FR#1051, as setkey
        already does.

#### USER-VISIBLE CHANGES

   *    The default for mult is now "all", as planned and
        prior notice given in FAQ 2.2.

   *    ?[.data.table has been merged into ?data.table and updated,
        simplified, corrected and formatted.

#### DEPRECATED & DEFUNCT

   *    The DT() alias is now fully deprecated, as warned
        in NEWS for v1.4, and FAQs 2.6 and 2.7.


### Changes in v1.5.2

#### NEW FEATURES

   *    'by' now works when DT contains list() columns i.e.
        where each value in a column may itself be vector
        or where each value is a different type. FR#1092.

   *    The result from merge() is now keyed. FR#1244.


#### BUG FIXES

    *   eval of parse()-ed expressions now works without
        needing quote() in the expression, bug #1243. Thanks
        to Joseph Voelkel for reporting.

    *   the result from the first group alone may be bigger
        than the table itself, bug #1245. Thanks to
        Steve Lianoglou for reporting.

    *   merge on a data.table with a single key'd column only
        and all=TRUE now works, bug #1241. Thanks to
        Joseph Voelkel for reporting.

    *   merge()-ing by a column called "x" now works, bug
        #1229 related to variable scope. Thanks to Steve
        Lianoglou for reporting.


### Changes in v1.5.1

#### BUG FIXES

    *   Fixed inheritance for other packages importing or depending
        on data.table, bugs #1093 and #1132. Thanks to Koert Kuipers
        for reporting.

    *   data.table queries can now be used at the debugger() prompt,
        fixing bug #1131 related to inheritance from data.frame.


### Changes in v1.5

#### NEW FEATURES

    *   data.table now *inherits* from data.frame, for functions and
        packages which _only_ accept data.frame, saving time and
        memory of conversion. A data.table is a data.frame too;
        is.data.frame() now returns TRUE.

    *   Integer-based date and time-of-day classes have been
        introduced. This allows dates and times to be used as keys
        more easily. See as.IDate, as.ITime, and IDateTime.
        Conversions to and from POSIXct, Date, and chron are
        supported.

    *   [<-.data.table and $<-.data.table were revised to check for
        changes to the key-ed columns. [<-.data.table also now allows
        data.table-style indexing for i. Both of these changes may
        introduce incompatibilities for existing code.

    *   Logical columns are now allowed in keys and in 'by', as are expressions
        that evaluate to logical. Thanks to David Winsemius for highlighting.


#### BUG FIXES

    *   DT[,5] now returns 5 as FAQ 1.1 says, for consistency
        with DT[,c(5)] and DT[,5+0]. DT[,"region"] now returns
        "region" as FAQ 1.2 says. Thanks to Harish V for reporting.

    *   When a quote()-ed expression q is passed to 'by' using
        by=eval(q), the group column names now come from the list
        in the expression rather than the name 'q' (bug #974) and,
        multiple items work (bug #975). Thanks to Harish V for
        reporting.

    *   quote()-ed i and j expressions receive similar fixes, bugs
        #977 and #1058. Thanks to Harish V and Branson Owen for
        reporting.

    *   Multiple errors (grammar, format and spelling) in intro.Rnw
        and faqs.Rnw corrected by Dennis Murphy. Thank you.

    *   Memory is now reallocated in rare cases when the up front
        allocate for the result of grouping is insufficient. Bug
        #952 raised by Georg V, and also reported by Harish. Thank
        you.

    *   A function call foo(arg=sum(b)) now finds b in DT when foo
        contains DT[,eval(substitute(arg)),by=a], fixing bug #1026.
        Thanks to Harish V for reporting.

    *   If DT contains column 'a' then DT[J(unique(a))] now finds
        'a', fixing bug #1005. Thanks to Branson Owen for reporting.

    *   'by' on no data (for example when 'i' returns no rows) now
        works, fixing bug #709.

    *   'by without by' now heeds nomatch=NA, fixing bug #1015.
        Thanks to Harish V for reporting.

    *   DT[NA] now returns 1 row of NA rather than the whole table
        via standard NA logical recycling. A single NA logical is
        a special case and is now replaced by NA_integer_. Thanks
        to Branson Owen for highlighting the issue.

    *   NROW removed from data.table, since the is.data.frame() in
        base::NROW now returns TRUE due to inheritance. Fixes bug
        #1039 reported by Bradley Buchsbaum. Thank you.

    *   setkey() now coerces character to factor and double to
        integer (provided they are all.equal), fixing bug #953.
        Thanks to Steve Lianoglou for reporting.

    *   'by' now accepts lists from the calling scope without the
        work around of wrapping with as.list() or {}, fixing bug
        #1060. Thanks to Johann Hibschman for reporting.


#### NOTES

    *   The package uses the 'default' option of base::getOption,
        and is therefore dependent on R 2.10.0. Updated DESCRIPTION
        file accordingly. Thanks to Christian Hudon for reporting.


### Changes in v1.4.1


#### NEW FEATURES

    *   Vignettes tidied up.


#### BUG FIXES

    *   Out of order levels in key columns are now sorted by
        setkey. Thanks to Steve Lianoglou for reporting.




### Changes in v1.4


#### NEW FEATURES

    *   'by' faster. Memory is allocated first for the result, then
    populated directly by the result of j for each group. Can be 10
    or more times faster than tapply() and aggregate(), see
    timings vignette.

    *   j should now be a list(), not DT(), of expressions. Use of
    j=DT(...) is caught internally and replaced with j=list(...).

    *   'by' may be a list() of expressions. A single column name
    is automatically list()-ed for convenience. 'by' may still be
    a comma separated character string, as before.
        DT[,sum(x),by=region]                     # new
        DT[,sum(x),by=list(region,month(date))]   # new
        DT[,sum(x),by="region"]                   # old, ok too
        DT[,sum(x),by="region,month(date)"]       # old, ok too

    *   key() and key<- added. More R-style alternatives to getkey()
    and setkey().

    *   haskey() added. Returns TRUE if a table has a key.

    *   radix sorting is now column by column where possible, was
    previously all or nothing. Helps with keys of many columns.

    *   Added format method.

    *   22 tests added to test.data.table(), now 149.

    *   Three vignettes added : FAQ, Intro & Timings


#### DEPRECATED & DEFUNCT

    *   The DT alias is removed. Use 'data.table' instead to create
    objects. See 2nd new feature above.

    *   RUnit framework removed.
    test.data.table() is called from examples in .Rd so 'R CMD check'
    will run it. Simpler. An eval(body(test.data.table))
    is also in the .Rd, to catch namespace issues.

    *   Dependency on package 'ref' removed.

    *   Arguments removed:  simplify, incbycols and byretn.
    Grouping is simpler now, these are superfluous.


#### BUG FIXES

    *   Column classes are now retained by subset and grouping.

    *   tail no longer fails when a column 'x' exists.


#### KNOWN PROBLEMS

    *   Minor : Join Inherited Scope not working, contrary
        to the documentation.


#### NOTES

    *   v1.4 was essentially the branch at rev 44, reintegrated
    at rev 78.




### Changes in v1.3


#### NEW FEATURES

    *   Radix sorting added. Speeds up setkey and add-hoc 'by'
    by factor of 10 or more.

    *   Merge method added, much faster than base::merge method
    of data.frame.

    *   'by' faster. Logic moved from R into C. Memory is
    allocated for the largest group only, then re-used.

    *   The Sub Data is accessible as a whole by j using object
    .SD. This should only be used in rare circumstances. See FAQ.

    *   Methods added : duplicated, unique, transform, within,
    [<-, t, Math, Ops, is.na, na.omit, summary

    *   Column name rules improved e.g. dots now allowed.

    *   as.data.frame.data.table rownames improved.

    *   29 tests added to test.data.table(), now 127.


#### USER-VISIBLE CHANGES

    *   Default of mb changed, now tables(mb=TRUE)


#### DEPRECATED & DEFUNCT

    *   ... removed in [.data.table.
    j may not be a function, so this is now superfluous.


#### BUG FIXES

    *   Incorrect version warning with R 2.10+ fixed.

    *   j enclosure raised one level. This fixes some bugs
    where the j expression previously saw internal variable
    names. It also speeds up grouping a little.


#### NOTES

    *   v1.3 was not released to CRAN. R-Forge repository only.



### v1.2 released to CRAN in Aug 2008


