## From: Winston Chang
## To: R Devel List ...@r-project.org
## Subject: [Rd] recordPlot/replayPlot not working with saveRDS/readRDS
## Date: Mon, 2 Apr 2018 12:23:06 -0500

# Save displaylist for a simple plot
png('test.png')
dev.control(displaylist ="enable")
plot(1:5, 1:5)
r <- recordPlot()
dev.off()

# Replay plot. This works.
png('test1.png')
replayPlot(r)
dev.off()

## Save the plot and load it, then replay it (in *same* R session):
## Now works, too
saveRDS(r, 'recordedplot.rds')
r2 <- readRDS('recordedplot.rds')
png('test2.png')
replayPlot(r2)
## Gave  Error: NULL value passed as symbol address
dev.off()

## Now check the three PNG graphics files do not differ:
(files <- dir(pattern = "test.*[.]png"))
tt <- lapply(files, readBin, what = "raw", n = 2^12)
lengths(tt)
sapply(tt, head)
stopifnot(
    identical(tt[[1]], tt[[2]]),
    identical(tt[[3]], tt[[2]]))
