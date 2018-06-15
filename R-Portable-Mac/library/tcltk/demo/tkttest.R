#  Copyright (C) 2000-2008 The R Core Team

require(tcltk) || stop("tcltk support is absent")
require(stats)

local({
    have_ttk <- as.character(tcl("info", "tclversion")) >= "8.5"
    if(have_ttk) {
        tkbutton <- ttkbutton
        tkcheckbutton <- ttkcheckbutton
        tkentry <- ttkentry
        tkframe <- ttkframe
        tklabel <- ttklabel
        tkradiobutton <- ttkradiobutton
    }
    dialog.t.test <- function(){
        tt <- tktoplevel()
        tkwm.title(tt,"t test")
        x.entry <- tkentry(tt, textvariable=xvar)
        y.entry <- tkentry(tt, textvariable=yvar)
	alt <- tclVar("two.sided")
	done <- tclVar(0)
	eqvar <- tclVar(0)

        reset <- function()
        {
            tclvalue(xvar)<-""
            tclvalue(yvar)<-""
            tclvalue(alt)<-"two.sided"
            tclvalue(eqvar)<-"0"
        }
        reset.but <- tkbutton(tt, text="Reset", command=reset)
        submit.but <- tkbutton(tt, text="submit",
                               command=function()tclvalue(done)<-1)

        build <- function()
        {
            ## notice that tclvalue() is correct here, since it is the
            ## string representation of xvar and yvar that is being
            ## displayed in the entry fields

            x  <- parse(text=tclvalue(xvar))[[1]]
            y  <- parse(text=tclvalue(yvar))[[1]]
            a <- tclvalue(alt)
            vv <- as.logical(tclObj(eqvar))
            substitute(t.test(x,y,alternative=a,var.equal=vv))
        }
        var.cbut <- tkcheckbutton(tt, text="Equal variance", variable=eqvar)
        alt.rbuts <- tkframe(tt)

        tkpack(tklabel(alt.rbuts, text="Alternative"))
        for ( i in c("two.sided", "less", "greater")){
            tmp <- tkradiobutton(alt.rbuts, text=i, variable=alt, value=i)
            tkpack(tmp,anchor="w")
        }

        tkgrid(tklabel(tt,text="t-test"),columnspan=2)
        tkgrid(tklabel(tt,text="x variable"), x.entry)
        tkgrid(tklabel(tt,text="y variable"), y.entry)
        tkgrid(var.cbut, alt.rbuts)
        tkgrid(submit.but, reset.but)

        if (tclvalue(alt)=="") tclvalue(alt)<-"two.sided"

        ## capture destroy (e.g. from window controls
        ## otherwise the tkwait hangs with nowhere to go
        tkbind(tt, "<Destroy>", function()tclvalue(done)<-2)

        tkwait.variable(done)

        if(tclvalue(done)=="2") stop("aborted")

        tkdestroy(tt)
        cmd <- build()
        cat("### Command executed via Tk ###\n")
        cat(deparse(build()),sep="\n")
        cat("### -----\n")
        eval.parent(cmd)
    }

    cat("******************************************************\n",
        "The source for this demo can be found in the file:\n",
        file.path(system.file(package = "tcltk"), "demo", "tkttest.R"),
        "\n******************************************************\n")

    xvar <- tclVar("Ozone[Month==5]")
    yvar <- tclVar("Ozone[Month==8]")
    with(airquality, dialog.t.test())
})
