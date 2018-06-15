xmlSource <-
#
# This is equivalent to source() but works
# on an XML file with special tags.
# See xml2tex.Sxml or promptXML.Sxml
# for an early example.
#  
function(file, env = globalenv(), include=character(0), validate = F, ..., trim=F)
{
    # This handler will convert a XMLNode tag <fragment>....</fragment>
    # into one with the additional class XMLFragmentNode, and
    # a reference to a fragment <fragmentRef id="?">
    # to an object of class XMLFragmentRefNode

  h <- list(fragment=function(x, attr){ class(x) <- c("XMLFragmentNode", class(x)) 
                                        x
                                      },
            fragmentRef=function(x, attr){ class(x) <- c("XMLFragmentRefNode", class(x)) 
                                        x
                                      },
            defRef=function(x, attr){ class(x) <- c("XMLFunctionDefNode", class(x)) 
                                        x
                                      },
            Sexpression=function(x, attr){ class(x) <- c("XMLSExpressionNode", class(x)) 
                                        x
                                      })

     # Parse the tree, using the handlers above.
  doc <- xmlTreeParse(file, handlers=h, validate=as.logical(validate), ..., trim=trim, asTree=T)
  r <- xmlRoot(doc)


    # Get all the top-level fragment elements from the document
    # and massage them into a usable form. This means forming
    # a named list whose elements are the fragment contents/definitions
    # and whose names are the ids of the fragments.

  fragments <- xmlChildren(r)[names(r) == "fragment"]
  tmp <- sapply(fragments, function(x) xmlAttrs(x)["id"])
#  fragments <- sapply(fragments, function(x) xmlValue(x[[1]]))
  names(fragments) <- tmp


      # Process all the children in the document. An apply..?
      # Perhaps a closure so that we can append the
      # functions that are defined to a list....

  funs <- character(0)
  for(i in xmlChildren(r)[names(r) != "fragment"]) {
       # if the node is a processing instruction for R (<?R ...?>), 
       # evaluate its contents as an R expression.
     if(inherits(i, "XMLProcessingInstruction") & xmlName(i) == "R")
       eval(parse(text=xmlValue(i)))
     else if(inherits(i, "XMLTextNode")) {
        # Otherwise, if it is a text node, just print it.
       print(xmlValue(i)); cat("\n")
     } else if(inherits(i, "XMLSExpressionNode")) {
        xmlExpressionEval(i, r, env, fragments)
     } else {
        # Now, let's handle the other tags via switch statment.
        # Function definitions are handed to xmlFunctionDef() along
        # with the document itself, the list of fragments in which
        # chunk/fragment references can be resolved and finally the
        # environment in which to assign the function definition.
       obj <- switch(xmlName(i), "function" = xmlFunctionDef(i, r, env, fragments, include))
       funs <- c(funs, obj)
     }
  }

 invisible(list(doc=r, defs = funs, file=file))
}

xmlExpressionEval <-
#
# Need to resolve the references here.
#
function(node, root, env = globalenv(), fragments = NULL)
{
 txt <- paste(unlist(xmlSApply(node, xmlValue)), collapse=" ")
 eval(parse(text=txt), envir=env)
}

xmlFunctionDef <-
#
# This takes a function definition in XML form and 
# resolves any fragment references and so generates
# a complete textual version of the function body and
# argument list.
# It grabs the name from the <name> tag assumed to be 
# at the top of the function definition.
#
#
# Needs to handle cross-references.
# That's why we need the entire document here.
#
function(node, root, env = globalenv(), fragments = NULL, includes=character(0))
{
   # First determine if this can run or not.
 isR <- length(xmlAttrs(node)) == 0 | is.na(match("lang", names(xmlAttrs(node))))

 if(!isR) {
    lang <- xmlAttrs(node)["lang"]
   isR <- lang== "S" | lang=="R"
 }

 if(!isR){
   warning(paste("Skipping function", xmlAttrs(node)["lang"]))
   return(F)
 }
  
    # What about multiple chunks within the definition
  def <- node[["def"]]
  if(is.null(def)) 
   return(NULL)

  def <- xmlFunctionDef.XMLFunctionDefNode(def, root, env, fragments)
  if(!is.na(match("sname", names(node)))) {
    name <- xmlValue(node[["sname"]][[1]])
    if(length(includes)) {
       if(is.na(match(name, includes)))
         warning(paste("Skipping function", name))
    }
# cat("Defining function",name,"\n")
    assign(name, def,  envir=env) 
    return(name)
  } else {
    return(def)
  }
}

xmlFunctionDef.XMLFunctionDefNode <-
#
# This attempts to convert the contents of a <def>...</def>
# element into a function definition. It does so by converting each
# element within this <def> to text, resolving any fragment references 
# and converting them to text recursively.
#
function(node, root, env = globalenv(), fragments = NULL)
{
 txt <- character(0)
 for(i in xmlChildren(node)) {
  if(inherits(i, "XMLFragmentRefNode"))
   txt <- c(txt, xmlResolveFragmentRefs(i, root, fragments))
  else {
   txt <- c(txt, " ", xmlValue(i))
  }
 }

#cat("Parsing.... ",paste(txt, collapse=""), "\n")
 obj <- eval(parse(text=paste(txt, collapse="")), envir = env)

 invisible(obj)
}

xmlResolveFragmentRefs <-
function(body, root, fragments = NULL)
{
 UseMethod("xmlResolveFragmentRefs")
}

xmlResolveFragmentRefs.XMLFragmentRefNode <-
function(body, root, fragments = NULL)
{
    id <- xmlAttrs(body)["id"]
    v <- xmlValue(fragments[[id]][[1]])
    return(v)
}

xmlResolveFragmentRefs.XMLNode <-
function(body, root, fragments = NULL)
{

 v <- xmlSApply(body, function(x, fragments) {

   	if(inherits(x, "XMLFragmentRefNode")) {
   	   id <- xmlAttrs(x)["id"]

# print(class(fragments[[id]]));print(xmlSize(fragments[[id]]));print(fragments[[id]])

           v <- xmlSApply(fragments[[id]], function(x, root, fragments)  {
                                             print(class(x))
                                             if(inherits(x,"XMLFragmentRefNode")) {
                                                print(x)
                                                xmlResolveFragmentRefs(x, root, fragments)
                                             } else if(inherits(x,"XMLNode"))
                                                xmlValue(x)
                                             else
                                                x
                                           }, root=root, fragments=fragments)
          v <- paste(as.character(unlist(v)), collapse=" ")
#print(v)
   	} else
           v <- c("\n",xmlValue(x))

       v
      }, fragments = fragments)

 paste(as.character(unlist(v)), collapse="")
}

