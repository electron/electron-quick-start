#
# An example of processing an SVG document
# See the example in the parallel directory data/svg.xml.
#
#
#  xmlplot <- xmlTreeParse("data/svg.xml")
#  x11()
#  svgRender(xmlplot)
#
# See also: mathml.R
#

#
# need support for the general SVG tags and attributes
#  desc
#  path
#  image

#  viewbox
#  stroke
#  transform matrix
#

svgRender <- 
function(doc)
{
 UseMethod("svgRender",doc)
}

svgRender.default <- 
function(doc)
{
  svgRender(doc$doc$children$svg)
}

svgRender.XMLNode <- 
#
# This processes an XML node assumed to come from an
# SVG document and either 
#  a) renders the corresponding element
#     and potentially recursively operates on its children, or
#  b) stores the settings specified in a group tag (<g> or <svg>)
#     for use in the processing of the sub-nodes.
#
#  This has basic support for circles, rectangles, polygons,
#  text 
#
function(top, settings = NULL) 
{
 if(is.null(settings)) {
   settings <- SVGSettings()
 }

 if(top$name == "svg") {
   dims <- top$attributes
   frame()
   par(usr=c(0, as.integer(dims[["width"]]) + 1, 0, as.integer(dims[["height"]])+1))
 } else if(top$name == "g") {
      if(!is.na(match("style", names(top$attributes)))) {
        settings$fill <- properties(top$attributes[["style"]])[["fill"]]
      }
 }
 
 for(i in top$children) {
  if(class(i) == "XMLComment")
    next
   ats <- i$attributes
   if(i$name == "rect") {
      
      if(!is.na(match("style", names(ats)))) {
        col <- properties(ats[["style"]])[["fill"]]
      } else {
         col <- settings$fill
      }

     rect(as.integer(ats[["x"]]), as.integer(ats[["y"]]), as.integer(ats[["x"]]) + as.integer(ats[["width"]]), as.integer(ats[["y"]]) + as.integer(ats[["width"]]), col = col)
   } else if(i$name == "text") {
       # need to gather up all the children in case the text 
       # is split into different components.
     val <- i$children[[1]]$value
     text(as.integer(ats[["x"]]), as.integer(ats[["y"]]), val, adj=1.0)
   } else if(i$name == "polygon") {
       # read the points attribute as a integer vector
     data <- scan.string(ats[["points"]])
     idx <- seq(1,length(data), by=2)
     x <- data[idx]
     y <- data[idx+1]

      if(!is.na(match("style", names(ats)))) {
        col <- properties(ats[["style"]])[["fill"]]
      } else {
        col <- settings$fill
      }

     polygon(x,y, col)
   } else if(i$name == "ellipse") {
      if(!is.na(match("style", names(ats)))) {
        col <- properties(ats[["style"]])[["fill"]]
      } else {
        col <- settings$fill
      }

     r <- min(as.integer(ats[["rx"]]), as.integer(ats[["ry"]]))
     symbols(as.integer(ats[["cx"]]), as.integer(ats[["cy"]]), circles=as.integer(r),inches=F, add=T)
   } else if(i$name == "g") {
      svgRender(i, settings)
   }
 }

 invisible(return(T))
}

SVGSettings <-
#
# This class of object is used for storing the
# "global" or currently active settings for within
# an SVG group. This includes things such as color
# fill style and color,  font, etc.
function()
{
  val <- list(fill=NULL, font=NULL, fg=NULL, bg=NULL)
  class(val) <- "SVGSettings"
 val
}



#
# The following are very simple (inefficient and potentially inconsistent with R) 
# ways of manipulating strings. These would be implemented using textConnection
# objects in S4.
#
scan.string <- function(data)
{
# This could use string split
# strsplit(data, rx)

 cmd <- paste("perl -e '$x = join(\"\n\", split(/ /, $ARGV[0])); printf \"$x\n\";'", paste("'",data,"'", collapse="",sep=""))
 els <- system(cmd, intern=T)
 vals <- as.integer(sapply(els, as.integer))

 return(vals)
}

properties <-
function(str)
{
 cmd <- paste("perl -e '$x = join(\"\n\", split(/ /, $ARGV[0])); printf \"$x\n\";'", paste("'",str,"'", collapse="",sep=""))

 els <- system(cmd, intern=T)

 idx <- seq(1,length(els), by=2)
 vals <- els[idx+1]
 names(vals) <- els[idx]

 return(vals)
}

