app <- function(env){
    req <- Request$new(env)
    res <- Response$new()
    getVars <- req$GET()
    postVars <- req$POST()

    content <- c("<!DOCTYPE html>\n",
      "<html>\n<head>\n<title>Rook Array Parameters</title>\n</head>\n",
      "<body>\n<h1>Rook Array Parameters</h1>\n",
      "<h2>GET request</h2>\n<form>\n<p>\n",
      "<label><input type='checkbox' name='foo[]' value='foo' /> foo</label>\n",
      "<label><input type='checkbox' name='foo[]' value='bar' /> bar</label>\n",
      "</p>\n<p>\n<input type='submit' name='get' />\n</p>\n</form>\n")

    if (length(getVars) > 0) {
      content <- c(content,
        "<pre>\n",
        paste(capture.output(str(getVars), file=NULL), collapse='\n'),
        "</pre>\n")
    }

    content <- c(content,
      "<h2>POST request</h2>\n<form method='post'>\n<p>\n",
      "<label><input type='checkbox' name='foo[]' value='foo' /> foo</label>\n",
      "<label><input type='checkbox' name='foo[]' value='bar' /> bar</label>\n",
      "</p>\n<p>\n<input type='submit' name='post' />\n</p>\n</form>\n")

    if (length(postVars) > 0 && 'post' %in% names(postVars)) {
      content <- c(content,
        "<pre>\n",
        paste(capture.output(str(postVars), file=NULL), collapse='\n'),
        "</pre>\n")
    }

    content <- c(content,
      "<h2>POST multipart request</h2>\n<form method='post' enctype='multipart/form-data'>\n<p>\n",
      "<label><input type='checkbox' name='foo[]' value='foo' /> foo</label>\n",
      "<label><input type='checkbox' name='foo[]' value='bar' /> bar</label>\n",
      "</p>\n<p>\n<input type='submit' name='multipart' />\n</p>\n</form>\n")

    if (length(postVars) > 0 && 'multipart' %in% names(postVars)) {
      content <- c(content,
        "<pre>\n",
        paste(capture.output(str(postVars), file=NULL), collapse='\n'),
        "</pre>\n")
    }

    res$write(c(content, "</body>\n</html>\n"))
    res$finish()
}
