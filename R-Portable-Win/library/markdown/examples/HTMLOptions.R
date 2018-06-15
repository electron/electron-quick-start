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
