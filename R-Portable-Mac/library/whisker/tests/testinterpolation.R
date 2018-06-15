# Automatically generated from specification file: 'interpolation.json'
#
# Interpolation tags are used to integrate dynamic content into the template.
# 
# The tag's content MUST be a non-whitespace character sequence NOT containing
# the current closing delimiter.
# 
# This tag's content names the data to replace the tag.  A single period (`.`)
# indicates that the item currently sitting atop the context stack should be
# used; otherwise, name resolution is as follows:
#   1) Split the name on periods; the first part is the name to resolve, any
#   remaining parts should be retained.
#   2) Walk the context stack from top to bottom, finding the first context
#   that is a) a hash containing the name as a key OR b) an object responding
#   to a method with the given name.
#   3) If the context is a hash, the data is the value associated with the
#   name.
#   4) If the context is an object, the data is the value returned by the
#   method with the given name.
#   5) If any name parts were retained in step 1, each should be resolved
#   against a context stack containing only the result from the former
#   resolution.  If any part fails resolution, the result should be considered
#   falsey, and should interpolate as the empty string.
# Data should be coerced into a string (and escaped, if appropriate) before
# interpolation.
# 
# The Interpolation tags MUST NOT be treated as standalone.
# 
library(testthat)
context('Spec v1.1, interpolation')

test_that( "No Interpolation", {
  #"Mustache-free templates should render as-is."
  template <- "Hello from {Mustache}!\n"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "Hello from {Mustache}!\n", label=deparse(str), info="Mustache-free templates should render as-is.")
})

test_that( "Basic Interpolation", {
  #"Unadorned tags should interpolate content into the template."
  template <- "Hello, {{subject}}!\n"
  data <- list(subject = "world")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "Hello, world!\n", label=deparse(str), info="Unadorned tags should interpolate content into the template.")
})

test_that( "HTML Escaping", {
  #"Basic interpolation should be HTML escaped."
  template <- "These characters should be HTML escaped: {{forbidden}}\n"
  data <- list(forbidden = "& \" < >")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n", label=deparse(str), info="Basic interpolation should be HTML escaped.")
})

test_that( "Triple Mustache", {
  #"Triple mustaches should interpolate without HTML escaping."
  template <- "These characters should not be HTML escaped: {{{forbidden}}}\n"
  data <- list(forbidden = "& \" < >")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "These characters should not be HTML escaped: & \" < >\n", label=deparse(str), info="Triple mustaches should interpolate without HTML escaping.")
})

test_that( "Ampersand", {
  #"Ampersand should interpolate without HTML escaping."
  template <- "These characters should not be HTML escaped: {{&forbidden}}\n"
  data <- list(forbidden = "& \" < >")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "These characters should not be HTML escaped: & \" < >\n", label=deparse(str), info="Ampersand should interpolate without HTML escaping.")
})

test_that( "Basic Integer Interpolation", {
  #"Integers should interpolate seamlessly."
  template <- "\"{{mph}} miles an hour!\""
  data <- list(mph = 85)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"85 miles an hour!\"", label=deparse(str), info="Integers should interpolate seamlessly.")
})

test_that( "Triple Mustache Integer Interpolation", {
  #"Integers should interpolate seamlessly."
  template <- "\"{{{mph}}} miles an hour!\""
  data <- list(mph = 85)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"85 miles an hour!\"", label=deparse(str), info="Integers should interpolate seamlessly.")
})

test_that( "Ampersand Integer Interpolation", {
  #"Integers should interpolate seamlessly."
  template <- "\"{{&mph}} miles an hour!\""
  data <- list(mph = 85)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"85 miles an hour!\"", label=deparse(str), info="Integers should interpolate seamlessly.")
})

test_that( "Basic Decimal Interpolation", {
  #"Decimals should interpolate seamlessly with proper significance."
  template <- "\"{{power}} jiggawatts!\""
  data <- list(power = 1.21)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"1.21 jiggawatts!\"", label=deparse(str), info="Decimals should interpolate seamlessly with proper significance.")
})

test_that( "Triple Mustache Decimal Interpolation", {
  #"Decimals should interpolate seamlessly with proper significance."
  template <- "\"{{{power}}} jiggawatts!\""
  data <- list(power = 1.21)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"1.21 jiggawatts!\"", label=deparse(str), info="Decimals should interpolate seamlessly with proper significance.")
})

test_that( "Ampersand Decimal Interpolation", {
  #"Decimals should interpolate seamlessly with proper significance."
  template <- "\"{{&power}} jiggawatts!\""
  data <- list(power = 1.21)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"1.21 jiggawatts!\"", label=deparse(str), info="Decimals should interpolate seamlessly with proper significance.")
})

test_that( "Basic Context Miss Interpolation", {
  #"Failed context lookups should default to empty strings."
  template <- "I ({{cannot}}) be seen!"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "I () be seen!", label=deparse(str), info="Failed context lookups should default to empty strings.")
})

test_that( "Triple Mustache Context Miss Interpolation", {
  #"Failed context lookups should default to empty strings."
  template <- "I ({{{cannot}}}) be seen!"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "I () be seen!", label=deparse(str), info="Failed context lookups should default to empty strings.")
})

test_that( "Ampersand Context Miss Interpolation", {
  #"Failed context lookups should default to empty strings."
  template <- "I ({{&cannot}}) be seen!"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "I () be seen!", label=deparse(str), info="Failed context lookups should default to empty strings.")
})

test_that( "Dotted Names - Basic Interpolation", {
  #"Dotted names should be considered a form of shorthand for sections."
  template <- "\"{{person.name}}\" == \"{{#person}}{{name}}{{/person}}\""
  data <- list(person = list(name = "Joe"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Joe\" == \"Joe\"", label=deparse(str), info="Dotted names should be considered a form of shorthand for sections.")
})

test_that( "Dotted Names - Triple Mustache Interpolation", {
  #"Dotted names should be considered a form of shorthand for sections."
  template <- "\"{{{person.name}}}\" == \"{{#person}}{{{name}}}{{/person}}\""
  data <- list(person = list(name = "Joe"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Joe\" == \"Joe\"", label=deparse(str), info="Dotted names should be considered a form of shorthand for sections.")
})

test_that( "Dotted Names - Ampersand Interpolation", {
  #"Dotted names should be considered a form of shorthand for sections."
  template <- "\"{{&person.name}}\" == \"{{#person}}{{&name}}{{/person}}\""
  data <- list(person = list(name = "Joe"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Joe\" == \"Joe\"", label=deparse(str), info="Dotted names should be considered a form of shorthand for sections.")
})

test_that( "Dotted Names - Arbitrary Depth", {
  #"Dotted names should be functional to any level of nesting."
  template <- "\"{{a.b.c.d.e.name}}\" == \"Phil\""
  data <- list(a = list(b = list(c = list(d = list(e = list(name = "Phil"))))))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Phil\" == \"Phil\"", label=deparse(str), info="Dotted names should be functional to any level of nesting.")
})

test_that( "Dotted Names - Broken Chains", {
  #"Any falsey value prior to the last part of the name should yield ''."
  template <- "\"{{a.b.c}}\" == \"\""
  data <- list(a = list())


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\" == \"\"", label=deparse(str), info="Any falsey value prior to the last part of the name should yield ''.")
})

test_that( "Dotted Names - Broken Chain Resolution", {
  #"Each part of a dotted name should resolve only against its parent."
  template <- "\"{{a.b.c.name}}\" == \"\""
  data <- list(a = list(b = list()), c = list(name = "Jim"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\" == \"\"", label=deparse(str), info="Each part of a dotted name should resolve only against its parent.")
})

test_that( "Dotted Names - Initial Resolution", {
  #"The first part of a dotted name should resolve as any other name."
  template <- "\"{{#a}}{{b.c.d.e.name}}{{/a}}\" == \"Phil\""
  data <- list(a = list(b = list(c = list(d = list(e = list(name = "Phil"))))), 
    b = list(c = list(d = list(e = list(name = "Wrong")))))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Phil\" == \"Phil\"", label=deparse(str), info="The first part of a dotted name should resolve as any other name.")
})

test_that( "Interpolation - Surrounding Whitespace", {
  #"Interpolation should not alter surrounding whitespace."
  template <- "| {{string}} |"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| --- |", label=deparse(str), info="Interpolation should not alter surrounding whitespace.")
})

test_that( "Triple Mustache - Surrounding Whitespace", {
  #"Interpolation should not alter surrounding whitespace."
  template <- "| {{{string}}} |"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| --- |", label=deparse(str), info="Interpolation should not alter surrounding whitespace.")
})

test_that( "Ampersand - Surrounding Whitespace", {
  #"Interpolation should not alter surrounding whitespace."
  template <- "| {{&string}} |"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| --- |", label=deparse(str), info="Interpolation should not alter surrounding whitespace.")
})

test_that( "Interpolation - Standalone", {
  #"Standalone interpolation should not alter surrounding whitespace."
  template <- "  {{string}}\n"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "  ---\n", label=deparse(str), info="Standalone interpolation should not alter surrounding whitespace.")
})

test_that( "Triple Mustache - Standalone", {
  #"Standalone interpolation should not alter surrounding whitespace."
  template <- "  {{{string}}}\n"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "  ---\n", label=deparse(str), info="Standalone interpolation should not alter surrounding whitespace.")
})

test_that( "Ampersand - Standalone", {
  #"Standalone interpolation should not alter surrounding whitespace."
  template <- "  {{&string}}\n"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "  ---\n", label=deparse(str), info="Standalone interpolation should not alter surrounding whitespace.")
})

test_that( "Interpolation With Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{ string }}|"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|---|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

test_that( "Triple Mustache With Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{{ string }}}|"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|---|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

test_that( "Ampersand With Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{& string }}|"
  data <- list(string = "---")


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|---|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

