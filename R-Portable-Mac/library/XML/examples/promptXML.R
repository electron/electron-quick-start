# Requires xmlOutputBuffer 

prompt.xml <-
function(object, file = NULL, ..., header='<!DOCTYPE Rhelp system "Shelp.dtd">\n\n<Rhelp>',footer="</Rhelp>")
{

  local <- list(...)

  name <- substitute(object)
    
    # Taken from prompt.default
  is.missing.arg <- function(arg) typeof(arg) == "symbol" && 
        deparse(arg) == ""

  if (is.language(name) && !is.name(name)) 
        name <- eval(name)
  name <- as.character(name)
  fn <- get(name)

  xml <- xmlOutputBuffer(nameSpace = "shelp")
  if(!is.null(header))
     xml$add(header)

  xml$addTag("sname",name)   
  xml$addTag("alias",name)   
  xml$addTag("title"," ~~function to do ... ~~ ")   

  xml$addTag("description","~~ A concise (1-5 lines) description of what the function does. ~~")   

  xml$addTag("usage", close=F)     


    # Now handle arguments  and generate the call.
   s <- seq(length = n <- length(argls <- formals(fn)))   
        if (n > 0) {
            arg.names <- names(argls)
        }
        xml$addTag("sname", name,sep="")
      
        for (i in s) {
            xml$addTag("arg", xml$tagString("argName", arg.names[i]), close=F)
           
            if(!is.missing.arg(argls[[i]]))  {
               xml$addTag("defaultValue", deparse(argls[[i]]),sep="")
            }
            xml$closeTag("arg")
            if(i < n)
              xml$addTag("next")
        }
  xml$add("</usage>")     

  xml$addTag("arguments", close=F)
    for(i in arg.names) {
      xml$addTag("argument", xml$tagString("argDescriptionName", i), "\n<argDescription>", 
                    "~~Describe ",i," here~~", "</argDescription>")
    }
  xml$add("</arguments>")


  xml$addTag("details","  ~~ If necessary, more details than the __description__  above ~~")
  xml$addTag("value", "~Describe the value returned",
               "  If it is a LIST, use", "  \\item{comp1 }{Description of `comp1'}", 
               "  \\item{comp2 }{Description of `comp2'}", "  ...")


  xml$addTag("references", ifelse(!is.null(local$references), local$references, ""))

  xml$addTag("author", ifelse(!is.null(local$author), local$author, ""))
  xml$addTag("note")

  xml$addTag("seeAlso", xml$tagString("a", attrs=list("href"="\"\"")))
  
  xml$addTag("examples", xml$tagString("example"))

  xml$addTag("keywords", xml$tagString("keyword"))

  if(!is.null(footer))
     xml$add(footer)

  val <- xml$value()

  if(!missing(file))
     cat(val, file=file)

  val
}

