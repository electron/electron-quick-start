# ------------------------------------------------------------------------------
#  arrow.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#   Public commands
#     - ArrowButton::create
#     - ArrowButton::configure
#     - ArrowButton::cget
#     - ArrowButton::invoke
#   Private commands (redraw commands)
#     - ArrowButton::_redraw
#     - ArrowButton::_redraw_state
#     - ArrowButton::_redraw_relief
#     - ArrowButton::_redraw_whole
#   Private commands (event bindings)
#     - ArrowButton::_destroy
#     - ArrowButton::_enter
#     - ArrowButton::_leave
#     - ArrowButton::_press
#     - ArrowButton::_release
#     - ArrowButton::_repeat
# ------------------------------------------------------------------------------

namespace eval ArrowButton {
    Widget::define ArrowButton arrow DynamicHelp

    Widget::tkinclude ArrowButton button .c \
	    include [list \
		-borderwidth -bd \
		-relief -highlightbackground \
		-highlightcolor -highlightthickness -takefocus]

    Widget::declare ArrowButton [list \
	    [list -type		Enum button 0 [list arrow button]] \
	    [list -dir		Enum top    0 [list top bottom left right]] \
	    [list -width	Int	15	0	"%d >= 0"] \
	    [list -height	Int	15	0	"%d >= 0"] \
	    [list -ipadx	Int	0	0	"%d >= 0"] \
	    [list -ipady	Int	0	0	"%d >= 0"] \
	    [list -clean	Int	2	0	"%d >= 0 && %d <= 2"] \
	    [list -activeforeground	TkResource	""	0 button] \
	    [list -activebackground	TkResource	""	0 button] \
	    [list -disabledforeground 	TkResource	""	0 button] \
	    [list -foreground		TkResource	""	0 button] \
	    [list -background		TkResource	""	0 button] \
	    [list -state		TkResource	""	0 button] \
	    [list -troughcolor		TkResource	""	0 scrollbar] \
	    [list -arrowbd	Int	1	0	"%d >= 0 && %d <= 2"] \
	    [list -arrowrelief	Enum	raised	0	[list raised sunken]] \
	    [list -command		String	""	0] \
	    [list -armcommand		String	""	0] \
	    [list -disarmcommand	String	""	0] \
	    [list -repeatdelay		Int	0	0	"%d >= 0"] \
	    [list -repeatinterval	Int	0	0	"%d >= 0"] \
	    [list -fg	Synonym	-foreground] \
	    [list -bg	Synonym	-background] \
	    ]
    DynamicHelp::include ArrowButton balloon

    bind BwArrowButtonC <Enter>           {ArrowButton::_enter %W}
    bind BwArrowButtonC <Leave>           {ArrowButton::_leave %W}
    bind BwArrowButtonC <ButtonPress-1>   {ArrowButton::_press %W}
    bind BwArrowButtonC <ButtonRelease-1> {ArrowButton::_release %W}
    bind BwArrowButtonC <Key-space>       {ArrowButton::invoke %W; break}
    bind BwArrowButtonC <Return>          {ArrowButton::invoke %W; break}
    bind BwArrowButton <Configure>       {ArrowButton::_redraw_whole %W %w %h}
    bind BwArrowButton <Destroy>         {ArrowButton::_destroy %W}

    variable _grab
    variable _moved

    array set _grab {current "" pressed "" oldstate "normal" oldrelief ""}
}


# -----------------------------------------------------------------------------
#  Command ArrowButton::create
# -----------------------------------------------------------------------------
proc ArrowButton::create { path args } {
    # Initialize configuration mappings and parse arguments
    array set submaps [list ArrowButton [list ] .c [list ]]
    array set submaps [Widget::parseArgs ArrowButton $args]

    # Create the class frame (so we can do the option db queries)
    frame $path -class ArrowButton -borderwidth 0 -highlightthickness 0 
    Widget::initFromODB ArrowButton $path $submaps(ArrowButton)

    # Create the canvas with the initial options
    eval [list canvas $path.c] $submaps(.c)

    # Compute the width and height of the canvas from the width/height
    # of the ArrowButton and the borderwidth/hightlightthickness.
    set w   [Widget::getMegawidgetOption $path -width]
    set h   [Widget::getMegawidgetOption $path -height]
    set bd  [Widget::cget $path -borderwidth]
    set ht  [Widget::cget $path -highlightthickness]
    set pad [expr {2*($bd+$ht)}]

    $path.c configure -width [expr {$w-$pad}] -height [expr {$h-$pad}]
    bindtags $path [list $path BwArrowButton [winfo toplevel $path] all]
    bindtags $path.c [list $path.c BwArrowButtonC [winfo toplevel $path.c] all]
    pack $path.c -expand yes -fill both

    DynamicHelp::sethelp $path $path.c 1

    set ::ArrowButton::_moved($path) 0

    return [Widget::create ArrowButton $path]
}


# -----------------------------------------------------------------------------
#  Command ArrowButton::configure
# -----------------------------------------------------------------------------
proc ArrowButton::configure { path args } {
    set res [Widget::configure $path $args]

    set ch1 [expr {[Widget::hasChanged $path -width  w] |
                   [Widget::hasChanged $path -height h] |
                   [Widget::hasChanged $path -borderwidth bd] |
                   [Widget::hasChanged $path -highlightthickness ht]}]
    set ch2 [expr {[Widget::hasChanged $path -type    val] |
                   [Widget::hasChanged $path -ipadx   val] |
                   [Widget::hasChanged $path -ipady   val] |
                   [Widget::hasChanged $path -arrowbd val] |
                   [Widget::hasChanged $path -clean   val] |
                   [Widget::hasChanged $path -dir     val]}]

    if { $ch1 } {
        set pad [expr {2*($bd+$ht)}]
        $path.c configure \
            -width [expr {$w-$pad}] -height [expr {$h-$pad}] \
            -borderwidth $bd -highlightthickness $ht
	set ch2 1
    }
    if { $ch2 } {
        _redraw_whole $path [winfo width $path] [winfo height $path]
    } else {
        _redraw_relief $path
        _redraw_state $path
    }
    DynamicHelp::sethelp $path $path.c

    return $res
}


# -----------------------------------------------------------------------------
#  Command ArrowButton::cget
# -----------------------------------------------------------------------------
proc ArrowButton::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::invoke
# ------------------------------------------------------------------------------
proc ArrowButton::invoke { path } {
    if { ![string equal [winfo class $path] "ArrowButton"] } {
	set path [winfo parent $path]
    }
    if { ![string equal [Widget::getoption $path -state] "disabled"] } {
        set oldstate [Widget::getoption $path -state]
        if { [string equal [Widget::getoption $path -type] "button"] } {
            set oldrelief [Widget::getoption $path -relief]
            configure $path -state active -relief sunken
        } else {
            set oldrelief [Widget::getoption $path -arrowrelief]
            configure $path -state active -arrowrelief sunken
        }
	update idletasks
        if {[llength [set cmd [Widget::getoption $path -armcommand]]]} {
            uplevel \#0 $cmd
        }
	after 10
        if { [string equal [Widget::getoption $path -type] "button"] } {
            configure $path -state $oldstate -relief $oldrelief
        } else {
            configure $path -state $oldstate -arrowrelief $oldrelief
        }
        if {[llength [set cmd [Widget::getoption $path -disarmcommand]]]} {
            uplevel \#0 $cmd
        }
        if {[llength [set cmd [Widget::getoption $path -command]]]} {
            uplevel \#0 $cmd
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_redraw
# ------------------------------------------------------------------------------
proc ArrowButton::_redraw { path width height } {
    variable _moved

    set _moved($path) 0
    set type  [Widget::getoption $path -type]
    set dir   [Widget::getoption $path -dir]
    set bd    [expr {[$path.c cget -borderwidth] + [$path.c cget -highlightthickness] + 1}]
    set clean [Widget::getoption $path -clean]
    if { [string equal $type "arrow"] } {
        if { [set id [$path.c find withtag rect]] == "" } {
            $path.c create rectangle $bd $bd [expr {$width-$bd-1}] [expr {$height-$bd-1}] -tags rect
        } else {
            $path.c coords $id $bd $bd [expr {$width-$bd-1}] [expr {$height-$bd-1}]
        }
        $path.c lower rect
        set arrbd [Widget::getoption $path -arrowbd]
        set bd    [expr {$bd+$arrbd-1}]
    } else {
        $path.c delete rect
    }
    # w and h are max width and max height of arrow
    set w [expr {$width  - 2*([Widget::getoption $path -ipadx]+$bd)}]
    set h [expr {$height - 2*([Widget::getoption $path -ipady]+$bd)}]

    if { $w < 2 } {set w 2}
    if { $h < 2 } {set h 2}

    if { $clean > 0 } {
        # arrange for base to be odd
        if { [string equal $dir "top"] || [string equal $dir "bottom"] } {
            if { !($w % 2) } {
                incr w -1
            }
            if { $clean == 2 } {
                # arrange for h = (w+1)/2
                set h2 [expr {($w+1)/2}]
                if { $h2 > $h } {
                    set w [expr {2*$h-1}]
                } else {
                    set h $h2
                }
            }
        } else {
            if { !($h % 2) } {
                incr h -1
            }
            if { $clean == 2 } {
                # arrange for w = (h+1)/2
                set w2 [expr {($h+1)/2}]
                if { $w2 > $w } {
                    set h [expr {2*$w-1}]
                } else {
                    set w $w2
                }
            }
        }
    }

    set x0 [expr {($width-$w)/2}]
    set y0 [expr {($height-$h)/2}]
    set x1 [expr {$x0+$w-1}]
    set y1 [expr {$y0+$h-1}]

    switch $dir {
        top {
            set xd [expr {($x0+$x1)/2}]
            if { [set id [$path.c find withtag poly]] == "" } {
                $path.c create polygon $x0 $y1 $x1 $y1 $xd $y0 -tags poly
            } else {
                $path.c coords $id $x0 $y1 $x1 $y1 $xd $y0
            }
            if { [string equal $type "arrow"] } {
                if { [set id [$path.c find withtag bot]] == "" } {
                    $path.c create line $x0 $y1 $x1 $y1 $xd $y0 -tags bot
                } else {
                    $path.c coords $id $x0 $y1 $x1 $y1 $xd $y0
                }
                if { [set id [$path.c find withtag top]] == "" } {
                    $path.c create line $x0 $y1 $xd $y0 -tags top
                } else {
                    $path.c coords $id $x0 $y1 $xd $y0
                }
                $path.c itemconfigure top -width $arrbd
                $path.c itemconfigure bot -width $arrbd
            } else {
                $path.c delete top
                $path.c delete bot
            }
        }
        bottom {
            set xd [expr {($x0+$x1)/2}]
            if { [set id [$path.c find withtag poly]] == "" } {
                $path.c create polygon $x1 $y0 $x0 $y0 $xd $y1 -tags poly
            } else {
                $path.c coords $id $x1 $y0 $x0 $y0 $xd $y1
            }
            if { [string equal $type "arrow"] } {
                if { [set id [$path.c find withtag top]] == "" } {
                    $path.c create line $x1 $y0 $x0 $y0 $xd $y1 -tags top
                } else {
                    $path.c coords $id $x1 $y0 $x0 $y0 $xd $y1
                }
                if { [set id [$path.c find withtag bot]] == "" } {
                    $path.c create line $x1 $y0 $xd $y1 -tags bot
                } else {
                    $path.c coords $id $x1 $y0 $xd $y1
                }
                $path.c itemconfigure top -width $arrbd
                $path.c itemconfigure bot -width $arrbd
            } else {
                $path.c delete top
                $path.c delete bot
            }
        }
        left {
            set yd [expr {($y0+$y1)/2}]
            if { [set id [$path.c find withtag poly]] == "" } {
                $path.c create polygon $x1 $y0 $x1 $y1 $x0 $yd -tags poly
            } else {
                $path.c coords $id $x1 $y0 $x1 $y1 $x0 $yd
            }
            if { [string equal $type "arrow"] } {
                if { [set id [$path.c find withtag bot]] == "" } {
                    $path.c create line $x1 $y0 $x1 $y1 $x0 $yd -tags bot
                } else {
                    $path.c coords $id $x1 $y0 $x1 $y1 $x0 $yd
                }
                if { [set id [$path.c find withtag top]] == "" } {
                    $path.c create line $x1 $y0 $x0 $yd -tags top
                } else {
                    $path.c coords $id $x1 $y0 $x0 $yd
                }
                $path.c itemconfigure top -width $arrbd
                $path.c itemconfigure bot -width $arrbd
            } else {
                $path.c delete top
                $path.c delete bot
            }
        }
        right {
            set yd [expr {($y0+$y1)/2}]
            if { [set id [$path.c find withtag poly]] == "" } {
                $path.c create polygon $x0 $y1 $x0 $y0 $x1 $yd -tags poly
            } else {
                $path.c coords $id $x0 $y1 $x0 $y0 $x1 $yd
            }
            if { [string equal $type "arrow"] } {
                if { [set id [$path.c find withtag top]] == "" } {
                    $path.c create line $x0 $y1 $x0 $y0 $x1 $yd -tags top
                } else {
                    $path.c coords $id $x0 $y1 $x0 $y0 $x1 $yd
                }
                if { [set id [$path.c find withtag bot]] == "" } {
                    $path.c create line $x0 $y1 $x1 $yd -tags bot
                } else {
                    $path.c coords $id $x0 $y1 $x1 $yd
                }
                $path.c itemconfigure top -width $arrbd
                $path.c itemconfigure bot -width $arrbd
            } else {
                $path.c delete top
                $path.c delete bot
            }
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_redraw_state
# ------------------------------------------------------------------------------
proc ArrowButton::_redraw_state { path } {
    set state [Widget::getoption $path -state]
    if { [string equal [Widget::getoption $path -type] "button"] } {
        switch $state {
            normal   {set bg -background;       set fg -foreground}
            active   {set bg -activebackground; set fg -activeforeground}
            disabled {set bg -background;       set fg -disabledforeground}
        }
        set fg [Widget::getoption $path $fg]
        $path.c configure -background [Widget::getoption $path $bg]
        $path.c itemconfigure poly -fill $fg -outline $fg
    } else {
        switch $state {
            normal   {set stipple "";     set bg [Widget::getoption $path -background] }
            active   {set stipple "";     set bg [Widget::getoption $path -activebackground] }
            disabled {set stipple gray50; set bg black }
        }
        set thrc [Widget::getoption $path -troughcolor]
        $path.c configure -background [Widget::getoption $path -background]
        $path.c itemconfigure rect -fill $thrc -outline $thrc
        $path.c itemconfigure poly -fill $bg   -outline $bg -stipple $stipple
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_redraw_relief
# ------------------------------------------------------------------------------
proc ArrowButton::_redraw_relief { path } {
    variable _moved

    if { [string equal [Widget::getoption $path -type] "button"] } {
        if { [string equal [Widget::getoption $path -relief] "sunken"] } {
            if { !$_moved($path) } {
                $path.c move poly 1 1
                set _moved($path) 1
            }
        } else {
            if { $_moved($path) } {
                $path.c move poly -1 -1
                set _moved($path) 0
            }
        }
    } else {
        set col3d [BWidget::get3dcolor $path [Widget::getoption $path -background]]
        switch [Widget::getoption $path -arrowrelief] {
            raised {set top [lindex $col3d 1]; set bot [lindex $col3d 0]}
            sunken {set top [lindex $col3d 0]; set bot [lindex $col3d 1]}
        }
        $path.c itemconfigure top -fill $top
        $path.c itemconfigure bot -fill $bot
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_redraw_whole
# ------------------------------------------------------------------------------
proc ArrowButton::_redraw_whole { path width height } {
    _redraw $path $width $height
    _redraw_relief $path
    _redraw_state $path
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_enter
# ------------------------------------------------------------------------------
proc ArrowButton::_enter { path } {
    variable _grab
    set path [winfo parent $path]
    set _grab(current) $path
    if { ![string equal [Widget::getoption $path -state] "disabled"] } {
        set _grab(oldstate) [Widget::getoption $path -state]
        configure $path -state active
        if { $_grab(pressed) == $path } {
            if { [string equal [Widget::getoption $path -type] "button"] } {
                set _grab(oldrelief) [Widget::getoption $path -relief]
                configure $path -relief sunken
            } else {
                set _grab(oldrelief) [Widget::getoption $path -arrowrelief]
                configure $path -arrowrelief sunken
            }
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_leave
# ------------------------------------------------------------------------------
proc ArrowButton::_leave { path } {
    variable _grab
    set path [winfo parent $path]
    set _grab(current) ""
    if { ![string equal [Widget::getoption $path -state] "disabled"] } {
        configure $path -state $_grab(oldstate)
        if { $_grab(pressed) == $path } {
            if { [string equal [Widget::getoption $path -type] "button"] } {
                configure $path -relief $_grab(oldrelief)
            } else {
                configure $path -arrowrelief $_grab(oldrelief)
            }
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_press
# ------------------------------------------------------------------------------
proc ArrowButton::_press { path } {
    variable _grab
    set path [winfo parent $path]
    if { ![string equal [Widget::getoption $path -state] "disabled"] } {
        set _grab(pressed) $path
            if { [string equal [Widget::getoption $path -type] "button"] } {
            set _grab(oldrelief) [Widget::getoption $path -relief]
            configure $path -relief sunken
        } else {
            set _grab(oldrelief) [Widget::getoption $path -arrowrelief]
            configure $path -arrowrelief sunken
        }
        if {[llength [set cmd [Widget::getoption $path -armcommand]]]} {
            uplevel \#0 $cmd
            if { [set delay [Widget::getoption $path -repeatdelay]]    > 0 ||
                 [set delay [Widget::getoption $path -repeatinterval]] > 0 } {
                after $delay [list ArrowButton::_repeat $path]
            }
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_release
# ------------------------------------------------------------------------------
proc ArrowButton::_release { path } {
    variable _grab
    set path [winfo parent $path]
    if { $_grab(pressed) == $path } {
        set _grab(pressed) ""
            if { [string equal [Widget::getoption $path -type] "button"] } {
            configure $path -relief $_grab(oldrelief)
        } else {
            configure $path -arrowrelief $_grab(oldrelief)
        }
        if {[llength [set cmd [Widget::getoption $path -disarmcommand]]]} {
            uplevel \#0 $cmd
        }
        if { $_grab(current) == $path &&
             ![string equal [Widget::getoption $path -state] "disabled"] &&
             [llength [set cmd [Widget::getoption $path -command]]]} {
            uplevel \#0 $cmd
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_repeat
# ------------------------------------------------------------------------------
proc ArrowButton::_repeat { path } {
    variable _grab
    if { $_grab(current) == $path && $_grab(pressed) == $path &&
         ![string equal [Widget::getoption $path -state] "disabled"] &&
         [llength [set cmd [Widget::getoption $path -armcommand]]]} {
        uplevel \#0 $cmd
    }
    if { $_grab(pressed) == $path &&
         ([set delay [Widget::getoption $path -repeatinterval]] > 0 ||
          [set delay [Widget::getoption $path -repeatdelay]]    > 0) } {
        after $delay [list ArrowButton::_repeat $path]
    }
}


# ------------------------------------------------------------------------------
#  Command ArrowButton::_destroy
# ------------------------------------------------------------------------------
proc ArrowButton::_destroy { path } {
    variable _moved
    Widget::destroy $path
    unset _moved($path)
}
