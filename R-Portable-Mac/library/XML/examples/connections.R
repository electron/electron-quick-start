library(XML)
fileName = system.file("exampleData", "job.xml", package = "XML")
# xmlEventParse(file(fileName, "r"))

xmlConnection = 
function(con) {

 if(is.character(con))
   con = file(con, "r")
  
 if(isOpen(con, "r"))
   open(con, "r")

 function(len) {

   if(len < 0) {
        cat("closing connection in xmlConnection\n")
        close(con)
        return(character(0))
   }
    
   cat("getting line from connection\n")

   x = character(0)
   tmp = ""
   while(length(tmp) > 0 && nchar(tmp) == 0) {
     tmp = readLines(con, 1)
     if(length(tmp) == 0)
       break
     if(nchar(tmp) == 0)
       x = append(x, "\n")
     else
       x = tmp
   }
   if(length(tmp) == 0)
     return(tmp)

   x = paste(x, collapse="")
   print(x)
   x
 }
}

v = xmlEventParse(xmlConnection(fileName))






