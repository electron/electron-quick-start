#  Copyright (C) 2000-2008 The R Core Team

require(tcltk) || stop("tcltk support is absent")
local({
    have_ttk <- as.character(tcl("info", "tclversion")) >= "8.5"

    tt <- tktoplevel()
    tkwm.title(tt, "R FAQ")
#    Gave tiny font on some systems
#    txt <- tktext(tt, bg="white", font="courier")
    txt <- tktext(tt, bg="white")
    scr <- if(have_ttk) ttkscrollbar(tt, command=function(...)tkyview(txt,...))
    else tkscrollbar(tt, repeatinterval=5,
                     command=function(...)tkyview(txt,...))
    ## Safest to make sure scr exists before setting yscrollcommand
    tkconfigure(txt, yscrollcommand=function(...)tkset(scr,...))
    tkpack(txt, side="left", fill="both", expand=TRUE)
    tkpack(scr, side="right", fill="y")

    chn <- tclopen(file.path(R.home("doc"), "FAQ"))
    tkinsert(txt, "end", tclread(chn))
    tclclose(chn)

    tkconfigure(txt, state="disabled")
    tkmark.set(txt,"insert","0.0")
    tkfocus(txt)

    cat("******************************************************\n",
        "The source for this demo can be found in the file:\n",
        file.path(system.file(package = "tcltk"), "demo", "tkfaq.R"),
        "\n******************************************************\n")
})
