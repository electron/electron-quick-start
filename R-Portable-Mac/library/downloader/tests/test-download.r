context("download")

# Download from a url, and return the contents of the file as a string
download_result <- function(url) {
  tfile <- tempfile()
  download(url, tfile, mode = "wb")

  # Read the file
  tfile_fd <- file(tfile, "r")
  dl_text <- readLines(tfile_fd, warn = FALSE)
  dl_text <- paste(dl_text, collapse = "\n")
  close(tfile_fd)
  unlink(tfile)

  dl_text
}

# CRAN has intermittent problems with these tests, since they rely on a
# particular website being accessible. This makes it run with devtools::test()
# but not on CRAN
if (Sys.getenv('NOT_CRAN') == "true") {

test_that("downloading http and https works properly", {
  # Download http from httpbin.org
  result <- download_result("http://httpbin.org/ip")
  # Check that it has the string "origin" in the text
  expect_true(grepl("origin", result))

  # Download https from httpbin.org
  result <- download_result("https://httpbin.org/ip")
  # Check that it has the string "origin" in the text
  expect_true(grepl("origin", result))
})

test_that("follows redirects", {
  # Download http redirect from httpbin.org
  result <- download_result("http://httpbin.org/redirect/3")
  # Check that it has the string "origin" in the text
  expect_true(grepl("origin", result))

  # Download https redirect from httpbin.org
  result <- download_result("https://httpbin.org/redirect/3")
  # Check that it has the string "origin" in the text
  expect_true(grepl("origin", result))
})

}
