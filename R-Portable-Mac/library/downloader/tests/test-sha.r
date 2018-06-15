context("sha")

test_that('sha_url', {
  # Create a temp file with simple R code
  temp_file <- tempfile()
  str <- 'a <<- a + 1'

  # Write str it to a file
  writeLines(str, sep = '', con = temp_file)
  url <- paste('file://', temp_file, sep = '')

  # Compare result from sha_url() to result directly from digest()
  expect_equal(sha_url(url), digest(str, algo = 'sha1', serialize = FALSE))
})


test_that('Check SHA hash with source_url', {

  # Create a temp file with simple R code
  temp_file <- tempfile()
  writeLines('a <<- a + 1', con = temp_file)
  url <- paste('file://', temp_file, sep = '')

  # Calculate the correct and incorrect SHA
  right_sha <- sha_url(url)
  wrong_sha <- '0000000000000000000000000000000000000000'

  # Counter - should be incremented by the code in the URL, which is a <<- a + 1
  .GlobalEnv$a <- 0

  # There are a total of 2x3x2=12 conditions, but we don't need to test them all

  # prompt=TRUE, right SHA, quiet=FALSE: print message
  expect_message(source_url(url, sha = right_sha), 'matches expected')
  expect_equal(a, 1)

  # prompt=TRUE, wrong SHA, quiet=FALSE: error
  expect_error(source_url(url, sha = wrong_sha))
  expect_equal(a, 1)

  # prompt=TRUE, no SHA, quiet=FALSE: should prompt and respond to y/n
  # (no way to automatically test this)
  #source_url(url)

  # prompt=FALSE, no SHA, quiet=FALSE: do it, with message about not checking
  expect_message(source_url(url, prompt = FALSE), 'Not checking')
  expect_equal(a, 2)

  # prompt=FALSE, right SHA, quiet=FALSE: should just do it, with message about match
  expect_message(source_url(url, sha = right_sha, prompt = FALSE), 'matches expected')
  expect_equal(a, 3)

  # prompt=FALSE, wrong SHA, quiet=FALSE: should error
  expect_error(source_url(url, sha = wrong_sha, prompt = FALSE))
  expect_equal(a, 3)

  # prompt=FALSE, no SHA, quiet=TRUE: should just do it, with no message about not checking
  source_url(url, prompt = FALSE, quiet = TRUE)
  expect_equal(a, 4)

  # prompt=FALSE, right SHA, quiet=TRUE: should just do it, with no message
  source_url(url, sha = right_sha, prompt = FALSE, quiet = TRUE)
  expect_equal(a, 5)
})
