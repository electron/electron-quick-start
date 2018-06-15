library(circlepackeR)
context("basic functionality")

test_that("accepts json input", {
  expect_that(circlepackeR("http://bl.ocks.org/mbostock/raw/7607535/flare.json"),
              is_a("circlepackeR"))
})

test_that("accepts hierarchical list input", {
  hierarchical_list <- list(name = "World",
    children = list(
      list(name = "North America",
           children = list(
             list(name = "United States", size = 308865000),
             list(name = "Mexico", size = 107550697),
             list(name = "Canada", size = 34033000))),
      list(name = "South America",
           children = list(
             list(name = "Brazil", size = 192612000),
             list(name = "Colombia", size = 45349000),
             list(name = "Argentina", size = 40134425))),
      list(name = "Europe",
           children = list(
             list(name = "Germany", size = 81757600),
             list(name = "France", size = 65447374),
             list(name = "United Kingdom", size = 62041708))),
      list(name = "Africa",
           children = list(
             list(name = "Nigeria", size = 154729000),
             list(name = "Ethiopia", size = 79221000),
             list(name = "Egypt", size = 77979000))),
      list(name = "Asia",
           children = list(
             list(name = "China", size = 1336335000),
             list(name = "India", size = 1178225000),
             list(name = "Indonesia", size = 231369500)))
    )
  )
  expect_that(circlepackeR(hierarchical_list), is_a("circlepackeR"))
})

test_that("accepts data.tree input", {
  library(data.tree)
  data(acme)
  expect_that(circlepackeR(acme, size = "cost"), is_a("circlepackeR"))
})

test_that("can change color range", {
  library(data.tree)
  data(acme)
  expect_that(circlepackeR(acme, size = "cost", color_min = "hsl(56,80%,80%)",
                           "hsl(341,30%,40%)"), is_a("circlepackeR"))
})
