## This can only be done in a locale that extends Latin-1
(inf <- l10n_info())
if(!(inf$`UTF-8` || inf$`Latin-1`)) {
    warning("this test must be done in a Latin-1 or UTF-8 locale")
    q()
}

inp <- readLines(n = 2)
«Latin-1 accented chars»: éè øØ å<Å æ<Æ é éè
éè

inp
(txt <- iconv(inp[1], "latin1", ""))
(pat <- iconv(inp[2], "latin1", ""))
if(any(is.na(c(txt, pat)))) {
    ## backup test
    warning("this test must be done in a Latin-1 or UTF-8 locale")
    q()
}

testit <- function(x) {print(x); stopifnot(identical(x, 1L))}
testit(grep(pat, txt))
testit(grep(pat, txt, ignore.case = TRUE))
testit(grep(pat, txt, useBytes = TRUE))
testit(grep(pat, txt, ignore.case = TRUE, useBytes = TRUE))
testit(grep(pat, txt, fixed = TRUE))
testit(grep(pat, txt, fixed = TRUE, useBytes = TRUE))
testit(grep(pat, txt, perl = TRUE))
testit(grep(pat, txt, ignore.case = TRUE, perl = TRUE))
testit(grep(pat, txt, perl = TRUE, useBytes = TRUE))
testit(grep(pat, txt, ignore.case = TRUE, perl = TRUE, useBytes = TRUE))
testit(grep(toupper(pat), txt, ignore.case = TRUE))
testit(grep(toupper(pat), txt, ignore.case = TRUE, perl = TRUE))
## matches in Latin-1 but not in UTF-8
grep(toupper(pat), txt, ignore.case = TRUE, perl = TRUE, useBytes = TRUE)

(r1 <- regexpr("en", txt, fixed=TRUE))
(r2 <- regexpr("en", txt, fixed=TRUE, useBytes=TRUE))
stopifnot(identical(r1, regexpr("en", txt)))
stopifnot(identical(r2, regexpr("en", txt, useBytes = TRUE)))
stopifnot(identical(r1, regexpr("en", txt, perl=TRUE)))
stopifnot(identical(r2, regexpr("en", txt, perl=TRUE, useBytes=TRUE)))
stopifnot(identical(r1, regexpr("EN", txt, ignore.case=TRUE)))
stopifnot(identical(r2, regexpr("EN", txt, ignore.case=TRUE, useBytes=TRUE)))
stopifnot(identical(r1, regexpr("EN", txt, ignore.case=TRUE, perl=TRUE)))
stopifnot(identical(r2, regexpr("EN", txt, ignore.case=TRUE, perl=TRUE,
                                useBytes=TRUE)))

(r1 <- regexpr(pat, txt, fixed=TRUE))
(r2 <- regexpr(pat, txt, fixed=TRUE, useBytes=TRUE))
stopifnot(identical(r1, regexpr(pat, txt)))
stopifnot(identical(r2, regexpr(pat, txt, useBytes=TRUE)))
stopifnot(identical(r1, regexpr(pat, txt, perl=TRUE)))
stopifnot(identical(r2, regexpr(pat, txt, perl=TRUE, useBytes=TRUE)))
stopifnot(identical(r1, regexpr(pat, txt, ignore.case=TRUE)))
stopifnot(identical(r2, regexpr(pat, txt, ignore.case=TRUE, useBytes=TRUE)))
stopifnot(identical(r1, regexpr(pat, txt, ignore.case=TRUE, perl=TRUE)))
stopifnot(identical(r2, regexpr(pat, txt, ignore.case=TRUE, perl=TRUE,
                                useBytes=TRUE)))
pat2 <- toupper(pat)
stopifnot(identical(r1, regexpr(pat2, txt, ignore.case=TRUE)))
stopifnot(identical(r1, regexpr(pat2, txt, ignore.case=TRUE, perl=TRUE)))
## will not match in a UTF-8 locale
regexpr(pat2, txt, ignore.case=TRUE, perl=TRUE, useBytes=TRUE)


(r1 <- gregexpr(pat, txt, fixed=TRUE))
(r2 <- gregexpr(pat, txt, fixed=TRUE, useBytes=TRUE))
stopifnot(identical(r1, gregexpr(pat, txt)))
stopifnot(identical(r2, gregexpr(pat, txt, useBytes=TRUE)))
stopifnot(identical(r1, gregexpr(pat, txt, perl=TRUE)))
stopifnot(identical(r2, gregexpr(pat, txt, perl=TRUE, useBytes=TRUE)))
stopifnot(identical(r1, gregexpr(pat, txt, ignore.case=TRUE)))
stopifnot(identical(r2, gregexpr(pat, txt, ignore.case=TRUE, useByte=TRUE)))
stopifnot(identical(r1, gregexpr(pat, txt, ignore.case=TRUE, perl=TRUE)))
stopifnot(identical(r2, gregexpr(pat, txt, ignore.case=TRUE, perl=TRUE,
                                 useBytes=TRUE)))

txt2 <- c("The", "licenses", "for", "most", "software", "are",
  "designed", "to", "take", "away", "your", "freedom",
  "to", "share", "and", "change", "it.",
   "", "By", "contrast,", "the", "GNU", "General", "Public", "License",
   "is", "intended", "to", "guarantee", "your", "freedom", "to",
   "share", "and", "change", "free", "software", "--",
   "to", "make", "sure", "the", "software", "is",
   "free", "for", "all", "its", "users")
( i <- grep("[gu]", txt2, perl = TRUE) )
stopifnot(identical(i, grep("[gu]", txt2)))
## results depend on the locale
(ot <- sub("[b-e]",".", txt2, perl = TRUE))
txt2[ot != sub("[b-e]",".", txt2)]
(ot <- sub("[b-e]",".", txt2, ignore.case = TRUE, perl = TRUE))
txt2[ot != sub("[b-e]",".", txt2, ignore.case = TRUE)]


## These may end up with different encodings: == copes, identical does not

eq <- function(a, b) a == b
(r1 <- gsub(pat, "ef", txt))
stopifnot(eq(r1, gsub(pat, "ef", txt, useBytes = TRUE)))
stopifnot(eq(r1, gsub(pat, "ef", txt, fixed = TRUE)))
stopifnot(eq(r1, gsub(pat, "ef", txt, fixed = TRUE, useBytes = TRUE)))
stopifnot(eq(r1, gsub(pat, "ef", txt, perl = TRUE)))
stopifnot(eq(r1, gsub(pat, "ef", txt, perl = TRUE, useBytes = TRUE)))

pat <- substr(pat, 1, 1)
(r1 <- gsub(pat, "gh", txt))
stopifnot(eq(r1, gsub(pat, "gh", txt, useBytes = TRUE)))
stopifnot(eq(r1, gsub(pat, "gh", txt, fixed = TRUE)))
stopifnot(eq(r1, gsub(pat, "gh", txt, fixed = TRUE, useBytes = TRUE)))
stopifnot(eq(r1, gsub(pat, "gh", txt, perl = TRUE)))
stopifnot(eq(r1, gsub(pat, "gh", txt, perl = TRUE, useBytes = TRUE)))


stopifnot(identical(gsub("a*", "x", "baaac"), "xbxcx"))
stopifnot(identical(gsub("a*", "x", "baaac"), "xbxcx"), perl = TRUE)
stopifnot(identical(gsub("a*", "x", "baaac"), "xbxcx"), useBytes = TRUE)
stopifnot(identical(gsub("a*", "x", "baaac"), "xbxcx"), perl = TRUE, useBytes = TRUE)

## this one seems system-dependent
(x <- gsub("\\b", "|", "The quick brown \ue8\ue9", perl = TRUE))
# stopifnot(identical(x, "|The| |quick| |brown| |\ue8\ue9|"))
(x <- gsub("\\b", "|", "The quick brown fox", perl = TRUE))
stopifnot(identical(x, "|The| |quick| |brown| |fox|"))
## The following is warned against in the help page, but worked in some versions
gsub("\\b", "|", "The quick brown fox")

(z <- strsplit(txt, pat)[[1]])
stopifnot(eq(z, strsplit(txt, pat, useBytes = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, pat, fixed = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, pat, fixed = TRUE, useBytes = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, pat, perl = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, pat, perl = TRUE, useBytes = TRUE)[[1]]))

(z <- strsplit(txt, "[a-c]")[[1]])
stopifnot(eq(z, strsplit(txt, "[a-c]", useBytes = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, "[a-c]", perl = TRUE)[[1]]))
stopifnot(eq(z, strsplit(txt, "[a-c]", perl = TRUE, useBytes = TRUE)[[1]]))

## from strsplit.Rd
z <- strsplit("A text I want to display with spaces", NULL)[[1]]
stopifnot(identical(z,
                    strsplit("A text I want to display with spaces", "")[[1]]))

x <- c(as = "asfef", qu = "qwerty", "yuiop[", "b", "stuff.blah.yech")
(z <- strsplit(x, "e"))
stopifnot(identical(z, strsplit(x, "e", useBytes = TRUE)))
stopifnot(identical(z, strsplit(x, "e", fixed = TRUE)))
stopifnot(identical(z, strsplit(x, "e", fixed = TRUE, useBytes = TRUE)))
stopifnot(identical(z, strsplit(x, "e", perl = TRUE)))
stopifnot(identical(z, strsplit(x, "e", perl = TRUE, useBytes = TRUE)))

## moved from reg-tests-1b.R.
## fails to match on Cygwin, Mar 2011
## regexpr(fixed = TRUE) with a single-byte pattern matching to a MBCS string
x <- iconv("fa\xE7ile a ", "latin1", "UTF-8")
stopifnot(identical(regexpr(" ", x), regexpr(" ", x, fixed=TRUE)))
# fixed=TRUE reported match position in bytes in R <= 2.10.0
stopifnot(identical(regexpr(" a", x), regexpr(" a", x, fixed=TRUE)))
## always worked.

## this broke and segfaulted in 2.13.1 and earlier (PR#14627)
x <- paste(rep("a ", 600), collapse="")
testit(agrep(x, x))
testit(agrep(x, x, max.distance=0.5))

## this is used in QC to check dependencies and was broken intermittently by TRE changes
stopifnot(isTRUE(grepl('^[[:space:]]*(R|[[:alpha:]][[:alnum:].]*[[:alnum:]])([[:space:]]*\\(([^) ]+)[[:space:]]+([^) ]+)\\))?[[:space:]]*$', ' R (>= 2.13.0) ')))

## Bad sub() and gsub() with some regexprs PR#16009
x <- c(NA, "  abc", "a b c    ", "a  b c")
(y <- gsub("\\s{2,}", " ", x))
stopifnot(y[-1] == c(" abc", "a b c ", "a b c"))
x <- c("\ue4", "  abc", "a b c    ", "a  b c")
(y <- gsub("\\s{2,}", " ", x))
stopifnot(y == c(x[1], " abc", "a b c ", "a b c"))
## results were c(x[1], " ", " ", " ") in both cases in R 3.1.1
