###
### This demonstration script creates a canvas widget showing a 2-D
### plot with data points that can be dragged with the mouse.
###
### It is a ripoff of the plot.tcl demo from the tk 8.0 distribution
### All I did was to add the code to plot the fitted regression line.

#  Copyright (C) 2000-2008 The R Core Team

require(tcltk) || stop("tcl/tk library not available")
require(graphics); require(stats)
local({
    have_ttk <- as.character(tcl("info", "tclversion")) >= "8.5"
    if(have_ttk) {
        tkbutton <- ttkbutton
        tkframe <- ttkframe
        tklabel <- ttklabel
    }
    tclServiceMode(FALSE) # don't display until complete
    top <- tktoplevel()
    tktitle(top) <- "Plot Demonstration"

    msg <- tklabel(top,
                   font="helvetica",
                   wraplength="4i",
                   justify="left",
                   text="This window displays a canvas widget containing a simple 2-dimensional plot.  You can doctor the data by dragging any of the points with mouse button 1.")

    tkpack(msg, side="top")

    buttons <- tkframe(top)
    tkpack(buttons, side="bottom", fill="x", pady="2m")
    dismiss <- tkbutton(buttons, text="Dismiss",
                        command=function()tkdestroy(top))
    tkpack(dismiss, side="left", expand=TRUE)

    canvas <- tkcanvas(top, relief="raised", width=450, height=300)
    tkpack(canvas, side="top", fill="x")

    plotFont <- "Helvetica 18"

    tkcreate(canvas, "line", 100, 250, 400, 250, width=2)
    tkcreate(canvas, "line", 100, 250, 100, 50, width=2)
    tkcreate(canvas, "text", 225, 20, text="A Simple Plot",
             font=plotFont, fill="brown")

    # X tickmarks & labels
    for (i in 0:10) {
        x <- 100 + i * 30
        tkcreate(canvas, "line", x, 250, x, 245, width=2)
        tkcreate(canvas, "text", x, 254,
                 text=10*i, anchor="n", font=plotFont)
    }
    # Y tickmarks & labels
    for (i in 0:5) {
        y <- 250 - i * 40
        tkcreate(canvas, "line", 100, y, 105, y, width=2)
        tkcreate(canvas, "text", 96, y,
                 text=formatC(50*i,format="f",digits=1),
                 anchor="e", font=plotFont)
    }

    # The (original) data
    points <- matrix(c(12, 56,
                       20, 94,
                       33, 98,
                       32, 120,
                       61, 180,
                       75, 160,
                       98, 223), ncol=2, byrow=TRUE)

    ## `self-drawing' point object
    point.items <- apply(points, 1, function(row) {
        x <- 100 + 3 * row[1]
        y <- 250 - 4/5 * row[2]
        item <- tkcreate(canvas, "oval", x - 6, y - 6, x + 6, y + 6,
                         width=1, outline="black",
                         fill="SkyBlue2")
        tkaddtag(canvas, "point", "withtag", item)
        item
    })

    plotDown <- function(x, y) {
      ## This procedure is invoked when the mouse is pressed over one
      ## of the data points.  It sets up state to allow the point
      ## to be dragged.
      ##
      ## Arguments:
      ## x, y -	The coordinates of the mouse press.
      x <- as.numeric(x)
      y <- as.numeric(y)
      tkdtag(canvas, "selected")
      tkaddtag(canvas, "selected", "withtag", "current")
      tkitemraise(canvas,"current")
      lastX <<- x
      lastY <<- y
    }

    plotMove <- function(x, y) {
        ## This procedure is invoked during mouse motion events.
        ## It drags the current item.
        ##
        ## Arguments:
        ## x, y -	The coordinates of the mouse.
        x <- as.numeric(x)
        y <- as.numeric(y)
        tkmove(canvas, "selected", x - lastX, y - lastY)
        lastX <<- x
        lastY <<- y
    }
### FIXME : Don't allow points to be moved outside the canvas !!

    plotLine <- function(){
        coords <- lapply(point.items,
                         function(item)
                         as.double(tkcoords(canvas,item)))
        x <- sapply(coords, function(z) (z[1]+z[3])/2)
        y <- sapply(coords, function(z) (z[2]+z[4])/2)
        lm.out <- lm(y~x)
        x0 <- range(x)
        y0 <- predict(lm.out, data.frame(x=x0))
        tkcreate(canvas, "line", x0[1], y0[1], x0[2], y0[2], width=3)
    }

    line <- plotLine()

    lastX <- 0
    lastY <- 0

    tkitembind(canvas, "point", "<Any-Enter>",
               function() tkitemconfigure(canvas, "current",
                                          fill="red"))
    tkitembind(canvas, "point", "<Any-Leave>",
               function() tkitemconfigure(canvas, "current",
                                          fill="SkyBlue2"))
    tkitembind(canvas, "point", "<1>", plotDown)
    tkitembind(canvas, "point", "<ButtonRelease-1>",
               function(x){
                   tkdtag(canvas, "selected")
                   tkdelete(canvas, "withtag", line)
                   line <<- plotLine()
               })
    tkbind(canvas, "<B1-Motion>", plotMove)
    tclServiceMode(TRUE)

    cat("******************************************************\n",
        "The source for this demo can be found in the file:\n",
        file.path(system.file(package = "tcltk"), "demo", "tkcanvas.R"),
        "\n******************************************************\n")

})
