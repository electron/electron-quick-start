# convert i
# xsltproc itunes.xsl ~/Music/iTunes/iTunes\ Music\ Library.xml > itunes.xml
# or with Sxslt
#
#   user  system elapsed 
#  7.514   0.090   7.981 
system.time({
library(Sxslt)
doc = xsltApplyStyleSheet("~/itunes.xml", "~/Projects/org/omegahat/XML/RS/examples/itunes.xsl")
top = xmlRoot(doc$doc)
songs.xsl = xmlApply(top, function(x) xmlSApply(x, xmlValue))
})


#####################

# As tempting as it is to take the xmlRoot() in this next command,
# that will allow the XML document to be freed and then a crash will ensue.
 
doc = xmlInternalTreeParse("~/Projects/org/omegahat/XML/RS/examples/itunes.xml")
# fields = unique(unlist(xmlApply(top, names)))
songs = xmlApply(xmlRoot(doc), function(x) xmlSApply(x, xmlValue))

########################
# Working form the original format of /plist/dict/dict/dict/
doc = xmlInternalTreeParse("~/itunes.xml")
dicts = doc["/plist/dict/dict/dict"]

transform =
function(dict)
{
  vals = xmlSApply(dict, xmlValue)
  i = seq(1, by = 2, length = length(vals)/2)
  structure(vals[i + 1], names = gsub(" ", "_", vals[i]))
}

songs = lapply(dicts, transform)


# For reading, xpath and lapply()
#   user  system elapsed 
#   6.784   0.073   7.153 

##########################################          


# distribution of bit rates for sampling of the sound.
table(as.numeric(sapply(songs, "[[", "Bit_Rate")))

  # How often each song was played.
hist(as.numeric(sapply(songs, "[[", "Play_Count")))


# Number of songs on each album
hist(table(sapply(songs, "[", "Album")))


# Year song was recorded (?)
hist(as.numeric(sapply(songs, "[", "Year")))


# Song size
hist(as.numeric(sapply(songs, "[", "Total_Time")))

# Album time
album.time = tapply(songs, sapply(songs, "[", "Album"), function(x) sum(as.numeric(sapply(x, "[", "Total_Time"))/1000))


dateAdded = as.POSIXct(strptime(sapply(songs, "[", "Date_Added"), "%Y-%m-%dT%H:%M:%S"))
 #XXX
hist(as.numeric(dateAdded))


 # Artists with most songs
sort(table(sapply(songs, "[", "Artist")), decreasing = TRUE)[1:40]


 # How many songs on single and double "albums"
table(sapply(songs, "[", "Disc_Number"))



table(sapply(songs, "[", "Kind"))

table(sapply(songs, "[", "Genre"))


 # Check the sampling rate for points off the line.
plot(as.numeric(sapply(songs, "[", "Total_Time")), as.numeric(sapply(songs, "[", "Size")))
