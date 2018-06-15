writeXML <-
function(x, con, ...)
{
 UseMethod("writeXML")
}

writeXML.default <-
function(x, con, ...)
{

 if(length(class(x)) > 0)
   return(writeXML.object(x, con, ...))

 name <- paste("writeXML", typeof(x), sep=".")

 if(exists(name, mode="function")) {
   f <- get(name)
   f(x, con, ...)
 } else if(is.integer(x)) {
    lapply(x, function(i, con, ...) { con$addTag("integer", i); T} , con=con, ...)
 } else if(!is.na(match(mode(x), c("integer", "numeric", "character", "logical")))) {
    lapply(x, function(i, con, tag, ...) { con$addTag(tag, i); T} , con=con, tag=mode(x), ...)
 } else if(typeof(x) == "NULL") {
   con$addTag("null")
 } else
   stop(paste("No method for writeXML", typeof(x)))

}



writeXML.list <-
#
# Write the representation of an S list
# to the XML connection.
#
#
function(x, con,  ...)
{
 isNamed <- (length(names(x)) > 0)
 tag <- ifelse(isNamed, "namedlist", "list")

 con$addTag(tag, attrs=c(length=length(x)), close=F)
 for(i in 1:length(x)) {
   if(isNamed) {
    con$addTag("name", names(x)[i])
   }
    con$addTag("element", close=F)
       writeXML(x[[i]], con, ...)
    con$addEndTag("element")
 }

 con$addEndTag(tag)

 invisible(con)
}



writeXML.object <-
#
# Writes a general S3 object, i.e. one with a 
# non-null class() value. 
# This just writes out the names of the named
# elements of x. 
# Doesn't handle non-named lists yet
#
function(x, con, ...)
{
 classes <- class(x)
 con$addTag("object", attrs=c(type=classes[1]), close=F)
 for(i in names(x)) {
   con$addTag("slot", attrs=c(name=i), close=F)
    writeXML(x[[i]], con, ...)
   con$addEndTag("slot")
 }
   
 if(length(classes) > 1) {
   con$addTag("classes", attrs=c(length=length(classes)))
   sapply(classes, function(x, con, ...) {
                          con$addTag("class", x)
                       }, con, ...)
   con$addEndTag("classes")
 }

  con$addEndTag("object")

 invisible(con)
}



writeXML.closure <-
function(x, con, ...)
{
 is.missing.arg <- function(arg) typeof(arg) == "symbol" && deparse(arg) == ""
 args <- formals(x)
 con$addTag("function", close=F)
 con$addTag("args", attrs=c(length=length(args)), close=F)
 for(i in names(args)) {
   con$addTag("arg", attrs=c(name=i), close=F)
   if(!is.missing.arg(args[[i]])) {
     con$addTag("value", close=F)
     writeXML(args[[i]], con, ...)
     con$addEndTag("value")
   }
   con$addEndTag("arg")
 }
 con$addEndTag("args")

 b <- body(x)
 if(length(b) > 1)
    bodyLen <- length(body(x))-1
 else
    bodyLen <- 1

 con$addTag("body", attrs=c(length=bodyLen), close = F)
   writeXML(b, con, ...)
 con$addEndTag("body")
 con$addEndTag("function")

 invisible(con)
}

writeXML.language <-
function(x, con, ...)
{
 if(x[[1]] == "if") {
   writeXML.if(x, con, ...)
 } else if(x[[1]] == "{") {
   for(i in 2:length(x))
     writeXML(x[[i]], con, ...)
 } else if(x[[1]] == "for") {
   writeXML.for(x, con, ...)
 } else if(isLogicalExpression(x)) {
   writeXML.logicalExpr(x, con, ...)
 } else if(isComparator(x)) {
   writeXML.comparator(x, con, ...)
 } else if(x[[1]] == "while") {
   writeXML.while(x, con, ...)
 } else if(x[[1]] == "break" || x[[1]] == "next") {
   con$addTag(x[[1]])
 } else if(x[[1]] == "<-") {
   con$addTag("assign", close=F)
   writeXML(x[[2]], con, ...)
   writeXML(x[[3]], con, ...)
   con$addEndTag("assign")
 } else if(x[[1]] == "repeat") {
   con$addTag("repeat", close=F)
   writeXML(x[[2]], con, ...)
   con$addEndTag("repeat")
 } else if(x[[1]] == "return") {
   con$addTag("return", close=F)
    if(length(x) > 1)
     writeXML(x[[2]], con, ...)
   con$addEndTag("return")
 } else if(mode(x) == "call") {
   writeXML.call(x, con, ...)
 } 

 invisible(con)
}

writeXML.if <-
function(x, con, ...)
{
 con$addTag("if", close=F)
 
  con$addTag("cond", close=F)
    writeXML(x[[2]], con, ...)
  con$addEndTag("cond")
  if(length(x) > 2) {
    con$addTag("action", close=F)
     writeXML(x[[3]], con, ...)
    con$addEndTag("action")
  }
  if(length(x) == 4) {
    con$addTag("else", close=F)
     writeXML(x[[4]], con, ...)
    con$addEndTag("else")
  }

 con$addEndTag("if")

 invisible(con)
}


writeXML.for <-
function(x, con, ...)
{
 con$addTag("for", close=F)
 
  con$addTag("index", close=F)
    writeXML(x[[2]], con, ...)
  con$addEndTag("index")

  con$addTag("elements", close=F)
     writeXML(x[[3]], con, ...)
  con$addEndTag("elements")

   con$addTag("loop", close=F)
     writeXML(x[[4]], con, ...)
   con$addEndTag("loop")

 con$addEndTag("for")

 invisible(con)
}


writeXML.while <-
function(x, con, ...)
{

 con$addTag("while", attrs = c(doWhile= (x[[1]] == "do")), close=F)
 
  con$addTag("cond", close=F)
    writeXML(x[[2]], con, ...)
  con$addEndTag("cond")

  con$addTag("loop", close=F)
     writeXML(x[[3]], con, ...)
  con$addEndTag("loop")

 con$addEndTag("while")

 invisible(con)
}

writeXML.symbol <-
function(x, con, ...)
{
 con$addTag("symbol", as.character(x))
 invisible(con)
}

writeXML.call <-
function(x, con, ...)
{
  con$addTag("call", close=F)
   con$addTag("caller", close=F)
    writeXML(x[[1]], con, ...)
   con$addEndTag("caller")
     # Don't make this a x[2:length(x)]
     # or x[-1]. Infinite loop results.
   argNames <- names(x)

 if(length(x) > 1) {
   for(i in seq(2, length=length(x)-1)) {
    if(!is.null(argNames) && argNames[i] != "")
     con$addTag("namedArg", attrs=c(name=argNames[i]), close=F)

    writeXML(x[[i]], con, ...)

    if(!is.null(argNames) && argNames[i] != "")
     con$addEndTag("namedArg")
   }
 }
  con$addEndTag("call")

 invisible(call)
}


isLogicalExpression <-
function(x, ...)
{
  !is.na(match(as.character(x[[1]]), c("&", "&&", "|", "||")))
}


writeXML.logicalExpr <-
function(x, con, ...)
{
 logicalTags <- c("&" ="elementAnd", "&&"="logicalAnd", 
                  "|" ="elementOr", "||"="logicalOr") 

  tag <- logicalTags[as.character(x[[1]])]

  con$addTag(tag, close=F)

  writeXML(x[[2]], con, ...)
  writeXML(x[[3]], con, ...)

  con$addEndTag(tag)
}

isComparator <-
function(x, ...)
{
  !is.na(match(as.character(x[[1]]), c("<", ">", "<=", ">=", "==", "!=")))
}

writeXML.comparator <-
function(x, con, ...)
{
 logicalTags <- c("<" ="lessThan", ">"="greaterThan", 
                  "<=" = "lessThanEqual", ">="="greaterThanEqual",
                  "==" = "equal", "!=" = "notEqual") 

  tag <- logicalTags[as.character(x[[1]])]

  con$addTag(tag, close=F)

  writeXML(x[[2]], con, ...)
  writeXML(x[[3]], con, ...)

  con$addEndTag(tag) 
}

writeXML.builtin <-
#
# for primitives 
#
function(x, con, ...)
{
 con$addTag("builtin", attrs=c(name=getPrimitiveName(x)), close=F)
}


writeXML.special <-
#
# for primitives 
#
function(x, con, ...)
{
 con$addTag("special", attrs=c(name=getPrimitiveName(x)), close=F)
}


writeXML.environment <-
#
# for primitives 
#
function(x, con, ...)
{
 con$addTag("environment", attrs=c(name=getPrimitiveName(x)), close=F)
}



getPrimitiveName <-
function(obj)
{
 .Call("RXML_getPrimitiveName", obj)
}
