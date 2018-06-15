saxHandlers =
function()
{
  tracks = list()

  dictLevel = 0L
  key = NA
  value = character()

  track = list()
  
  text = function(val) {
          value <<- paste(value, val, sep = "")
        }

  startElement =
    function(name, attrs) {
       if(name %in% c("integer", "string", "date", "key"))
         value <<- character()

       if(name == "dict")
         dictLevel <<- dictLevel + 1L
    }


  convertValue =
    function(value, textType) {
      switch(textType,
             integer = as.numeric(value),
             string = value,
             date = as.POSIXct(strptime(value, "%Y-%m-%dT%H:%M:%S")),
             default = value)
     }
  
  endElement = function(name) {

    if(name %in% c("integer", "string", "date")) 
       track[[key]] <<- convertValue(value, name)
    else if(name == "key")
       key <<- value
    
    else if(name == "dict" && dictLevel == 3) {
      class(track) = "iTunesTrackInfo"
      tracks[[ length(tracks) + 1]] <<- track
      track <<- list()
      dictLevel <<- 2
    }
  }

  list(startElement = startElement, endElement = endElement, text = text, tracks = function() tracks)
}  

h = saxHandlers()
#xmlEventParse(path.expand(fileName), handlers = h)

# 5.9 seconds. But this is parsing and processing into tracks.
# system.time({dd = xmlEventParse(path.expand(fileName), handlers = h, addContext = FALSE)})

# 5.93 seconds on average (SD of .09)
# sax = replicate(10, system.time({dd = xmlEventParse(path.expand(fileName), handlers = h, addContext = FALSE)}))
