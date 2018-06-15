
Lines <- "DeployID Date.Time LocationQuality Latitude Longitude

STM05-1 28/02/2005 17:35 Good -35.562 177.158
STM05-1 28/02/2005 19:44 Good -35.487 177.129
STM05-1 28/02/2005 23:01 Unknown -35.399 177.064
STM05-1 01/03/2005 07:28 Unknown -34.978 177.268
STM05-1 01/03/2005 18:06 Poor -34.799 177.027
STM05-1 01/03/2005 18:47 Poor -34.85 177.059
STM05-2 28/02/2005 12:49 Good -35.928 177.328
STM05-2 28/02/2005 21:23 Poor -35.926 177.314
"

#################################
## in R
#################################

library(chron)
# in next line replace textConnection(Lines) with "myfile.dat"
DF <- read.table(textConnection(Lines), skip = 1,  as.is = TRUE,
 col.names = c("Id", "Date", "Time", "Quality", "Lat", "Long"))

DF2 <- transform(DF,
       Date = chron(Date, format = "d/m/y"),
       Time = times(paste(Time, "00", sep = ":")),
       Quality = factor(Quality, levels = c("Good", "Poor", "Unknown")))

o <- order(DF2$Date, as.numeric(DF2$Quality), abs(DF2$Time - times("12:00:00")))
DF2 <- DF2[o,]

DF2[tapply(row.names(DF2), DF2$Date, head, 1), ]

# The last line above could alternately be written like this:
do.call("rbind", by(DF2, DF2$Date, head, 1))

#################################
## in sqldf
#################################

DFo <- sqldf("select * from DF order by
 substr(Date, 7, 4) || substr(Date, 4, 2) || substr(Date, 1, 2) DESC,
 Quality DESC,
 abs(substr(Time, 1, 2) + substr(Time, 4, 2) /60 - 12) DESC")
sqldf("select * from DFo group by Date")

#################################
# Another way to do it also using sqldf is via nested selects like this using
# the same DF as above
#################################

sqldf("select * from DF u
 where abs(substr(Time, 1, 2) + substr(Time, 4, 2) /60 - 12) =
  (select min(abs(substr(Time, 1, 2) + substr(Time, 4, 2) /60 - 12))
    from DF x where Quality =
      (select min(Quality) from DF y
         where x.Date = y.Date) and x.Date = u.Date)")


