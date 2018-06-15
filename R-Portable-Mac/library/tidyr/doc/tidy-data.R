## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
set.seed(1014)
options(dplyr.print_max = 10)

## ------------------------------------------------------------------------
preg <- read.csv("preg.csv", stringsAsFactors = FALSE)
preg

## ------------------------------------------------------------------------
read.csv("preg2.csv", stringsAsFactors = FALSE)

## ---- message = FALSE----------------------------------------------------
library(tidyr)
library(dplyr)
preg2 <- preg %>% 
  gather(treatment, n, treatmenta:treatmentb) %>%
  mutate(treatment = gsub("treatment", "", treatment)) %>%
  arrange(name, treatment)
preg2

## ------------------------------------------------------------------------
pew <- tbl_df(read.csv("pew.csv", stringsAsFactors = FALSE, check.names = FALSE))
pew

## ------------------------------------------------------------------------
pew %>%
  gather(income, frequency, -religion)

## ------------------------------------------------------------------------
billboard <- tbl_df(read.csv("billboard.csv", stringsAsFactors = FALSE))
billboard

## ------------------------------------------------------------------------
billboard2 <- billboard %>% 
  gather(week, rank, wk1:wk76, na.rm = TRUE)
billboard2

## ------------------------------------------------------------------------
billboard3 <- billboard2 %>%
  mutate(
    week = extract_numeric(week),
    date = as.Date(date.entered) + 7 * (week - 1)) %>%
  select(-date.entered)
billboard3

## ------------------------------------------------------------------------
billboard3 %>% arrange(artist, track, week)

## ------------------------------------------------------------------------
billboard3 %>% arrange(date, rank)

## ------------------------------------------------------------------------
tb <- tbl_df(read.csv("tb.csv", stringsAsFactors = FALSE))
tb

## ------------------------------------------------------------------------
tb2 <- tb %>% 
  gather(demo, n, -iso2, -year, na.rm = TRUE)
tb2

## ------------------------------------------------------------------------
tb3 <- tb2 %>% 
  separate(demo, c("sex", "age"), 1)
tb3

## ------------------------------------------------------------------------
weather <- tbl_df(read.csv("weather.csv", stringsAsFactors = FALSE))
weather

## ------------------------------------------------------------------------
weather2 <- weather %>%
  gather(day, value, d1:d31, na.rm = TRUE)
weather2

## ------------------------------------------------------------------------
weather3 <- weather2 %>% 
  mutate(day = extract_numeric(day)) %>%
  select(id, year, month, day, element, value) %>%
  arrange(id, year, month, day)
weather3

## ------------------------------------------------------------------------
weather3 %>% spread(element, value)

## ------------------------------------------------------------------------
song <- billboard3 %>% 
  select(artist, track, year, time) %>%
  unique() %>%
  mutate(song_id = row_number())
song

## ------------------------------------------------------------------------
rank <- billboard3 %>%
  left_join(song, c("artist", "track", "year", "time")) %>%
  select(song_id, date, week, rank) %>%
  arrange(song_id, date)
rank

## ---- eval = FALSE-------------------------------------------------------
#  library(purrr)
#  paths <- dir("data", pattern = "\\.csv$", full.names = TRUE)
#  names(paths) <- basename(paths)
#  map_dfr(paths, read.csv, stringsAsFactors = FALSE, .id = "filename")

