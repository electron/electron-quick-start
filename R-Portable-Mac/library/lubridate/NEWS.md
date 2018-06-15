Version 1.7.4
=============

### NEW FEATURES

* [#658](https://github.com/tidyverse/lubridate/issues/658) `%within%` now accepts a list of intervals, in which case an instant is checked if it occurs within any of the supplied intervals.

### CHANGES

* [#661](https://github.com/tidyverse/lubridate/issues/661) Throw error on invalid multi-unit rounding.
* [#633](https://github.com/tidyverse/lubridate/issues/633) `%%` on intervals relies on `%m+` arithmetic and doesn't produce NAs when intermediate computations result in non-existent dates.
* `tz()` always returns "UTC" when `tzone` attribute cannot be inferred.

### BUG FIXES

* [#664](https://github.com/tidyverse/lubridate/issues/664) Fix lookup of period functions in `as.period`

Version 1.7.3
=============

### BUG FIXES

* [#643](https://github.com/tidyverse/lubridate/issues/643), [#640](https://github.com/tidyverse/lubridate/issues/640), [#645](https://github.com/tidyverse/lubridate/issues/645) Fix faulty caching of system timezone.

Version 1.7.2
=============

### NEW FEATURES

* Durations, Periods and difftimes are now comparable with each other.
* `interval` constructor accepts start and end character vectors in ISO 8601 format
* [#362](https://github.com/tidyverse/lubridate/issues/362) Add support for ISO 8601 formats in interval constructor
* [#622](https://github.com/tidyverse/lubridate/issues/622) Add support for ISO 8601 formats in periods and durations constructor

### CHANGES

* Correct license to the originally intended GPL (>= 2)

### BUG FIXES

* [#605](https://github.com/tidyverse/lubridate/issues/605) Fix wrong ceiling of days during DST transition.
* [#607](https://github.com/tidyverse/lubridate/issues/607) Re-instate `format` argument to `as_date` and `as_datetime` (regression in v1.7.1)
* Fix intersection of intervals with missing values.
* Fix UBSAN errors in update.cpp

Version 1.7.1
=============

### BUG FIXES

* [#575](https://github.com/tidyverse/lubridate/issues/598), [#600](https://github.com/tidyverse/lubridate/issues/600), [#602](https://github.com/tidyverse/lubridate/issues/602) Fix zoneinfo lookup on windows and solaris.
* [#598](https://github.com/tidyverse/lubridate/issues/598) Fix broken parsing of `ymd_hms` strings by `as_date`.
* [#597](https://github.com/tidyverse/lubridate/issues/597) Fix broken parsing of `ymd` strings by `as_datetime`.

Version 1.7.0
=============

### NEW FEATURES

* Reduced memory footprint on `trunc_multi_unit` so that it overwrites the vector argument `x` versus making a new vector `y`.
* [#438](https://github.com/tidyverse/lubridate/issues/438) New function `force_tzs` for "enforcement" of heterogeneous time zones.
* [#438](https://github.com/tidyverse/lubridate/issues/438) New function `local_time` for the retrieval of local day time in different time zones.
* [#560](https://github.com/tidyverse/lubridate/issues/560) New argument `cutoff_2000` for parsing functions to indicate 20th century cutoff for `y` format.
* [#257](https://github.com/tidyverse/lubridate/issues/257) New `week_start` parameter in `wday` and `wday<-` to set week start.
* [#401](https://github.com/tidyverse/lubridate/issues/401) New parameter `locale` in `wday`. Labels of the returned factors (when `label=TRUE`) now respect current locale.
* [#485](https://github.com/tidyverse/lubridate/pull/485) `quarter` gained a new argument `fiscal_start` to address the issue of different fiscal conventions.
* [#492](https://github.com/tidyverse/lubridate/issues/492) New functions `epiweek` and `epiyear`.
* [#508](https://github.com/tidyverse/lubridate/pull/508) New parameter `locale` in `month`. Labels of the returned factors (when `label=TRUE`) now respect current locale.
* [#509](https://github.com/tidyverse/lubridate/issues/509) New parameter `week_start` to `floor_date`, `ceiling_date` and `round_date`.
* [#519](https://github.com/tidyverse/lubridate/issues/519) Support fractional units in duration and period string constructors.
* [#502](https://github.com/tidyverse/lubridate/issues/502) Support rounding to fractions of a seconds.
* [#529](https://github.com/tidyverse/lubridate/issues/529) Internal parser now ignores the case of alpha months (B format)
* [#535](https://github.com/tidyverse/lubridate/issues/535) Rounding to `season` is now supported.
* [#536](https://github.com/tidyverse/lubridate/issues/536) `as_date` and `as_datetime` now understand character vectors.
* New parsing parameters to `parse_date_time` - `train=TRUE` and `drop=FALSE` which allow more refined control of the format guessing. Formats are no longer dropped in the process by default, process which resulted in surprising behavior on several occasions ([#516](https://github.com/tidyverse/lubridate/issues/516),[#308](https://github.com/tidyverse/lubridate/issues/308),[#307](https://github.com/tidyverse/lubridate/issues/307)).

### CHANGES

* [#401](https://github.com/tidyverse/lubridate/issues/401) **[Breaking Change]** Labels returned by `wday` and `month` are now in current locale. The abbreviated labels in English locales have been changed to standard abbreviations (Tues -> Tue, Thurs -> Thu etc.).
* [#469](https://github.com/tidyverse/lubridate/issues/469) Throw warning in `with_tz` on invalid timezone.
* [#572](https://github.com/tidyverse/lubridate/issues/572) `B` and `b` formats no longer match numeric months. This corresponds to the original intent, and was always documented as such.

### BUG FIXES

* [#314](https://github.com/tidyverse/lubridate/issues/314), [#407](https://github.com/tidyverse/lubridate/issues/407), [#499](https://github.com/tidyverse/lubridate/issues/499) Make `days`, `dhours`, `round_date` work when the methods package is not loaded.
* [#543](https://github.com/tidyverse/lubridate/issues/543) Make `wday` work on character inputs as it is the case with all other day accessors.
* [#566](https://github.com/tidyverse/lubridate/issues/566) Comparing durations and periods no-longer infloops.
* [#556](https://github.com/tidyverse/lubridate/issues/556) Fix incorrect scoring of `y` format when it's the last in format order (as in `mdy`).
* [#584](https://github.com/tidyverse/lubridate/issues/584) Fix interval by period division.
* [#559](https://github.com/tidyverse/lubridate/issues/559) Parsing of alpha-months in English locales now drops correctly to low level C parsing. Thus, parsing with multiple orders containing `m` and `b` formats now works correctly.
* [#570](https://github.com/tidyverse/lubridate/issues/570), [#574](https://github.com/tidyverse/lubridate/issues/574) Fix broken `date()` when called with missing argument.
* [#567](https://github.com/tidyverse/lubridate/issues/567) Fix year update and rounding for leap years.
* [#545](https://github.com/tidyverse/lubridate/pull/545) Fix wrong locale selection in stamp.
* [#466](https://github.com/tidyverse/lubridate/pull/466) Fix wrong formats within ymd_h family of functions.
* [#472](https://github.com/tidyverse/lubridate/pull/472) Printing method for duration doesn't throw format error on fractional seconds.
* [#475](https://github.com/tidyverse/lubridate/pull/475) character<> comparisons is no longer slow.
* [#483](https://github.com/tidyverse/lubridate/pull/483) Fix add_duration_to_date error when duration first element is NA.
* [#486](https://github.com/tidyverse/lubridate/issues/486) ceiling_date handles `NA` properly.
* [#491](https://github.com/tidyverse/lubridate/issues/491) `make_datetime` respects `tz` argument and is much faster now.
* [#507](https://github.com/tidyverse/lubridate/issues/507) Period and duration parsers now understand 0 units.
* [#524](https://github.com/tidyverse/lubridate/pull/524) Correctly compute length of period in months (issue #490)
* [#525](https://github.com/tidyverse/lubridate/pull/525) Fix to prevent `day<-`, `minute<-`, etc. from producing an error when length(x) is 0 (issue #517)
* [#530](https://github.com/tidyverse/lubridate/issues/530) `parse_date_time` now throw warnings only for actual parsing errors (input with all NAs are silent)
* [#534](https://github.com/tidyverse/lubridate/issues/534) Fix arithmetics with large numbers
* [#554](https://github.com/tidyverse/lubridate/pull/554) Fix tests when running in non-English locales

Version 1.6.0
=============

### NEW FEATURES

* [#464](https://github.com/hadley/lubridate/issues/464) New function `semester` to extract semesters form date-time objects.
* [#459](https://github.com/hadley/lubridate/issues/459) Flexible C-level parsing for periods and durations has been implemented; `period` and `duration` constructors now accept string as first argument. Same parsing rules apply to the 'unit' parameter in rounding functions.
* [#459](https://github.com/hadley/lubridate/issues/459) Comparison between character vectors and periods/durations is now possible.
* [#287](https://github.com/hadley/lubridate/issues/287) C-level and derivative parsers now handle English months (%b and %B formats) irrespective of the current locale.
* [#327](https://github.com/hadley/lubridate/issues/327) C-level and derivative parsers now handles English AM/PM indicator irrespective of the current locale.
* [#417](https://github.com/hadley/lubridate/issues/417) `hms`, `hm`, `ms` gained new argument `roll=TRUE` which rolls minutes and seconds bigger than 59 towards higher units.
* [#445](https://github.com/hadley/lubridate/issues/445) Division of intervals by periods is now accurate.
* [#442](https://github.com/hadley/lubridate/issues/442) `round_date`, `floor_date` and `ceiling_date` now support rounding to multiple of units.
* [#422](https://github.com/hadley/lubridate/issues/422) New parsing function `yq` for parsing most common version of quarter strings.
* [#422](https://github.com/hadley/lubridate/issues/422) New format `q` for parsing quarters in all lubridate parsing functions.
* [#441](https://github.com/hadley/lubridate/issues/441) Comparison between POSIXt and Date objects is now possible.
* [#437](https://github.com/hadley/lubridate/issues/437) New function `as_datetime` to coerce to POSIXct object. A counterpart of `as_date`.
* [#412](https://github.com/hadley/lubridate/issues/412) New function `make_date` to produce Date objects. A counterpart of `make_datetime`.
* [#443](https://github.com/hadley/lubridate/issues/443) Behavior of `ceiling_date` for `Date` objects was changed to what most of the users expect. Rounding up by months now produces first day of the next months even for first day of the month.
* [#268](https://github.com/hadley/lubridate/issues/268) `round_date`, `ceiling_date`, and `floor_date` now accept "quarter", "bimonth", and "halfyear" as `unit` options.
* [#418](https://github.com/hadley/lubridate/issues/418) C level parsing functions understand 24:00:00 in datetime strings.

### CHANGES

* Low letter specs for HMS (hms,hm,ms) in `parse_date_time` and related functions are now deprecated.
* [#445](https://github.com/hadley/lubridate/issues/445) No more warning on occasional imprecise period length conversions. Imprecise arithmetics with periods is extensively documented.
* `pretty.*` family of functions were renamed and are no longer exported. If you need to use them, use `lubridate:::pretty_*` versions.
* `change_on_boundary` argument in `ceiling_date` does not allow for global option anymore.
* `as.duration`, `as.numeric` don't show "only estimate" messages on conversion from periods. The occasional approximate conversion is documented and deemed common knowledge.
* `as.numeric` with `unit="month"` now works on duration objects.
* [#403](https://github.com/hadley/lubridate/issues/403) Update on `Date` objects now return `POSIXct` instead of `POSIXlt`.
* [#411](https://github.com/hadley/lubridate/issues/411) format `mdy` or `myd` beginning with `"January"` or `"Jan"` now parsing correctly
* `here` and `olson_time_zones` were deprecated in favor of `new` and base `OlsonNames` respectively.
* Internally, S4 Compare and Ops generics were cleaned and simplified.
* [#456](https://github.com/hadley/lubridate/issues/456) Evaluation output in documentation examples was removed.

### BUG FIXES

* [#479](https://github.com/hadley/lubridate/issues/479) Fix the inconsistent behavior in `ceiling_date` when `unit = "week"`
* [#463](https://github.com/hadley/lubridate/issues/463) Fix NA subscripting error in %m+% when rollback is involved.
* [#462](https://github.com/hadley/lubridate/issues/462) Non-numeric or non-character arguments are disallowed as arguments to `period` and `duration` constructors.
* [#458](https://github.com/hadley/lubridate/issues/458) When year is missing in parsing, return consistently year 0.
* [#448](https://github.com/hadley/lubridate/issues/448) Correctly handle missing months and days in C parser.
* [#450](https://github.com/hadley/lubridate/issues/450) Fix incorrect handling of DST gaps in `date_decimal` and `decimal_date`.
* [#420](https://github.com/hadley/lubridate/issues/420) `as.numeric` correctly converts periods to (aproximate) numeric time lengths.

Version 1.5.6
============

### NEW FEATURES

* [#390](https://github.com/hadley/lubridate/issues/390) `ceiling_date` gains new argument `change_on_boundary` to allow ceiling on boundary of date-time objects.
* C parser can now produce a list of date-time components suitable for POSIXlt constructors.
* `parse_date_time2` and `fast_strptime` gain new `lt` argument to control type of output.
* [#373](https://github.com/hadley/lubridate/issues/373) New `date` and `date<-` additions to the `year`, `month` etc family of accessors.
* [#365](https://github.com/hadley/lubridate/issues/365) New very fast datetime constructor `make_datetime` (dropin replacement of `ISOdatetime`).
* [#344](https://github.com/hadley/lubridate/issues/344) `force_tz` and `with_tz` can handle data.frames component-wise.
* [#355](https://github.com/hadley/lubridate/issues/355) New `as_date` replacement of `as.Date` with more intuitive behavior with non-UTC timezones.
* [#333](https://github.com/hadley/lubridate/issues/333) `hms` parsers now handle negative components.

### CHANGES

* [#391](https://github.com/hadley/lubridate/issues/391) `ymd` family of functions return `Date` object when `tz` argument is NULL (new default) and POSIXct otherwise.
* [#364](https://github.com/hadley/lubridate/issues/364) Remove epoch functions.
* For consistency with `base:strptime` `fast_strptime` now returns `POSIXlt` object. That is, its `lt` argument defaults to `TRUE`.

### BUG FIXES

* `interval` constructor treats timezones correctly and  works with UTC whenever meaningful.
* [#371](https://github.com/hadley/lubridate/issues/371) `as.period` correctly computes months with intervals spanning multiple years.
* [#388](https://github.com/hadley/lubridate/issues/388) `time_length` and `add_with_rollback` now work correctly with missing intervals.
* [#394](https://github.com/hadley/lubridate/issues/394) `fast_strptime` and `parse_date_time2` correctly treat non-UTC time zones.
* [#399](https://github.com/hadley/lubridate/issues/399) `floor_date` and `round_date` are not preserving tz component for larger than day units

Version 1.5.0
=============

### NEW FEATURES

* New `time_length` method.
* Added `isoyear` function to line up with `isoweek`.
* [#326](https://github.com/hadley/lubridate/issues/326) Added `exact = TRUE` option to `parse_date_time` for faster and much more flexible specification of formats.
* New `simple` argument to `fit_to_timeline` and `update` methods mostly intended for internal use.
* [#315](https://github.com/hadley/lubridate/issues/315) Implement `unique` method for `interval` class.
* [#295](https://github.com/hadley/lubridate/issues/295) New args `preserve_hms` and `roll_to_first` in `rollback` function.
* [#303](https://github.com/hadley/lubridate/issues/303) New `quarter` option in `floor_date` and friends.
* [#348](https://github.com/hadley/lubridate/issues/348) New `as.list.Interval` S3 method.
* [#278](https://github.com/hadley/lubridate/issues/278) Added settors and accessors for `qday` (quarter day).

### CHANGES

* New maintainer Vitalie Spinu (@vspinu)
* Time span constructors were re-factored; `new_interval`, `new_period`, `new_duration`, `new_difftime` were deprecated in favour of the more powerful `interval`, `period`, `duration` and `make_difftime` functions.
* `eseconds`, `eminutes` etc. were deprecated in favour of `dsecons`, `dminutes` etc.
* Many documentation improvements.
* New testthat conventions are adopted. Tests are now in `test/testthat`.
* Internally `isodate` was replaced with a much faster `parse_date_time2(paste(...))` alternative
* [#325](https://github.com/hadley/lubridate/issues/325) `Lubridate`'s `trunc`, `ceiling` and `floor` functions have been optimised and now are relying on R's `trunc.POSIXct` whenever possible.
* [#285](https://github.com/hadley/lubridate/issues/285) Algebraic computations with negative periods are behaving asymmetrically with respect to their positive counterparts.
* Made necessary changes to accommodate new zoo-based `fst` objects.

### BUG FIXES

* [#360](https://github.com/hadley/lubridate/issues/360) Fix c parser for Z (zulu) indicator.
* [#322](https://github.com/hadley/lubridate/issues/322) Explicitly encode formatted string with `enc2utf8`.
* [#302](https://github.com/hadley/lubridate/issues/302) Allow parsing long numbers such as 20140911000000 as date+time.
* [#349](https://github.com/hadley/lubridate/issues/349) Fix broken interval -> period conversion.
* [#336](https://github.com/hadley/lubridate/issues/336) Fix broken interval-> period conversion with negative diffs.
* [#227](https://github.com/hadley/lubridate/issues/227) Treat "days" and "years" units specially for pretty.point.
* [#286](https://github.com/hadley/lubridate/issues/286) %m+-% correctly handles dHMS period components.
* [#323](https://github.com/hadley/lubridate/issues/323) Implement coercion methods for Duration class.
* [#226](https://github.com/hadley/lubridate/issues/226) Propagate NAs in `int_standardize`
* [#235](https://github.com/hadley/lubridate/issues/235) Fix integer division with months and years.
* [#240](https://github.com/hadley/lubridate/issues/240) Make `ceiling_date` skip day light gap.
* [#254](https://github.com/hadley/lubridate/issues/254) Don't preprocess a/A formats if expressly specified by the user.
* [#289](https://github.com/hadley/lubridate/issues/289) Check for valid day-months combinations in C parser.
* [#306](https://github.com/hadley/lubridate/issues/306) When needed double guess with `preproc_wday=T`.
* [#308](https://github.com/hadley/lubridate/issues/308) Document sparce format guessing in `parse_date_time`.
* [#313](https://github.com/hadley/lubridate/issues/313) Fixed and optimized `fit_to_timeline` function.
* [#311](https://github.com/hadley/lubridate/issues/311) Always use UTC in `isoweek` computation
* [#294](https://github.com/hadley/lubridate/issues/294) Don't use years in `seconds_to_period`.
* Values on `$<-` assignment for periods are now properly recycled.
* Correctly handle NA subscripting in `round_date`.


Version 1.4.0
=============

### CHANGES

* [#219](//github.com/hadley/lubridate/issues/219) In `interval` use UTC when tzone is missing.
* [#255](//github.com/hadley/lubridate/issues/255) Parse yy > 68 as 19yy to comply with `strptime`.

### BUG FIXES

* [#266](//github.com/hadley/lubridate/issues/266) Include `time-zones.R` in `coercion.R`.
* [#251](//github.com/hadley/lubridate/issues/251) Correct computation of weeks.
* [#262](//github.com/hadley/lubridate/issues/262) Document that month boundary is the first second of the month.
* [#270](//github.com/hadley/lubridate/issues/270) Add check for empty unit names in `standardise_lt_names`.
* [#276](//github.com/hadley/lubridate/issues/276) Perform conversion in `as.period.period` if `unit != NULL`.
* [#284](//github.com/hadley/lubridate/issues/284) Compute periods in `as.period.interval` without recurring to modulo arithmetic.
* [#272](//github.com/hadley/lubridate/issues/272) Update examples for `hms`, `hm` and `ms` for new printing style.
* [#236](//github.com/hadley/lubridate/issues/236) Don't allow zeros in month and day during parsing.
* [#247](//github.com/hadley/lubridate/issues/247) Uninitialized index was mistakenly used in subseting.
* [#229](//github.com/hadley/lubridate/issues/229) `guess_formats` now matches flex regexp first.
* `dmilliseconds` now correctly returns a `Duration` object.
* Fixed setdiff for discontinuous intervals.


Version 1.3.3
=============

### CHANGES

* New low level C parser for numeric formats and two new front-end R functions
  parse_date_time2 and fast_strptime. The achieved speed up is 50-100x as
  compared to standard as.POSIXct and strptime functions.

  The user level parser functions of ymd_hms family drop to these C routines
  whenever plain numeric formats are detected.

### BUG FIXES

* olson_time_zones now supports Solaris OS
* infinite recursion on parsing non-existing leap times was fixed


Version 1.3.2
=============

* Lubridate's s4 methods no longer use the representation argument, which has been deprecated in R 3.0.0 (see ?setClass). As a result, lubridate is no longer backwards compatible with R <3.0.0.


Version 1.3.0
=============

### CHANGES

* v1.3.0. treats math with month and year Periods more consistently. If adding or subtracting n months would result in a non-existent date, lubridate will return an NA instead of a day in the following month or year. For example, `ymd("2013-01-31") + months(1)` will return `NA` instead of `2013-03-04` as in v1.2.0. `ymd("2012-02-29") + years(1)` will also return an `NA`. This rule change helps ensure that date + timespan - timespan = date (or NA). If you'd prefer that such arithmetic just returns the last day of the resulting month, see `%m+%` and `%m-%`.
* update.POSIXct and update.POSIXlt have been rewritten to be 7x faster than their versions in v1.2.0. The speed gain is felt in `force_tz`, `with_tz`, `floor_date`, `ceiling_date`, `second<-`, `minute<-`, `hour<-`, `day<-`, `month<-`, `year<-`, and other functions that rely on update (such as math with Periods).
* lubridate includes a Korean translation provided by http://korea.gnu.org/gnustats/

### NEW FEATURES

* lubridate parser and stamp functions now handle ISO8601 date format (e.g., 2013-01-24 19:39:07.880-06:00, 2013-01-24 19:39:07.880Z)
* lubridate v1.3.0 comes with a new R vignette. see `browseVignettes("lubridate")` to view it.
* The accessors `second`, `minute`, `hour`, `day`, `month`, `year` and the settors `second<-`, `minute<-`, `hour<-`, `day<-`, `month<-`, `year<-` now work on Period class objects
* users can control which messages lubridate returns when parsing and estimating with the global option lubridate.verbose. Run `options(lubridate.verbose = TRUE)` to turn parsing messages on. Run `options(lubridate.verbose = FALSE)` to turn estimation and coercion messages off.
* lubridate parser functions now propagate NA's just as as.POSIXct, strptime and other functions do. Previously lubridate's parse functions would only return an error.
* added [[ and [[<- methods for INterval, Period and Duration class objects
* added `%m+%` and `%m-%` methods for Interval and Duration class objects that throw useful errors.
* `olson_time_zones` retreives a character vector is Olson-style time zone names to use in lubridate
* summary methods for Interval, Period, and Duration classes
* date_decimal converts a date written as a decimal of a year into a POSIXct date-time

### BUG FIXES

* fixed bug in way update.POSIXct and update.POSIXlt handle dates that occur in the fall daylight savings overlap. update will choose the date-time closest to the original date time (on the timeline) when two identical clock times exist due to the DST overlap.
* fixed bugs that created unintuitive results for `as.interval`, `int_overlaps`, `%within%` and the interval methods of `c`, `intersect`, `union`, `setdiff`, and `summary`.
* parse functions, `as.interval`, `as.period` and `as.duration` now handlevectors of NA's without returning errors.
* parsers better handle vectors of input that have more than 100 elements and many NAs
* data frames that contain timespan objects with NAs in thme no longer fail toprint
* `round_date`, `ceiling_date` and `update` now correctly handle input of length zero
* `decimal_date` no longer returns NaN for first second of the year

Version 1.2.0
=============

### CHANGES

* lubridate 1.2.0 is significantly faster than lubridate 1.1.0. This is
largely thanks to a parser rewrite submitted by Vitalie Spinu. Thank you,
Vitalie. Some metrics:
  - parser speed up - 60x faster
  - `with_tz` speed up - 15x faster
  - `force_tz` speed up - 3x faster

* Development for 1.2.0 has also focused on improving the way we work with
months. `rollback` rolls dates back to the last day of the previous month.
provides more options for working with months. `days_in_month` finds the
number of days in a date's month. And, `%m+%` and `%m-%` provide a new way to
### handle unequal month lengths while doing arithmetic. See NEW FEATURES for more
details

* date parsing can now parse multiple date formats within the same vector of
date-times. Parsing can also recognize a greater variety of date-time formats
as well as incomplete (truncated) date-times. Contributed by Vitalie Spinu.
Thank you, Vitalie.

* 1.2.0 introduces a new display format for periods. The display is more math
and international friendly.

* 1.2.0 transforms negative intervals into periods much more gracefully (e.g, -
 3 days instead of -1 years, 11 months, and 27 days)

* S3 update methods are now exported

### NEW FEATURES

* `stamp` allows users to print dates in whatever form they like. Contributed
by Vitalie Spinu. Thank you, Vitalie.

* periods now handle fractional seconds. Contributed by Vitalie Spinu. Thank
you, Vitalie.

* date parsing can now parse multiple date formats within the same vector of
date-times. Parsing can also recognize a greater variety of date-time formats
as well as incomplete (truncated) date-times. Contributed by Vitalie Spinu.
Thank you, Vitalie.

* `sort`, `order`, `rank` and `xtfrm` now work with periods

* `as.period.Interval` accepts a unit argument. `as.period` will convert
intervals into periods no larger than the supplied unit.

* `days_in_month` takes a date, returns the number of days in the date's month.
 Contributed by Richard Cotton. Thank you, Richard.

* `%m+%` and `%m-%` perform addition and subtraction with months (and years)
without rollover at the end of a month. These can be used in place of + and -.
These can't be used with periods smaller than a month, which should be handled
separately. An example of the new behavior:

    ymd("2010-01-31") %m+% months(1)
    # "2010-02-28 UTC"

    ymd("2010-01-31") + months(1)
    # "2010-03-03 UTC"

    ymd("2010-03-31") %m-% months(1)
    # "2010-02-28 UTC"

    ymd("2010-01-31") - months(1)
    # "2010-03-03 UTC"

* `rollback` rolls a date back to the last day of the previous month.

* `quarter` returns the fiscal quarter that a date occurs in. Like `quartes`
in base R, but returns a numeric instead of a character string.

### BUG FIXES

* date parsers now handle NAs

* periods now handle NAs

* `[<-` now correctly updates all elements of a period inside a vector, list,
or data.frame

* `period()` now works with unit = "weeks"

* `ceiling_date` no longer rounds up if a date is already at a ceiling

* the redundant (i.e, repeated) hour of fall daylight savings time now
displays with the correct time zone

* `update.POSIXct` and `update.POSIXlt` handle vectors that sum to zero in the
days argument

* the format method for periods, intervals and duration now accurately
displays objects of length 0.



Version 1.1.0
=============

### CHANGES

* lubridate no longer overwrites base R methods for +, - , *, /, %%, and %/%.
To recreate the previous experience of subtracting two date times to create an
interval, we've added the interval creation function %--%.

* lubridate has moved to an S4 object system. Timespans, Intervals, Durations,
and Periods have each been redefined as an S4 class with its own methods.

* arithmetic operations will no longer perform implicit class changes between
timespans. Users must explicitly state how and when they wish class changes to
occur with as.period(), as.duration(), and as.interval(). This makes code
written with lubridate more robust, as such implicit changes often did not
produce consistent behavior across a variety of operations. It also allows
lubridate to be less chatty with fewer console messages. lubridate does not
need to explain what it is doing, because it no longer attempts to do things
whose outcome would not be clear. On the other hand, arithmetic between
multiple time classes will produce informative error messages.

* the internal structure of lubridate R code has been reorganized at
https://github.com/hadley/lubridate to make lubridate more development friendly.


### NEW FEATURES

* intervals are now more useful and lubridate has more ways to manipulate them.
Intervals can be created with %--%; modified with int_shift(), int_flip(), and
int_standardize(); manipulated with intersect(), union(), and setdiff(); and
used in logical tests with int_aligns(), int_overlaps(), and %within%.
lubridate will no longer perform arithmetic between two intervals because the
correct results of such operations is no more obvious than the correct result
of adding two dates. Instead users are encouraged to use the new set
operations or to directly modify intervals with int_start() and int_end(),
which can also be used as settors. lubridate now supports negative intervals
as well as positive intervals. Intervals also now display with a time zone.

* Modulo methods for timespans have been changed to return a timespan. this
allows modulo methods to be used with integer division in an intuitive manner,
e.g. `a = a %/% b * b + a %% b`

Users can still acheive a numerical result by using as.numeric() on input
before performing modulo.

* Periods, durations, and intervals can now all be put into a data frame.

* Periods, durations, and intervals can be intuitively subset with $ and [].
These operations also can be used as settors with <-.

* The parsing functions and the as.period method for intervals are now
slightly faster.

* month<- and wday<- settors accept names as well as numbers

* parsing functions now have a quiet argument to parse without messages and a
tz argument to directly parse times into the desired time zone.

* logical comparison methods now work for period objects.


Version 0.2.6
=============


* use `test_package` to avoid incompatibility with current version of
  `testthat`

* other minor fixes to pass `R CMD check`


Version 0.2.5
=============

* added ymdThms() for parsing ISO 8061 formatted combned dates and times

### BUG FIXES

* removed bug in parsing dates with "T" in them

* modified as.period.interval() to display periods in positive units


Version 0.2.4
=============

* Add citations to JSS article


Version 0.2.3
=============

### NEW FEATURES

* ymd_hms(), hms(), and ms() functions can now parse dates that include
decimal values in the seconds element.

* milliseconds(), microseconds(), nanoseconds(), and picoseconds() create
period objects of the specified lengths. dmilliseconds(), dmicroseconds(),
dnanoseconds(), and dpicoseconds() make duration objects of the specified
lengths.


### BUG FIXES

* lubridate no longer overwrites months(), start(), and end() from base R.
Start and end have been replaced with int_start() and int_end().

* lubridate imports plyr and stringr packages, instead of depending on them.


Version 0.2.2
=============

### NEW FEATURES

* made division, modulo, and integer division operations compatible with
difftimes

* created c() methods for periods and durations


### BUG FIXES

* fixed bug in division, modulo, and integer operations with timespans



Version 0.2.1
=============

### NEW FEATURES

* created parsing functions ymd_hm ymd_h dmy_hms dmy_hm dmy_h mdy_hms mdy_hm
mdy_h ydm_hms ydm_hm ydm_h, which operate in the same way as ymd_hms().

### BUG FIXES

* fixed bug in add_dates(). duration objects can now be successfully added to
numeric objects.


-----------
Version 0.2
===========

### NEW FEATURES

* division between timespans: each timespan class (durations, periods,
intervals) can be divided by other timespans. For example, how many weeks are
there between Halloween and Christmas?: (christmas - halloween) / weeks(1)

* modulo operations between timespans

* duration objects now have their own class and display format separate from
difftimes

* interval objects now use an improved data structure and have a cleaner
display format

* lubridate now loads its own namespace

* math operations now automatically coerce interval objects to duration objects.
Allows intervals to be used "right out of the box" without error messages.

* created start() and end() functions for accessing and changing the boundary
date-times of an interval


* rep() methods for periods, intervals, and durations



### MINOR CHANGES

* added a package help page with functions listed by purpose

* eseconds(), eminutes(), etc. are aliased to dseconds(), dminutes(), etc. to
make it easier to remember they are duration objects.

* changed leap.years() to leap_years() to maintain consistent naming scheme



### BUG FIXES

* rewrote as.period() to create only positive periods.

* fixed rollover bug in update.POSIXct()

* edited make_diff() to display in days when approporiate, not weeks
