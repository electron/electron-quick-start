# ------------------------------------------------------------------------------
#  labelframe.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: labelframe.tcl,v 1.6.2.1 2011/02/14 16:56:09 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelFrame::create
#     - LabelFrame::getframe
#     - LabelFrame::configure
#     - LabelFrame::cget
#     - LabelFrame::align
# ------------------------------------------------------------------------------

namespace eval LabelFrame {
    Widget::define LabelFrame labelframe Label

    Widget::bwinclude LabelFrame Label .l \
        remove     {
            -highlightthickness -highlightcolor -highlightbackground
            -takefocus -relief -borderwidth
            -cursor
            -dragenabled -draginitcmd -dragendcmd -dragevent -dragtype
            -dropenabled -droptypes -dropovercmd  -dropcmd} \
        initialize {-anchor w}

    Widget::declare LabelFrame {
        {-relief      TkResource flat 0 frame}
        {-borderwidth TkResource 0    0 frame}
        {-side        Enum       left 1 {left right top bottom}}
        {-bd          Synonym    -borderwidth}
    }

    Widget::addmap LabelFrame "" :cmd {-background {}}
    Widget::addmap LabelFrame "" .f   {-background {} -relief {} -borderwidth {}}

    bind BwLabelFrame <FocusIn> [list Label::setfocus %W.l]
    bind BwLabelFrame <Destroy> [list LabelFrame::_destroy %W]
}


# ----------------------------------------------------------------------------
#  Command LabelFrame::create
# ----------------------------------------------------------------------------
proc LabelFrame::create { path args } {
    Widget::init LabelFrame $path $args

    if {[Widget::theme]} {
        set path  [eval [list ttk::frame $path] [Widget::subcget $path :cmd] \
            -takefocus 0 \
            -class LabelFrame]
    }  else  {
        set path  [eval [list frame $path] [Widget::subcget $path :cmd] \
            -relief flat -bd 0 -takefocus 0 -highlightthickness 0 \
            -class LabelFrame]
    }

    set label [eval [list Label::create $path.l] [Widget::subcget $path .l] \
        -takefocus 0 -dropenabled 0 -dragenabled 0]
    if {[Widget::theme]} {
        set frame [eval [list ttk::frame $path.f] [Widget::subcget $path .f] \
            -takefocus 0]
    }  else  {
        set frame [eval [list frame $path.f] [Widget::subcget $path .f] \
            -highlightthickness 0 -takefocus 0]
    }

    switch  [Widget::getoption $path -side] {
        left   {set packopt "-side left"}
        right  {set packopt "-side right"}
        top    {set packopt "-side top -fill x"}
        bottom {set packopt "-side bottom -fill x"}
    }

    eval [list pack $label] $packopt
    pack $frame -fill both -expand yes

    bindtags $path [list $path BwLabelFrame [winfo toplevel $path] all]

    return [Widget::create LabelFrame $path]
}


# ----------------------------------------------------------------------------
#  Command LabelFrame::getframe
# ----------------------------------------------------------------------------
proc LabelFrame::getframe { path } {
    return $path.f
}


# ----------------------------------------------------------------------------
#  Command LabelFrame::configure
# ----------------------------------------------------------------------------
proc LabelFrame::configure { path args } {
    return [Widget::configure $path $args]
}


# ----------------------------------------------------------------------------
#  Command LabelFrame::cget
# ----------------------------------------------------------------------------
proc LabelFrame::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command LabelFrame::align
#  This command align label of all widget given by args of class LabelFrame
#  (or "derived") by setting their width to the max one +1
# ----------------------------------------------------------------------------
proc LabelFrame::align { args } {
    set maxlen 0
    set wlist  {}
    foreach wl $args {
        foreach w $wl {
            if { ![info exists Widget::_class($w)] } {
                continue
            }
            set class $Widget::_class($w)
            if { [string equal $class "LabelFrame"] } {
                set textopt  -text
                set widthopt -width
            } else {
                upvar 0 Widget::${class}::map classmap
                set textopt  ""
                set widthopt ""
                set notdone  2
                foreach {option lmap} [array get classmap] {
                    foreach {subpath subclass realopt} $lmap {
                        if { [string equal $subclass "LabelFrame"] } {
                            if { [string equal $realopt "-text"] } {
                                set textopt $option
                                incr notdone -1
                                break
                            }
                            if { [string equal $realopt "-width"] } {
                                set widthopt $option
                                incr notdone -1
                                break
                            }
                        }
                    }
                    if { !$notdone } {
                        break
                    }
                }
                if { $notdone } {
                    continue
                }
            }
            set len [string length [$w cget $textopt]]
            if { $len > $maxlen } {
                set maxlen $len
            }
            lappend wlist $w $widthopt
        }
    }
    incr maxlen
    foreach {w widthopt} $wlist {
        $w configure $widthopt $maxlen
    }
}


proc LabelFrame::_destroy { path } {
    Widget::destroy $path
}
