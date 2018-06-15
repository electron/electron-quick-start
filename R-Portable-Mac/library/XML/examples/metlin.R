readMetlin =
function(url = "http://metlin.scripps.edu/download/MSMS_test.XML",
         what = c("molid" = "integer", name = "character", formula = "character", mass = "numeric", mz = "numeric"))
{  

   doc = xmlTreeParse(url, useInternal = TRUE)
   z = xmlChildren(xmlRoot(doc))
   nodes = z[ sapply(z, inherits, "XMLInternalElementNode") ]

   if(length(nodes) > 1) {

   }

   nodes = nodes[[1]]
   n = xmlSize(nodes)
   ans = as.data.frame(lapply(what, function(x) get(x)(n)))

   for(i in 1:n) {
     node = nodes[[i]]
     sapply(names(what),
               function(id) {
                    ans[i, id] <<- as(xmlValue(node[[id]]), what[id])
              })
   }

   ans
 }

