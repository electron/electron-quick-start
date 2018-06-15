# Create testthat test from the specification file for Mustache, so it can be
# tested if lives up to the specification
# 
# Please note:
# * You'll need rjson for reading the specifications
# * an installed whisker, because that is used for the generation of the test 
#   (eat your own dog food...)

library(rjson)
library(whisker)

header <- 
"# Automatically generated from specification file: '{{file}}'
#
{{overview}}
library(testthat)
context('Spec v1.1, {{type}}')
"
testtemplate <- 
"test_that( {{&name}}, {
  #{{&desc}}
  template <- {{&template}}
  data <- {{&data}}

{{#partials}}
  partials <- {{&partials}}
  str <- whisker.render(template, partials=partials, data=data)
{{/partials}}
{{^partials}}
  str <- whisker.render(template, data=data)
{{/partials}}
  
  expect_equal(str, {{&expected}}, label=deparse(str), info={{&desc}})
})
"

convertToTest <- function(files){
  for (json in files){
    writeSpec(json)
  }
}

writeSpec <- function(file){
  outfile <- gsub("^(.+).json", "../tests/test\\1.R", file)
  spec <- fromJSON(file=file)
  con <- file(outfile, open="wt")
  on.exit(close(con))
  
  spec$file <- file
  spec$overview <- gsub("(^|\n)", "\\1# ", spec$overview)
  spec$type <- gsub(".json", "", file)

  writeLines(whisker.render(header, data=spec), con) 
  test <- sapply(spec$test, writeTest)
  writeLines(test, con)
}

writeTest <- function(test){
  test <- lapply(test, deparse, control=c("keepNA"))  
  test$data <- paste(test$data, collapse="\n")
  whisker.render(testtemplate, data=test)
}

spec <- c( "interpolation.json"
         , "comments.json"
         , "inverted.json"
         , "sections.json"
         , "partials.json"
         , "delimiters.json"
         #, "lambdas.json"
         )
convertToTest(spec)