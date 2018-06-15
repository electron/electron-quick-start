# readr 1.1.1

* Point release for test compatibility with tibble v1.3.1.
* Fixed undefined behavior in localtime.c when using `locale(tz = "")` after
  loading a timezone due to incomplete reinitialization of the global locale.

# readr 1.1.0

## New features

### Parser improvements
* `parse_factor()` gains a `include_na` argument, to include `NA` in the factor levels (#541).
* `parse_factor()` will now can accept `levels = NULL`, which allows one to generate factor levels based on the data (like stringsAsFactors = TRUE) (#497).
* `parse_numeric()` now returns the full string if it contains no numbers (#548).
* `parse_time()` now correctly handles 12 AM/PM (#579).
* `problems()` now returns the file path in additional to the location of the error in the file (#581).
* `read_csv2()` gives a message if it updates the default locale (#443, @krlmlr).
* `read_delim()` now signals an error if given an empty delimiter (#557).
* `write_*()` functions witting whole number doubles are no longer written with a trailing `.0` (#526).

### Whitespace / fixed width improvements

* `fwf_cols()` allows for specifying the `col_positions` argument of
  `read_fwf()` with named arguments of either column positions or widths
  (#616, @jrnold).
* `fwf_empty()` gains an `n` argument to control how many lines are read for whitespace to determine column structure (#518, @Yeedle).
* `read_fwf()` gives error message if specifications have overlapping columns (#534, @gergness)
* `read_table()` can now handle `pipe()` connections (#552).
* `read_table()` can now handle files with many lines of leading comments (#563).
* `read_table2()` which allows any number of whitespace characters as delimiters, a more exact replacement for `utils::read.table()` (#608).

## Writing to connections
* `write_*()` functions now support writing to binary connections. In addition output filenames with `.gz`, `.bz2` or `.xz` will automatically open the appropriate connection and to write the compressed file. (#348)
* `write_lines()` now accepts a list of raw vectors (#542).

## Miscellaneous features
* `col_euro_double()`, `parse_euro_double()`, `col_numeric()`, and `parse_numeric()` have been removed.
* `guess_encoding()` returns a tibble, and works better with lists of raw vectors (as returned by `read_lines_raw()`).
* `ListCallback` R6 Class to provide a more flexible return type for callback functions (#568, @mmuurr)
* `tibble::as.tibble()` now used to construct tibbles (#538).
* `read_csv`, `read_csv2`, and `read_tsv` gain a `quote` argument, (#631, @noamross)

## Bugfixes
* `parse_factor()` now converts data to UTF-8 based on the supplied locale (#615).
* `read_*()` functions with the `guess_max` argument now throw errors on inappropriate inputs (#588).
* `read_*_chunked()` functions now properly end the stream if `FALSE` is returned from the callback.
* `read_delim()` and `read_fwf()` when columns are skipped using `col_types` now report the correct column name (#573, @cb4ds).
* `spec()` declarations that are long now print properly (#597).
* `read_table()` does not print `spec` when `col_types` is not `NULL` (#630, @jrnold).
* `guess_encoding()` now returns a tibble for all ASCII input as well (#641).

# readr 1.0.0

## Column guessing

The process by which readr guesses the types of columns has received a substantial overhaul to make it easier to fix problems when the initial guesses aren't correct, and to make it easier to generate reproducible code. Now column specifications are printing by default when you read from a file:

```R
challenge <- read_csv(readr_example("challenge.csv"))
#> Parsed with column specification:
#> cols(
#>   x = col_integer(),
#>   y = col_character()
#> )
```

And you can extract those values after the fact with `spec()`:

```R
spec(challenge)
#> cols(
#>   x = col_integer(),
#>   y = col_character()
#> )
```

This makes it easier to quickly identify parsing problems and fix them (#314). If the column specification is long, the new `cols_condense()` is used to condense the spec by identifying the most common type and setting it as the default. This is particularly useful when only a handful of columns have a different type (#466).

You can also generating an initial specification without parsing the file using `spec_csv()`, `spec_tsv()`, etc.

Once you have figured out the correct column types for a file, it's often useful to make the parsing strict. You can do this either by copying and pasting the printed output, or for very long specs, saving the spec to disk with `write_rds()`. In production scripts, combine this with `stop_for_problems()` (#465): if the input data changes form, you'll fail fast with an error.

You can now also adjust the number of rows that readr uses to guess the column types with `guess_max`:

```R
challenge <- read_csv(readr_example("challenge.csv"), guess_max = 1500)
#> Parsed with column specification:
#> cols(
#>   x = col_double(),
#>   y = col_date(format = "")
#> )
```

You can now access the guessing algorithm from R. `guess_parser()` will tell you which parser readr will select for a character vector (#377). We've made a number of fixes to the guessing algorithm:

* New example `extdata/challenge.csv` which is carefully created to cause 
  problems with the default column type guessing heuristics.

* Blank lines and lines with only comments are now skipped automatically
  without warning (#381, #321).

* Single '-' or '.' are now parsed as characters, not numbers (#297).

* Numbers followed by a single trailing character are parsed as character,
  not numbers (#316).

* We now guess at times using the `time_format` specified in the `locale()`.

We have made a number of improvements to the reification of the `col_types`, `col_names` and the actual data:

* If `col_types` is too long, it is subsetted correctly (#372, @jennybc).

* If `col_names` is too short, the added names are numbered correctly 
  (#374, @jennybc).
  
* Missing colum name names are now given a default name (`X2`, `X7` etc) (#318).
  Duplicated column names are now deduplicated. Both changes generate a warning;
  to suppress it supply an explicit `col_names` (setting `skip = 1` if there's
  an existing ill-formed header).

* `col_types()` accepts a named list as input (#401).

## Column parsing

The date time parsers recognise three new format strings:

* `%I` for 12 hour time format (#340).

* `%AD` and `%AT` are "automatic" date and time parsers. They are both slightly
  less flexible than previous defaults. The automatic date parser requires a 
  four digit year, and only accepts `-` and `/` as separators (#442). The 
  flexible time parser now requires colons between hours and minutes and 
  optional seconds (#424). 

`%y` and `%Y` are now strict and require 2 or 4 characters respectively.

Date and time parsing functions received a number of small enhancements:

* `parse_time()` returns `hms` objects rather than a custom `time` class (#409).
  It now correctly parses missing values (#398).

* `parse_date()` returns a numeric vector (instead of an integer vector) (#357).

* `parse_date()`, `parse_time()` and `parse_datetime()` gain an `na` 
  argument to match all other parsers (#413).
  
* If the format argument is omitted `parse_date()` or `parse_time()`, 
  date and time formats specified in the locale will be used. These now
  default to `%AD` and `%AT` respectively.
  
* You can now parse partial dates with `parse_date()` and 
 `parse_datetime()`, e.g. `parse_date("2001", "%Y")` returns `2001-01-01`.

`parse_number()` is slightly more flexible - it now parses numbers up to the first ill-formed character. For example `parse_number("-3-")` and `parse_number("...3...")` now return -3 and 3 respectively. We also fixed a major bug where parsing negative numbers yielded positive values (#308).

`parse_logical()` now accepts `0`, `1` as well as lowercase `t`, `f`, `true`, `false`. 

## New readers and writers

* `read_file_raw()` reads a complete file into a single raw vector (#451).

* `read_*()` functions gain a `quoted_na` argument to control whether missing
  values within quotes are treated as missing values or as strings (#295).
  
* `write_excel_csv()` can be used to write a csv file with a UTF-8 BOM at the
  start, which forces Excel to read it as UTF-8 encoded (#375).
  
* `write_lines()` writes a character vector to a file (#302).

* `write_file()` to write a single character or raw vector
  to a file (#474).

* Experimental support for chunked reading a writing (`read_*_chunked()`)
  functions. The API is unstable and subject to change in the future (#427).

## Minor features and bug fixes

* Printing double values now uses an
  [implementation](https://github.com/juj/MathGeoLib/blob/master/src/Math/grisu3.c)
  of the [grisu3 algorithm](http://www.cs.tufts.edu/~nr/cs257/archive/florian-loitsch/printf.pdf)
  which speeds up writing of large numeric data frames by ~10X. (#432) '.0' is
  appended to whole number doubles, to ensure they will be read as doubles as
  well. (#483)

* readr imports tibble so that you get consistent `tbl_df` behaviour 
  (#317, #385).
  
* New example `extdata/challenge.csv` which is carefully created to cause 
  problems with the default column type guessing heuristics.

* `default_locale()` now sets the default locale in `readr.default_locale`
  rather than regenerating it for each call. (#416).

* `locale()` now automatically sets decimal mark if you set the grouping 
  mark. It throws an error if you accidentally set decimal and grouping marks
  to the same character (#450).

* All `read_*()` can read into long vectors, substantially increasing the
  number of rows you can read (#309).

* All `read_*()` functions return empty objects rather than signaling an error 
  when run on an empty file (#356, #441).

* `read_delim()` gains a `trim_ws` argument (#312, noamross)

* `read_fwf()` received a number of improvements:

  * `read_fwf()` now can now reliably read only a partial set of columns
    (#322, #353, #469)
   
  * `fwf_widths()` accepts negative column widths for compatibility with the 
    `widths` argument in `read.fwf()` (#380, @leeper).
  
  * You can now read fixed width files with ragged final columns, by setting
    the final end position in `fwf_positions()` or final width in `fwf_widths()` 
    to `NA` (#353, @ghaarsma). `fwf_empty()` does this automatically.

  * `read_fwf()` and `fwf_empty()` can now skip commented lines by setting a
    `comment` argument (#334).

* `read_lines()` ignores embedded null's in strings (#338) and gains a `na`
  argument (#479).

* `readr_example()` makes it easy to access example files bundled with readr.

* `type_convert()` now accepts only `NULL` or a `cols` specification for
  `col_types` (#369).

* `write_delim()` and `write_csv()` now invisibly return the input data frame
  (as documented, #363).

* Doubles are parsed with `boost::spirit::qi::long_double` to work around a bug 
  in the spirit library when parsing large numbers (#412).

* Fix bug when detecting column types for single row files without headers
  (#333).

# readr 0.2.2

* Fix bug when checking empty values for missingness (caused valgrind issue
  and random crashes).

# readr 0.2.1

* Fixes so that readr works on Solaris.

# readr 0.2.0

## Internationalisation

readr now has a strategy for dealing with settings that vary from place to place: locales. The default locale is still US centric (because R itself is), but you can now easily override the default timezone, decimal separator, grouping mark, day & month names, date format, and encoding. This has lead to a number of changes:

* `read_csv()`, `read_tsv()`, `read_fwf()`, `read_table()`, 
  `read_lines()`, `read_file()`, `type_convert()`, `parse_vector()` 
  all gain a `locale` argument.
  
* `locale()` controls all the input settings that vary from place-to-place.

* `col_euro_double()` and `parse_euro_double()` have been deprecated.
  Use the `decimal_mark` parameter to `locale()` instead.
  
* The default encoding is now UTF-8. To load files that are not 
  in UTF-8, set the `encoding` parameter of the `locale()` (#40).
  New `guess_encoding()` function uses stringi to help you figure out the
  encoding of a file.
  
* `parse_datetime()` and `parse_date()` with `%B` and `%b` use the
  month names (full and abbreviate) defined in the locale (#242).
  They also inherit the tz from the locale, rather than using an
  explicit `tz` parameter.
  
See `vignette("locales")` for more details.

## File parsing improvements

* `cols()` lets you pick the default column type for columns not otherwise
  explicitly named (#148). You can refer to parsers either with their full 
  name (e.g. `col_character()`) or their one letter abbreviation (e.g. `c`).

* `cols_only()` allows you to load only named columns. You can also choose to 
  override the default column type in `cols()` (#72).

* `read_fwf()` is now much more careful with new lines. If a line is too short, 
  you'll get a warning instead of a silent mistake (#166, #254). Additionally,
  the last column can now be ragged: the width of the last field is silently 
  extended until it hits the next line break (#146). This appears to be a
  common feature of "fixed" width files in the wild.

* In `read_csv()`, `read_tsv()`, `read_delim()` etc:
 
  * `comment` argument allows you to ignore comments (#68).
  
  * `trim_ws` argument controls whether leading and trailing whitespace is 
    removed. It defaults to `TRUE` (#137).
  
  * Specifying the wrong number of column names, or having rows with an 
    unexpected number of columns, generates a warning, rather than an error 
    (#189).

  * Multiple NA values can be specified by passing a character vector to 
    `na` (#125). The default has been changed to `na = c("", "NA")`. Specifying 
    `na = ""` now works as expected with character columns (#114).

## Column parsing improvements

Readr gains `vignette("column-types")` which describes how the defaults work and how to override them (#122).

* `parse_character()` gains better support for embedded nulls: any characters 
  after the first null are dropped with a warning (#202).

* `parse_integer()` and `parse_double()` no longer silently ignore trailing
  letters after the number (#221).

* New `parse_time()` and `col_time()` allows you to parse times (hours, minutes, 
  seconds) into number of seconds since midnight. If the format is omitted, it 
  uses a flexible parser that looks for hours, then optional colon, then 
  minutes, then optional colon, then optional seconds, then optional am/pm 
  (#249).

* `parse_date()` and `parse_datetime()`: 

    * `parse_datetime()` no longer incorrectly reads partial dates (e.g. 19, 
      1900, 1900-01) (#136). These triggered common false positives and after 
      re-reading the ISO8601 spec, I believe they actually refer to periods of 
      time, and should not be translated in to a specific instant (#228). 
      
    * Compound formats "%D", "%F", "%R", "%X", "%T", "%x" are now parsed 
      correctly, instead of using the  ISO8601 parser (#178, @kmillar). 
      
    * "%." now requires a non-digit. New "%+" skips one or more non-digits.
      
    * You can now use `%p` to refer to AM/PM (and am/pm) (#126).
      
    * `%b` and `%B` formats (month and abbreviated month name) ignore case 
      when matching (#219).
      
    * Local (non-UTC) times with and without daylight savings are now parsed
      correctly (#120, @andres-s).

* `parse_number()` is a somewhat flexible numeric parser designed to read
  currencies and percentages. It only reads the first number from a string
  (using the grouping mark defined by the locale). 
  
* `parse_numeric()` has been deprecated because the name is confusing - 
  it's a flexible number parser, not a parser of "numerics", as R collectively
  calls doubles and integers. Use `parse_number()` instead. 

As well as improvements to the parser, I've also made a number of tweaks to the heuristics that readr uses to guess column types:

* New `parse_guess()` and `col_guess()` to explicitly guess column type.

* Bumped up row inspection for column typing guessing from 100 to 1000.

* The heuristics for guessing `col_integer()` and `col_double()` are stricter.
  Numbers with leading zeros now default to being parsed as text, rather than
  as integers/doubles (#266).
  
* A column is guessed as `col_number()` only if it parses as a regular number
  when you ignoring the grouping marks.

## Minor improvements and bug fixes

* Now use R's platform independent `iconv` wrapper, thanks to BDR (#149).

* Pathological zero row inputs (due to empty input, `skip` or `n_max`) now
  return zero row data frames (#119).
  
* When guessing field types, and there's no information to go on, use
  character instead of logical (#124, #128).

* Concise `col_types` specification now understands `?` (guess) and
  `-` (skip) (#188).

* `count_fields()` starts counting from 1, not 0 (#200).

* `format_csv()` and `format_delim()` make it easy to render a csv or 
  delimited file into a string.

* `fwf_empty()` now works correctly when `col_names` supplied (#186, #222).

* `parse_*()` gains a `na` argument that allows you to specify which values 
  should be converted to missing.

* `problems()` now reports column names rather than column numbers (#143).
  Whenever there is a problem, the first five problems are printing out 
  in a warning message, so you can more easily see what's wrong.

* `read_*()` throws a warning instead of an error is `col_types`
  specifies a non-existent column (#145, @alyst).

* `read_*()` can read from a remote gz compressed file (#163).

* `read_delim()` defaults to `escape_backslash = FALSE` and 
  `escape_double = TRUE` for consistency. `n_max` also affects the number 
  of rows read to guess the column types (#224).

* `read_lines()` gains a progress bar. It now also correctly checks for 
  interrupts every 500,000 lines so you can interrupt long running jobs.
  It also correctly estimates the number of lines in the file, considerably
  speeding up the reading of large files (60s -> 15s for a 1.5 Gb file).

* `read_lines_raw()` allows you to read a file into a list of raw vectors,
  one element for each line.

* `type_convert()` gains `NA` and `trim_ws` arguments, and removes missing
  values before determining column types.

* `write_csv()`, `write_delim()`, and `write_rds()` all invisably return their
  input so you can use them in a pipe (#290).

* `write_delim()` generalises `write_csv()` to write any delimited format (#135).
  `write_tsv()` is a helpful wrapper for tab separated files.
  
    * Quotes are only used when they're needed (#116): when the string contains 
      a quote, the delimiter, a new line or NA. 
      
    * Double vectors are saved using same amount of precision as 
      `as.character()` (#117). 
      
    * New `na` argument that specifies how missing values should be written 
      (#187)
    
    * POSIXt vectors are saved in a ISO8601 compatible format (#134). 
    
    * No longer fails silently if it can't open the target for 
      writing (#193, #172).

* `write_rds()` and `read_rds()` wrap around `readRDS()` and `saveRDS()`,
  defaulting to no compression (#140, @nicolasCoutin).
