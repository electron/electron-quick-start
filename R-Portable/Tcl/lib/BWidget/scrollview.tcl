# ------------------------------------------------------------------------------
#  scrollview.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: scrollview.tcl,v 1.7 2003/11/05 18:04:29 hobbs Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - ScrolledWindow::create
#     - ScrolledWindow::configure
#     - ScrolledWindow::cget
#     - ScrolledWindow::_set_hscroll
#     - ScrolledWindow::_set_vscroll
#     - ScrolledWindow::_update_scroll
#     - ScrolledWindow::_set_view
#     - ScrolledWindow::_resize
# ------------------------------------------------------------------------------

namespace eval ScrollView {
    Widget::define ScrollView scrollview

    Widget::tkinclude ScrollView canvas :cmd \
	    include {-relief -borderwidth -background -width -height -cursor} \
	    initialize {-relief flat -borderwidth 0 -width 30 -height 30 \
		-cursor crosshair}

    Widget::declare ScrollView {
        {-width       TkResource 30        0 canvas}
        {-height      TkResource 30        0 canvas}
        {-background  TkResource ""        0 canvas}
        {-foreground  String     black     0}
        {-fill        String     ""        0}
        {-relief      TkResource flat      0 canvas}
        {-borderwidth TkResource 0         0 canvas}
        {-cursor      TkResource crosshair 0 canvas}
        {-window      String     ""        0}
        {-fg          Synonym    -foreground}
        {-bg          Synonym    -background}
        {-bd          Synonym    -borderwidth}
    }

    bind BwScrollView <B1-Motion>   [list ScrollView::_set_view %W motion %x %y]
    bind BwScrollView <ButtonPress-1> [list ScrollView::_set_view %W set %x %y]
    bind BwScrollView <Configure>     [list ScrollView::_resize %W]
    bind BwScrollView <Destroy>       [list ScrollView::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command ScrollView::create
# ------------------------------------------------------------------------------
proc ScrollView::create { path args } {
    Widget::init ScrollView $path $args
    eval [list canvas $path] [Widget::subcget $path :cmd] -highlightthickness 0

    Widget::create ScrollView $path

    Widget::getVariable $path _widget

    set w               [Widget::cget $path -window]
    set _widget(bd)     [Widget::cget $path -borderwidth]
    set _widget(width)  [Widget::cget $path -width]
    set _widget(height) [Widget::cget $path -height]

    if {[winfo exists $w]} {
        set _widget(oldxscroll) [$w cget -xscrollcommand]
        set _widget(oldyscroll) [$w cget -yscrollcommand]
        $w configure \
            -xscrollcommand [list ScrollView::_set_hscroll $path] \
            -yscrollcommand [list ScrollView::_set_vscroll $path]
    }
    $path:cmd create rectangle -2 -2 -2 -2 \
        -fill    [Widget::cget $path -fill]       \
        -outline [Widget::cget $path -foreground] \
        -tags    view

    bindtags $path [list $path BwScrollView [winfo toplevel $path] all]

    return $path
}


# ------------------------------------------------------------------------------
#  Command ScrollView::configure
# ------------------------------------------------------------------------------
proc ScrollView::configure { path args } {
    Widget::getVariable $path _widget

    set oldw [Widget::getoption $path -window] 
    set res  [Widget::configure $path $args]

    if { [Widget::hasChanged $path -window w] } {
        if { [winfo exists $oldw] } {
            $oldw configure \
                -xscrollcommand $_widget(oldxscroll) \
                -yscrollcommand $_widget(oldyscroll)
        }
        if { [winfo exists $w] } {
            set _widget(oldxscroll) [$w cget -xscrollcommand]
            set _widget(oldyscroll) [$w cget -yscrollcommand]
            $w configure \
                -xscrollcommand [list ScrollView::_set_hscroll $path] \
                -yscrollcommand [list ScrollView::_set_vscroll $path]
        } else {
            $path:cmd coords view -2 -2 -2 -2
            set _widget(oldxscroll) {}
            set _widget(oldyscroll) {}
        }
    }

    if { [Widget::hasChanged $path -fill fill] |
         [Widget::hasChanged $path -foreground fg] } {
        $path:cmd itemconfigure view \
            -fill    $fill \
            -outline $fg
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command ScrollView::cget
# ------------------------------------------------------------------------------
proc ScrollView::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_set_hscroll
# ------------------------------------------------------------------------------
proc ScrollView::_set_hscroll { path vmin vmax } {
    Widget::getVariable $path _widget

    set c  [$path:cmd coords view]
    set x0 [expr {$vmin*$_widget(width)+$_widget(bd)}]
    set x1 [expr {$vmax*$_widget(width)+$_widget(bd)-1}]
    $path:cmd coords view $x0 [lindex $c 1] $x1 [lindex $c 3]
    if { $_widget(oldxscroll) != "" } {
        uplevel \#0 $_widget(oldxscroll) $vmin $vmax
    }
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_set_vscroll
# ------------------------------------------------------------------------------
proc ScrollView::_set_vscroll { path vmin vmax } {
    Widget::getVariable $path _widget

    set c  [$path:cmd coords view]
    set y0 [expr {$vmin*$_widget(height)+$_widget(bd)}]
    set y1 [expr {$vmax*$_widget(height)+$_widget(bd)-1}]
    $path:cmd coords view [lindex $c 0] $y0 [lindex $c 2] $y1
    if { $_widget(oldyscroll) != "" } {
        uplevel \#0 $_widget(oldyscroll) $vmin $vmax
    }
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_update_scroll
# ------------------------------------------------------------------------------
proc ScrollView::_update_scroll { path callscroll hminmax vminmax } {
    Widget::getVariable $path _widget

    set c    [$path:cmd coords view]
    set hmin [lindex $hminmax 0]
    set hmax [lindex $hminmax 1]
    set vmin [lindex $vminmax 0]
    set vmax [lindex $vminmax 1]
    set x0   [expr {$hmin*$_widget(width)+$_widget(bd)}]
    set x1   [expr {$hmax*$_widget(width)+$_widget(bd)-1}]
    set y0   [expr {$vmin*$_widget(height)+$_widget(bd)}]
    set y1   [expr {$vmax*$_widget(height)+$_widget(bd)-1}]
    $path:cmd coords view $x0 $y0 $x1 $y1
    if { $callscroll } {
        if { $_widget(oldxscroll) != "" } {
            uplevel \#0 $_widget(oldxscroll) $hmin $hmax
        }
        if { $_widget(oldyscroll) != "" } {
            uplevel \#0 $_widget(oldyscroll) $vmin $vmax
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_set_view
# ------------------------------------------------------------------------------
proc ScrollView::_set_view { path cmd x y } {
    Widget::getVariable $path _widget

    set w [Widget::getoption $path -window]
    if {[winfo exists $w]} {
        if {[string equal $cmd "set"]} {
            set c  [$path:cmd coords view]
            set x0 [lindex $c 0]
            set y0 [lindex $c 1]
            set x1 [lindex $c 2]
            set y1 [lindex $c 3]
            if {$x >= $x0 && $x <= $x1 &&
                $y >= $y0 && $y <= $y1} {
                set _widget(dx) [expr {$x-$x0}]
                set _widget(dy) [expr {$y-$y0}]
                return
            } else {
                set x0 [expr {$x-($x1-$x0)/2}]
                set y0 [expr {$y-($y1-$y0)/2}]
                set _widget(dx) [expr {$x-$x0}]
                set _widget(dy) [expr {$y-$y0}]
                set vh [expr {double($x0-$_widget(bd))/$_widget(width)}]
                set vv [expr {double($y0-$_widget(bd))/$_widget(height)}]
            }
        } elseif {[string equal $cmd "motion"]} {
            set vh [expr {double($x-$_widget(dx)-$_widget(bd))/$_widget(width)}]
            set vv [expr {double($y-$_widget(dy)-$_widget(bd))/$_widget(height)}]
        }
        $w xview moveto $vh
        $w yview moveto $vv
        _update_scroll $path 1 [$w xview] [$w yview]
    }
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_resize
# ------------------------------------------------------------------------------
proc ScrollView::_resize { path } {
    Widget::getVariable $path _widget

    set _widget(bd)     [Widget::getoption $path -borderwidth]
    set _widget(width)  [expr {[winfo width  $path]-2*$_widget(bd)}]
    set _widget(height) [expr {[winfo height $path]-2*$_widget(bd)}]
    set w [Widget::getoption $path -window]
    if { [winfo exists $w] } {
        _update_scroll $path 0 [$w xview] [$w yview]
    }
}


# ------------------------------------------------------------------------------
#  Command ScrollView::_destroy
# ------------------------------------------------------------------------------
proc ScrollView::_destroy { path } {
    Widget::getVariable $path _widget

    set w [Widget::getoption $path -window] 
    if { [winfo exists $w] } {
        $w configure \
            -xscrollcommand $_widget(oldxscroll) \
            -yscrollcommand $_widget(oldyscroll)
    }
    Widget::destroy $path
}
