context("yaml.load_file")

test_that("reading from a connection works", {
  cat("foo: 123", file="files/foo.yml", sep="\n")
  foo <- file('files/foo.yml', 'r')
  x <- yaml.load_file(foo)
  close(foo)
  unlink("files/foo.yml")
  expect_equal(123L, x$foo)
})

test_that("reading from specified filename works", {
  cat("foo: 123", file="files/foo.yml", sep="\n")
  x <- yaml.load_file('files/foo.yml')
  unlink("files/foo.yml")
  expect_equal(123L, x$foo)
})

test_that("reading a complicated document works", {
  x <- yaml.load_file('files/test.yml')
})
