context("as.yaml")

test_that("named list is converted", {
  expect_equal("foo: bar\n", as.yaml(list(foo="bar")))

  x <- list(foo=1:10, bar=c("junk", "test"))
  y <- yaml.load(as.yaml(x))
  expect_equal(y$foo, x$foo)
  expect_equal(y$bar, x$bar)

  x <- list(foo=1:10, bar=list(foo=11:20, bar=letters[1:10]))
  y <- yaml.load(as.yaml(x))
  expect_equal(x$foo, y$foo)
  expect_equal(x$bar$foo, y$bar$foo)
  expect_equal(x$bar$bar, y$bar$bar)

  # nested lists
  x <- list(foo = list(a = 1, b = 2), bar = list(b = 4))
  y <- yaml.load(as.yaml(x))
  expect_equal(x$foo$a, y$foo$a)
  expect_equal(x$foo$b, y$foo$b)
  expect_equal(x$bar$b, y$bar$b)
})

test_that("data frame is converted", {
  x <- data.frame(a=1:10, b=letters[1:10], c=11:20)
  y <- as.data.frame(yaml.load(as.yaml(x)))
  expect_equal(x$a, y$a)
  expect_equal(x$b, y$b)
  expect_equal(x$c, y$c)

  x <- as.yaml(x, column.major = FALSE)
  y <- yaml.load(x)
  expect_equal(5L,  y[[5]]$a)
  expect_equal("e", y[[5]]$b)
  expect_equal(15L, y[[5]]$c)
})

test_that("empty nested list is converted", {
  x <- list(foo=list())
  expect_equal("foo: []\n", as.yaml(x))
})

test_that("empty nested data frame is converted", {
  x <- list(foo=data.frame())
  expect_equal("foo: {}\n", as.yaml(x))
})

test_that("empty nested vector is converted", {
  x <- list(foo=character())
  expect_equal("foo: []\n", as.yaml(x))
})

test_that("list is converted as omap", {
  x <- list(a=1:2, b=3:4)
  expected <- "!omap\n- a:\n  - 1\n  - 2\n- b:\n  - 3\n  - 4\n"
  expect_equal(expected, as.yaml(x, omap=TRUE))
})

test_that("nested list is converted as omap", {
  x <- list(a=list(c=list(e=1L, f=2L)), b=list(d=list(g=3L, h=4L)))
  expected <- "!omap\n- a: !omap\n  - c: !omap\n    - e: 1\n    - f: 2\n- b: !omap\n  - d: !omap\n    - g: 3\n    - h: 4\n"
  expect_equal(expected, as.yaml(x, omap=TRUE))
})

test_that("omap is loaded", {
  x <- yaml.load(as.yaml(list(a=1:2, b=3:4, c=5:6, d=7:8), omap=TRUE))
  expect_equal(c("a", "b", "c", "d"), names(x))
})

test_that("numeric is converted correctly", {
  result <- as.yaml(c(1, 5, 10, 15))
  expect_equal(result, "- 1.0\n- 5.0\n- 10.0\n- 15.0\n", label = result)
})

test_that("multiline string is converted", {
  expect_equal("|-\n  foo\n  bar\n", as.yaml("foo\nbar"))
  expect_equal("- foo\n- |-\n  bar\n  baz\n", as.yaml(c("foo", "bar\nbaz")))
  expect_equal("foo: |-\n  foo\n  bar\n", as.yaml(list(foo = "foo\nbar")))
  expect_equal("a:\n- foo\n- bar\n- |-\n  baz\n  quux\n", as.yaml(data.frame(a = c('foo', 'bar', 'baz\nquux'))))
})

test_that("function is converted", {
  x <- function() { runif(100) }
  expected <- "!expr |\n  function ()\n  {\n      runif(100)\n  }\n"
  result <- as.yaml(x)
  expect_equal(expected, result)
})

test_that("list with unnamed items is converted", {
  x <- list(foo=list(list(a = 1L, b = 2L), list(a = 3L, b = 4L)))
  expected <- "foo:
- a: 1
  b: 2
- a: 3
  b: 4
"
  result <- as.yaml(x)
  expect_equal(result, expected)
})

test_that("pound signs are escaped in strings", {
  result <- as.yaml("foo # bar")
  expect_equal("'foo # bar'\n", result)
})

test_that("NULL is converted", {
  expect_equal("~\n...\n", as.yaml(NULL))
})

test_that("different line seps are used", {
  result <- as.yaml(c('foo', 'bar'), line.sep = "\n")
  expect_equal("- foo\n- bar\n", result)

  result <- as.yaml(c('foo', 'bar'), line.sep = "\r\n")
  expect_equal("- foo\r\n- bar\r\n", result)

  result <- as.yaml(c('foo', 'bar'), line.sep = "\r")
  expect_equal("- foo\r- bar\r", result)
})

test_that("custom indent is used", {
  result <- as.yaml(list(foo=list(bar=list('foo', 'bar'))), indent = 3)
  expect_equal("foo:\n   bar:\n   - foo\n   - bar\n", result)
})

test_that("block sequences in mapping context are indented when indent.mapping.sequence is TRUE", {
  result <- as.yaml(list(foo=list(bar=list('foo', 'bar'))), indent.mapping.sequence = TRUE)
  expect_equal("foo:\n  bar:\n    - foo\n    - bar\n", result)
})

test_that("indent value is validated", {
  expect_that(as.yaml(list(foo=list(bar=list('foo', 'bar'))), indent = 0),
    throws_error())
})

test_that("strings are escaped properly", {
  result <- as.yaml("12345")
  expect_equal("'12345'\n", result)
})

test_that("unicode strings are not escaped", {
  x <- list('име' = 'Александар', 'презиме' = 'Благотић')
  result <- as.yaml(x, unicode = TRUE)
  expect_equal("име: Александар\nпрезиме: Благотић\n", result, label = result)
})

test_that("unicode strings are escaped", {
  x <- 'é'
  result <- as.yaml(x, unicode = FALSE)
  expect_equal("\"\\xE9\"\n", result, expected.label = result)
})

test_that("unknown objects cause error", {
  expect_that(as.yaml(expression(foo <- bar)), throws_error())
})

test_that("Inf is emitted properly", {
  result <- as.yaml(Inf)
  expect_equal(".inf\n...\n", result, expected.label = result)
})

test_that("-Inf is emitted properly", {
  result <- as.yaml(-Inf)
  expect_equal("-.inf\n...\n", result, expected.label = result)
})

test_that("NaN is emitted properly", {
  result <- as.yaml(NaN)
  expect_equal(".nan\n...\n", result, expected.label = result)
})

test_that("NA (logical) is emitted properly", {
  result <- as.yaml(NA)
  expect_equal(".na\n...\n", result, expected.label = result)
})

test_that("NA (numeric) is emitted properly", {
  result <- as.yaml(NA_real_)
  expect_equal(".na.real\n...\n", result, expected.label = result)
})

test_that("NA (integer) is emitted properly", {
  result <- as.yaml(NA_integer_)
  expect_equal(".na.integer\n...\n", result, expected.label = result)
})

test_that("NA (string) is emitted properly", {
  result <- as.yaml(NA_character_)
  expect_equal(".na.character\n...\n", result, expected.label = result)
})

test_that("TRUE is emitted properly", {
  result <- as.yaml(TRUE)
  expect_equal("yes\n...\n", result, expected.label = result)
})

test_that("FALSE is emitted properly", {
  result <- as.yaml(FALSE)
  expect_equal("no\n...\n", result, expected.label = result)
})

test_that("named list keys are escaped properly", {
  result <- as.yaml(list(n = 123))
  expect_equal("'n': 123.0\n", result, expected.label = result)
})

test_that("data frame keys are escaped properly when row major", {
  result <- as.yaml(data.frame(n=1:3), column.major = FALSE)
  expect_equal("- 'n': 1\n- 'n': 2\n- 'n': 3\n", result, expected.label = result)
})

test_that("scientific notation is valid YAML", {
  result <- as.yaml(10000000)
  expect_equal("1.0e+07\n...\n", result, expected.label = result)
})

test_that("precision must be in the range 1..22", {
  expect_that(as.yaml(12345, precision = -1),
    throws_error())
  expect_that(as.yaml(12345, precision = 0),
    throws_error())
  expect_that(as.yaml(12345, precision = 23),
    throws_error())
})

test_that("factor with NAs is emitted properly", {
  x <- factor('foo', levels=c('bar', 'baz'))
  result <- as.yaml(x)
  expect_equal(".na.character\n...\n", result, expected.label = result)
})
