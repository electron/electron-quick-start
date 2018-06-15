# Automatically generated from specification file: 'partials.json'
#
# Partial tags are used to expand an external template into the current
# template.
# 
# The tag's content MUST be a non-whitespace character sequence NOT containing
# the current closing delimiter.
# 
# This tag's content names the partial to inject.  Set Delimiter tags MUST NOT
# affect the parsing of a partial.  The partial MUST be rendered against the
# context stack local to the tag.
# 
# Partial tags SHOULD be treated as standalone when appropriate.  If this tag
# is used standalone, any whitespace preceding the tag should treated as
# indentation, and prepended to each line of the partial before rendering.
# 
library(testthat)
context('Spec v1.1, partials')

test_that( "Basic Behavior", {
  #"The greater-than operator should expand to the named partial."
  template <- "\"{{>text}}\""
  data <- list()

  partials <- list(text = "from partial")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "\"from partial\"", label=deparse(str), info="The greater-than operator should expand to the named partial.")
})

test_that( "Context", {
  #"The greater-than operator should operate within the current context."
  template <- "\"{{>partial}}\""
  data <- list(text = "content")

  partials <- list(partial = "*{{text}}*")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "\"*content*\"", label=deparse(str), info="The greater-than operator should operate within the current context.")
})

test_that( "Recursion", {
  #"The greater-than operator should properly recurse."
  template <- "{{>node}}"
  data <- list(content = "X", nodes = list(list(content = "Y", nodes = list())))

  partials <- list(node = "{{content}}<{{#nodes}}{{>node}}{{/nodes}}>")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "X<Y<>>", label=deparse(str), info="The greater-than operator should properly recurse.")
})

test_that( "Surrounding Whitespace", {
  #"The greater-than operator should not alter surrounding whitespace."
  template <- "| {{>partial}} |"
  data <- list()

  partials <- list(partial = "\t|\t")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "| \t|\t |", label=deparse(str), info="The greater-than operator should not alter surrounding whitespace.")
})

test_that( "Inline Indentation", {
  #"Whitespace should be left untouched."
  template <- "  {{data}}  {{> partial}}\n"
  data <- list(data = "|")

  partials <- list(partial = ">\n>")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "  |  >\n>\n", label=deparse(str), info="Whitespace should be left untouched.")
})

test_that( "Standalone Line Endings", {
  #"\"\\r\\n\" should be considered a newline for standalone tags."
  template <- "|\r\n{{>partial}}\r\n|"
  data <- list()

  partials <- list(partial = ">")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "|\r\n>|", label=deparse(str), info="\"\\r\\n\" should be considered a newline for standalone tags.")
})

test_that( "Standalone Without Previous Line", {
  #"Standalone tags should not require a newline to precede them."
  template <- "  {{>partial}}\n>"
  data <- list()

  partials <- list(partial = ">\n>")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "  >\n  >>", label=deparse(str), info="Standalone tags should not require a newline to precede them.")
})

test_that( "Standalone Without Newline", {
  #"Standalone tags should not require a newline to follow them."
  template <- ">\n  {{>partial}}"
  data <- list()

  partials <- list(partial = ">\n>")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, ">\n  >\n  >", label=deparse(str), info="Standalone tags should not require a newline to follow them.")
})

test_that( "Standalone Indentation", {
  #"Each line of the partial should be indented before rendering."
  template <- "\\\n {{>partial}}\n/\n"
  data <- list(content = "<\n->")

  partials <- list(partial = "|\n{{{content}}}\n|\n")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "\\\n |\n <\n->\n |\n/\n", label=deparse(str), info="Each line of the partial should be indented before rendering.")
})

test_that( "Padding Whitespace", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{> partial }}|"
  data <- list(boolean = TRUE)

  partials <- list(partial = "[]")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "|[]|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

