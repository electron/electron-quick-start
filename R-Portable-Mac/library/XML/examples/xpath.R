xpathExprCollector =
function(targetAttributes = c("test", "select"))
{
    # Collect a list of attributes for each element.
  tags = list()
    # frequency table for the element names
  counts = integer()
  
  start =
    function(name, attrs, ...) {

      attrs = attrs[ names(attrs) %in% targetAttributes ]
      if(length(attrs) == 0)
        return(TRUE)

      tags[names(attrs)] <<-
           lapply(names(attrs),
             function(id)
                   c(tags[[id]] , attrs[id]))
    }

  list(.startElement = start, 
       .getEntity = function(x, ...) "xxx",
       .getParameterEntity = function(x, ...) "xxx",
       result = function() lapply(tags, function(x) sort(table(x), decreasing = TRUE)))
}
