# This works on the transformed version that has
# the <fieldName>value</fieldName> form
# rather than the generic
#  <dict><key>name</key><integer>12</integer>....</dict>
# for of a property/p list.
#
count = 0
songs = vector("list", 100)

song =
function(parser, node, ...)
{
  count <<- count + 1
  if(count == length(songs))
     xmlStopParser(parser)
  
  songs[[count]] <<- node

  TRUE
}

class(song)  = "XMLParserContextFunction"

xmlEventParse("itunes.xml", branches = list(song = song))
