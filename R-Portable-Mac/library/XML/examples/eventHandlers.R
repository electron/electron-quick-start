characterOnlyHandler <- function() {
  txt <- NULL
  text <- function(val,...) {
    txt <<- c(txt, val)
  }

  getText <- function() { txt }

  return(list(text=text, getText=getText))
}
