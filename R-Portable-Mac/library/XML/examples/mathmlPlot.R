#
# Functions to illustrate how to convert a MathML tree
# to an R expression that can be used to annotate a plot 
# as an argument to plotmath.
#

#
# mchar
# mfrac
# !=, ==, <=, >=, etc.to the 
# sqrt,
# sub-, super-script [], ^
# times %*%
# %~~%
# %subset%, %subseteq%
# %supset%, %supseteq%
# %in%
# %notin%
# hat
# tilde
# group("(",list(a, b),"]")
# inf(S)

# sum(x[i],i==1,n)

#
# 
#
#

mathmlPlot <-
function(node)
{
 UseMethod("mathmlPlot",node)
}

mathmlPlot.XMLDocument <-
function(doc)
{
 return(mathmlPlot(doc$doc$children))
}

mathmlPlot.default <-
function(children)
{
  expr <- expression()
  i <- 1
  ok <- (i <= length(children))



  while(ok) {
#cat(i,"\n")
    child <- children[[i]]

   if(is.null(child)) {
       i <- i+1
       ok <- (i <= length(children))
       next
   }

    if(!is.null(class(child)) && class(child) == "XMLComment") {
       i <- i+1
       ok <- (i <= length(children))
       next
    }

#    if(inherits(child,"XMLNode")) {}
#if(is.null(class(child))) cat("Null child:",child,"\n")
     if(xmlName(child) == "mo") {
        op <- child$children[[1]]$value
        if(op == "sum") {
               # needs to get operand.
          tmp <- c(as.name(op), quote(x[i]),mathmlPlot(children[[i+1]]), mathmlPlot(children[[i+2]]))
          expr <- c(expr, tmp)
          i <- i+2
        } else {
          expr <- c(mathmlPlot(child), expr , mathmlPlot(children[[i+1]]))
        }

        mode(expr) <- "call"
        i <- i+1
     } else {
        expr <- c(expr, mathmlPlot(child))
     }

    i <- i+1
    ok <- (i <= length(children))
#cat(i,length(children),"\n")
  }

  return(expr)
}

mathmlPlot.XMLEntityRef <-
function(node)
{
  nm <- xmlName(node)

  val <- switch(nm,
           PlusMinus=as.name("%+-%"),
           InvisibleTimes=as.name("*"),
           int=as.name("integral"),
           infty = as.name("infinity"),
           NULL
          )

  if(is.null(val)) {
    val <- as.name(nm)
  }
    
  
 return(val)
}


mathmlPlot.XMLNode <-
function(node)
{
 nm <- name(node)

  if(nm == "mi" || nm == "ci") {
    val <- c(as.name("italic"),mathmlPlot(node$children))
    mode(val) <- "call"
  } else if(nm == "msqrt") {
     val <- c(as.name("sqrt"), mathmlPlot(node$children))
     mode(val) <- "call"
  } else if(nm == "msubsup") {
    tmp <- c(as.name("^"), mathmlPlot(node$children[[1]]),mathmlPlot(node$children[[2]]))
    mode(tmp) <- "call"
    val <- c(as.name("["), tmp, mathmlPlot(node$children[[3]]))
    mode(val) <- "call"
  } else if(nm == "mrow") {
    val <- mathmlPlot(node$children)
  } else if(nm == "text") {
    val <- node$value
  } else if(nm == "mo") {
    if(inherits(node$children[[1]],"XMLEntityRef"))
      val <- mathmlPlot(node$children[[1]])
    else {
      op <- node$children[[1]]$value
      tmp <- switch(op,
              "=" = "==",
              op)
      val <- as.name(tmp)
      
    }
  } else if(nm == "mfrac") {
    val <- list(as.name("frac"), mathmlPlot(node$children[[1]]), mathmlPlot(node$children[[2]]))
    mode(val) <- "call"
  } else if(nm == "msup" || nm == "msub") {
    op <- switch(nm, "msup" = "^", "msub"="[")
    val <- c(as.name(op), mathmlPlot(node$children[[1]]), mathmlPlot(node$children[[2]]))
    mode(val) <- "call"
  } else if(nm == "mn" || nm == "cn") {
     val <- as.numeric(node$children[[1]]$value)
  } else if(nm == "mstyle") {
    val <- mathmlPlot(node$children)
  } else if(nm == "munderover") {
    val <- mathmlPlot(node$children)
  } else if(nm == "mroot") {
    val <- c(as.name("sqrt"), mathmlPlot(node$children[[1]]), mathmlPlot(node$children[[2]]))
    mode(val) <- "call"
  } else if(nm == "reln") {
    val <- mathmlPlot(node$children)
    mode(val) <- "call"
  } else if(nm == "eq") {
    val <- as.name("==")
  } else if(nm == "geq") {
    val <- as.name(">=")
  } else if(nm == "set") {
       # This looks for a <condition> tag and takes 
       # everything before that as preceeding the `|'
    n <- min( (1:length(node$children))[sapply(node$children, xmlName) == "condition"])
cat("Condition @",n,"\n")
    args <- c(mathmlPlot(node$children[1:(n-1)]), "|", mathmlPlot(node$children[n:length(node$children)]))
    args <- c(as.name("paste"), args)
    mode(args) <- "call"
    val <- list(as.name("group"),"{", args,"}")
    mode(val) <- "call"
  } else if(nm == "bvar") {
    val <- mathmlPlot(node$children)
  } else if(nm == "condition") {
    val <- mathmlPlot(node$children)
  } else if(nm == "interval") {
     sep <- xmlAttrs(node)[["closure"]]
     sep <- switch(sep,
              open=c("(",")"),
              closed=c("[","]"),
              "closed-open"=c("[",")"),
              "open-closed"=c("(","]"),
            )
    els <- mathmlPlot(node$children)
    els <- c(as.name("paste"), els[[1]],",",els[[2]])
    mode(els) <- "call"
    val <- list(as.name("group"),sep[1], els ,sep[2])
    mode(val) <- "call"
  } else if(nm == "power") {
    val <- c(as.name("^"), mathmlPlot(node$children[[1]]), mathmlPlot(node$children[[2]]))
#    mode(val) <- "call"
  } else if(nm == "plus") {
     val <- as.name("+")
  } else if(nm == "apply") {
    val <- mathmlPlot.apply(node)
  }

 return(val)
}

mathmlPlot.apply <-
function(node)
{
  sub <- mathmlPlot(node$children)

  nm <- xmlName(node$children[[1]])
print(node$children[[1]])
  if(nm == "plus" || nm == "minus" || nm == "times" || nm == "div" ) {
print(sub[[1]])
    val <- c(mathmlPlot(node$children[[1]]), sub[[2]], sub[[3]])
    mode(val) <- "call"
    for(i in 4:length(sub)) {
     tmp <- c(mathmlPlot(node$children[[1]]), val, sub[[i]])
     mode(tmp) <- "call"
     val <- tmp
    }
  } else {
   val <- sub
   mode(val) <- "call"
  }

 return(val)
}

