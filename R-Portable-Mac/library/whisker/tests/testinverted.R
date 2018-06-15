# Automatically generated from specification file: 'inverted.json'
#
# Inverted Section tags and End Section tags are used in combination to wrap a
# section of the template.
# 
# These tags' content MUST be a non-whitespace character sequence NOT
# containing the current closing delimiter; each Inverted Section tag MUST be
# followed by an End Section tag with the same content within the same
# section.
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
# This section MUST NOT be rendered unless the data list is empty.
# 
# Inverted Section and End Section tags SHOULD be treated as standalone when
# appropriate.
# 
library(testthat)
context('Spec v1.1, inverted')

test_that( "Falsey", {
  #"Falsey sections should have their contents rendered."
  template <- "\"{{^boolean}}This should be rendered.{{/boolean}}\""
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"This should be rendered.\"", label=deparse(str), info="Falsey sections should have their contents rendered.")
})

test_that( "Truthy", {
  #"Truthy sections should have their contents omitted."
  template <- "\"{{^boolean}}This should not be rendered.{{/boolean}}\""
  data <- list(boolean = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\"", label=deparse(str), info="Truthy sections should have their contents omitted.")
})

test_that( "Context", {
  #"Objects and hashes should behave like truthy values."
  template <- "\"{{^context}}Hi {{name}}.{{/context}}\""
  data <- list(context = list(name = "Joe"))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\"", label=deparse(str), info="Objects and hashes should behave like truthy values.")
})

test_that( "List", {
  #"Lists should behave like truthy values."
  template <- "\"{{^list}}{{n}}{{/list}}\""
  data <- list(list = list(list(n = 1), list(n = 2), list(n = 3)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\"", label=deparse(str), info="Lists should behave like truthy values.")
})

test_that( "Empty List", {
  #"Empty lists should behave like falsey values."
  template <- "\"{{^list}}Yay lists!{{/list}}\""
  data <- list(list = list())


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Yay lists!\"", label=deparse(str), info="Empty lists should behave like falsey values.")
})

test_that( "Doubled", {
  #"Multiple inverted sections per template should be permitted."
  template <- "{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
  data <- list(two = "second", bool = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "* first\n* second\n* third\n", label=deparse(str), info="Multiple inverted sections per template should be permitted.")
})

test_that( "Nested (Falsey)", {
  #"Nested falsey sections should have their contents rendered."
  template <- "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
  data <- list(bool = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| A B C D E |", label=deparse(str), info="Nested falsey sections should have their contents rendered.")
})

test_that( "Nested (Truthy)", {
  #"Nested truthy sections should be omitted."
  template <- "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
  data <- list(bool = TRUE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| A  E |", label=deparse(str), info="Nested truthy sections should be omitted.")
})

test_that( "Context Misses", {
  #"Failed context lookups should be considered falsey."
  template <- "[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
  data <- list()


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "[Cannot find key 'missing'!]", label=deparse(str), info="Failed context lookups should be considered falsey.")
})

test_that( "Dotted Names - Truthy", {
  #"Dotted names should be valid for Inverted Section tags."
  template <- "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"\""
  data <- list(a = list(b = list(c = TRUE)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"\" == \"\"", label=deparse(str), info="Dotted names should be valid for Inverted Section tags.")
})

test_that( "Dotted Names - Falsey", {
  #"Dotted names should be valid for Inverted Section tags."
  template <- "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
  data <- list(a = list(b = list(c = FALSE)))


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Not Here\" == \"Not Here\"", label=deparse(str), info="Dotted names should be valid for Inverted Section tags.")
})

test_that( "Dotted Names - Broken Chains", {
  #"Dotted names that cannot be resolved should be considered falsey."
  template <- "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
  data <- list(a = list())


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "\"Not Here\" == \"Not Here\"", label=deparse(str), info="Dotted names that cannot be resolved should be considered falsey.")
})

test_that( "Surrounding Whitespace", {
  #"Inverted sections should not alter surrounding whitespace."
  template <- " | {{^boolean}}\t|\t{{/boolean}} | \n"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " | \t|\t | \n", label=deparse(str), info="Inverted sections should not alter surrounding whitespace.")
})

test_that( "Internal Whitespace", {
  #"Inverted should not alter internal whitespace."
  template <- " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " |  \n  | \n", label=deparse(str), info="Inverted should not alter internal whitespace.")
})

test_that( "Indented Inline Sections", {
  #"Single-line sections should not alter surrounding whitespace."
  template <- " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, " NO\n WAY\n", label=deparse(str), info="Single-line sections should not alter surrounding whitespace.")
})

test_that( "Standalone Lines", {
  #"Standalone lines should be removed from the template."
  template <- "| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| This Is\n|\n| A Line\n", label=deparse(str), info="Standalone lines should be removed from the template.")
})

test_that( "Standalone Indented Lines", {
  #"Standalone indented lines should be removed from the template."
  template <- "| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "| This Is\n|\n| A Line\n", label=deparse(str), info="Standalone indented lines should be removed from the template.")
})

test_that( "Standalone Line Endings", {
  #"\"\\r\\n\" should be considered a newline for standalone tags."
  template <- "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|\r\n|", label=deparse(str), info="\"\\r\\n\" should be considered a newline for standalone tags.")
})

test_that( "Standalone Without Previous Line", {
  #"Standalone tags should not require a newline to precede them."
  template <- "  {{^boolean}}\n^{{/boolean}}\n/"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "^\n/", label=deparse(str), info="Standalone tags should not require a newline to precede them.")
})

test_that( "Standalone Without Newline", {
  #"Standalone tags should not require a newline to follow them."
  template <- "^{{^boolean}}\n/\n  {{/boolean}}"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "^\n/\n", label=deparse(str), info="Standalone tags should not require a newline to follow them.")
})

test_that( "Padding", {
  #"Superfluous in-tag whitespace should be ignored."
  template <- "|{{^ boolean }}={{/ boolean }}|"
  data <- list(boolean = FALSE)


  str <- whisker.render(template, data=data)
  
  expect_equal(str, "|=|", label=deparse(str), info="Superfluous in-tag whitespace should be ignored.")
})

