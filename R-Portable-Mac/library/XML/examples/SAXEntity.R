entities <- new.env(TRUE)
assign(".text", "", entities)
handlers = list(  
     .entityDeclaration = function(name, type, content, system, public) {
        if((length(content) == 0 || nchar(content) == 0) &&  length(system) > 0) {
            #
          if(file.exists(system))
            content = paste(readLines(system), collapse = "\n")
        }

        if(length(content)) 
          assign(name, content, entities)
        else
          warning("Can't resolve entity ", name)
     },
     .getEntity = function(name) {

       if(exists(name, entities))
         return(get(name, entities))

       return(character())
     },
     .text = function(txt) {
         entities$.text <- paste(entities$.text, txt)
     })

xmlEventParse("entity2.xml", handlers, useDotNames = TRUE)
