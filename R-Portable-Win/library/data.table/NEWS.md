**If you are viewing this file on CRAN, please check [latest news on GitHub](https://github.com/Rdatatable/data.table/blob/master/NEWS.md) where the formatting is also better.**

### Changes in v1.12.2

#### NEW FEATURES

1. `:=` no longer recycles length>1 RHS vectors. There was a warning when recycling left a remainder but no warning when the LHS length was an exact multiple of the RHS length (the same behaviour as base R). Consistent feedback for several years has been that recycling is more often a bug. In rare cases where you need to recycle a length>1 vector, please use `rep()` explicitly. Single values are still recycled silently as before. Early warning was given in [this tweet](https://twitter.com/MattDowle/status/1088544083499311104). The 774 CRAN and Bioconductor packages using data.table were tested and the maintainers of the 16 packages affected (2%) were consulted before going ahead, [#3310](https://github.com/Rdatatable/data.table/pull/3310). Upon agreement we went ahead. Many thanks to all those maintainers for already updating on CRAN, [#3347](https://github.com/Rdatatable/data.table/pull/3347).

2. `foverlaps` now supports `type="equal"`, [#3416](https://github.com/Rdatatable/data.table/issues/3416) and part of [#3002](https://github.com/Rdatatable/data.table/issues/3002).

3. The number of logical CPUs used by default has been reduced from 100% to 50%. The previous 100% default was reported to cause significant slow downs when other non-trivial processes were also running, [#3395](https://github.com/Rdatatable/data.table/issues/3395) [#3298](https://github.com/Rdatatable/data.table/issues/3298). Two new optional environment variables (`R_DATATABLE_NUM_PROCS_PERCENT` & `R_DATATABLE_NUM_THREADS`) control this default. \code(setDTthreads()) gains \code{percent=} and \code{?setDTthreads} has been significantly revised. The output of \code{getDTthreads(verbose=TRUE)} has been expanded. The environment variable `OMP_THREAD_LIMIT` is now respected ([#3300](https://github.com/Rdatatable/data.table/issues/3300)) in addition to `OMP_NUM_THREADS` as before.

4. `rbind` and `rbindlist` now retain the position of duplicate column names rather than grouping them together [#3373](https://github.com/Rdatatable/data.table/issues/3373), fill length 0 columns (including NULL) with NA with warning [#1871](https://github.com/Rdatatable/data.table/issues/1871), and recycle length-1 columns [#524](https://github.com/Rdatatable/data.table/issues/524). Thanks to Kun Ren for the requests which arose when parsing JSON.

5. `rbindlist`'s `use.names=` default has changed from `FALSE` to `"check"`. This emits a message if the column names of each item are not identical and then proceeds as if `use.names=FALSE` for backwards compatibility; i.e., bind by column position not by column name. The `rbind` method for `data.table` already sets `use.names=TRUE` so this change affects `rbindlist` only and not `rbind.data.table`. To stack differently named columns together silently (the previous default behavior of `rbindlist`), it is now necessary to specify `use.names=FALSE` for clarity to readers of your code. Thanks to Clayton Stanley who first raised the issue [here](http://lists.r-forge.r-project.org/pipermail/datatable-help/2014-April/002480.html). To aid pinpointing the calls to `rbindlist` that need attention, the message can be turned to error using `options(datatable.rbindlist.check="error")`. This option also accepts `"warning"`, `"message"` and `"none"`. In this release the message is suppressed for default column names (`"V[0-9]+"`); the next release will emit the message for those too. In 6 months the default will be upgraded from message to warning. There are two slightly different messages. They are helpful, include context and point to this news item :
    ```
    Column %d ['%s'] of item %d is missing in item %d. Use fill=TRUE to fill with
      NA (NULL for list columns), or use.names=FALSE to ignore column names.
      See news item 5 in v1.12.2 for options to control this message.

    Column %d ['%s'] of item %d appears in position %d in item %d. Set use.names=TRUE
      to match by column name, or use.names=FALSE to ignore column names.
      See news item 5 in v1.12.2 for options to control this message.
    ```

6. `fread` gains `keepLeadingZeros`, [#2999](https://github.com/Rdatatable/data.table/issues/2999). By default `FALSE` so that, as before, a field containing `001` is interpretted as the integer 1, otherwise the character string `"001"`. The default may be changed using `options(datatable.keepLeadingZeros=TRUE)`. Many thanks to @marc-outins for the PR.

#### BUG FIXES

1. `rbindlist()` of a malformed factor which is missing a levels attribute is now a helpful error rather than a cryptic error about `STRING_ELT`, [#3315](https://github.com/Rdatatable/data.table/issues/3315). Thanks to Michael Chirico for reporting.

2. Forgetting `type=` in `shift(val, "lead")` would segfault, [#3354](https://github.com/Rdatatable/data.table/issues/3354). A helpful error is now produced to indicate `"lead"` is being passed to `n=` rather than the intended `type=` argument. Thanks to @SymbolixAU for reporting.

3. The default print output (top 5 and bottom 5 rows) when ncol>255 could display the columns in the wrong order, [#3306](https://github.com/Rdatatable/data.table/issues/3306). Thanks to Kun Ren for reporting.

4. Grouping by unusual column names such as `by='string_with_\\'` and `keyby="x y"` could fail, [#3319](https://github.com/Rdatatable/data.table/issues/3319) [#3378](https://github.com/Rdatatable/data.table/issues/3378). Thanks to @HughParsonage for reporting and @MichaelChirico for the fixes.

5. `foverlaps()` could return incorrect results for `POSIXct <= 1970-01-01`, [#3349](https://github.com/Rdatatable/data.table/issues/3349). Thanks to @lux5 for reporting.

6. `dcast.data.table` now handles functions passed to `fun.aggregate=` via a variable; e.g., `funs <- list(sum, mean); dcast(..., fun.aggregate=funs`, [#1974](https://github.com/Rdatatable/data.table/issues/1974) [#1369](https://github.com/Rdatatable/data.table/issues/1369) [#2064](https://github.com/Rdatatable/data.table/issues/2064) [#2949](https://github.com/Rdatatable/data.table/issues/2949). Thanks to @sunbee, @Ping2016, @smidelius and @d0rg0ld for reporting.

7. Some non-equijoin cases could segfault, [#3401](https://github.com/Rdatatable/data.table/issues/3401). Thanks to @Gayyam for reporting.

8. `dcast.data.table` could sort rows containing `NA` incorrectly, [#2202](https://github.com/Rdatatable/data.table/issues/2202). Thanks to @Galileo-Galilei for the report.

9. Sorting, grouping and finding unique values of a numeric column containing at most one finite value (such as `c(Inf,0,-Inf)`) could return incorrect results, [#3372](https://github.com/Rdatatable/data.table/issues/3372) [#3381](https://github.com/Rdatatable/data.table/issues/3381); e.g., `data.table(A=c(Inf,0,-Inf), V=1:3)[,sum(V),by=A]` would treat the 3 rows as one group. This was a regression in 1.12.0. Thanks to Nicolas Ampuero for reporting.

10. `:=` with quoted expression and dot alias now works as expected, [#3425](https://github.com/Rdatatable/data.table/pull/3425). Thanks to @franknarf1 for raising and @jangorecki for the PR.

11. A join's result could be incorrectly keyed when a single nomatch occurred at the very beginning while all other values matched, [#3441](https://github.com/Rdatatable/data.table/issues/3441). The incorrect key would cause incorrect results in subsequent queries. Thanks to @symbalex for reporting and @franknarf1 for pinpointing the root cause.

12. `rbind` and `rbindlist(..., use.names=TRUE)` with over 255 columns could return the columns in a random order, [#3373](https://github.com/Rdatatable/data.table/issues/3373). The contents and name of each column was correct but the order that the columns appeared in the result might not have matched the original input.

13. `rbind` and `rbindlist` now combine `integer64` columns together with non-`integer64` columns correctly [#1349](https://github.com/Rdatatable/data.table/issues/1349), and support `raw` columns [#2819](https://github.com/Rdatatable/data.table/issues/2819).

14. `NULL` columns are caught and error appropriately rather than segfault in some cases, [#2303](https://github.com/Rdatatable/data.table/issues/2303) [#2305](https://github.com/Rdatatable/data.table/issues/2305). Thanks to Hugh Parsonage and @franknarf1 for reporting.

15. `melt` would error with 'factor malformed' or segfault in the presence of duplicate column names, [#1754](https://github.com/Rdatatable/data.table/issues/1754). Many thanks to @franknarf1, William Marble, wligtenberg and Toby Dylan Hocking for reproducible examples. All examples have been added to the test suite.

16. Removing a column from a null (0-column) data.table is now a (standard and simpler) warning rather than error, [#2335](https://github.com/Rdatatable/data.table/issues/2335). It is no longer an error to add a column to a null (0-column) data.table.

17. Non-UTF8 strings were not always sorted correctly on Windows (a regression in v1.12.0), [#3397](https://github.com/Rdatatable/data.table/issues/3397) [#3451](https://github.com/Rdatatable/data.table/issues/3451). Many thanks to @shrektan for reporting and fixing.

18. `cbind` with a null (0-column) `data.table` now works as expected, [#3445](https://github.com/Rdatatable/data.table/issues/3445). Thanks to @mb706 for reporting.

19. Subsetting does a better job of catching a malformed `data.table` with error rather than segfault. A column may not be NULL, nor may a column be an object such as a data.frame or matrix which have columns. Thanks to a comment and reproducible example in [#3369](https://github.com/Rdatatable/data.table/issues/3369) from Drew Abbot which demonstrated the issue which arose from parsing JSON. The next release will enable `as.data.table` to unpack columns which are data.frame to support this use case.

#### NOTES

1. When upgrading to 1.12.0 some Windows users might have seen `CdllVersion not found` in some circumstances. We found a way to catch that so the [helpful message](https://twitter.com/MattDowle/status/1084528873549705217) now occurs for those upgrading from versions prior to 1.12.0 too, as well as those upgrading from 1.12.0 to a later version. See item 1 in notes section of 1.12.0 below for more background.

2. v1.12.0 checked itself on loading using `tools::checkMD5sums("data.table")` but this check failed under the `packrat` package manager on Windows because `packrat` appears to modify the DESCRIPTION file of packages it has snapshot, [#3329](https://github.com/Rdatatable/data.table/issues/3329). This check is now removed. The `CdllVersion` check was introduced after the `checkMD5sums()` attempt and is better; e.g., reliable on all platforms. 

3. As promised in new feature 6 of v1.11.6 Sep 2018 (see below in this news file), the `datatable.CJ.names` option's default is now `TRUE`. In v1.13.0 it will be removed.

4. Travis CI gains OSX using homebrew llvm for OpenMP support, [#3326](https://github.com/Rdatatable/data.table/issues/3326). Thanks @marcusklik for the PR.

5. Calling `data.table:::print.data.table()` directly (i.e. bypassing method dispatch by using 3 colons) and passing it a 0-column `data.frame` (not `data.table`) now works, [#3363](https://github.com/Rdatatable/data.table/pull/3363). Thanks @heavywatal for the PR.

6. v1.12.0 did not compile on Solaris 10 using Oracle Developer Studio 12.6, [#3285](https://github.com/Rdatatable/data.table/issues/3285). Many thanks to Prof Ripley for providing and testing a patch. For future reference and other package developers, a `const` variable should not be passed to OpenMP's `num_threads()` directive otherwise `left operand must be modifiable lvalue` occurs. This appears to be a compiler bug which is why the specific versions are mentioned in this note.

7. `foverlaps` provides clearer error messages w.r.t. factor and POSIXct interval columns, [#2645](https://github.com/Rdatatable/data.table/issues/2645) [#3007](https://github.com/Rdatatable/data.table/issues/3007) [#1143](https://github.com/Rdatatable/data.table/issues/1143). Thanks to @sritchie73, @msummersgill and @DavidArenburg for the reports.

8. `unique(DT)` checks up-front the types of all the columns and will fail if any column is type `list` even though those `list` columns may not be needed to establish uniqueness. Use `unique(DT, by=...)` to specify columns that are not type `list`. v1.11.8 and before would also correctly fail with the same error, but not when uniqueness had been established in prior columns: it would stop early, not look at the `list` column and return the correct result. Checking up-front was necessary for some internal optimizations and it's probably best to be explicit anyway. Thanks to James Lamb for reporting, [#3332](https://github.com/Rdatatable/data.table/issues/3332). The error message has been embellished :
    ```
    Column 2 of by= (2) is type 'list', not yet supported. Please use the by= argument to specify columns with types that are supported.
    ```

9. Reminder that note 11 in v1.11.0 (May 2018) warned that `set2key()` and `key2()` will be removed in May 2019. They have been warning since v1.9.8 (Nov 2016) and their warnings were upgraded to errors in v1.11.0 (May 2018). When they were introduced in version 1.9.4 (Oct 2014) they were marked as 'experimental'.

10. The `key(DT)<-` form of `setkey()` has been warning since at least 2012 to use `setkey()`. The warning is now stronger: `key(x)<-value is deprecated and not supported. Please change to use setkey().`. This warning will be upgraded to error in one year.


### Changes in v1.12.0  (13 Jan 2019)

#### NEW FEATURES

1. `setDTthreads()` gains `restore_after_fork=`, [#2885](https://github.com/Rdatatable/data.table/issues/2885). The default `NULL` leaves the internal option unchanged which by default is `TRUE`. `data.table` has always switched to single-threaded mode on fork. It used to restore multithreading after a fork too but problems were reported on Mac and Intel OpenMP library (see 1.10.4 notes below). We are now trying again thanks to suggestions and success reported by Kun Ren and Mark Klik in package `fst`. If you experience problems with multithreading after a fork, please restart R and call `setDTthreads(restore_after_fork=FALSE)`.

2. Subsetting, ordering and grouping now use more parallelism. See benchmarks [here](https://h2oai.github.io/db-benchmark/) and Matt Dowle's presentation in October 2018 on YouTube [here](https://youtu.be/Ddr8N9STSuI). These internal changes gave rise to 4 regressions which were found before release thanks to Kun Ren, [#3211](https://github.com/Rdatatable/data.table/issues/3211). He kindly volunteers to 'go-first' and runs data.table through his production systems before release. We are looking for a 'go-second' volunteer please. A request to test before release was tweeted on 17 Dec [here](https://twitter.com/MattDowle/status/1074746218645938176). As usual, all CRAN and Bioconductor packages using data.table (currently 750) have been tested against this release, [#3233](https://github.com/Rdatatable/data.table/issues/3233). There are now 8,000 tests in 13,000 lines of test code; more lines of test code than there is code. Overall coverage has increased to 94% thanks to Michael Chirico.

3. New `frollmean` has been added by Jan Gorecki to calculate _rolling mean_, see `?froll` for documentation. Function name and arguments are experimental. Related to [#2778](https://github.com/Rdatatable/data.table/issues/2778) (and [#624](https://github.com/Rdatatable/data.table/issues/624), [#626](https://github.com/Rdatatable/data.table/issues/626), [#1855](https://github.com/Rdatatable/data.table/issues/1855)). Other rolling statistics will follow.

4. `fread()` can now read a remote compressed file in one step; `fread("https://domain.org/file.csv.bz2")`. The `file=` argument now supports `.gz` and `.bz2` too; i.e. `fread(file="file.csv.gz")` works now where only `fread("file.csv.gz")` worked in 1.11.8.

5. `nomatch=NULL` now does the same as `nomatch=0L` in both `DT[...]` and `foverlaps()`; i.e. discards missing values silently (inner join). The default is still `nomatch=NA` (outer join) for statistical safety so that missing values are retained by default. After several years have elapsed, we will start to deprecate `0L`; please start using `NULL`. In future `nomatch=.(0)` (note that `.()` creates a `list` type and is different to `nomatch=0`) will fill with `0` to save replacing `NA` with `0` afterwards, [#857](https://github.com/Rdatatable/data.table/issues/857).

6. `setnames()` gains `skip_absent` to skip names in `old` that aren't present, [#3030](https://github.com/Rdatatable/data.table/issues/3030). By default `FALSE` so that it is still an error, as before, to attempt to change a column name that is not present. Thanks to @MusTheDataGuy for the suggestion and the PR.

7. `NA` in `between()` and `%between%`'s `lower` and `upper` are now taken as missing bounds and return `TRUE` rather than `NA`. This is now documented.

8. `shift()` now interprets negative values of `n` to mean the opposite `type=`, [#1708](https://github.com/Rdatatable/data.table/issues/1708). When `give.names=TRUE` the result is named using a positive `n` with the appropriate `type=`. Alternatively, a new `type="shift"` names the result using a signed `n` and constant type.
    ```R
    shift(x, n=-5:5, give.names=TRUE)                =>  "_lead_5" ... "_lag_5"
    shift(x, n=-5:5, type="shift", give.names=TRUE)  =>  "_shift_-5" ... "_shift_5"
    ``` 

9. `fwrite()` now accepts `matrix`, [#2613](https://github.com/Rdatatable/data.table/issues/2613). Thanks to Michael Chirico for the suggestion and Felipe Parages for implementing. For now matrix input is converted to data.table (which can be costly) before writing. 

10. `fread()` and `fwrite()` can now handle file names in native and UTF-8 encoding, [#3078](https://github.com/Rdatatable/data.table/issues/3078). Thanks to Daniel Possenriede (@dpprdan) for reporting and fixing.

11. `DT[i]` and `DT[i,cols]` now call internal parallel subsetting code, [#2951](https://github.com/Rdatatable/data.table/issues/2951). Subsetting is significantly faster (as are many other operations) with factor columns rather than character.
    ```R
    N = 2e8                           # 4GB data on 4-core CPU with 16GB RAM
    DT = data.table(ID = sample(LETTERS,N,TRUE),
                    V1 = sample(5,N,TRUE),
                    V2 = runif(N))
    w = which(DT$V1 > 3)              #  select 40% of rows
                                      #  v1.12.0   v1.11.8
    system.time(DT[w])                #     0.8s      2.6s
    DT[, ID := as.factor(ID)]
    system.time(DT[w])                #     0.4s      2.3s
    system.time(DT[w, c("ID","V2")])  #     0.3s      1.9s
    ```
    
12. `DT[..., .SDcols=]` now accepts `patterns()`; e.g. `DT[..., .SDcols=patterns("^V")]`, for filtering columns according to a pattern (as in `melt.data.table`), [#1878](https://github.com/Rdatatable/data.table/issues/1878). Thanks to many people for pushing for this and @MichaelChirico for ultimately filing the PR. See `?data.table` for full details and examples.

13. `split` data.table method will now preserve attributes, closes [#2047](https://github.com/Rdatatable/data.table/issues/2047). Thanks to @caneff for reporting.

14. `DT[i,j]` now retains user-defined and inherited attributes, [#995](https://github.com/Rdatatable/data.table/issues/995); e.g.
    ```R
    attr(datasets::BOD,"reference")                     # "A1.4, p. 270"
    attr(as.data.table(datasets::BOD)[2],"reference")   # was NULL now "A1.4, p. 270"
    ```
    If a superclass defines attributes that may not be valid after a `[` subset then the superclass should implement its own `[` method to manage those after calling `NextMethod()`.

#### BUG FIXES

1. Providing an `i` subset expression when attempting to delete a column correctly failed with helpful error, but when the column was missing too created a new column full of `NULL` values, [#3089](https://github.com/Rdatatable/data.table/issues/3089). Thanks to Michael Chirico for reporting.

2. Column names that look like expressions (e.g. `"a<=colB"`) caused an error when used in `on=` even when wrapped with backticks, [#3092](https://github.com/Rdatatable/data.table/issues/3092). Additionally, `on=` now supports white spaces around operators; e.g. `on = "colA == colB"`. Thanks to @mt1022 for reporting and to @MarkusBonsch for fixing.

3. Unmatched `patterns` in `measure.vars` fail early and with feedback, [#3106](https://github.com/Rdatatable/data.table/issues/3106).

4. `fread(..., skip=)` now skips non-standard `\r` and `\n\r` line endings properly again, [#3006](https://github.com/Rdatatable/data.table/issues/3006). Standard line endings (`\n` Linux/Mac and `\r\n` Windows) were skipped ok. Thanks to @brattono and @tbrycekelly for providing reproducible examples, and @st-pasha for fixing.

5. `fread(..., colClasses=)` could return a corrupted result when a lower type was requested for one or more columns (e.g. reading "3.14" as integer), [#2922](https://github.com/Rdatatable/data.table/issues/2922) [#2863](https://github.com/Rdatatable/data.table/issues/2863) [#3143](https://github.com/Rdatatable/data.table/issues/3143). It now ignores the request as documented and the helpful message in verbose mode is upgraded to warning. In future, coercing to a lower type might be supported (with warning if any accuracy is lost). `"NULL"` is recognized again in both vector and list mode; e.g. `colClasses=c("integer","NULL","integer")` and `colClasses=list(NULL=2, integer=10:40)`. Thanks to Arun Srinivasan, Kun Ren, Henri Ståhl and @kszela24 for reporting.

6. `cube()` will now produce expected order of results, [#3179](https://github.com/Rdatatable/data.table/issues/3179). Thanks to @Henrik-P for reporting.

7. `groupingsets()` groups by empty column set and constant value in `j`, [#3173](https://github.com/Rdatatable/data.table/issues/3173).

8. `split.data.table()` failed if `DT` had a factor column named `"x"`, [#3151](https://github.com/Rdatatable/data.table/issues/3151). Thanks to @tdeenes for reporting and fixing.

9. `fsetequal` now handles properly datasets having last column a character, closes [#2318](https://github.com/Rdatatable/data.table/issues/2318). Thanks to @pschil and @franknarf1 for reporting.

10. `DT[..., .SDcols=integer(0L)]` could fail, [#3185](https://github.com/Rdatatable/data.table/issues/3185). An empty `data.table` is now returned correctly.

11. `as.data.table.default` method will now always copy its input, closes [#3230](https://github.com/Rdatatable/data.table/issues/3230). Thanks to @NikdAK for reporting.

12. `DT[..., .SDcols=integer()]` failed with `.SDcols is numeric but has both +ve and -ve indices`, [#1789](https://github.com/Rdatatable/data.table/issues/1789) and [#3185](https://github.com/Rdatatable/data.table/issues/3185). It now functions as `.SDcols=character()` has done and creates an empty `.SD`. Thanks to Gabor Grothendieck and Hugh Parsonage for reporting. A related issue with empty `.SDcols` was fixed in development before release thanks to Kun Ren's testing, [#3211](https://github.com/Rdatatable/data.table/issues/3211).

13. Multithreaded stability should be much improved with R 3.5+. Many thanks to Luke Tierney for pinpointing a memory issue with package `constellation` caused by `data.table` and his advice, [#3165](https://github.com/Rdatatable/data.table/issues/3165). Luke also added an extra check to R-devel when compiled with `--enable-strict-barrier`. The test suite is run through latest daily R-devel after every commit as usual, but now with `--enable-strict-barrier` on too via GitLab Pipelines ("Extra" badge at the top of the data.table [homepage](http://r-datatable.com)) thanks to Jan Gorecki.

14. Fixed an edge-case bug of platform-dependent output of `strtoi("", base = 2L)` on which `groupingsets` had relied, [#3267](https://github.com/Rdatatable/data.table/issues/3267). 

#### NOTES

1. When data.table loads it now checks its DLL version against the version of its R level code. This is to detect installation issues on Windows when i) the DLL is in use by another R session and ii) the CRAN source version > CRAN binary binary which happens just after a new release (R prompts users to install from source until the CRAN binary is available). This situation can lead to a state where the package's new R code calls old C code in the old DLL; [R#17478](https://bugs.r-project.org/bugzilla/show_bug.cgi?id=17478), [#3056](https://github.com/Rdatatable/data.table/issues/3056). This broken state can persist until, hopefully, you experience a strange error caused by the mismatch. Otherwise, wrong results may occur silently. This situation applies to any R package with compiled code not just data.table, is Windows-only, and is long-standing. It has only recently been understood as it typically only occurs during the few days after each new release until binaries are available on CRAN.

2. When `on=` is provided but not `i=`, a helpful error is now produced rather than silently ignoring `on=`. Thanks to Dirk Eddelbuettel for the idea.

3. `.SDcols=` is more helpful when passed non-existent columns, [#3116](https://github.com/Rdatatable/data.table/issues/3116) and [#3118](https://github.com/Rdatatable/data.table/issues/3118). Thanks to Michael Chirico for the investigation and PR.

4. `update.dev.pkg()` gains `type=` to specify if update should be made from binaries, sources or both. [#3148](https://github.com/Rdatatable/data.table/issues/3148). Thanks to Reino Bruner for the detailed suggestions.

5. `setDT()` improves feedback when passed a ragged list (i.e. where all columns in the list are not the same length), [#3121](https://github.com/Rdatatable/data.table/issues/3121). Thanks @chuk-yong for highlighting.

6. The one and only usage of `UNPROTECT_PTR()` has been removed, [#3232](https://github.com/Rdatatable/data.table/issues/3232). Thanks to Tomas Kalibera's investigation and advice here: https://developer.r-project.org/Blog/public/2018/12/10/unprotecting-by-value/index.html


### Changes in v1.11.8  (30 Sep 2018)

#### NEW FEATURES

1. `fread()` can now read `.gz` and `.bz2` files directly: `fread("file.csv.gz")`, [#717](https://github.com/Rdatatable/data.table/issues/717) [#3058](https://github.com/Rdatatable/data.table/issues/3058). It uses `R.utils::decompressFile` to decompress to a `tempfile()` which is then read by `fread()` in the usual way. For greater speed on large-RAM servers, it is recommended to use ramdisk for temporary files by setting `TEMPDIR` to `/dev/shm`; see `?tempdir`. The decompressed temporary file is removed as soon as `fread` completes even if there is an error reading the file. Reading a remote compressed file in one step will be supported in the next version; e.g. `fread("http://domain.org/file.csv.bz2")`.

#### BUG FIXES

1. Joining two keyed tables using `on=` to columns not forming a leading subset of `key(i)` could result in an invalidly keyed result, [#3061](https://github.com/Rdatatable/data.table/issues/3061). Subsequent queries on the result could then return incorrect results. A warning `longer object length is not a multiple of shorter object length` could also occur. Thanks to @renkun-ken for reporting and the PR.

2. `keyby=` on columns for which an index exists now uses the index (new feature 7 in v1.11.6 below) but if an `i` subset is present in the same query then it could segfault, [#3062](https://github.com/Rdatatable/data.table/issues/3062). Again thanks to @renkun-ken for reporting.

3. Assigning an out-of-range integer to an item in a factor column (a rare operation) correctly created an `NA` in that spot with warning, but now no longer also corrupts the variable being assigned, [#2984](https://github.com/Rdatatable/data.table/issues/2984). Thanks to @radfordneal for reporting and @MarkusBonsch for fixing. Assigning a string which is missing from the factor levels continues to automatically append the string to the factor levels.

4. Assigning a sequence to a column using base R methods (e.g. `DT[["foo"]] = 1:10`) could cause subsetting to fail with `Internal error in subset.c: column <n> is an ALTREP vector`, [#3051](https://github.com/Rdatatable/data.table/issues/3051). Thanks to Michel Lang for reporting.

5. `as.data.table` `matrix` method now properly handles rownames for 0 column data.table output. Thanks @mllg for reporting. Closes [#3149](https://github.com/Rdatatable/data.table/issues/3149).

#### NOTES

1. The test suite now turns on R's new _R_CHECK_LENGTH_1_LOGIC2_ to catch when internal use of `&&` or `||` encounter arguments of length more than one. Thanks to Hugh Parsonage for implementing and fixing the problems caught by this.

2. Some namespace changes have been made with respect to melt, dcast and xts. No change is expected but if you do have any trouble, please file an issue.

3. `split.data.table` was exported in v1.11.6 in addition to being registered using `S3method(split, data.table)`. The export has been removed again. It had been added because a user said they found it difficult to find, [#2920](https://github.com/Rdatatable/data.table/issues/2920). But S3 methods are not normally exported explicitly by packages. The proper way to access the `split.data.table` method is to call `split(DT)` where `DT` is a `data.table`. The generic (`base::split` in this case) then dispatches to the `split.data.table` method. v1.11.6 was not on CRAN very long (1 week) so we think it's better to revert this change quickly. To know what methods exist, R provides the `methods()` function.
    ```R
    methods(split)               # all the methods for the split generic
    methods(class="data.table")  # all the generics that data.table has a method for (47 currently)
    ```


### Changes in v1.11.6  (19 Sep 2018)

#### NEW FEATURES

1. For convenience when some of the files in `fnams` are empty in `rbindlist(lapply(fnams,fread))`, `fread` now reads empty input as a null-data.table with warning rather than error, [#2898](https://github.com/Rdatatable/data.table/issues/2898). For consistency, `fwrite(data.table(NULL))` now creates an empty file and warns instead of error, too.

2. `setcolorder(DT)` without further arguments now defaults to moving the key columns to be first, [#2895](https://github.com/Rdatatable/data.table/issues/2895). Thanks to @jsams for the PR.

3. Attempting to subset on `col` when the column is actually called `Col` will still error, but the error message will helpfully suggest similarly-spelled columns, [#2887](https://github.com/Rdatatable/data.table/issues/2887). This is experimental, applies just to `i` currently, and we look forward to feedback. Thanks to Michael Chirico for the suggestion and PR.

4. `fread()` has always accepted literal data; e.g. `fread("A,B\n1,2\n3,4")`. It now gains explicit `text=`; e.g. `fread(text="A,B\n1,2\n3,4")`. Unlike the first general purpose `input=` argument, the `text=` argument accepts multi-line input; e.g. `fread(text=c("A,B","1,2","3,4"))`, [#1423](https://github.com/Rdatatable/data.table/issues/1423). Thanks to Douglas Clark for the request and Hugh Parsonage for the PR.

5. `fread()` has always accepted system commands; e.g. `fread("grep blah file.txt")`. It now gains explicit `cmd=`; e.g. `fread(cmd="grep blah file.txt")`. Further, if and only if `input=` is a system command and a variable was used to hold that command (`fread(someCommand)` not `fread("grep blah file.txt")`) or a variable is used to construct it (`fread(paste("grep",variable,"file.txt"))`), a message is now printed suggesting `cmd=`. This is to inform all users that there is a potential security concern if you are i) creating apps, and ii) your app takes input from a public user who could be malicious, and iii) input from the malicious user (such as a filename) is passed by your app to `fread()`, and iv) your app in not running in a protected environment. If all 4 conditions hold then the malicious user could provide a system command instead of a filename which `fread()` would run, and that would be a problem too. If the app is not running in a protected environment (e.g. app is running as root) then this could do damage or obtain data you did not intend. Public facing apps should be running with limited operating system permission so that any breach from any source is contained. We agree with [Linus Torvald's advice](https://lkml.org/lkml/2017/11/21/356) on this which boils down to: "when addressing security concerns the first step is do no harm, just inform". If you aren't creating apps or apis that could have a malicious user then there is no risk but we can't distinguish you so we have to inform everyone. Please change to `fread(cmd=...)` at your leisure. The new message can be suppressed with `options(datatable.fread.input.cmd.message=FALSE)`. Passing system commands to `fread()` continues to be recommended and encouraged and is widely used; e.g. via the techniques gathered together in the book [Data Science at the Command Line](https://www.datascienceatthecommandline.com/). A `warning()` is too strong because best-practice for production systems is to set `options(warn=2)` to tolerate no warnings. Such production systems have no user input and so there is no security risk; we don't want to do harm by breaking production systems via a `warning()` which gets turned into an error by `options(warn=2)`. Now that we have informed all users, we request feedback. There are 3 options for future releases: i) remove the message, ii) leave the message in place, iii) upgrade the message to warning and then eventually error. The default choice is the middle one: leave the message in place.

6. New `options(datatable.CJ.names=TRUE)` changes `CJ()` to auto-name its inputs exactly as `data.table()` does, [#1596](https://github.com/Rdatatable/data.table/issues/1596). Thanks @franknarf1 for the suggestion. Current default is `FALSE`; i.e. no change. The option's default will be changed to `TRUE` in v1.12.0 and then eventually the option will be removed. Any code that depends on `CJ(x,y)$V1` will need to be changed to `CJ(x,y)$x` and is more akin to a bug fix due to the inconsistency with `data.table()`.

7. If an appropriate index exists, `keyby=` will now use it. For example, given `setindex(DT,colA,colB)`, both `DT[,j,keyby=colA]` (a leading subset of the index columns) and `DT[,j,keyby=.(colA,colB)]` will use the index, but not `DT[,j,keyby=.(colB,colA)]`. The option `options(datatable.use.index=FALSE)` will turn this feature off. Please always use `keyby=` unless you wish to retain the order of groups by first-appearance order (in which case use `by=`). Also, both `keyby=` and `by=` already used the key where possible but are now faster when using just the first column of the key. As usual, setting `verbose=TRUE` either per-query or globally using `options(datatable.verbose=TRUE)` will report what's being done internally.

#### BUG FIXES

1. `fread` now respects the order of columns passed to `select=` when column numbers are used, [#2986](https://github.com/Rdatatable/data.table/issues/2986). It already respected the order when column names are used. Thanks @privefl for raising the issue.

2. `gmin` and `gmax` no longer fail on _ordered_ factors, [#1947](https://github.com/Rdatatable/data.table/issues/1947). Thanks to @mcieslik-mctp for identifying and @mbacou for the nudge.

3. `as.ITime.character` now properly handles NA when attempting to detect the format of non-NA values in vector. Thanks @polyjian for reporting, closes [#2940](https://github.com/Rdatatable/data.table/issues/2940).

4. `as.matrix(DT, rownames="id")` now works when `DT` has a single row, [#2930](https://github.com/Rdatatable/data.table/issues/2930). Thanks to @malcook for reporting and @sritchie73 for fixing. The root cause was the dual meaning of the `rownames=` argument: i) a single column name/number (most common), or ii) rowname values length 1 for the single row. For clarity and safety, `rownames.value=` has been added. Old usage (i.e. `length(rownames)>1`) continues to work for now but will issue a warning in a future release, and then error in a release after that.

5. Fixed regression in v1.11.0 (May 2018) caused by PR [#2389](https://github.com/Rdatatable/data.table/pull/2389) which introduced partial key retainment on `:=` assigns. This broke the joining logic that assumed implicitly that assigning always drops keys completely. Consequently, join and subset results could be wrong when matching character to factor columns with existing keys, [#2881](https://github.com/Rdatatable/data.table/issues/2881). Thanks to @ddong63 for reporting and to @MarkusBonsch for fixing. Missing test added to ensure this doesn't arise again.

6. `as.IDate.numeric` no longer ignores "origin", [#2880](https://github.com/Rdatatable/data.table/issues/2880). Thanks to David Arenburg for reporting and fixing.

7. `as.ITime.times` was rounding fractional seconds while other methods were truncating, [#2870](https://github.com/Rdatatable/data.table/issues/2870). The `as.ITime` method gains `ms=` taking `"truncate"` (default), `"nearest"` and `"ceil"`. Thanks to @rossholmberg for reporting and Michael Chirico for fixing.

8. `fwrite()` now writes POSIXct dates after 2038 correctly, [#2995](https://github.com/Rdatatable/data.table/issues/2995). Thanks to Manfred Zorn for reporting and Philippe Chataignon for the PR fixing it.

9. `fsetequal` gains the `all` argument to make it consistent with the other set operator functions `funion`, `fsetdiff` and `fintersect` [#2968](https://github.com/Rdatatable/data.table/issues/2968). When `all = FALSE` `fsetequal` will treat rows as elements in a set when checking whether two `data.tables` are equal (i.e. duplicate rows will be ignored). For now the default value is `all = TRUE` for backwards compatibility, but this will be changed to `all = FALSE` in a future release to make it consistent with the other set operation functions. Thanks to @franknarf1 for reporting and @sritchie73 for fixing.

10. `fintersect` failed on tables with a column called `y`, [#3034](https://github.com/Rdatatable/data.table/issues/3034). Thanks to Maxim Nazarov for reporting.

11. Compilation fails in AIX because NAN and INFINITY macros definition in AIX make them not constant literals, [#3043](https://github.com/Rdatatable/data.table/pull/3043). Thanks to Ayappan for reporting and fixing.

12. The introduction of altrep in R 3.5.0 caused some performance regressions of about 20% in some cases, [#2962](https://github.com/Rdatatable/data.table/issues/2962). Investigating this led to some improvements to grouping which are faster than before R 3.5.0 in some cases. Thanks to Nikolay S. for reporting. The work to accomodate altrep is not complete but it is better and it is highly recommended to upgrade to this update.

13. Fixed 7 memory faults thanks to CRAN's [`rchk`](https://github.com/kalibera/rchk) tool by Tomas Kalibera, [#3033](https://github.com/Rdatatable/data.table/pull/3033).

#### NOTES

1. The type coercion warning message has been improved, [#2989](https://github.com/Rdatatable/data.table/pull/2989). Thanks to @sarahbeeysian on [Twitter](https://twitter.com/sarahbeeysian/status/1021359529789775872) for highlighting. For example, given the follow statements:
    ```R
    DT = data.table(id=1:3)
    DT[2, id:="foo"]
    ```
    the warning message has changed from :<br>
    ```
    Coerced character RHS to integer to match the column's type. Either change the target column ['id']
    to character first (by creating a new character vector length 3 (nrows of entire table) and assign
    that; i.e. 'replace' column), or coerce RHS to integer (e.g. 1L, NA_[real|integer]_, as.*, etc) to
    make your intent clear and for speed. Or, set the column type correctly up front when you create the
    table and stick to it, please.
    ```
    to :<br>
    ```
    Coerced character RHS to integer to match the type of the target column (column 1 named 'id'). If the
    target column's type integer is correct, it's best for efficiency to avoid the coercion and create
    the RHS as type integer. To achieve that consider R's type postfix: typeof(0L) vs typeof(0), and
    typeof(NA) vs typeof(NA_integer_) vs typeof(NA_real_). Wrapping the RHS with as.integer() will avoid
    this warning but still perform the coercion. If the target column's type is not correct, it is best
    to revisit where the DT was created and fix the column type there; e.g., by using colClasses= in
    fread(). Otherwise, you can change the column type now by plonking a new column (of the desired type)
    over the top of it; e.g. DT[, `id`:=as.character(`id`)]. If the RHS of := has nrow(DT) elements then
    the assignment is called a column plonk and is the way to change a column's type. Column types can be
    observed with sapply(DT,typeof).
    ```
    Further, if a coercion from double to integer is performed, fractional data such as 3.14 is now detected and the truncation to 3 is warned about if and only if truncation has occurred.
    ```R
    DT = data.table(v=1:3)
    DT[2, v:=3.14]
    Warning message:
      Coerced double RHS to integer to match the type of the target column (column 1 named 'v'). One or
      more RHS values contain fractions which have been lost; e.g. item 1 with value 3.140000 has been
      truncated to 3.
    ```

2. `split.data.table` method is now properly exported, [#2920](https://github.com/Rdatatable/data.table/issues/2920). But we don't recommend it because `split` copies all the pieces into new memory.

3. Setting indices on columns which are part of the key will now create those indices.

4. `hour`, `minute`, and `second` utility functions use integer arithmetic when the input is already (explicitly) UTC-based `POSIXct` for 4-10x speedup vs. using `as.POSIXlt`.

5. Error added for incorrect usage of `%between%`, with some helpful diagnostic hints, [#3014](https://github.com/Rdatatable/data.table/issues/3014). Thanks @peterlittlejohn for offering his user experience and providing the impetus.


### Changes in v1.11.4  (27 May 2018)

1. Empty RHS of `:=` is no longer an error when the `i` clause returns no rows to assign to anyway, [#2829](https://github.com/Rdatatable/data.table/issues/2829). Thanks to @cguill95 for reporting and to @MarkusBonsch for fixing.

2. Fixed runaway memory usage with R-devel (R > 3.5.0), [#2882](https://github.com/Rdatatable/data.table/pull/2882). Thanks to many people but in particular to Trang Nguyen for making the breakthrough reproducible example, Paul Bailey for liaising, and Luke Tierney for then pinpointing the issue. It was caused by an interaction of two or more data.table threads operating on new compact vectors in the ALTREP framework, such as the sequence `1:n`. This interaction could result in R's garbage collector turning off, and hence the memory explosion. Problems may occur in R 3.5.0 too but we were only able to reproduce in R > 3.5.0. The R code in data.table's implementation benefits from ALTREP (`for` loops in R no longer allocate their range vector input, for example) but are not so appropriate as data.table columns. Sequences such as `1:n` are common in test data but not very common in real-world datasets. Therefore, there is no need for data.table to support columns which are ALTREP compact sequences. The `data.table()` function already expanded compact vectors (by happy accident) but `setDT()` did not (it now does). If, somehow, a compact vector still reaches the internal parallel regions, a helpful error will now be generated. If this happens, please report it as a bug.

3. Tests 1590.3 & 1590.4 now pass when users run `test.data.table()` on Windows, [#2856](https://github.com/Rdatatable/data.table/pull/2856). Thanks to Avraham Adler for reporting. Those tests were passing on AppVeyor, win-builder and CRAN's Windows because `R CMD check` sets `LC_COLLATE=C` as documented in R-exts$1.3.1, whereas by default on Windows `LC_COLLATE` is usually a regional Windows-1252 dialect such as `English_United States.1252`.

4. Around 1 billion very small groups (of size 1 or 2 rows) could result in `"Failed to realloc working memory"` even when plenty of memory is available, [#2777](https://github.com/Rdatatable/data.table/issues/2777). Thanks once again to @jsams for the detailed report as a follow up to bug fix 40 in v1.11.0.


### Changes in v1.11.2  (08 May 2018)

1. `test.data.table()` created/overwrote variable `x` in `.GlobalEnv`, [#2828](https://github.com/Rdatatable/data.table/issues/2828); i.e. a modification of user's workspace which is not allowed. Thanks to @etienne-s for reporting.

2. `as.chron` methods for `IDate` and `ITime` have been removed, [#2825](https://github.com/Rdatatable/data.table/issues/2825). `as.chron` still works since `IDate` inherits from `Date`. We are not sure why we had specific methods in the first place. It may have been from a time when `IDate` did not inherit from `Date`, perhaps. Note that we don't use `chron` ourselves in our own work.

3. Fixed `SETLENGTH() cannot be applied to an ALTVEC object` starting in R-devel (R 3.6.0) on 1 May 2018, a few hours after 1.11.0 was accepted on CRAN, [#2820](https://github.com/Rdatatable/data.table/issues/2820). Many thanks to Luke Tierney for pinpointing the problem.

4. Fixed some rare memory faults in `fread()` and `rbindlist()` found with `gctorture2()` and [`rchk`](https://github.com/kalibera/rchk), [#2841](https://github.com/Rdatatable/data.table/issues/2841).


### Changes in v1.11.0  (01 May 2018)

#### NOTICE OF INTENDED FUTURE POTENTIAL BREAKING CHANGES

1. `fread()`'s `na.strings=` argument :
    ```R
    "NA"                                      # old default
    getOption("datatable.na.strings", "NA")   # this release; i.e. the same; no change yet
    getOption("datatable.na.strings", "")     # future release
    ```
    This option controls how `,,` is read in character columns. It does not affect numeric columns which read `,,` as `NA` regardless. We would like `,,`=>`NA` for consistency with numeric types, and `,"",`=>empty string to be the standard default for `fwrite/fread` character columns so that `fread(fwrite(DT))==DT` without needing any change to any parameters. `fwrite` has never written `NA` as `"NA"` in case `"NA"` is a valid string in the data; e.g., 2 character id columns sometimes do. Instead, `fwrite` has always written `,,` by default for an `<NA>` in a character columns. The use of R's `getOption()` allows users to move forward now, using `options(datatable.fread.na.strings="")`, or restore old behaviour when the default's default is changed in future, using `options(datatable.fread.na.strings="NA")`.

2. `fread()` and `fwrite()`'s `logical01=` argument :
    ```R
    logical01 = FALSE                         # old default
    getOption("datatable.logical01", FALSE)   # this release; i.e. the same; no change yet
    getOption("datatable.logical01", TRUE)    # future release
    ```
    This option controls whether a column of all 0's and 1's is read as `integer`, or `logical` directly to avoid needing to change the type afterwards to `logical` or use `colClasses`. `0/1` is smaller and faster than `"TRUE"/"FALSE"`, which can make a significant difference to space and time the more `logical` columns there are. When the default's default changes to `TRUE` for `fread` we do not expect much impact since all arithmetic operators that are currently receiving 0's and 1's as type `integer` (think `sum()`) but instead could receive `logical`, would return exactly the same result on the 0's and 1's as `logical` type. However, code that is manipulating column types using `is.integer` or `is.logical` on `fread`'s result, could require change. It could be painful if `DT[(logical_column)]` (i.e. `DT[logical_column==TRUE]`) changed behaviour due to `logical_column` no longer being type `logical` but `integer`. But that is not the change proposed. The change is the other way around; i.e., a previously `integer` column holding only 0's and 1's would now be type `logical`. Since it's that way around, we believe the scope for breakage is limited. We think a lot of code is converting 0/1 integer columns to logical anyway, either using `colClasses=` or afterwards with an assign. For `fwrite`, the level of breakage depends on the consumer of the output file. We believe `0/1` is a better more standard default choice to move to. See notes below about improvements to `fread`'s sampling for type guessing, and automatic rereading in the rare cases of out-of-sample type surprises.


These options are meant for temporary use to aid your migration, [#2652](https://github.com/Rdatatable/data.table/pull/2652). You are not meant to set them to the old default and then not migrate your code that is dependent on the default. Either set the argument explicitly so your code is not dependent on the default, or change the code to cope with the new default. Over the next few years we will slowly start to remove these options, warning you if you are using them, and return to a simple default. See the history of NEWS and NEWS.0 for past migrations that have, generally speaking, been successfully managed in this way. For example, at the end of NOTES for this version (below in this file) is a note about the usage of `datatable.old.unique.by.key` now warning, as you were warned it would do over a year ago. When that change was introduced, the default was changed and that option provided an option to restore the old behaviour. These `fread`/`fwrite` changes are even more cautious and not even changing the default's default yet. Giving you extra warning by way of this notice to move forward. And giving you a chance to object.

#### NEW FEATURES

1. `fread()`:
    * Efficiency savings at C level including **parallelization** announced [here](https://github.com/Rdatatable/data.table/wiki/talks/BARUG_201704_ParallelFread.pdf); e.g. a 9GB 2 column integer csv input is **50s down to 12s** to cold load on a 4 core laptop with 16GB RAM and SSD. Run `echo 3 >/proc/sys/vm/drop_caches` first to measure cold load time. Subsequent load time (after file has been cached by OS on the first run) **40s down to 6s**.
    * The [fread for small data](https://github.com/Rdatatable/data.table/wiki/Convenience-features-of-fread) page has been revised.
    * Memory maps lazily; e.g. reading just the first 10 rows with `nrow=10` is **12s down to 0.01s** from cold for the 9GB file. Large files close to your RAM limit may work more reliably too. The progress meter will commence sooner and more consistently.
    * `fread` has always jumped to the middle and to the end of the file for a much improved column type guess. The sample size is increased from 100 rows at 10 jump jump points (1,000 rows) to 100 rows at 100 jumps points (10,000 row sample). In the rare case of there still being out-of-sample type exceptions, those columns are now *automatically reread* so you don't have to use `colClasses` yourself.
    * Large number of columns support; e.g. **12,000 columns** tested.
    * **Quoting rules** are more robust and flexible. See point 10 on the wiki page [here](https://github.com/Rdatatable/data.table/wiki/Convenience-features-of-fread#10-automatic-quote-escape-method-detection-including-no-escape).
    * Numeric data that has been quoted is now detected and read as numeric.
    * The ability to position `autostart` anywhere inside one of multiple tables in a single file is removed with warning. It used to search upwards from that line to find the start of the table based on a consistent number of columns. People appear to be using `skip="string"` or `skip=nrow` to find the header row exactly, which is retained and simpler. It was too difficult to retain search-upwards-autostart together with skipping/filling blank lines, filling incomplete rows and parallelization too. If there is any header info above the column names, it is still auto detected and auto skipped (particularly useful when loading a set of files where the column names start on different lines due to a varying height messy header).
    * `dec=','` is now implemented directly so there is no dependency on locale. The options `datatable.fread.dec.experiment` and `datatable.fread.dec.locale` have been removed.
    * `\\r\\r\\n` line endings are now handled such as produced by `base::download.file()` when it doubles up `\\r`. Other rare line endings (`\\r` and `\\n\\r`) are now more robust.
    * Mixed line endings are now handled; e.g. a file formed by concatenating a Unix file and a Windows file so that some lines end with `\\n` while others end with `\\r\\n`.
    * Improved automatic detection of whether the first row is column names by comparing the types of the fields on the first row against the column types ascertained by the 10,000 rows sample (or `colClasses` if provided). If a numeric column has a string value at the top, then column names are deemed present.
    * Detects GB-18030 and UTF-16 encodings and in verbose mode prints a message about BOM detection.
    * Detects and ignores trailing ^Z end-of-file control character sometimes created on MS DOS/Windows, [#1612](https://github.com/Rdatatable/data.table/issues/1612). Thanks to Gergely Daróczi for reporting and providing a file.
    * Added ability to recognize and parse hexadecimal floating point numbers, as used for example in Java. Thanks for @scottstanfield [#2316](https://github.com/Rdatatable/data.table/issues/2316) for the report.
    * Now handles floating-point NaN values in a wide variety of formats, including `NaN`, `sNaN`, `1.#QNAN`, `NaN1234`, `#NUM!` and others, [#1800](https://github.com/Rdatatable/data.table/issues/1800). Thanks to Jori Liesenborgs for highlighting and the PR.
    * If negative numbers are passed to `select=` the out-of-range error now suggests `drop=` instead, [#2423](https://github.com/Rdatatable/data.table/issues/2423). Thanks to Michael Chirico for the suggestion.
    * `sep=NULL` or `sep=""` (i.e., no column separator) can now be used to specify single column input reliably like `base::readLines`, [#1616](https://github.com/Rdatatable/data.table/issues/1616). `sep='\\n'` still works (even on Windows where line ending is actually `\\r\\n`) but `NULL` or `""` are now documented and recommended. Thanks to Dmitriy Selivanov for the pull request and many others for comments. As before, `sep=NA` is not valid; use the default `"auto"` for automatic separator detection. `sep='\\n'` is now deprecated and in future will start to warn when used.
    * Single-column input with blank lines is now valid and the blank lines are significant (representing `NA`). The blank lines are significant even at the very end, which may be surprising on first glance. The change is so that `fread(fwrite(DT))==DT` for single-column inputs containing `NA` which are written as blank. There is no change when `ncol>1`; i.e., input stops with detailed warning at the first blank line, because a blank line when `ncol>1` is invalid input due to no separators being present. Thanks to @skanskan, Michael Chirico, @franknarf1 and Pasha for the testing and discussions, [#2106](https://github.com/Rdatatable/data.table/issues/2106).
    * Too few column names are now auto filled with default column names, with warning, [#1625](https://github.com/Rdatatable/data.table/issues/1625). If there is just one missing column name it is guessed to be for the first column (row names or an index), otherwise the column names are filled at the end. Similarly, too many column names now automatically sets `fill=TRUE`, with warning.
    * `skip=` and `nrow=` are more reliable and are no longer affected by invalid lines outside the range specified. Thanks to Ziyad Saeed and Kyle Chung for reporting, [#1267](https://github.com/Rdatatable/data.table/issues/1267).
    * Ram disk (`/dev/shm`) is no longer used for the output of system command input. Although faster when it worked, it was causing too many device full errors; e.g., [#1139](https://github.com/Rdatatable/data.table/issues/1139) and [zUMIs/19](https://github.com/sdparekh/zUMIs/issues/19). Thanks to Kyle Chung for reporting. Standard `tempdir()` is now used. If you wish to use ram disk, set TEMPDIR to `/dev/shm`; see `?tempdir`.
    * Detecting whether a very long input string is a file name or data is now much faster, [#2531](https://github.com/Rdatatable/data.table/issues/2531). Many thanks to @javrucebo for the detailed report, benchmarks and suggestions.
    * A column of `TRUE/FALSE`s is ok, as well as `True/False`s and `true/false`s, but mixing styles (e.g. `TRUE/false`) is not and will be read as type `character`.
    * New argument `index` to compliment the existing `key` argument for applying secondary orderings out of the box for convenience, [#2633](https://github.com/Rdatatable/data.table/issues/2633).
    * A warning is now issued whenever incorrectly quoted fields have been detected and fixed using a non-standard quote rule. `fread` has always used these advanced rules but now it warns that it is using them. Most file writers correctly quote fields if the field contains the field separator, but a common error is not to also quote fields that contain a quote and then escape those quotes, particularly if that quote occurs at the start of the field. The ability to detect and fix such files is referred to as self-healing. Ambiguities are resolved using the knowledge that the number of columns is constant, and therefore this ability is not available when `fill=TRUE`. This feature can be improved in future by using column type consistency as well as the number of fields.
    ```R
    txt = 'A,B\n1,hello\n2,"howdy" said Joe\n3,bonjour\n'
    cat(txt)
    # A,B
    # 1,hello
    # 2,"howdy" said Joe
    # 3,bonjour
    fread(txt)
           A                B
       <int>           <char>
    1:     1            hello
    2:     2 "howdy" said Joe
    3:     3          bonjour
    Warning message:
    In fread(txt) : Found and resolved improper quoting
    ```
    * Many thanks to @yaakovfeldman, Guillermo Ponce, Arun Srinivasan, Hugh Parsonage, Mark Klik, Pasha Stetsenko, Mahyar K, Tom Crockett, @cnoelke, @qinjs, @etienne-s, Mark Danese, Avraham Adler, @franknarf1, @MichaelChirico, @tdhock, Luke Tierney, Ananda Mahto, @memoryfull, @brandenkmurray for testing dev and reporting these regressions before release to CRAN: #1464, #1671, #1888, #1895, #2070, #2073, #2087, #2091, #2092, #2107, #2118, #2123, #2167, #2194, #2196, #2201, #2222, #2228, #2238, #2246, #2251, #2265, #2267, #2285, #2287, #2299, #2322, #2347, #2352, #2370, #2371, #2395, #2404, #2446, #2453, #2457, #2464, #2481, #2499, #2512, #2515, #2516, #2518, #2520, #2523, #2526, #2535, #2542, #2548, #2561, #2600, #2625, #2666, #2697, #2735, #2744.

2. `fwrite()`:
    * empty strings are now always quoted (`,"",`) to distinguish them from `NA` which by default is still empty (`,,`) but can be changed using `na=` as before. If `na=` is provided and `quote=` is the default `'auto'` then `quote=` is set to `TRUE` so that if the `na=` value occurs in the data, it can be distinguished from `NA`. Thanks to Ethan Welty for the request [#2214](https://github.com/Rdatatable/data.table/issues/2214) and Pasha for the code change and tests, [#2215](https://github.com/Rdatatable/data.table/issues/2215).
    * `logical01` has been added and the old name `logicalAsInt` retained. Pease move to the new name when convenient for you. The old argument name (`logicalAsInt`) will slowly be deprecated over the next few years. The default is unchanged: `FALSE`, so `logical` is still written as `"TRUE"`/`"FALSE"` in full by default. We intend to change the default's default in future to `TRUE`; see the notice at the top of these release notes.

3. Added helpful message when subsetting by a logical column without wrapping it in parentheses, [#1844](https://github.com/Rdatatable/data.table/issues/1844). Thanks @dracodoc for the suggestion and @MichaelChirico for the PR.

4. `tables` gains `index` argument for supplementary metadata about `data.table`s in memory (or any optionally specified environment), part of [#1648](https://github.com/Rdatatable/data.table/issues/1648). Thanks due variously to @jangorecki, @rsaporta, @MichaelChirico for ideas and work towards PR.

5. Improved auto-detection of `character` inputs' formats to `as.ITime` to mirror the logic in `as.POSIXlt.character`, [#1383](https://github.com/Rdatatable/data.table/issues/1383) Thanks @franknarf1 for identifying a discrepancy and @MichaelChirico for investigating.

6. `setcolorder()` now accepts less than `ncol(DT)` columns to be moved to the front, [#592](https://github.com/Rdatatable/data.table/issues/592). Thanks @MichaelChirico for the PR. This also incidentally fixed [#2007](https://github.com/Rdatatable/data.table/issues/2007) whereby explicitly setting `select = NULL` in `fread` errored; thanks to @rcapell for reporting that and @dselivanov and @MichaelChirico for investigating and providing a new test.

7. Three new *Grouping Sets* functions: `rollup`, `cube` and `groupingsets`, [#1377](https://github.com/Rdatatable/data.table/issues/1377). Allows to aggregation on various grouping levels at once producing sub-totals and grand total.

8. `as.data.table()` gains new method for `array`s to return a useful data.table, [#1418](https://github.com/Rdatatable/data.table/issues/1418).

9. `print.data.table()` (all via master issue  [#1523](https://github.com/Rdatatable/data.table/issues/1523)):

    * gains `print.keys` argument, `FALSE` by default, which displays the keys and/or indices (secondary keys) of a `data.table`. Thanks @MichaelChirico for the PR, Yike Lu for the suggestion and Arun for honing that idea to its present form.

    * gains `col.names` argument, `"auto"` by default, which toggles which registers of column names to include in printed output. `"top"` forces `data.frame`-like behavior where column names are only ever included at the top of the output, as opposed to the default behavior which appends the column names below the output as well for longer (>20 rows) tables. `"none"` shuts down column name printing altogether. Thanks @MichaelChirico for the PR, Oleg Bondar for the suggestion, and Arun for guiding commentary.

    * list columns would print the first 6 items in each cell followed by a comma if there are more than 6 in that cell. Now it ends ",..." to make it clearer, part of [#1523](https://github.com/Rdatatable/data.table/issues/1523). Thanks to @franknarf1 for drawing attention to an issue raised on Stack Overflow by @TMOTTM [here](https://stackoverflow.com/q/47679701).

10. `setkeyv` accelerated if key already exists [#2331](https://github.com/Rdatatable/data.table/issues/2331). Thanks to @MarkusBonsch for the PR.

11. Keys and indexes are now partially retained up to the key column assigned to with ':=' [#2372](https://github.com/Rdatatable/data.table/issues/2372). They used to be dropped completely if any one of the columns was affected by `:=`. Tanks to @MarkusBonsch for the PR.

12. Faster `as.IDate` and `as.ITime` methods for `POSIXct` and `numeric`, [#1392](https://github.com/Rdatatable/data.table/issues/1392). Thanks to Jan Gorecki for the PR.

13. `unique(DT)` now returns `DT` early when there are no duplicates to save RAM, [#2013](https://github.com/Rdatatable/data.table/issues/2013). Thanks to Michael Chirico for the PR, and thanks to @mgahan for pointing out a reversion in `na.omit.data.table` before release, [#2660](https://github.com/Rdatatable/data.table/issues/2660#issuecomment-371027948).

14. `uniqueN()` is now faster on logical vectors. Thanks to Hugh Parsonage for [PR#2648](https://github.com/Rdatatable/data.table/pull/2648).
    ```
    N = 1e9
                                          was      now
    x = c(TRUE,FALSE,NA,rep(TRUE,N))
    uniqueN(x) == 3                      5.4s    0.00s
    x = c(TRUE,rep(FALSE,N), NA)
    uniqueN(x,na.rm=TRUE) == 2           5.4s    0.00s
    x = c(rep(TRUE,N),FALSE,NA)
    uniqueN(x) == 3                      6.7s    0.38s
    ```

15. Subsetting optimization with keys and indices is now possible for compound queries like `DT[a==1 & b==2]`, [#2472](https://github.com/Rdatatable/data.table/issues/2472).
Thanks to @MichaelChirico for reporting and to @MarkusBonsch for the implementation.

16. `melt.data.table` now offers friendlier functionality for providing `value.name` for `list` input to `measure.vars`, [#1547](https://github.com/Rdatatable/data.table/issues/1547). Thanks @MichaelChirico and @franknarf1 for the suggestion and use cases, @jangorecki and @mrdwab for implementation feedback, and @MichaelChirico for ultimate implementation.

17. `update.dev.pkg` is new function to update package from development repository, it will download package sources only when newer commit is available in repository. `data.table::update.dev.pkg()` defaults updates `data.table`, but any package can be used.

18. Item 1 in NEWS for [v1.10.2](https://github.com/Rdatatable/data.table/blob/master/NEWS.md#changes-in-v1102--on-cran-31-jan-2017) on CRAN in Jan 2017 included :
    > When j is a symbol prefixed with `..` it will be looked up in calling scope and its value taken to be column names or numbers.
    > When you see the `..` prefix think one-level-up, like the directory `..` in all operating systems means the parent directory.
    > In future the `..` prefix could be made to work on all symbols apearing anywhere inside `DT[...]`.

    The response has been positive ([this tweet](https://twitter.com/MattDowle/status/967290562725359617) and [FR#2655](https://github.com/Rdatatable/data.table/issues/2655)) and so this prefix is now expanded to all symbols appearing in `j=` as a first step; e.g. :
    ```R
    cols = "colB"
    DT[, c(..cols, "colC")]   # same as DT[, .(colB,colC)]
    DT[, -..cols]             # all columns other than colB
    ```
    Thus, `with=` should no longer be needed in any cases. Please change to using the `..` prefix and over the next few years we will start to formally deprecate and remove the `with=` parameter.  If this is well received, the `..` prefix could be expanded to symbols appearing in `i=` and `by=`, too. Note that column names should not now start with `..`. If a symbol `..var` is used in `j=` but `..var` exists as a column name, the column still takes precedence, for backwards compatibility. Over the next few years, data.table will start issuing warnings/errors when it sees column names starting with `..`. This affects one CRAN package out of 475 using data.table, so we do not believe this restriction to be unreasonable. Our main focus here which we believe `..` achieves is to resolve the more common ambiguity when `var` is in calling scope and `var` is a column name too. Further, we have not forgotten that in the past we recommended prefixing the variable in calling scope with `..` yourself. If you did that and `..var` exists in calling scope, that still works, provided neither `var` exists in calling scope nor `..var` exists as a column name. Please now remove the `..` prefix on `..var` in calling scope to tidy this up. In future data.table will start to warn/error on such usage.

19. `setindexv` can now assign multiple (separate) indices by accepting a `list` in the `cols` argument.

20. `as.matrix.data.table` method now has an additional `rownames` argument allowing for a single column to be used as the `rownames` after conversion to a `matrix`. Thanks to @sritchie73 for the suggestion, use cases, [#2692](https://github.com/Rdatatable/data.table/issues/2692) and implementation [PR#2702](https://github.com/Rdatatable/data.table/pull/2702) and @MichaelChirico for additional use cases.

#### BUG FIXES

1. The new quote rules handles this single field `"Our Stock Screen Delivers an Israeli Software Company (MNDO, CTCH)<\/a> SmallCapInvestor.com - Thu, May 19, 2011 10:02 AM EDT<\/cite><\/div>Yesterday in \""Google, But for Finding
 Great Stocks\"", I discussed the value of stock screeners as a powerful tool"`, [#2051](https://github.com/Rdatatable/data.table/issues/2051). Thanks to @scarrascoso for reporting. Example file added to test suite.

2. `fwrite()` creates a file with permissions that now play correctly with `Sys.umask()`, [#2049](https://github.com/Rdatatable/data.table/issues/2049). Thanks to @gnguy for reporting.

3. `fread()` no longer holds an open lock on the file when a line outside the large sample has too many fields and generates an error, [#2044](https://github.com/Rdatatable/data.table/issues/2044). Thanks to Hugh Parsonage for reporting.

4. Setting `j = {}` no longer results in an error, [#2142](https://github.com/Rdatatable/data.table/issues/2142). Thanks Michael Chirico for the pull request.

5. Segfault in `rbindlist()` when one or more items are empty, [#2019](https://github.com/Rdatatable/data.table/issues/2019). Thanks Michael Lang for the pull request. Another segfault if the result would be more than 2bn rows, thanks to @jsams's comment in [#2340](https://github.com/Rdatatable/data.table/issues/2340#issuecomment-331505494).

6. Error printing 0-length `ITime` and `NA` objects, [#2032](https://github.com/Rdatatable/data.table/issues/2032) and [#2171](https://github.com/Rdatatable/data.table/issues/2171). Thanks Michael Chirico for the pull requests and @franknarf1 for pointing out a shortcoming of the initial fix.

7. `as.IDate.POSIXct` error with `NULL` timezone, [#1973](https://github.com/Rdatatable/data.table/issues/1973). Thanks @lbilli for reporting and Michael Chirico for the pull request.

8. Printing a null `data.table` with `print` no longer visibly outputs `NULL`, [#1852](https://github.com/Rdatatable/data.table/issues/1852). Thanks @aaronmcdaid for spotting and @MichaelChirico for the PR.

9. `data.table` now works with Shiny Reactivity / Flexdashboard. The error was typically something like `col not found` in `DT[col==val]`. Thanks to Dirk Eddelbuettel leading Matt through reproducible steps and @sergeganakou and Richard White for reporting. Closes [#2001](https://github.com/Rdatatable/data.table/issues/2001) and [shiny/#1696](https://github.com/rstudio/shiny/issues/1696).

10. The `as.IDate.POSIXct` method passed `tzone` along but was not exported. So `tzone` is now taken into account by `as.IDate` too as well as `IDateTime`, [#977](https://github.com/Rdatatable/data.table/issues/977) and [#1498](https://github.com/Rdatatable/data.table/issues/1498). Tests added.

11. Named logical vector now select rows as expected from single row data.table. Thanks to @skranz for reporting. Closes [#2152](https://github.com/Rdatatable/data.table/issues/2152).

12. `fread()`'s rare `Internal error: Sampling jump point 10 is before the last jump ended` has been fixed, [#2157](https://github.com/Rdatatable/data.table/issues/2157). Thanks to Frank Erickson and Artem Klevtsov for reporting with example files which are now added to the test suite.

13. `CJ()` no longer loses attribute information, [#2029](https://github.com/Rdatatable/data.table/issues/2029). Thanks to @MarkusBonsch and @royalts for the pull request.

14. `split.data.table` respects `factor` ordering in `by` argument, [#2082](https://github.com/Rdatatable/data.table/issues/2082). Thanks to @MichaelChirico for identifying and fixing the issue.

15. `.SD` would incorrectly include symbol on lhs of `:=` when `.SDcols` is specified and `get()` appears in `j`. Thanks @renkun-ken for reporting and the PR, and @ProfFancyPants for reporing a regression introduced in the PR. Closes [#2326](https://github.com/Rdatatable/data.table/issues/2326) and [#2338](https://github.com/Rdatatable/data.table/issues/2338).

16. Integer values that are too large to fit in `int64` will now be read as strings [#2250](https://github.com/Rdatatable/data.table/issues/2250).

17. Internal-only `.shallow` now retains keys correctly, [#2336](https://github.com/Rdatatable/data.table/issues/2336). Thanks to @MarkusBonsch for reporting, fixing ([PR #2337](https://github.com/Rdatatable/data.table/pull/2337)) and adding 37 tests. This much advances the journey towards exporting `shallow()`, [#2323](https://github.com/Rdatatable/data.table/issues/2323).

18. `isoweek` calculation is correct regardless of local timezone setting (`Sys.timezone()`), [#2407](https://github.com/Rdatatable/data.table/issues/2407). Thanks to @MoebiusAV and @SimonCoulombe for reporting and @MichaelChirico for fixing.

19. Fixed `as.xts.data.table` to support all xts supported time based index clasess [#2408](https://github.com/Rdatatable/data.table/issues/2408). Thanks to @ebs238 for reporting and for the PR.

20. A memory leak when a very small number such as `0.58E-2141` is bumped to type `character` is resolved, [#918](https://github.com/Rdatatable/data.table/issues/918).

21. The edge case `setnames(data.table(), character(0))` now works rather than error, [#2452](https://github.com/Rdatatable/data.table/issues/2452).

22. Order of rows returned in non-equi joins were incorrect in certain scenarios as reported under [#1991](https://github.com/Rdatatable/data.table/issues/1991). This is now fixed. Thanks to @Henrik-P for reporting.

23. Non-equi joins work as expected when `x` in `x[i, on=...]` is a 0-row data.table. Closes [#1986](https://github.com/Rdatatable/data.table/issues/1986).

24. Non-equi joins along with `by=.EACHI` returned incorrect result in some rare cases as reported under [#2360](https://github.com/Rdatatable/data.table/issues/2360). This is fixed now. This fix also takes care of [#2275](https://github.com/Rdatatable/data.table/issues/2275). Thanks to @ebs238 for the nice minimal reproducible report, @Mihael for asking on SO and to @Frank for following up on SO and filing an issue.

25. `by=.EACHI` works now when `list` columns are being returned and some join values are missing, [#2300](https://github.com/Rdatatable/data.table/issues/2300). Thanks to @jangorecki and @franknarf1 for the reproducible examples which have been added to the test suite.

26. Indices are now retrieved by exact name, [#2465](https://github.com/Rdatatable/data.table/issues/2465). This prevents usage of wrong indices as well as unexpected row reordering in join results. Thanks to @pannnda for reporting and providing a reproducible example and to @MarkusBonsch for fixing.

27. `setnames` of whole table when original table had `NA` names skipped replacing those, [#2475](https://github.com/Rdatatable/data.table/issues/2475). Thanks to @franknarf1 and [BenoitLondon on StackOverflow](https://stackoverflow.com/questions/47228836/) for the report and @MichaelChirico for fixing.

28. `CJ()` works with multiple empty vectors now [#2511](https://github.com/Rdatatable/data.table/issues/2511). Thanks to @MarkusBonsch for fixing.

29. `:=` assignment of one vector to two or more columns, e.g. `DT[, c("x", "y") := 1:10]`, failed to copy the `1:10` data causing errors later if and when those columns were updated by reference, [#2540](https://github.com/Rdatatable/data.table/issues/2540). This is an old issue ([#185](https://github.com/Rdatatable/data.table/issues/185)) that had been fixed but reappeared when code was refactored. Thanks to @patrickhowerter for the detailed report with reproducible example and to @MarkusBonsch for fixing and strengthening tests so it doesn't reappear again.

30. "Negative length vectors not allowed" error when grouping `median` and `var` fixed, [#2046](https://github.com/Rdatatable/data.table/issues/2046) and [#2111](https://github.com/Rdatatable/data.table/issues/2111). Thanks to @caneff and @osofr for reporting and to @kmillar for debugging and explaining the cause.

31. Fixed a bug on Windows where `data.table`s containing non-UTF8 strings in `key`s were not properly sorted, [#2462](https://github.com/Rdatatable/data.table/issues/2462), [#1826](https://github.com/Rdatatable/data.table/issues/1826)  and [StackOverflow](https://stackoverflow.com/questions/47599934/why-doesnt-r-data-table-support-well-for-non-ascii-keys-on-windows). Thanks to @shrektan for reporting and fixing.

32. `x.` prefixes during joins sometimes resulted in a "column not found" error. This is now fixed. Closes [#2313](https://github.com/Rdatatable/data.table/issues/2313). Thanks to @franknarf1 for the MRE.

33. `setattr()` no longer segfaults when setting 'class' to empty character vector, [#2386](https://github.com/Rdatatable/data.table/issues/2386). Thanks to @hatal175 for reporting and to @MarkusBonsch for fixing.

34. Fixed cases where the result of `merge.data.table()` would contain duplicate column names if `by.x` was also in `names(y)`.
`merge.data.table()` gains the `no.dups` argument (default TRUE) to match the correpsonding patched behaviour in `base:::merge.data.frame()`. Now, when `by.x` is also in `names(y)` the column name from `y` has the corresponding `suffixes` added to it. `by.x` remains unchanged for backwards compatibility reasons.
In addition, where duplicate column names arise anyway (i.e. `suffixes = c("", "")`) `merge.data.table()` will now throw a warning to match the behaviour of `base:::merge.data.frame()`.
Thanks to @sritchie73 for reporting and fixing [PR#2631](https://github.com/Rdatatable/data.table/pull/2631) and [PR#2653](https://github.com/Rdatatable/data.table/pull/2653)

35. `CJ()` now fails with proper error message when results would exceed max integer, [#2636](https://github.com/Rdatatable/data.table/issues/2636).

36. `NA` in character columns now display as `<NA>` just like base R to distinguish from `""` and `"NA"`.

37. `getDTthreads()` could return INT_MAX (2 billion) after an explicit call to `setDTthreads(0)`, [PR#2708](https://github.com/Rdatatable/data.table/pull/2708).

38. Fixed a bug on Windows that `data.table` may break if the garbage collecting was triggered when sorting a large number of non-ASCII characters. Thanks to @shrektan for reporting and fixing [PR#2678](https://github.com/Rdatatable/data.table/pull/2678),  [#2674](https://github.com/Rdatatable/data.table/issues/2674).

39. Internal aliasing of `.` to `list` was over-aggressive in applying `list` even when `.` was intended within `bquote`, [#1912](https://github.com/Rdatatable/data.table/issues/1912). Thanks @MichaelChirico for reporting/filing and @ecoRoland for suggesting and testing a fix.

40. Attempt to allocate a wildly large amount of RAM (16EB) when grouping by key and there are close to 2 billion 1-row groups, [#2777](https://github.com/Rdatatable/data.table/issues/2777). Thanks to @jsams for the detailed report.

41. Fix a bug that `print(dt, class=TRUE)` shows only `topn - 1` rows. Thanks to @heavywatal for reporting [#2803](https://github.com/Rdatatable/data.table/issues/2803) and filing [PR#2804](https://github.com/Rdatatable/data.table/pull/2804).

#### NOTES

0. The license has been changed from GPL to MPL (Mozilla Public License). All contributors were consulted and approved. [PR#2456](https://github.com/Rdatatable/data.table/pull/2456) details the reasons for the change.

1. `?data.table` makes explicit the option of using a `logical` vector in `j` to select columns, [#1978](https://github.com/Rdatatable/data.table/issues/1978). Thanks @Henrik-P for the note and @MichaelChirico for filing.

2. Test 1675.1 updated to cope with a change in R-devel in June 2017 related to `factor()` and `NA` levels.

3. Package `ezknitr` has been added to the whitelist of packages that run user code and should be consider data.table-aware, [#2266](https://github.com/Rdatatable/data.table/issues/2266). Thanks to Matt Mills for testing and reporting.

4. Printing with `quote = TRUE` now quotes column names as well, [#1319](https://github.com/Rdatatable/data.table/issues/1319). Thanks @jan-glx for the suggestion and @MichaelChirico for the PR.

5. Added a blurb to `?melt.data.table` explicating the subtle difference in behavior of the `id.vars` argument vis-a-vis its analog in `reshape2::melt`, [#1699](https://github.com/Rdatatable/data.table/issues/1699). Thanks @MichaelChirico for uncovering and filing.

6. Added some clarification about the usage of `on` to `?data.table`, [#2383](https://github.com/Rdatatable/data.table/issues/2383). Thanks to @peterlittlejohn for volunteering his confusion and @MichaelChirico for brushing things up.

7. Clarified that "data.table always sorts in `C-locale`" means that upper-case letters are sorted before lower-case letters by ordering in data.table (e.g. `setorder`, `setkey`, `DT[order(...)]`). Thanks to @hughparsonage for the pull request editing the documentation. Note this makes no difference in most cases of data; e.g. ids where only uppercase or lowercase letters are used (`"AB123"<"AC234"` is always true, regardless), or country names and words which are consistently capitalized. For example, `"America" < "Brazil"` is not affected (it's always true), and neither is `"america" < "brazil"` (always true too); since the first letter is consistently capitalized. But, whether `"america" < "Brazil"` (the words are not consistently capitalized) is true or false in base R depends on the locale of your R session. In America it is true by default and false if you i) type `Sys.setlocale(locale="C")`, ii) the R session has been started in a C locale for you which can happen on servers/services (the locale comes from the environment the R session is started in). However, `"america" < "Brazil"` is always, consistently false in data.table which can be a surprise because it differs to base R by default in most regions. It is false because `"B"<"a"` is true because all upper-case letters come first, followed by all lower case letters (the ascii number of each letter determines the order, which is what is meant by `C-locale`).

8. `data.table`'s dependency has been moved forward from R 3.0.0 (Apr 2013) to R 3.1.0 (Apr 2014; i.e. 3.5 years old). We keep this dependency as old as possible for as long as possible as requested by users in managed environments. Thanks to Jan Gorecki, the test suite from latest dev now runs on R 3.1.0 continously, as well as R-release (currently 3.4.2) and latest R-devel snapshot. [Our CRAN release procedures](https://github.com/Rdatatable/data.table/blob/master/CRAN_Release.cmd) also double check with this stated dependency before release to CRAN. The primary motivation for the bump to R 3.1.0 was allowing one new test which relies on better non-copying behaviour in that version, [#2484](https://github.com/Rdatatable/data.table/issues/2484). It also allows further internal simplifications. Thanks to @MichaelChirico for fixing another test that failed on R 3.1.0 due to slightly different behaviour of `base::read.csv` in R 3.1.0-only which the test was comparing to, [#2489](https://github.com/Rdatatable/data.table/pull/2489).

9. New vignette added: _Importing data.table_ - focused on using data.table as a dependency in R packages. Answers most commonly asked questions and promote good practices.

10. As warned in v1.9.8 release notes below in this file (25 Nov 2016) it has been 1 year since then and so use of `options(datatable.old.unique.by.key=TRUE)` to restore the old default is now deprecated with warning. The new warning states that this option still works and repeats the request to pass `by=key(DT)` explicitly to `unique()`, `duplicated()`, `uniqueN()` and `anyDuplicated()` and to stop using this option. In another year, this warning will become error. Another year after that the option will be removed.

11. As `set2key()` and `key2()` have been warning since v1.9.8 (Nov 2016), their warnings have now been upgraded to errors. Note that when they were introduced in version 1.9.4 (Oct 2014) they were marked as 'experimental' in NEWS item 4. They will be removed in one year.
    ```
    Was warning: set2key() will be deprecated in the next relase. Please use setindex() instead.
    Now error: set2key() is now deprecated. Please use setindex() instead.
    ```

12. The option `datatable.showProgress` is no longer set to a default value when the package is loaded. Instead, the `default=` argument of `getOption` is used by both `fwrite` and `fread`. The default is the result of `interactive()` at the time of the call. Using `getOption` in this way is intended to be more helpful to users looking at `args(fread)` and `?fread`.

13. `print.data.table()` invisibly returns its first argument instead of `NULL`. This behavior is compatible with the standard `print.data.frame()` and tibble's `print.tbl_df()`. Thanks to @heavywatal for [PR#2807](https://github.com/Rdatatable/data.table/pull/2807)


### Changes in v1.10.4-3  (20 Oct 2017)

1. Fixed crash/hang on MacOS when `parallel::mclapply` is used and data.table is merely loaded, [#2418](https://github.com/Rdatatable/data.table/issues/2418). Oddly, all tests including test 1705 (which tests `mclapply` with data.table) passed fine on CRAN. It appears to be some versions of MacOS or some versions of libraries on MacOS, perhaps. Many thanks to Martin Morgan for reporting and confirming this fix works. Thanks also to @asenabouth, Joe Thorley and Danton Noriega for testing, debugging and confirming that automatic parallelism inside data.table (such as `fwrite`) works well even on these MacOS installations. See also news items below for 1.10.4-1 and 1.10.4-2.


### Changes in v1.10.4-2  (12 Oct 2017)

1. OpenMP on MacOS is now supported by CRAN and included in CRAN's package binaries for Mac. But installing v1.10.4-1 from source on MacOS failed when OpenMP was not enabled at compile time, [#2409](https://github.com/Rdatatable/data.table/issues/2409). Thanks to Liz Macfie and @fupangpangpang for reporting. The startup message when OpenMP is not enabled has been updated.

2. Two rare potential memory faults fixed, thanks to CRAN's automated use of latest compiler tools; e.g. clang-5 and gcc-7


### Changes in v1.10.4-1  (09 Oct 2017)

1. The `nanotime` v0.2.0 update (June 2017) changed from `integer64` to `S4` and broke `fwrite` of `nanotime` columns. Fixed to work with `nanotime` both before and after v0.2.0.

2. Pass R-devel changes related to `deparse(,backtick=)` and `factor()`.

3. Internal `NAMED()==2` now `MAYBE_SHARED()`, [#2330](https://github.com/Rdatatable/data.table/issues/2330). Back-ported to pass under the stated dependency, R 3.0.0.

4. Attempted improvement on Mac-only when the `parallel` package is used too (which forks), [#2137](https://github.com/Rdatatable/data.table/issues/2137). Intel's OpenMP implementation appears to leave threads running after the OpenMP parallel region (inside data.table) has finished unlike GNU libgomp. So, if and when `parallel`'s `fork` is invoked by the user after data.table has run in parallel already, instability occurs. The problem only occurs with Mac package binaries from CRAN because they are built by CRAN with Intel's OpenMP library. No known problems on Windows or Linux and no known problems on any platform when `parallel` is not used. If this Mac-only fix still doesn't work, call `setDTthreads(1)` immediately after `library(data.table)` which has been reported to fix the problem by putting `data.table` into single threaded mode earlier.

5. When `fread()` and `print()` see `integer64` columns are present but package `bit64` is not installed, the warning is now displayed as intended. Thanks to a question by Santosh on r-help and forwarded by Bill Dunlap.


### Changes in v1.10.4  (01 Feb 2017)

#### BUG FIXES

1. The new specialized `nanotime` writer in `fwrite()` type punned using `*(long long *)&REAL(column)[i]` which, strictly, is undefined behavour under C standards. It passed a plethora of tests on linux (gcc 5.4 and clang 3.8), win-builder and 6 out 10 CRAN flavours using gcc. But failed (wrong data written) with the newest version of clang (3.9.1) as used by CRAN on the failing flavors, and solaris-sparc. Replaced with the union method and added a grep to CRAN_Release.cmd.


### Changes in v1.10.2  (31 Jan 2017)

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


### Changes in v1.10.0  (03 Dec 2016)

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


### Old news from v1.9.8 (Nov 2016) back to v1.2 (Aug 2008) has been moved to [NEWS.0.md](https://github.com/Rdatatable/data.table/blob/master/NEWS.0.md)
