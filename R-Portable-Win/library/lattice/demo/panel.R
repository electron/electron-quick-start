

panel.stackedDens <-
    function(x, y,
             overlap = 0.3,
             horizontal = TRUE,

             alpha = plot.polygon$alpha,
             border = plot.polygon$border,
             lty = plot.polygon$lty,
             lwd = plot.polygon$lwd,
             col = plot.polygon$col,

             varwidth = FALSE,
             ref = TRUE,

             bw = NULL,
             adjust = NULL,
             kernel = NULL,
             window = NULL,
             width = NULL,
             n = 50,
             from = NULL,
             to = NULL,
             cut = NULL,
             na.rm = TRUE,
             
             ...)
{
    if (all(is.na(x) | is.na(y))) return()
    x <- as.numeric(x)
    y <- as.numeric(y)

    reference.line <- trellis.par.get("reference.line")
    plot.polygon <- trellis.par.get("plot.polygon")

    ## density doesn't handle unrecognized arguments (not even to
    ## ignore it).  A tedious but effective way to handle that is to
    ## have all arguments to density be formal arguments to this panel
    ## function, as follows:

    darg <- list()
    darg$bw <- bw
    darg$adjust <- adjust
    darg$kernel <- kernel
    darg$window <- window
    darg$width <- width
    darg$n <- n
    darg$from <- from
    darg$to <- to
    darg$cut <- cut
    darg$na.rm <- na.rm

    my.density <- function(x) do.call("density", c(list(x = x), darg))

    numeric.list <- if (horizontal) split(x, factor(y)) else split(y, factor(x))
    levels.fos <- as.numeric(names(numeric.list))
    d.list <- lapply(numeric.list, my.density)
    ## n.list <- sapply(numeric.list, length)  UNNECESSARY
    dx.list <- lapply(d.list, "[[", "x")
    dy.list <- lapply(d.list, "[[", "y")

    max.d <- sapply(dy.list, max)
    if (varwidth) max.d[] <- max(max.d)

    ##str(max.d)
    
    xscale <- current.panel.limits()$xlim
    yscale <- current.panel.limits()$ylim
    height <- (1 + overlap)

    if (horizontal)
    {
        for (i in rev(seq_along(levels.fos)))
        {
            n <- length(dx.list[[i]])
            panel.polygon(x = dx.list[[i]][c(1, 1:n, n)],
                          y = levels.fos[i] - 0.5 + height * c(0, dy.list[[i]], 0) / max.d[i],
                          col = col, border = border,
                          lty = lty, lwd = lwd, alpha = alpha)
            if (ref)
            {
                panel.abline(h = levels.fos[i] - 0.5,
                             col = reference.line$col,
                             lty = reference.line$lty,
                             lwd = reference.line$lwd,
                             alpha = reference.line$alpha)
            }
        }
    }
    else
    {
        for (i in rev(seq_along(levels.fos)))
        {
            n <- length(dx.list[[i]])
            panel.polygon(x = levels.fos[i] - 0.5 + height * c(0, dy.list[[i]], 0) / max.d[i],
                          y = dx.list[[i]][c(1, 1:n, n)],
                          col = col, border = border,
                          lty = lty, lwd = lwd, alpha = alpha)
            if (ref)
            {
                panel.abline(v = levels.fos[i] - 0.5,
                             col = reference.line$col,
                             lty = reference.line$lty,
                             lwd = reference.line$lwd,
                             alpha = reference.line$alpha)
            }
        }
    }
    invisible()
}


overlap <- 0.3

bwplot(voice.part ~ height, singer,
       panel = panel.stackedDens,
       overlap = overlap,
       lattice.options = list(axis.padding = list(factor = c(0.6, 1 + overlap))))


