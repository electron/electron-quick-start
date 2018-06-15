# This version works on the generic plist form
# We want the dict/dict/dict

depth = 0
count = 0
songs = vector("list", 1300)

songNode =
function(parser, node)
{
  count <<- count + 1
  songs[[count]] <<- node
}
class(songNode) = c("XMLParserContextFunction", "SAXBranchFunction")

dict =
function(parser, node, ...)
{
  print(depth)
  if(depth == 2) {
      # return the songNode function so that it will be used as a branch
      # function for this <dict> node, i.e. will be invoked
    return(songNode)
  } else
    depth <<- depth + 1


  TRUE
}

xmlEventParse("~/itunes.xml", handlers = list(dict = dict), saxVersion = 2L)
