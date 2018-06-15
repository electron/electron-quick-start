# pillar 1.2.2 (2018-04-25)

- Whole numbers are printed without a decimal dot again. Numbers that are the result of a whole number divided by a power of 10 (subject to a tolerance to account for floating-point imprecision) are shown without trailing decimal zeros, even if these zeros are significant according to the `pillar.sigfig` option (#105).
- New `new_pillar_title()` and `new_pillar_type()` to support consistent output in `glimpse()` (#31).
- New `format_type_sum()` generic that allows overriding the formatting of the type summary in the capital (#73).
- The `digits.secs` option is respected when computing the width for date-time values (#102).


# pillar 1.2.1 (2018-02-26)

Display
-------

- Turned off using subtle style for digits that are considered insignificant.  Negative numbers are shown all red.  Set the new option `pillar.subtle_num` to `TRUE` to turn it on again (default: `FALSE`).
- The negation sign is printed next to the number again (#91).
- Scientific notation uses regular digits again for exponents (#90).
- Groups of three digits are now underlined, starting with the fourth before/after the decimal point. This gives a better idea of the order of magnitude of the numbers (#78).
- Logical columns are displayed as `TRUE` and `FALSE` again (#95).
- The decimal dot is now always printed for numbers of type `numeric`. Trailing zeros are not shown anymore if all displayed numbers are whole numbers (#62).
- Decimal values longer than 13 characters always print in scientific notation.

Bug fixes
---------

- Numeric values with a `"class"` attribute (e.g., `Duration` from lubridate) are now formatted using `format()` if the `pillar_shaft()` method is not implemented for that class (#88).
- Very small numbers (like `1e-310`) are now printed corectly (tidyverse/tibble#377).
- Fix representation of right-hand side for `getOption("pillar.sigfig") >= 6` (tidyverse/tibble#380).
- Fix computation of significant figures for numbers with absolute value >= 1 (#98).

New functions
-------------

- New styling helper `style_subtle_num()`, formatting depends on the `pillar.subtle_num` option.


# pillar 1.1.0 (2018-01-14)

- `NA` values are now shown in plain red, without changing the background color (#70).
- New options to control the output, with defaults that match the current behavior unless stated otherwise:
    - `pillar.sigfig` to control the number of significant digits, for highlighting and truncation (#72),
    - `pillar.subtle` to specify if insignificant digits should be printed in gray (#72),
    - `pillar.neg` to specify if negative digits should be printed in red,
    - `pillar.bold` to specify if column headers should be printed in bold (default: `FALSE`, #76),
    - `pillar.min_title_chars` to specify the minimum number of characters to display for each column name (default: 15 characters, #75).
- Shortened abbreviations for types: complex: cplx -> cpl, function: fun -> fn, factor: fctr -> fct (#71).
- Date columns now show sub-seconds if the `digits.secs` option is set (#74).
- Very wide tibbles now print faster (#85).


# pillar 1.0.1 (2017-11-27)

- Work around failing CRAN tests on Windows.


# pillar 1.0.0 (2017-11-16)

Initial release.

## User functions

    pillar(x, title = NULL, width = NULL, ...)
    colonnade(x, has_row_id = TRUE, width = NULL, ...)
    squeeze(x, width = NULL, ...)

## Functions for implementers of data types

    new_pillar_shaft_simple(formatted, ..., width = NULL, align = "left", min_width = NULL, na_indent = 0L)
    new_pillar_shaft(x, ..., width, min_width = width, subclass)
    new_ornament(x, width = NULL, align = NULL)
    get_extent(x)
    get_max_extent(x)

## Utilities

    dim_desc(x)
    style_na(x)
    style_neg(x)
    style_num(x, negative, significant = rep_along(x, TRUE))
    style_subtle(x)

## Testing helper

    expect_known_display(object, file, ..., width = 80L, crayon = TRUE)

## Own S3 methods

    pillar_shaft(x, ...) # AsIs, Date, POSIXt, character, default, list, logical, numeric
    type_sum(x) # AsIs, Date, POSIXct, data.frame, default, difftime, factor, ordered
    is_vector_s3(x) # Date, POSIXct, data.frame, default, difftime, factor, ordered
    obj_sum(x) # AsIs, POSIXlt, default, list
    extra_cols(x, ...) # squeezed_colonnade
