


library(lattice)

## prepanel and panel function for displaying confidence intervals

prepanel.ci <- function(x, y, lx, ux, subscripts, ...)
{
    x <- as.numeric(x)
    lx <- as.numeric(lx[subscripts])
    ux <- as.numeric(ux[subscripts])
    list(xlim = range(x, ux, lx, finite = TRUE))
}


panel.ci <- function(x, y, lx, ux, subscripts, pch = 16, ...)
{
    x <- as.numeric(x)
    y <- as.numeric(y)
    lx <- as.numeric(lx[subscripts])
    ux <- as.numeric(ux[subscripts])
    panel.abline(h = unique(y), col = "grey")
    panel.arrows(lx, y, ux, y, col = 'black',
                 length = 0.25, unit = "native",
                 angle = 90, code = 3)
    panel.xyplot(x, y, pch = pch, ...)
}



## constructing an example for confidence intervals for medians (see
## ?boxplot.stats for a discussion of what the intervals mean)

singer.split <-
    with(singer,
         split(height, voice.part))

singer.ucl <-
    sapply(singer.split,
           function(x) {
               st <- boxplot.stats(x)
               c(st$stats[3], st$conf)
           })

singer.ucl <- as.data.frame(t(singer.ucl))
names(singer.ucl) <- c("median", "lower", "upper")
singer.ucl$voice.part <-
    factor(rownames(singer.ucl),
           levels = rownames(singer.ucl))
    
singer.ucl




with(singer.ucl,
     dotplot(voice.part ~ median,
             lx = lower, ux = upper,
             prepanel = prepanel.ci,
             panel = panel.ci))
singer.split <-
    with(singer,
         split(height, voice.part))

singer.ucl <-
    sapply(singer.split,
           function(x) {
               st <- boxplot.stats(x)
               c(st$stats[3], st$conf)
           })

singer.ucl <- as.data.frame(t(singer.ucl))
names(singer.ucl) <- c("median", "lower", "upper")
singer.ucl$voice.part <-
    factor(rownames(singer.ucl),
           levels = rownames(singer.ucl))
    
singer.ucl




with(singer.ucl,
     xyplot(voice.part ~ median,
            lx = lower, ux = upper,
            prepanel = prepanel.ci,
            panel = panel.ci))





