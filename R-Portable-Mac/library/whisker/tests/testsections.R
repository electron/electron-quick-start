# Automatically generated from specification file: 'sections.json'
#
# Section tags and End Section tags are used in combination to wrap a section
# of the template for iteration
# 
# These tags' content MUST be a non-whitespace character sequence NOT
# containing the current closing delimiter; each Section tag MUST be followed
# by an End Section tag with the same content within the same section.
# 
# This tag's content names the data to replace the tag.  Name resolution is as
# follows:
#   1) Split the name on periods; the first part is the name to resolve, any
#   remaining parts should be retained.
#   2) Walk the context stack from top to bottom, finding the first context
#   that is a) a hash containing the name as a key OR b) an object responding
#   to a method with the given name.
#   3) If the context is a hash, the data is the value associated with the
#   name.
#   4) If the context is an object and the method with the given name has an
#   arity of 1, the method SHOULD be called with a String containing the
#   unprocessed contents of the sections; the data is the value returned.
#   5) Otherwise, the data is the value returned by calling the method with
#   the given name.
#   6) If any name parts were retained in step 1, each should be resolved
#   against a context stack containing only the result from the former
#   resolution.  If any part fails resolution, the result should be considered
#   falsey, and should interpolate as the empty string.
# If the data is not of a list type, it is coerced into a list as follows: if
# the data is truthy (e.g. `!!data == true`), use a single-element list
# containing the data, otherwise use an empty list.
# 
# For each element in the data list, the element MUST be pushed onto the
# context stack, the section MUST be rendered, and the element MUST be popped
# off the context stack.
# 
# Section and End Section tags SHOULD be treated as standalone when
# appropriate.
# 
library(testthat)
context('Spec v1.1, sections')

test_that( "Truthy", {
  #"Truthy sections should have their contents rendered."
  template <- "\"{{#boolean}}This should be rendered.{{/boolean}}\""
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"This should be rendered.\"", label=deparse(str), info="Truthy sections should have their contents rendered.")
})

test_that( "Falsey", {
  #"Falsey sections should have their contents omitted."
  template <- "\"{{#boolean}}This should not be rendered.{{/boolean}}\""
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\"", label=deparse(str), info="Falsey sections should have their contents omitted.")
})

test_that( "Context", {
  #"Objects and hashes should be pushed onto the context stack."
  template <- "\"{{#context}}Hi {{name}}.{{/context}}\""
  data <- list(context = list(name = "Joe"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Hi Joe.\"", label=deparse(str), info="Objects and hashes should be pushed onto the context stack.")
})

test_that( "Deeply Nested Contexts", {
  #"All elements on the context stack should be accessible."
  template <- "{{#a}}\n{{one}}\n{{#b}}\n{{one}}{{two}}{{one}}\n{{#c}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{#d}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{#e}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{/e}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{/d}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{/c}}\n{{one}}{{two}}{{one}}\n{{/b}}\n{{one}}\n{{/a}}\n"
  data <- list(a = list(one = 1), b = list(two = 2), c = list(three = 3), 
    d = list(four = 4), e = list(five = 5))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "1\n121\n12321\n1234321\n123454321\n1234321\n12321\n121\n1\n", label=deparse(str), info="All elements on the context stack should be accessible.")
})

test_that( "List", {
  #"Lists should be iterated; list items should visit the context stack."
  template <- "\"{{#list}}{{item}}{{/list}}\""
  data <- list(list = list(list(item = 1), list(item = 2), list(item = 3)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"123\"", label=deparse(str), info="Lists should be iterated; list items should visit the context stack.")
})

test_that( "Empty List", {
  #"Empty lists should behave like falsey values."
  template <- "\"{{#list}}Yay lists!{{/list}}\""
  data <- list(list = list())


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\"", label=deparse(str), info="Empty lists should behave like falsey values.")
})

test_that( "Doubled", {
  #"Multiple sections per template should be permitted."
  template <- "{{#bool}}\n* first\n{{/bool}}\n* {{two}}\n{{#bool}}\n* third\n{{/bool}}\n"
  data <- list(two = "second", bool = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "* first\n* second\n* third\n", label=deparse(str), info="Multiple sections per template should be permitted.")
})

test_that( "Nested (Truthy)", {
  #"Nested truthy sections should have their contents rendered."
  template <- "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
  data <- list(bool = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| A B C D E |", label=deparse(str), info="Nested truthy sections should have their contents rendered.")
})

test_that( "Nested (Falsey)", {
  #"Nested falsey sections should be omitted."
  template <- "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
  data <- list(bool = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| A  E |", label=deparse(str), info="Nested falsey sections should be omitted.")
})

test_that( "Context Misses", {
  #"Failed context lookups should be considered falsey."
  template <- "[{{#missing}}Found key 'missing'!{{/missing}}]"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "[]", label=deparse(str), info="Failed context lookups should be considered falsey.")
})

test_that( "Implicit Iterator - String", {
  #"Implicit iterators should directly interpolate strings."
  template <- "\"{{#list}}({{.}}){{/list}}\""
  data <- list(list = c("a", "b", "c", "d", "e"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"(a)(b)(c)(d)(e)\"", label=deparse(str), info="Implicit iterators should directly interpolate strings.")
})

test_that( "Implicit Iterator - Integer", {
  #"Implicit iterators should cast integers to strings and interpolate."
  template <- "\"{{#list}}({{.}}){{/list}}\""
  data <- list(list = c(1, 2, 3, 4, 5))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"(1)(2)(3)(4)(5)\"", label=deparse(str), info="Implicit iterators should cast integers to strings and interpolate.")
})

test_that( "Implicit Iterator - Decimal", {
  #"Implicit iterators should cast decimals to strings and interpolate."
  template <- "\"{{#list}}({{.}}){{/list}}\""
  data <- list(list = c(1.1, 2.2, 3.3, 4.4, 5.5))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"(1.1)(2.2)(3.3)(4.4)(5.5)\"", label=deparse(str), info="Implicit iterators should cast decimals to strings and interpolate.")
})

test_that( "Dotted Names - Truthy", {
  #"Dotted names should be valid for Section tags."
  template <- "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"Here\""
  data <- list(a = list(b = list(c = TRUE)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Here\" == \"Here\"", label=deparse(str), info="Dotted names should be valid for Section tags.")
})

test_that( "Dotted Names - Falsey", {
  #"Dotted names should be valid for Section tags."
  template <- "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\""
  data <- list(a = list(b = list(c = FALSE)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\" == \"\"", label=deparse(str), info="Dotted names should be valid for Section tags.")
})

test_that( "Dotted Names - Broken Chains", {
  #"Dotted names that cannot be resolved should be considered falsey."
  template <- "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\""
  data <- list(a = list())


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\" == \"\"", label=deparse(str), info="Dotted names that cannot be resolved should be considered falsey.")
})

test_that( "Surrounding Whitespace", {
  #"Sections should not alter surrounding whitespace."
  template <- " | {{#boolean}}\t|\t{{/boolean}} | \n"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " | \t|\t | \n", label=deparse(str), info="Sections should not alter surrounding whitespace.")
})

test_that( "Internal Whitespace", {
  #"Sections should not alter internal whitespace."
  template <- " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " |  \n  | \n", label=deparse(str), info="Sections should not alter internal whitespace.")
})

test_that( "Indented Inline Sections", {
  #"Single-line sections should not alter surrounding whitespace."
  template <- " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " YES\n GOOD\n", label=deparse(str), info="Single-line sections should not alter surrounding whitespace.")
})

test_that( "Standalone Lines", {
  #"Standalone lines should be removed from the template."
  template <- "| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line\n"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| This Is\n|\n| A Line\n", label=deparse(str), info="Standalone lines should be removed from the template.")
})

test_that( "Indented Standalone Lines", {
  #"Indented standalone lines should be removed from the template."
  template <- "| This Is\n  {{#boolean}}\n|\n  {{/boolean}}\n| A Line\n"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| This Is\n|\n| A Line\n", label=deparse(str), info="Indented standalone lines should be removed from the template.")
})

test_that( "Standalone Line Endings", {
  #"\"\\r\\n\" should be considered a newline for standalone tags."
  template <- "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|\r\n|", label=deparse(str), info="\"\\r\\n\" should be considered a newline for standalone tags.")
})

test_that( "Standalone Without Previous Line", {
  #"Standalone tags should not require a newline to precede them."
  template <- "  {{#boolean}}\n#{{/boolean}}\n/"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "#\n/", label=deparse(str), info="Standalone tags should not require a newline to precede them.")
})

test_that( "Standalone Without Newline", {
  #"Standalone tags should not require a newline to follow them."
  template <- "#{{#boolean}}\n/\n  {{/boolean}}"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "#\n/\n", label=deparse(str), info="Standalone tags should not require a newline to follow them.")
})

test_that( "Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{# boolean }}={{/ boolean }}|"
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|=|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

