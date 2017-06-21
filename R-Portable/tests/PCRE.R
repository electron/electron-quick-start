.ptime <- proc.time()

### tests of recursion in PCRE matching
### Based on PR16757

## This is expected to throw a warning at some point if PCRE uses a stack,
## depending on the system and stack size.
## Typical stack 8-10M, some people use 40M.

pcre_config()["stack"]

op <- options(warn = 1)
for (n in c(seq(5000L, 10000L, 1000L), 20000L, 50000L, 100000L)) {
    print(n)
    x <- paste0(rep("a", n), collapse="")
    print(grepl("(a|b)+", x, perl = TRUE))
}
options(op)


### tests of PCRE's JIT.
if(!pcre_config()["JIT"]) {
    message("These tests are pointless without JIT support")
    q("no")
}


## Test from example(grep)

txt2 <- c("The", "licenses", "for", "most", "software", "are",
          "designed", "to", "take", "away", "your", "freedom",
          "to", "share", "and", "change", "it.",
          "", "By", "contrast,", "the", "GNU", "General", "Public", "License",
          "is", "intended", "to", "guarantee", "your", "freedom", "to",
          "share", "and", "change", "free", "software", "--",
          "to", "make", "sure", "the", "software", "is",
          "free", "for", "all", "its", "users")
grep("[gu]", txt2, perl = TRUE)

st <- function(expr) sum(system.time(expr)[1:2])

## here JIT is slightly slower
options(PCRE_study = FALSE)
st(for(i in 1:1e4) grep("[gu]", txt2, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e4) grep("[gu]", txt2, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = TRUE)
st(for(i in 1:1e4) grep("[gu]", txt2, perl = TRUE))


## and for more inputs, study starts to pay off
txt3 <- rep(txt2, 10)
options(PCRE_study = FALSE)
st(for(i in 1:1e3) grep("[gu]", txt3, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e3) grep("[gu]", txt3, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = TRUE)
st(for(i in 1:1e3) grep("[gu]", txt3, perl = TRUE))


## An example where JIT really pays off (e.g. 10x)
pat <- "([^[:alpha:]]|a|b)+"
long_string <- paste0(rep("a", 1023), collapse="")
N <- 10
options(PCRE_study = FALSE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e3) grep(pat, rep(long_string, N), perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e3) grep(pat, rep(long_string, N), perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = TRUE)
st(for(i in 1:1e3) grep(pat, rep(long_string, N), perl = TRUE))


## This needs to test 50 strings to see much gain from study
txt <- rep("a test of capitalizing", 50)
options(PCRE_study = FALSE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e4) gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", txt, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = FALSE)
st(for(i in 1:1e4) gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", txt, perl = TRUE))
options(PCRE_study = TRUE, PCRE_use_JIT = TRUE)
st(for(i in 1:1e4) gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", txt, perl = TRUE))

cat("Time elapsed: ", proc.time() - .ptime,"\n")
