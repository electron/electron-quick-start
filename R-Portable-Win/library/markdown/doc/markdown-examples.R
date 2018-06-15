## ----read-code, include=FALSE--------------------------------------------
library(knitr)
opts_chunk$set(tidy = FALSE)  # otherwise \n will cause problems
read_chunk(system.file('examples', 'markdownExtensions.R', package = 'markdown'),
           labels = 'md-extensions')
read_chunk(system.file('examples', 'HTMLOptions.R', package = 'markdown'),
           labels = 'html-options')

## ------------------------------------------------------------------------
library(markdown)

## ----md-extensions-------------------------------------------------------
# The following examples are short, so we set the HTML option 'fragment_only'

options(markdown.HTML.options = "fragment_only")

# no_intra_emphasis example
cat(markdownToHTML(text = "foo_bar_function", extensions = c()))
cat(markdownToHTML(text = "foo_bar_function", extensions = c("no_intra_emphasis")))

# tables example (need 4 spaces at beginning of line here)
cat(markdownToHTML(text = "
    First Header  | Second Header
    ------------- | -------------
    Content Cell  | Content Cell
    Content Cell  | Content Cell
", extensions = c()))

# but not here
cat(markdownToHTML(text = "
First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell
", extensions = c("tables")))

# fenced_code example (need at least three leading ~ or `)
fenced_block <- function(text, x = "`", n = 3) {
  fence <- paste(rep(x, n), collapse = "")
  paste(fence, text, fence, sep = "")
}
cat(markdownToHTML(text = fenced_block("
preformatted text here without having to indent
first line.
"), extensions = c()))

cat(markdownToHTML(text = fenced_block("
preformatted text here without having to indent
first line.
"), extensions = c("fenced_code")))

# autolink example
cat(markdownToHTML(text = "https://www.r-project.org/", extensions = c()))
cat(markdownToHTML(text = "https://www.r-project.org/", extensions = c("autolink")))

# strikethrough example
cat(markdownToHTML(text = "~~awesome~~", extensions = c()))
cat(markdownToHTML(text = "~~awesome~~", extensions = c("strikethrough")))

# lax_spacing
cat(markdownToHTML(text = "
Embedding html without surrounding with empty newline.
<div>_markdown_</div>
extra text.
", extensions = c("")))
cat(markdownToHTML(text = "
Embedding html without surrounding with empty newline.
<div>_markdown_</div>
extra text.
", extensions = c("lax_spacing")))

# space_headers example
cat(markdownToHTML(text = "#A Header\neven though there is no space between # and A",
                   extensions = c("")))
cat(markdownToHTML(text = "#Not A Header\nbecause there is no space between # and N",
                   extensions = c("space_headers")))

# superscript example
cat(markdownToHTML(text = "2^10", extensions = c()))
cat(markdownToHTML(text = "2^10", extensions = c("superscript")))

## ----html-options--------------------------------------------------------
# HTML OPTIONS

# The following examples are short, so we allways add the HTML option 'fragment_only'
tOpt <- "fragment_only"

# skip_html example
mkd = '<style></style><img src="http://cran.rstudio.com/Rlogo.jpg"><a href="#">Hello</a>'
cat(markdownToHTML(text = mkd, options = c(tOpt)))
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_html")))

# skip_style example
cat(markdownToHTML(text = mkd, options = c(tOpt)))
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_style")))

# skip_images example
cat(markdownToHTML(text = mkd, options = c(tOpt)))
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_images")))

# skip_links example
cat(markdownToHTML(text = mkd, options = c(tOpt)))
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_links")))

# safelink example
cat(markdownToHTML(text = '[foo](http://google.com "baz")', options = c(tOpt)))
cat(markdownToHTML(text = '[foo](http://google.com "baz")', options = c(tOpt, "safelink")))

# toc example
mkd <- paste(c("# Header 1", "p1", "## Header 2", "p2"), collapse = "\n")

cat(markdownToHTML(text = mkd, options = c(tOpt)))
cat(markdownToHTML(text = mkd, options = c(tOpt, "toc")))

# hard_wrap example
cat(markdownToHTML(text = "foo\nbar\n", options = c(tOpt)))
cat(markdownToHTML(text = "foo\nbar\n", options = c(tOpt, "hard_wrap")))

# use_xhtml example
cat(markdownToHTML(text = "foo\nbar\n", options = c(tOpt, "hard_wrap")))
cat(markdownToHTML(text = "foo\nbar\n", options = c(tOpt, "hard_wrap", "use_xhtml")))

# escape example
mkd = '<style></style><img src="http://cran.rstudio.com/Rlogo.jpg"><a href="#">Hello</a>'
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_html")))
# overrides all 'skip_*' options
cat(markdownToHTML(text = mkd, options = c(tOpt, "skip_html", "escape")))

# smartypants example
cat(markdownToHTML(text = "1/2 (c)", options = c(tOpt)))
cat(markdownToHTML(text = "1/2 (c)", options = c(tOpt, "smartypants")))

cat(smartypants(text = "1/2 (c)\n"))

## ----include=FALSE-------------------------------------------------------
options(markdown.HTML.options=markdownHTMLOptions(defaults=TRUE))

