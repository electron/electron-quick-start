## ----echo = FALSE--------------------------------------------------------
library(magrittr)
library(xml2)
knitr::opts_chunk$set(echo = FALSE)
r <- rprojroot::is_r_package$make_fix_file()

## ----error=TRUE----------------------------------------------------------
rd_db <- tools::Rd_db(dir = r())

Links <- tools::findHTMLlinks()

html_topic <- function(name) {
  rd <- rd_db[[paste0(name, ".Rd")]]

  conn <- textConnection(NULL, "w")
  on.exit(close(conn))

  #tools::Rd2HTML(rd, conn, Links = Links)
  tools::Rd2HTML(rd, conn)

  textConnectionValue(conn)
}

xml_topic <- function(name, patcher) {
  html <- html_topic(name)
  x <- read_html(paste(html, collapse = "\n"))

  # No idea why this is necessary when embedding HTML in Markdown
  codes <- x %>% xml_find_all("//code[contains(., '$')]")
  xml_text(codes) <- gsub("[$]", "\\\\$", xml_text(codes))

  xx <- x %>% xml_find_first("/html/body")
  xx %>% xml_find_first("//table") %>% xml_remove()
  patcher(xx)
}

asis_topic <- function(name, patcher = identity) {
  xml <- lapply(name, xml_topic, patcher = patcher)
  asis <- sapply(xml, as.character) %>% paste(collapse = "\n")
  knitr::asis_output(asis)
}

patch_package_doc <- function(x) {
  x %>% xml_find_first("//h3") %>% xml_remove

  remove_see_also_section(x)
  remove_authors_section(x)

  x
}

move_contents_of_usage_section <- function(x) {
  # http://stackoverflow.com/a/3839299/946850
  usage_contents <-
    x %>%
    xml_find_all(
      "//h3[.='Usage']/following-sibling::node() [not(self::h3)] [count(preceding-sibling::h3)=2]")

  usage_text <-
    usage_contents %>%
    xml_find_first("//pre") %>% 
    xml_text

  h3 <- x %>% xml_find_first("//h3")

  intro_text <-
    read_xml(
      paste0(
        "<p>This section describes the behavior of the following method",
        if (length(grep("[(]", strsplit(usage_text, "\n")[[1]])) > 1) "s" else "",
        ":</p>")
    )

  xml_add_sibling(
    h3,
    intro_text,
    .where = "before")
  lapply(usage_contents, xml_add_sibling, .x = h3, .copy = FALSE, .where = "before")

  x %>% xml_find_first("//h3[.='Usage']") %>% xml_remove
  x
}

move_additional_arguments_section <- function(x) {
  # http://stackoverflow.com/a/3839299/946850 and some trial and error
  additional_arguments <- x %>%
    xml_find_all(
      "//h3[.='Additional arguments'] | //h3[.='Additional arguments']/following-sibling::node()[following-sibling::h3]")

  after_arg <- x %>% xml_find_first("//h3[text()='Arguments']/following-sibling::h3")

  lapply(additional_arguments, xml_add_sibling, .x = after_arg, .copy = FALSE, .where = "before")

  x
}

remove_see_also_section <- function(x) {
  # http://stackoverflow.com/a/3839299/946850 and some trial and error
  x %>%
    xml_find_all(
      "//h3[.='See Also'] | //h3[.='See Also']/following-sibling::node()[following-sibling::h3]") %>%
    xml_remove()
  x
}

remove_authors_section <- function(x) {
  # http://stackoverflow.com/a/3839299/946850 and some trial and error
  x %>%
    xml_find_all(
      "//h3[.='Author(s)'] | //h3[.='Author(s)']/following-sibling::node()[following-sibling::h3]") %>%
    xml_remove()
  x
}

patch_method_doc <- function(x) {
  move_contents_of_usage_section(x)
  remove_see_also_section(x)
  move_additional_arguments_section(x)
  x
}

asis_topic("DBI-package", patch_package_doc)
topics <- c(
  "dbDataType",
  "dbConnect",
  "dbDisconnect",
  "dbSendQuery",
  "dbFetch",
  "dbClearResult",
  "dbBind",
  "dbGetQuery",
  "dbSendStatement",
  "dbExecute",
  "dbQuoteString",
  "dbQuoteIdentifier",
  "dbReadTable",
  "dbWriteTable",
  "dbListTables",
  "dbExistsTable",
  "dbRemoveTable",
  "dbListFields",
  "dbIsValid",
  "dbHasCompleted",
  "dbGetStatement",
  "dbGetRowCount",
  "dbGetRowsAffected",
  "dbColumnInfo",
  "transactions",
  "dbWithTransaction"
)

asis_topic(topics, patch_method_doc)

