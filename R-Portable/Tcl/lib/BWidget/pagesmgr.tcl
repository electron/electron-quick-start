# ------------------------------------------------------------------------------
#  pagesmgr.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: pagesmgr.tcl,v 1.6.2.1 2011/02/14 16:56:09 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - PagesManager::create
#     - PagesManager::configure
#     - PagesManager::cget
#     - PagesManager::compute_size
#     - PagesManager::add
#     - PagesManager::delete
#     - PagesManager::raise
#     - PagesManager::page
#     - PagesManager::pages
#     - PagesManager::getframe
#     - PagesManager::_test_page
#     - PagesManager::_select
#     - PagesManager::_redraw
#     - PagesManager::_draw_area
#     - PagesManager::_realize
# ------------------------------------------------------------------------------
package require Tcl 8.1.1

namespace eval PagesManager {
    Widget::define PagesManager pagesmgr

    Widget::declare PagesManager {
        {-background TkResource "" 0 frame}
        {-cursor     TkResource "" 0 frame}
        {-width      Int        0  0 "%d >= 0"}
        {-height     Int        0  0 "%d >= 0"}
    }

    Widget::addmap PagesManager "" :cmd { -width {} -height {} -cursor {} }
}


# ------------------------------------------------------------------------------
#  Command PagesManager::create
# ------------------------------------------------------------------------------
proc PagesManager::create { path args } {
    variable $path
    upvar 0  $path data

    Widget::init PagesManager $path $args

    set data(select)   ""
    set data(pages)    {}
    set data(cpt)      0
    set data(realized) 0

    # --- creation du canvas -----------------------------------------------------------------
    eval canvas $path -relief flat -bd 0 -highlightthickness 0 \
	    [Widget::subcget $path :cmd]

    bind $path <Configure> [list PagesManager::_realize $path]
    bind $path <Destroy>   [list PagesManager::_destroy $path]

    return [Widget::create PagesManager $path]
}


# ------------------------------------------------------------------------------
#  Command PagesManager::configure
# ------------------------------------------------------------------------------
proc PagesManager::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command PagesManager::cget
# ------------------------------------------------------------------------------
proc PagesManager::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command PagesManager::compute_size
# ------------------------------------------------------------------------------
proc PagesManager::compute_size { path } {
    variable $path
    upvar 0  $path data

    set wmax 0
    set hmax 0
    update idletasks
    foreach page $data(pages) {
        set w    [winfo reqwidth  $path.f$page]
        set h    [winfo reqheight $path.f$page]
        set wmax [expr {$w>$wmax ? $w : $wmax}]
        set hmax [expr {$h>$hmax ? $h : $hmax}]
    }
    configure $path -width $wmax -height $hmax
}


# ------------------------------------------------------------------------------
#  Command PagesManager::add
# ------------------------------------------------------------------------------
proc PagesManager::add { path page } {
    variable $path
    upvar 0  $path data

    if { [lsearch -exact $data(pages) $page] != -1 } {
        return -code error "page \"$page\" already exists"
    }

    lappend data(pages) $page

    if {[Widget::theme]} {
        ttk::frame $path.f$page
    }  else  {
        frame $path.f$page -relief flat \
            -background [Widget::cget $path -background] -borderwidth 0
    }

    return $path.f$page
}


# ------------------------------------------------------------------------------
#  Command PagesManager::delete
# ------------------------------------------------------------------------------
proc PagesManager::delete { path page } {
    variable $path
    upvar 0  $path data

    set pos [_test_page $path $page]
    set data(pages) [lreplace $data(pages) $pos $pos]
    if { $data(select) == $page } {
        set data(select) ""
    }
    destroy $path.f$page
    _redraw $path
}


# ------------------------------------------------------------------------------
#  Command PagesManager::raise
# ------------------------------------------------------------------------------
proc PagesManager::raise { path {page ""} } {
    variable $path
    upvar 0  $path data

    if { $page != "" } {
        _test_page $path $page
        _select $path $page
    }
    return $data(select)
}


# ------------------------------------------------------------------------------
#  Command PagesManager::page - deprecated, use pages
# ------------------------------------------------------------------------------
proc PagesManager::page { path first {last ""} } {
    variable $path
    upvar 0  $path data

    if { $last == "" } {
        return [lindex $data(pages) $first]
    } else {
        return [lrange $data(pages) $first $last]
    }
}


# ------------------------------------------------------------------------------
#  Command PagesManager::pages
# ------------------------------------------------------------------------------
proc PagesManager::pages { path {first ""} {last ""} } {
    variable $path
    upvar 0  $path data

    if { ![string length $first] } {
	return $data(pages)
    }

    if { ![string length $last] } {
        return [lindex $data(pages) $first]
    } else {
        return [lrange $data(pages) $first $last]
    }
}


# ------------------------------------------------------------------------------
#  Command PagesManager::getframe
# ------------------------------------------------------------------------------
proc PagesManager::getframe { path page } {
    return $path.f$page
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_test_page
# ------------------------------------------------------------------------------
proc PagesManager::_test_page { path page } {
    variable $path
    upvar 0  $path data

    if { [set pos [lsearch $data(pages) $page]] == -1 } {
        return -code error "page \"$page\" does not exists"
    }
    return $pos
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_select
# ------------------------------------------------------------------------------
proc PagesManager::_select { path page } {
    variable $path
    upvar 0  $path data

    set oldsel $data(select)
    if { $page != $oldsel } {
        set data(select) $page
        _draw_area $path
    }
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_redraw
# ------------------------------------------------------------------------------
proc PagesManager::_redraw { path } {
    variable $path
    upvar 0  $path data

    if { !$data(realized) } {
        return
    }
    _draw_area $path
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_draw_area
# ------------------------------------------------------------------------------
proc PagesManager::_draw_area { path } {
    variable $path
    upvar 0  $path data

    set w   [winfo width  $path]
    set h   [winfo height $path]
    set sel $data(select)
    if { $sel != "" } {
        if { [llength [$path:cmd find withtag "window"]] } {
            $path:cmd coords "window" 0 0
            $path:cmd itemconfigure "window"    \
                -width  $w        \
                -height $h    \
                -window $path.f$sel
        } else {
            $path:cmd create window 0 0 \
                -width  $w          \
                -height $h       \
                -anchor nw                      \
                -tags   "window"                \
                -window $path.f$sel
        }
    } else {
        $path:cmd delete "window"
    }
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_realize
# ------------------------------------------------------------------------------
proc PagesManager::_realize { path } {
    variable $path
    upvar 0  $path data

    if { [set width  [Widget::cget $path -width]]  == 0 ||
         [set height [Widget::cget $path -height]] == 0 } {
        compute_size $path
    }

    set data(realized) 1
    _draw_area $path
    bind $path <Configure> [list PagesManager::_draw_area $path]
}


# ------------------------------------------------------------------------------
#  Command PagesManager::_destroy
# ------------------------------------------------------------------------------
proc PagesManager::_destroy { path } {
    variable $path
    upvar 0  $path data
    Widget::destroy $path
    unset data
}
