## moved from reg-tests-1d.R and datetime.R as failure should not be fatal
## to make check-devel.

## PR#17186 - Sys.timezone() on some Debian-derived platforms
(S.t <- Sys.timezone())
## NB: This will fail on non-standard platforms, or even standard new OSes.
## --  We are strict here, in order to *learn* about those and possibly work around:
if(is.na(S.t) || !nzchar(S.t)) stop("could not get timezone")
## has been NA_character_  in Ubuntu 14.04.5 LTS
