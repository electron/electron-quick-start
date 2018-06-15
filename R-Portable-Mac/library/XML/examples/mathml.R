#
# Functions to illustrate how to convert a MathML tree an 
# R expression.
#
#

mathml <-
# generic method that converts an XMLNode
# object to an R/S expression.
function(node)
{
  UseMethod("mathml", node)
}



mathml.XMLDocument <-
function(doc)
{
 return(mathml(doc$doc$children))
}

mathml.default <-
#
# Attempts to create an expression from the Math ML
# document tree given to it.
# This is an example using the mathml.xml and is not
# in any way intended to be a general MathML "interpreter"
# for R/S.
#
function(children)
{
  expr <- list()
  for(i in children) {
    if(class(i) == "XMLComment")
      next

    expr <- c(expr, mathml(i))
  }

 return(expr)
}


mergeMathML <-
#
# This takes a list of objects previously converted to R terms
# from MathML and aggregates them by collapsing elements
# such as 
#      term operator term
# into R calls.
#
# see mathml.XMLNode
#
function(els)
{
#cat("Merging",length(els));
#print(els)
 ans <- list() 
 more <- T
 ctr <- 1
 while(more) {
  i <- els[[ctr]]
   if(inherits(i, "MathMLOperator")) {
     ans <- c(i, ans, els[[ctr+1]])
     mode(ans) <- "call"
     ctr <- ctr + 1
   } else if(inherits(i,"MathMLGroup")) {
#print("MathMLGroup")
     ans <- c(ans, i)
     mode(ans) <- "call"
   } else
    ans <- c(ans, i)
  
  ctr <- ctr + 1
  more <- (ctr <= length(els))
 }
#cat("Merged: "); print(ans)
 return(ans)
}



mathml.XMLNode <-
#
# Interprets a MathML node and converts it
# to an R expression term. This handles tags
# such as mi, mo, mn, msup, mfrac, mrow, mfenced, 
# msqrt, mroot
#
# Other tags include:
#   msub
#   msubsup
#   munder
#   mover
#   munderover
#   mmultiscripts
#
#   mtable
#   mtr
#   mtd
#
#  set, interval, vector, matrix
#  cn
#  matrix, matrixrow
#  transpose


# Attributes for mfenced: open, close  "["

function(node)
{
 nm <- name(node)

 if(nm == "msup" || nm == "mfrac") {
   op <- switch(nm, msup="^", mfrac="/")
    a <- mathml(node$children[[1]])
    b <- mathml(node$children[[2]])
    expr <- list(as.name(op), a, b)
    mode(expr) <- "call"
    val <- expr
 } else if(nm == "mi" || nm == "ci") {
     # display in italics
   if(!is.null(node$children[[1]]$value))
     val <- as.name(node$children[[1]]$value)
 } else if(nm == "mo") {
    if(inherits(node$children[[1]],"XMLEntityRef")) {
      # node$children[[1]]$value   
      val <- as.name("*")
      class(val) <- "MathMLOperator"
    } else {
      # operator
    tmp <- node$children[[1]]$value
    if(!is.null(tmp)) {
      if(tmp == "=") {
          # or we could use "=="
          # to indicate equality, not assignment.
        tmp <- "<-" 
      }
      val <- as.name(tmp)
      class(val) <- "MathMLOperator"
    }
   }
 } else if(nm == "text") {
     val <- node$value
 } else if(nm == "matrix"){
    val <- mathml.matrix(node)
 } else if(nm == "vector"){
    val <- mathml.vector(node)
 } else if(nm == "mn"  || nm == "cn") {
       # number tag.
   if(!is.null(node$children[[1]]$value))
     val <- as.numeric(node$children[[1]]$value)
 } else if(nm == "mrow" || nm == "mfenced" || nm == "msqrt" || nm == "mroot") {
    # group of elements (displayed in a single row)
   ans <- vector("list", length(node$children))
   ctr <- 1
   for(i in node$children) {
    ans[[ctr]] <- mathml(i)
#cat(ctr,i$name,length(ans),"\n")
    ctr <- ctr + 1
   }

   ans <- mergeMathML(ans)

    # if this is an mfenced, msqrt or mroot element, add the 
    # enclosing parentheses or function call.
    #   ....
   if(nm == "msqrt") {
    ans <- c(as.name("sqrt"), ans)
    mode(ans) <- "call"
   } else if(nm == "mfenced") {
     class(ans) <- "MathMLGroup"
   }

   val <- ans
 } else if(nm == "reln") {
   val <- mathml(node$children)
   mode(val) <- "call"
 } else if(nm == "eq") {
    val <- as.name("==")
 } else if(nm == "apply") {
   val <- mathml(node$children)
cat("apply:",length(val),"\n")
print(val)

   mode(val) <- "call"
 } else if(nm == "times") {
   val <- as.name("%*%")
 } else if(nm == "transpose") {
   val <- as.name("t")
 }
 return(val)
}

mathml.matrix <-
#
#
#
#
function(node)
{
 m <- matrix(character(1), length(node$children), length(node$children[[1]]$children))
 i <- 1
 for(row in  node$children) {
  j <- 1
  for(cell in row$children) {
    tmp <- mathml(cell)
    m[i,j] <- as.character((tmp))
    j <- j + 1
  }
   i <- i + 1
 }

print(m)
 return(m)
}


mathml.vector <-
function(node)
{
 ans <- character(length(node$children))

 for(i in 1:length(node$children)) {
  tmp <- mathml(node$children[[i]])
  ans[i] <- as.character(tmp)
 }

print(ans)
 return(ans)
}
