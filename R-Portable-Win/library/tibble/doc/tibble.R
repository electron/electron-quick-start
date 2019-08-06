## ---- echo = FALSE, message = FALSE, error = TRUE------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(tibble)
set.seed(1014)

options(crayon.enabled = TRUE)
options(pillar.bold = TRUE)

knitr::opts_chunk$set(collapse = TRUE, comment = pillar::style_subtle("#>"))

colourise_chunk <- function(type) {
  function(x, options) {
    # lines <- strsplit(x, "\\n")[[1]]
    lines <- x
    if (type != "output") {
      lines <- crayon::red(lines)
    }
    paste0(
      '<div class="sourceCode"><pre class="sourceCode"><code class="sourceCode">',
      paste0(
        sgr_to_html(htmltools::htmlEscape(lines)),
        collapse = "\n"
      ),
      "</code></pre></div>"
    )
  }
}

knitr::knit_hooks$set(
  output = colourise_chunk("output"),
  message = colourise_chunk("message"),
  warning = colourise_chunk("warning"),
  error = colourise_chunk("error")
)

# Fallback if fansi is missing
sgr_to_html <- identity
sgr_to_html <- fansi::sgr_to_html

## ------------------------------------------------------------------------
tibble(x = letters)

## ------------------------------------------------------------------------
tibble(x = 1:3, y = list(1:5, 1:10, 1:20))

## ------------------------------------------------------------------------
names(data.frame(`crazy name` = 1))
names(tibble(`crazy name` = 1))

## ------------------------------------------------------------------------
tibble(x = 1:5, y = x ^ 2)

## ----error = TRUE, eval = FALSE------------------------------------------
#  l <- replicate(26, sample(100), simplify = FALSE)
#  names(l) <- letters
#  
#  timing <- bench::mark(
#    as_tibble(l),
#    as.data.frame(l),
#    check = FALSE
#  )
#  
#  timing

## ----echo = FALSE--------------------------------------------------------
readRDS("timing.rds")

## ------------------------------------------------------------------------
tibble(x = -5:1000)

## ------------------------------------------------------------------------
df1 <- data.frame(x = 1:3, y = 3:1)
class(df1[, 1:2])
class(df1[, 1])

df2 <- tibble(x = 1:3, y = 3:1)
class(df2[, 1:2])
class(df2[, 1])

## ------------------------------------------------------------------------
class(df2[[1]])
class(df2$x)

## ---- error = TRUE-------------------------------------------------------
df <- data.frame(abc = 1)
df$a

df2 <- tibble(abc = 1)
df2$a

## ------------------------------------------------------------------------
data.frame(a = 1:3)[, "a", drop = TRUE]
tibble(a = 1:3)[, "a", drop = TRUE]

## ---- error = TRUE-------------------------------------------------------
tibble(a = 1, b = 1:3)
tibble(a = 1:3, b = 1)
tibble(a = 1:3, c = 1:2)
tibble(a = 1, b = integer())
tibble(a = integer(), b = 1)

