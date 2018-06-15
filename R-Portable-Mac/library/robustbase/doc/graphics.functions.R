## some additional functions to help plotting
## g.drop.labels <- function(breaks, labels) {
##   ind <- breaks %in% labels
##   breaks <- as.character(breaks)
##   breaks[!ind] <- ''
##   breaks
## }
  

g.scale_y_log10_0.05 <- function(breaks =  c(0.00001, 0.0001, 0.001, 0.01,
                                   0.02, 0.03, 0.05, 0.07, 0.1, 0.14,
                                   0.2, 0.4, 0.8),
                                 minor_breaks = seq(0,1,by = 0.01), ...)
  ## Purpose: add nice breaks and labels 
  ## ----------------------------------------------------------------------
  ## Arguments: just like scale_y_log10
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 11 Nov 2009, 11:52
  scale_y_log10(breaks = breaks, minor_breaks = minor_breaks, ...)

## the same for lattice:
g.scale_y_log10_0.05_lattice <- list(at = log10(c(seq(0.1, 0.01, by = -0.01), 0.001,
                                       0.0001, 0.00001)),
                                     labels = c("", 0.09, "", 0.07, "", 0.05, "", 0.03,
                                       "", 0.01, 0.001, 0.0001, 0.00001))

g.scale_y_log10_1 <- function(breaks = c(seq(0,1,by=0.1), seq(1.2, 3.5,by=0.2)),
                              minor_breaks = seq(0,10,by = 0.1), ...)
  ## Purpose: add nice breaks and labels 
  ## ----------------------------------------------------------------------
  ## Arguments: just like scale_y_log10
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 11 Nov 2009, 11:52
  scale_y_log10(breaks = breaks, minor_breaks = minor_breaks, ...)

g.scale_y_log10_1_l <- function(breaks = c(seq(0,.4,by=0.1), seq(0.6,1.4,by=0.2),
                                  seq(1.6, 3.4, by = 0.4)),
                                minor_breaks = seq(0,10,by = 0.1), ...)
  ## Purpose: add nice breaks and labels 
  ## ----------------------------------------------------------------------
  ## Arguments: just like scale_y_log10
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 11 Nov 2009, 11:52
  scale_y_log10(breaks = breaks, minor_breaks = minor_breaks, ...)

g.scale_shape_defaults = c(16, 17, 15, 3, 7, 8)
g.scale_shape_defaults2 = c(g.scale_shape_defaults,9,1,2,4)
g.scale_linetype_defaults = c("solid", "22", "42", "44", "13", "1343", "73",
  "2262", "12223242", "F282", "F4448444", "224282F2", "F1")

g.scale_shape <- function(..., values=g.scale_shape_defaults2)
    scale_shape_manual(..., values = values) 

g.get_colors <- function(n, h=c(0,360) + 15, l=65, c=100, start=0, direction = 1) {
  rotate <- function(x) (x + start) %% 360 * direction

  if ((diff(h) %% 360) < 1) {
    h[2] <- h[2] - 360 / n
  }
  
  grDevices::hcl(h = rotate(seq(h[1], h[2], length = n)), 
                 c = c, l = l)
}

g.get_colors_brewer <- function(n, name='Dark2') {
  idx <- 1:n
  if (name=='Dark2') {
    idx <- c(6,2:5,1,7,8)[idx]
  }
  RColorBrewer::brewer.pal(n, name)[idx]
}

g.scale_colour <- function(..., n=8, values=g.get_colors_brewer(n=n))
  scale_colour_manual(..., values=values)

###########################################################################
## some useful helper functions
###########################################################################

f.range.xy <- function(x,...) UseMethod("f.range.xy")
  ## Purpose: get plot range for x and y axis and return as a data.frame
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:42

f.range.xy.default <- function(x, ...)
  data.frame(x = range(x$x), y = range(x$y))
f.range.xy.data.frame <- function(x, names = c('x','y'), ...)
  sapply(x[,names],range)
f.range.xy.matrix <- function(x, names = c('x','y'), ...)
  sapply(x[,names],range)
f.range.xy.list <- function(x,...)
  data.frame(x = range(sapply(x, function(x) x$x)),
             y = range(sapply(x, function(x) x$y)))

f.range.xy.histogram <- function(x,...)
  data.frame(x = range(sapply(x, function(x) x$breaks)),
             y = range(sapply(x, function(x) x$counts)))

f.trim <- function(data, trim = 0.05)
{
  ## Purpose: trim alpha observations
  ## ----------------------------------------------------------------------
  ## Arguments: data and trim
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 19 Nov 2009, 14:33
  n <- length(data)
  lo <- floor(n * trim) + 1
  hi <- n + 1 - lo
  sort.int(data, partial = unique(c(lo, hi)))[lo:hi]
}

f.seq <- function(x, ...)
  ## Purpose: make seq callable with an vector x = c(from, to)
  ## ----------------------------------------------------------------------
  ## Arguments: x: vector of length two (from, to)
  ##            ...: other arguments to seq
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 20 Nov 2009, 08:55
  seq(from = x[1], to = x[2],...)

curves <- function(expr, from = NULL, to = NULL, n = 101, add = FALSE, 
                   type = "l", ylab = 'values', xlab = 'x', log = NULL,
                   xlim = NULL, xcol = NULL, geom = geom_path, wrap = TRUE,
                   ...) 
{
  ## Purpose: curves: does the same as curve, but for multivariate output
  ## ----------------------------------------------------------------------
  ## Arguments: same as curve
  ##            xcol: column of data.frame to use for x instead of default
  ##            geom: what geom function to use, defaults to geom_path
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 15 Jan 2010, 08:48

  sexpr <- substitute(expr)
  if (is.name(sexpr)) {
    fcall <- paste(sexpr, "(x)")
    expr <- parse(text = fcall)
    if (is.null(ylab)) 
      ylab <- fcall
  }
  else {
    if (!(is.call(sexpr) && match("x", all.vars(sexpr), nomatch = 0L))) 
      stop("'expr' must be a function or an expression containing 'x'")
    expr <- sexpr
    if (is.null(ylab)) 
      ylab <- deparse(sexpr)
  }
  if (is.null(xlim)) 
    delayedAssign("lims", {
      pu <- par("usr")[1L:2L]
      if (par("xaxs") == "r") 
        pu <- extendrange(pu, f = -1/27)
      if (par("xlog")) 
        10^pu
      else pu
    })
  else lims <- xlim
  if (is.null(from)) 
    from <- lims[1L]
  if (is.null(to)) 
    to <- lims[2L]
  lg <- if (length(log)) 
    log
  else paste(if (add && par("xlog")) 
             "x", if (add && par("ylog")) 
             "y", sep = "")
  if (length(lg) == 0) 
    lg <- ""
  x <- if (lg != "" && "x" %in% strsplit(lg, NULL)[[1L]]) {
    if (any(c(from, to) <= 0)) 
      stop("'from' and 'to' must be > 0 with log=\"x\"")
    exp(seq.int(log(from), log(to), length.out = n))
  }
  else seq.int(from, to, length.out = n)
  y <- eval(expr, envir = list(x = x), enclos = parent.frame())
  
  ## up this was an exact copy of curve
  if (length(dim(y)) == 1) {
    ydf <- data.frame(x = x, values = y)
    gl <- geom(data = ydf, aes(x = x, y = values), ...)
    ret <- if (add) gl
    else ggplot(ydf) + gl
  } else {
    ## check whether we have to transpose y
    if (NCOL(y) != n) {
      if (NROW(y) == n) y <- t(y)
      else stop(paste('output should have n =',n,' columns'))
    }
    ## add dimnames
    dm <- dimnames(y)
    if (is.null(dm)) dm <- list(1:NROW(y), 1:NCOL(y))
    if (is.null(names(dm))) names(dm) <- c('rows', 'cols')
    if (is.null(dm[[1]])) dm[[1]] <- 1:NROW(y)
    if (is.null(dm[[2]])) dm[[2]] <- 1:NCOL(y)
    dimnames(y) <- dm
    ## restructure the output matrix to a data.frame
    ydf <- melt(y)
    ## un-factor the first two columns
    for (i in 1:2) {
      if (is.factor(ydf[[i]])) 
        ydf[[i]] <- f.as.numeric.vectorized(levels(ydf[[i]]))[ydf[[i]]]
    }
    ## add x column
    ydf$x <- rep(x, each = NROW(y))
    if (is.null(xcol)) {
      xcol <- 'x'
    } else {
      ## get desired x column
      lx <- ydf[idx <- ydf[,1] == xcol,3]
      ## remove it from the values
      ydf <- ydf[!idx,]
      ## add as additional column
      ydf[[xcol]] <- rep(lx, each = NROW(y) - 1)
      if (missing(xlab)) xlab <- xcol
    }
    
    if (wrap) { ## use facet wrap, or assume it was used before
      ## there seems to be a bug in ggplot that requires sorting for the rows variable
      ydf <- ydf[order(ydf[,1],ydf[,2]),]
      gl <- geom(data = ydf, aes_string(x = xcol, y = 'value'), ...)
      ret <- if (add) gl
      else ggplot(ydf) + gl + xlab(xlab) +
        facet_wrap(substitute(~ rows, list(rows = as.name(names(dm)[1]))))
    } else {
      ## factor 'rows' again
      ydf[, 1] <- factor(ydf[, 1], levels = unique(ydf[, 1]))
      ret <- if (add) geom(data = ydf, aes_string(x = xcol, y = 'value',
                             color = names(dm)[1]), ...)
      else  ggplot(ydf) + geom(aes_string(x = xcol, y = 'value',
                                          linetype = names(dm)[1]), ...) +
        xlab(xlab)
    }
  }

  if (!add && !is.null(log)) {
    ret <- ret + switch(log,
                        xy = coord_trans(x = 'log', y='log'),
                        x = coord_trans(x = 'log'),
                        y = coord_strans(y = 'log'),
                        list()
                        )
  }
  
  ret
}

f.get.range <- function(p, axis)
{
  ## Purpose: get range of axis from ggplot object
  ## ----------------------------------------------------------------------
  ## Arguments: p: ggplot return object
  ##            axis: 'x' or 'y' 
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 27 Jan 2010, 09:37

  lr <- NULL
  ## get range in from base mapping, if available
  if (!is.null(p$mapping[[axis]]))
    lr <- range(p$data[[as.character(p$mapping[[axis]])]], na.rm = TRUE)
  ## walk layers
  for (llayer in p$layers) {
    lvar <- as.character(llayer$mapping[[axis]])
    if (!is.null(lvar) && length(lvar) > 0) {
      ## check if the variable is available in custom data.frame
      if (!is.null(llayer$data) && NCOL(llayer$data) > 0 &&
          lvar %in% colnames(llayer$data)) ## if so, update range
        lr <- range(c(llayer$data[[lvar]], lr), na.rm = TRUE)
      else ## try to update range with data from global data.frame
        if (!is.null(p$data) && NCOL(p$data) > 0 &&
            lvar %in% colnames(p$data)) ## if so, update range
          lr <- range(c(p$data[[lvar]], lr), na.rm = TRUE)
    }
  }
  lr
}


## makeFootnote: add footnote to plot (like stamp)
## from: http://www.r-bloggers.com/r-good-practice-%E2%80%93-adding-footnotes-to-graphics/
makeFootnote <- function(footnoteText=
                         format(Sys.time(), "%d %b %Y"),
                         size= .7, color="black")
{
   ## require(grid)
   pushViewport(viewport())
   grid.text(label= footnoteText ,
             x = unit(1,"npc") - unit(2, "mm"),
             y= unit(2, "mm"),
             just=c("right", "bottom"),
             gp=gpar(cex= size, col=color))
   popViewport()
}
## ## Example ##
## plot(1:10)
## makeFootnote(footnote)

## using this and multicore results in segmentation fault
## print.ggplot <- function(..., footnote)
## {
##   ## Purpose: print ggplot and add a footnote
##   ## ----------------------------------------------------------------------
##   ## Arguments: see ?print.ggplot
##   ##            footnote: text to be added as footnote
##   ## ----------------------------------------------------------------------
##   ## Author: Manuel Koller, Date: 25 Jan 2010, 16:32

##   ggplot2::print.ggplot(...)
##   ## if (!missing(footnote)) grid.text(footnote, x = unit(1, 'npc') - unit(2, 'mm'),
##   ##                                   y = unit(2, 'mm'),
##   ##                                   just = c('right', 'bottom'),
##   ##                                   gp=gpar(cex=.7, col=grey(.5)))
##   if (!missing(footnote)) makeFootnote(footnote)o
## }

## ## modify print.ggplot: update legend automatically
## print.ggplot <- function (x, newpage = is.null(vp), vp = NULL, ...) 
## {
##   set_last_plot(x)
##   lg <- ggplotGrob(x, ...)
##   ## edit grob: change legends
##   ## get all legend texts
##   lls <- getGrob(lg, gPath='legend.text.text', grep = TRUE, global = TRUE)
##   for(le in lls) {
##     print(le$label)
##     if (!is.expression(le$label) && le$label %in% names(legend.mod)) {
##       lg <- editGrob(lg, gPath=le$name, label = legend.mod[[le$label]])
##     }
##   }
##   if (newpage) 
##         grid.newpage()
##   if (is.null(vp)) {
##     grid.draw(lg)
##     }
##   else {
##     if (is.character(vp)) 
##       seekViewport(vp)
##     else pushViewport(vp)
##     grid.draw(lg)
##     upViewport()
##   }
## }

require(grid)

print.ggplot <- function(x, newpage = is.null(vp), vp = NULL, ...,
                         footnote = NULL, footnote.col = 'black', footnote.size = .7,
                         footnote.just = c("right", "bottom"),
                         legend.mod = NULL)
{
    ## Purpose: print ggplot and add footnote
    ## ----------------------------------------------------------------------
    ## Arguments: x, newpage, vp, ...: see ?print.ggplot
    ##            footnote: text to be added as footnote
    ##            footnote.col: color of footnote
    ##                    .size: size of footnote text (cex)
    ##                    .just: justification of footnote
    ##            legend.mod: named list on what legend entries to replace
    ##                        by value
    ## ----------------------------------------------------------------------
    ## Author: Manuel Koller, Date: 26 Jan 2010, 09:01
    
    if ((missing(footnote) && missing(legend.mod)) ||
        packageVersion("ggplot2") > "0.9.1")
        return(ggplot2:::print.ggplot(x, newpage, vp, ...))

    ## this is mostly a copy of ggplot2::print.ggplot
    ggplot2:::set_last_plot(x)
    if (newpage)
        grid.newpage()
    grob <- ggplotGrob(x, ...)
    if (!missing(legend.mod)) {
        ## edit grob: change legends and strip text
        lls <- getGrob(grob, gPath='(xlab-|ylab-|title-|label-|legend.text.text|strip.text.x.text|strip.text.y.text)',
                       grep=TRUE, global=TRUE)
        ## walk all legend texts
        for(le in lls) {
            if (!is.null(le$label) && !is.expression(le$label) &&
                length(le$label) > 0 && le$label %in% names(legend.mod)) {
                grob <- editGrob(grob, gPath=le$name, label = legend.mod[[le$label]])
            }
        }
        ## also: remove alpha in legend key points
        lls <- getGrob(grob, gPath='key.points', grep=TRUE, global=TRUE)
        for (le in lls) {
            if (is.character(le$gp$col) && grepl('^\\#', le$gp$col)) {
                lgp <- le$gp
                lgp$col <- substr(lgp$col, 1, 7)
                grob <- editGrob(grob, gPath=le$name, gp=lgp)
            }
        }
        ## also: change spacing of legends
        grob$children$legends$framevp$layout$heights <-
            grob$children$legends$framevp$layout$heights * .91
    }
    if (missing(footnote))
        grid.draw(grob)
    else {
        if (is.null(vp)) {
            ## add footnote to grob
            grob$children$footnote <- grid.text(label=footnote,
                                                x = unit(1, "npc") - unit(2, "mm"),
                                                y = unit(2, "mm"), just = footnote.just,
                                                gp=gpar(cex = footnote.size,
                                                col = footnote.col), draw = FALSE)
            llen <- length(grob$childrenOrder)
            grob$childrenOrder[llen+1] <- 'footnote'
            grid.draw(grob)
        } else {
            if (is.character(vp)) 
                seekViewport(vp)
            else pushViewport(vp)
            grid.draw(grob)
            upViewport()
            ## add footnote to plot (from makeFootnote)
            pushViewport(viewport())
            grid.text(label=footnote,
                      x = unit(1, "npc") - unit(2, "mm"),
                      y = unit(2, "mm"), just = footnote.just,
                      gp=gpar(cex = footnote.size,
                      col = footnote.col))
            popViewport() 
        }
    }
}


## guide_legends_box <- function (scales, layers, default_mapping, horizontal = FALSE, 
##     theme) 
## {
##   print('hello')
##     legs <- guide_legends(scales, layers, default_mapping, theme = theme)
##     n <- length(legs)
##     if (n == 0) 
##         return(zeroGrob())
##     if (!horizontal) {
##         width <- do.call("max", lapply(legs, widthDetails))
##         heights <- do.call("unit.c", lapply(legs, function(x) heightDetails(x) * 
##             10))
##         fg <- frameGrob(grid.layout(nrow = n, 1, widths = width, 
##             heights = heights, just = "centre"), name = "legends")
##         for (i in 1:n) {
##             fg <- placeGrob(fg, legs[[i]], row = i)
##         }
##     }
##     else {
##         height <- do.call("sum", lapply(legs, heightDetails))
##         widths <- do.call("unit.c", lapply(legs, function(x) widthDetails(x) * 
##             1.1))
##         fg <- frameGrob(grid.layout(ncol = n, 1, widths = widths, 
##             heights = height, just = "centre"), name = "legends")
##         for (i in 1:n) {
##             fg <- placeGrob(fg, legs[[i]], col = i)
##         }
##     }
##     fg
## }

### viewport test
## data <- data.frame(x = 1:10, y = 1:10)
## tg <- ggplot(data, aes(x, y)) + geom_line() +
##   geom_text(data=data.frame(x=10, y=1), label='test')

## print(tg)

## tgrob2 <- ggplotGrob(tg)

## str(tgrob, max.level = 2)
## str(tgrob2, max.level = 2)

## tgrob$children$footnote <- grid.text(label= 'test haha2', x = unit(1,"npc") - unit(2, "mm"),
##                                      y= unit(2, "mm"), just=c("right", "bottom"),
##                                      gp=gpar(cex= .7, col=grey(.5)), draw=FALSE)
## tgrob$childrenOrder[7] <- 'footnote'


## grid.draw(tgrob)

## print(tg, footnote = 'footnote test text')


##########################################################################
## ggplot 0.8.7 bugfix
##########################################################################

## require(ggplot2)
## data <- data.frame(x = 1:10, y = exp(0:9))
## ggplot(data, aes(x, y)) + geom_point() +
##   geom_hline(yintercept = 9) + geom_vline(xintercept = 2)
## last_plot() + coord_trans(y = 'log', x = 'sqrt') 

## GeomVline$draw <- function(., data, scales, coordinates, ...) {
##   data$y    <- if(coordinates$objname=="trans" &&
##                   coordinates$ytr$objname%in%c("log", "sqrt")) 0 else -Inf
##   data$yend <- Inf
##   GeomSegment$draw(unique(data), scales, coordinates)
## }
## GeomHline$draw <- function(., data, scales, coordinates, ...) {
##   data$x    <- if(coordinates$objname=="trans" &&
##                   coordinates$xtr$objname%in%c("log", "sqrt")) 0 else -Inf
##   data$xend <- Inf
##   GeomSegment$draw(unique(data), scales, coordinates)
## }
## Coord$munch_group <- function(., data, details, npieces=50) {
##   n <- nrow(data)
##   if(n==2 && (all(data$x==c(-Inf,Inf)) || all(data$y==c(-Inf,Inf)))) npieces=1
##   x <- approx(data$x, n = npieces * (n - 1) + 1)$y
##   y <- approx(data$y, n = npieces * (n - 1) + 1)$y
##   cbind(
##         .$transform(data.frame(x=x, y=y), details),
##         data[c(rep(1:(n-1), each=npieces), n), setdiff(names(data), c("x", "y"))]
##         )
## } 

cs <- function(x, y, ..., if.col)
{
  ## Purpose: make aes dependent on global variable color
  ## ----------------------------------------------------------------------
  ## Arguments: same arguments as for aes
  ##            if.col: list of arguments that are only applied if
  ##                    color = TRUE
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  7 Sep 2010, 08:36

  aes <- structure(as.list(match.call()[-1]), class = "uneval")
  if (globalenv()$color) {
    aes2 <- as.list(aes$if.col[-1])
    for (item in names(aes2)) {
      aes[[item]] <- aes2[[item]]
    }
  }
  aes$if.col <- NULL
  rename_aes(aes)
}

## replace levels by legend.mod
lab <- function(..., lm=legend.mod) {
    factors <- list(...)
    lev <- unlist(lapply(factors, levels))
    if (length(factors) > 1)
        lev <- sort(lev)
    ret <- as.list(lev)
    idx <- lev %in% names(lm)
    ret[idx] <- lm[lev[idx]]
    ret
}

## my labeller
mylabel <- function(name, value, lm) {
    str(name)
    str(value)
    if (value %in% names(lm)) lm[[value]] else value
}
