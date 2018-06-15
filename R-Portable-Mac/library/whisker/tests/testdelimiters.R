# Automatically generated from specification file: 'delimiters.json'
#
# Set Delimiter tags are used to change the tag delimiters for all content
# following the tag in the current compilation unit.
# 
# The tag's content MUST be any two non-whitespace sequences (separated by
# whitespace) EXCEPT an equals sign ('=') followed by the current closing
# delimiter.
# 
# Set Delimiter tags SHOULD be treated as standalone when appropriate.
# 
library(testthat)
context('Spec v1.1, delimiters')

test_that( "Pair Behavior", {
  #"The equals sign (used on both sides) should permit delimiter changes."
  template <- "{{=<% %>=}}(<%text%>)"
  data <- list(text = "Hey!")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "(Hey!)", label=deparse(str), info="The equals sign (used on both sides) should permit delimiter changes.")
})

test_that( "Special Characters", {
  #"Characters with special meaning regexen should be valid delimiters."
  template <- "({{=[ ]=}}[text])"
  data <- list(text = "It worked!")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "(It worked!)", label=deparse(str), info="Characters with special meaning regexen should be valid delimiters.")
})

test_that( "Sections", {
  #"Delimiters set outside sections should persist."
  template <- "[\n{{#section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|#section|\n  {{data}}\n  |data|\n|/section|\n]\n"
  data <- list(section = TRUE, data = "I got interpolated.")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n", label=deparse(str), info="Delimiters set outside sections should persist.")
})

test_that( "Inverted Sections", {
  #"Delimiters set outside inverted sections should persist."
  template <- "[\n{{^section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|^section|\n  {{data}}\n  |data|\n|/section|\n]\n"
  data <- list(section = FALSE, data = "I got interpolated.")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n", label=deparse(str), info="Delimiters set outside inverted sections should persist.")
})

test_that( "Partial Inheritence", {
  #"Delimiters set in a parent template should not affect a partial."
  template <- "[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
  data <- list(value = "yes")

  partials <- list(include = ".{{value}}.")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "[ .yes. ]\n[ .yes. ]\n", label=deparse(str), info="Delimiters set in a parent template should not affect a partial.")
})

test_that( "Post-Partial Behavior", {
  #"Delimiters set in a partial should not affect the parent template."
  template <- "[ {{>include}} ]\n[ .{{value}}.  .|value|. ]\n"
  data <- list(value = "yes")

  partials <- list(include = ".{{value}}. {{= | | =}} .|value|.")
  str <- whisker.render(template, partials=partials, data=data)
  
  expect_equal(str, "[ .yes.  .yes. ]\n[ .yes.  .|value|. ]\n", label=deparse(str), info="Delimiters set in a partial should not affect the parent template.")
})

test_that( "Surrounding Whitespace", {
  #"Surrounding whitespace should be left untouched."
  template <- "| {{=@ @=}} |"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|  |", label=deparse(str), info="Surrounding whitespace should be left untouched.")
})

test_that( "Outlying Whitespace (Inline)", {
  #"Whitespace should be left untouched."
  template <- " | {{=@ @=}}\n"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " | \n", label=deparse(str), info="Whitespace should be left untouched.")
})

test_that( "Standalone Tag", {
  #"Standalone lines should be removed from the template."
  template <- "Begin.\n{{=@ @=}}\nEnd.\n"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "Begin.\nEnd.\n", label=deparse(str), info="Standalone lines should be removed from the template.")
})

test_that( "Indented Standalone Tag", {
  #"Indented standalone lines should be removed from the template."
  template <- "Begin.\n  {{=@ @=}}\nEnd.\n"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "Begin.\nEnd.\n", label=deparse(str), info="Indented standalone lines should be removed from the template.")
})

test_that( "Standalone Line Endings", {
  #"\"\\r\\n\" should be considered a newline for standalone tags."
  template <- "|\r\n{{= @ @ =}}\r\n|"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|\r\n|", label=deparse(str), info="\"\\r\\n\" should be considered a newline for standalone tags.")
})

test_that( "Standalone Without Previous Line", {
  #"Standalone tags should not require a newline to precede them."
  template <- "  {{=@ @=}}\n="
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "=", label=deparse(str), info="Standalone tags should not require a newline to precede them.")
})

test_that( "Standalone Without Newline", {
  #"Standalone tags should not require a newline to follow them."
  template <- "=\n  {{=@ @=}}"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "=\n", label=deparse(str), info="Standalone tags should not require a newline to follow them.")
})

test_that( "Pair with Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{= @   @ =}}|"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "||", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

