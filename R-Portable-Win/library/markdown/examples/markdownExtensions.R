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
