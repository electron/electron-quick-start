## ---- include = FALSE----------------------------------------------------
library(readr)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ------------------------------------------------------------------------
locale()

## ------------------------------------------------------------------------
locale("ko") # Korean
locale("fr") # French

## ------------------------------------------------------------------------
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
parse_date("14 oct. 1979", "%d %b %Y", locale = locale("fr"))

## ------------------------------------------------------------------------
parse_date("1 août 2015", "%d %B %Y", locale = locale("fr"))
parse_date("1 aout 2015", "%d %B %Y", locale = locale("fr", asciify = TRUE))

## ------------------------------------------------------------------------
maori <- locale(date_names(
  day = c("Rātapu", "Rāhina", "Rātū", "Rāapa", "Rāpare", "Rāmere", "Rāhoroi"),
  mon = c("Kohi-tātea", "Hui-tanguru", "Poutū-te-rangi", "Paenga-whāwhā",
    "Haratua", "Pipiri", "Hōngongoi", "Here-turi-kōkā", "Mahuru",
    "Whiringa-ā-nuku", "Whiringa-ā-rangi", "Hakihea")
))

## ------------------------------------------------------------------------
parse_datetime("2001-10-10 20:10")
parse_datetime("2001-10-10 20:10", locale = locale(tz = "Pacific/Auckland"))
parse_datetime("2001-10-10 20:10", locale = locale(tz = "Europe/Dublin"))

## ---- eval = FALSE-------------------------------------------------------
#  is_datetime <- sapply(df, inherits, "POSIXct")
#  df[is_datetime] <- lapply(df[is_datetime], function(x) {
#    attr(x, "tzone") <- "UTC"
#    x
#  })

## ------------------------------------------------------------------------
str(parse_guess("2010-10-10"))

## ------------------------------------------------------------------------
str(parse_guess("01/02/2013"))
str(parse_guess("01/02/2013", locale = locale(date_format = "%d/%m/%Y")))

## ------------------------------------------------------------------------
library(stringi)
x <- "Émigré cause célèbre déjà vu.\n"
y <- stri_conv(x, "UTF-8", "latin1")

# These strings look like they're identical:
x
y
identical(x, y)

# But they have difference encodings:
Encoding(x)
Encoding(y)

# That means while they print the same, their raw (binary)
# representation is actually quite different:
charToRaw(x)
charToRaw(y)

# readr expects strings to be encoded as UTF-8. If they're
# not, you'll get weird characters
parse_character(x)
parse_character(y)

# If you know the encoding, supply it:
parse_character(y, locale = locale(encoding = "latin1"))

## ------------------------------------------------------------------------
guess_encoding(x)
guess_encoding(y)

# Note that the first guess produces a valid string, but isn't correct:
parse_character(y, locale = locale(encoding = "ISO-8859-2"))
# But ISO-8859-1 is another name for latin1
parse_character(y, locale = locale(encoding = "ISO-8859-1"))

## ------------------------------------------------------------------------
parse_double("1,23", locale = locale(decimal_mark = ","))

## ------------------------------------------------------------------------
parse_number("$1,234.56")
parse_number("$1.234,56", 
  locale = locale(decimal_mark = ",", grouping_mark = ".")
)

# readr is smart enough to guess that if you're using , for decimals then
# you're probably using . for grouping:
parse_number("$1.234,56", locale = locale(decimal_mark = ","))

