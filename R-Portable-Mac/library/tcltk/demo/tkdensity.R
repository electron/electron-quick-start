### Interactive density plots. Based on Tcl version by Guido Masarotto

#  Copyright (C) 2000-2009 The R Core Team

require(tcltk) || stop("tcltk support is absent")
require(graphics); require(stats)
local({
    have_ttk <- as.character(tcl("info", "tclversion")) >= "8.5"
    if(have_ttk) {
        tkbutton <- ttkbutton
        tkframe <- ttkframe
        tklabel <- ttklabel
        tkradiobutton <- ttkradiobutton
    }

    y <- NULL
    xlim <- NULL
    size  <- tclVar(50)
    dist  <- tclVar(1)
    kernel<- tclVar("gaussian")
    bw    <- tclVar(1)
    bw.sav <- 1 # in case replot.maybe is called too early

    replot <- function(...) {
        if (is.null(y)) return() # too early...
        bw.sav <<- b <- as.numeric(tclObj(bw))
        k <- as.character(tclObj(kernel))
        sz <- as.numeric(tclObj(size))
        eval(substitute(plot(density(y, bw=b, kernel=k),xlim=xlim)))
        points(y,rep(0,sz))
    }

    replot.maybe <- function(...)
    {
        if (as.numeric(tclObj(bw)) != bw.sav) replot()
    }

    regen <- function(...) {
        if (tclvalue(dist)=="1") y<<-rnorm(as.numeric(tclObj(size)))
        else y<<-rexp(as.numeric(tclObj(size)))
        xlim <<- range(y) + c(-2,2)
        replot()
    }

    grDevices::devAskNewPage(FALSE) # override setting in demo()
    tclServiceMode(FALSE)
    base <- tktoplevel()
    tkwm.title(base, "Density")

    spec.frm <- tkframe(base,borderwidth=2)
    left.frm <- tkframe(spec.frm)
    right.frm <- tkframe(spec.frm)

    ## Two left frames:
    frame1 <- tkframe(left.frm, relief="groove", borderwidth=2)
    tkpack(tklabel(frame1, text="Distribution"))
    tkpack(tkradiobutton(frame1, command=regen, text="Normal",
                         value=1, variable=dist), anchor="w")
    tkpack(tkradiobutton(frame1, command=regen, text="Exponential",
                         value=2, variable=dist), anchor="w")

    frame2 <- tkframe(left.frm, relief="groove", borderwidth=2)
    tkpack(tklabel(frame2, text="Kernel"))
    for ( i in c("gaussian", "epanechnikov", "rectangular",
                 "triangular", "cosine") ) {
        tmp <- tkradiobutton(frame2, command=replot,
                             text=i, value=i, variable=kernel)
        tkpack(tmp, anchor="w")
    }

    ## Two right frames:
    frame3 <-tkframe(right.frm, relief="groove", borderwidth=2)
    tkpack(tklabel(frame3, text="Sample size"))
    for ( i in c(50,100,200,300) ) {
        tmp <- tkradiobutton(frame3, command=regen,
                             text=i,value=i,variable=size)
        tkpack(tmp, anchor="w")

    }

    frame4 <-tkframe(right.frm, relief="groove", borderwidth=2)
    tkpack(tklabel (frame4, text="Bandwidth"))
    tkpack(tkscale(frame4, command=replot.maybe, from=0.05, to=2.00,
                   showvalue=FALSE, variable=bw,
                   resolution=0.05, orient="horiz"))

    tkpack(frame1, frame2, fill="x")
    tkpack(frame3, frame4, fill="x")
    tkpack(left.frm, right.frm,side="left", anchor="n")

    ## `Bottom frame' (on base):
    q.but <- tkbutton(base,text="Quit",
                      command=function() tkdestroy(base))

    tkpack(spec.frm, q.but)
    tclServiceMode(TRUE)

    cat("******************************************************\n",
        "The source for this demo can be found in the file:\n",
        file.path(system.file(package = "tcltk"), "demo", "tkdensity.R"),
        "\n******************************************************\n")

    regen()
})
