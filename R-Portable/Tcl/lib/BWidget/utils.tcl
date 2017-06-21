# ----------------------------------------------------------------------------
#  utils.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: utils.tcl,v 1.15.2.1 2009/09/03 17:29:03 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - GlobalVar::exists
#     - GlobalVar::setvarvar
#     - GlobalVar::getvarvar
#     - BWidget::assert
#     - BWidget::clonename
#     - BWidget::get3dcolor
#     - BWidget::XLFDfont
#     - BWidget::place
#     - BWidget::grab
#     - BWidget::focus
# ----------------------------------------------------------------------------

namespace eval GlobalVar {
    proc use {} {}
}


namespace eval BWidget {
    variable _top
    variable _gstack {}
    variable _fstack {}
    proc use {} {}
}


# ----------------------------------------------------------------------------
#  Command GlobalVar::exists
# ----------------------------------------------------------------------------
proc GlobalVar::exists { varName } {
    return [uplevel \#0 [list info exists $varName]]
}


# ----------------------------------------------------------------------------
#  Command GlobalVar::setvar
# ----------------------------------------------------------------------------
proc GlobalVar::setvar { varName value } {
    return [uplevel \#0 [list set $varName $value]]
}


# ----------------------------------------------------------------------------
#  Command GlobalVar::getvar
# ----------------------------------------------------------------------------
proc GlobalVar::getvar { varName } {
    return [uplevel \#0 [list set $varName]]
}


# ----------------------------------------------------------------------------
#  Command GlobalVar::tracevar
# ----------------------------------------------------------------------------
proc GlobalVar::tracevar { cmd varName args } {
    return [uplevel \#0 [list trace $cmd $varName] $args]
}



# ----------------------------------------------------------------------------
#  Command BWidget::lreorder
# ----------------------------------------------------------------------------
proc BWidget::lreorder { list neworder } {
    set pos     0
    set newlist {}
    foreach e $neworder {
        if { [lsearch -exact $list $e] != -1 } {
            lappend newlist $e
            set tabelt($e)  1
        }
    }
    set len [llength $newlist]
    if { !$len } {
        return $list
    }
    if { $len == [llength $list] } {
        return $newlist
    }
    set pos 0
    foreach e $list {
        if { ![info exists tabelt($e)] } {
            set newlist [linsert $newlist $pos $e]
        }
        incr pos
    }
    return $newlist
}


# ----------------------------------------------------------------------------
#  Command BWidget::assert
# ----------------------------------------------------------------------------
proc BWidget::assert { exp {msg ""}} {
    set res [uplevel 1 expr $exp]
    if { !$res} {
        if { $msg == "" } {
            return -code error "Assertion failed: {$exp}"
        } else {
            return -code error $msg
        }
    }
}


# ----------------------------------------------------------------------------
#  Command BWidget::clonename
# ----------------------------------------------------------------------------
proc BWidget::clonename { menu } {
    set path     ""
    set menupath ""
    set found    0
    foreach widget [lrange [split $menu "."] 1 end] {
        if { $found || [winfo class "$path.$widget"] == "Menu" } {
            set found 1
            append menupath "#" $widget
            append path "." $menupath
        } else {
            append menupath "#" $widget
            append path "." $widget
        }
    }
    return $path
}


# ----------------------------------------------------------------------------
#  Command BWidget::getname
# ----------------------------------------------------------------------------
proc BWidget::getname { name } {
    if { [string length $name] } {
        set text [option get . "${name}Name" ""]
        if { [string length $text] } {
            return [parsetext $text]
        }
    }
    return {}
 }


# ----------------------------------------------------------------------------
#  Command BWidget::parsetext
# ----------------------------------------------------------------------------
proc BWidget::parsetext { text } {
    set result ""
    set index  -1
    set start  0
    while { [string length $text] } {
        set idx [string first "&" $text]
        if { $idx == -1 } {
            append result $text
            set text ""
        } else {
            set char [string index $text [expr {$idx+1}]]
            if { $char == "&" } {
                append result [string range $text 0 $idx]
                set    text   [string range $text [expr {$idx+2}] end]
                set    start  [expr {$start+$idx+1}]
            } else {
                append result [string range $text 0 [expr {$idx-1}]]
                set    text   [string range $text [expr {$idx+1}] end]
                incr   start  $idx
                set    index  $start
            }
        }
    }
    return [list $result $index]
}


# ----------------------------------------------------------------------------
#  Command BWidget::get3dcolor
# ----------------------------------------------------------------------------
proc BWidget::get3dcolor { path bgcolor } {
    foreach val [winfo rgb $path $bgcolor] {
        lappend dark [expr {60*$val/100}]
        set tmp1 [expr {14*$val/10}]
        if { $tmp1 > 65535 } {
            set tmp1 65535
        }
        set tmp2 [expr {(65535+$val)/2}]
        lappend light [expr {($tmp1 > $tmp2) ? $tmp1:$tmp2}]
    }
    return [list [eval format "#%04x%04x%04x" $dark] [eval format "#%04x%04x%04x" $light]]
}


# ----------------------------------------------------------------------------
#  Command BWidget::XLFDfont
# ----------------------------------------------------------------------------
proc BWidget::XLFDfont { cmd args } {
    switch -- $cmd {
        create {
            set font "-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
        }
        configure {
            set font [lindex $args 0]
            set args [lrange $args 1 end]
        }
        default {
            return -code error "XLFDfont: commande incorrect: $cmd"
        }
    }
    set lfont [split $font "-"]
    if { [llength $lfont] != 15 } {
        return -code error "XLFDfont: description XLFD incorrect: $font"
    }

    foreach {option value} $args {
        switch -- $option {
            -foundry { set index 1 }
            -family  { set index 2 }
            -weight  { set index 3 }
            -slant   { set index 4 }
            -size    { set index 7 }
            default  { return -code error "XLFDfont: option incorrecte: $option" }
        }
        set lfont [lreplace $lfont $index $index $value]
    }
    return [join $lfont "-"]
}



# ----------------------------------------------------------------------------
#  Command BWidget::place
# ----------------------------------------------------------------------------
#
# Notes:
#  For Windows systems with more than one monitor the available screen area may
#  have negative positions. Geometry settings with negative numbers are used
#  under X to place wrt the right or bottom of the screen. On windows, Tk
#  continues to do this. However, a geometry such as 100x100+-200-100 can be
#  used to place a window onto a secondary monitor. Passing the + gets Tk
#  to pass the remainder unchanged so the Windows manager then handles -200
#  which is a position on the left hand monitor.
#  I've tested this for left, right, above and below the primary monitor.
#  Currently there is no way to ask Tk the extent of the Windows desktop in 
#  a multi monitor system. Nor what the legal co-ordinate range might be.
#
proc BWidget::place { path w h args } {
    variable _top

    update idletasks

    # If the window is not mapped, it may have any current size.
    # Then use required size, but bound it to the screen width.
    # This is mostly inexact, because any toolbars will still be removed
    # which may reduce size.
    if { $w == 0 && [winfo ismapped $path] } {
        set w [winfo width $path]
    } else {
        if { $w == 0 } {
            set w [winfo reqwidth $path]
        }
        set vsw [winfo vrootwidth  $path]
        if { $w > $vsw } { set w $vsw }
    }

    if { $h == 0 && [winfo ismapped $path] } {
        set h [winfo height $path]
    } else {
        if { $h == 0 } {
            set h [winfo reqheight $path]
        }
        set vsh [winfo vrootheight $path]
        if { $h > $vsh } { set h $vsh }
    }

    set arglen [llength $args]
    if { $arglen > 3 } {
        return -code error "BWidget::place: bad number of argument"
    }

    if { $arglen > 0 } {
        set where [lindex $args 0]
	set list  [list "at" "center" "left" "right" "above" "below"]
        set idx   [lsearch $list $where]
        if { $idx == -1 } {
	    return -code error [BWidget::badOptionString position $where $list]
        }
        if { $idx == 0 } {
            set err [catch {
                # purposely removed the {} around these expressions - [PT]
                set x [expr int([lindex $args 1])]
                set y [expr int([lindex $args 2])]
            }]
            if { $err } {
                return -code error "BWidget::place: incorrect position"
            }
            if {$::tcl_platform(platform) == "windows"} {
                # handle windows multi-screen. -100 != +-100
                if {[string index [lindex $args 1] 0] != "-"} {
                    set x "+$x"
                }
                if {[string index [lindex $args 2] 0] != "-"} {
                    set y "+$y"
                }
            } else {
                if { $x >= 0 } {
                    set x "+$x"
                }
                if { $y >= 0 } {
                    set y "+$y"
                }
            }
        } else {
            if { $arglen == 2 } {
                set widget [lindex $args 1]
                if { ![winfo exists $widget] } {
                    return -code error "BWidget::place: \"$widget\" does not exist"
                }
	    } else {
		set widget .
	    }
            set sw [winfo screenwidth  $path]
            set sh [winfo screenheight $path]
            if { $idx == 1 } {
                if { $arglen == 2 } {
                    # center to widget
                    set x0 [expr {[winfo rootx $widget] + ([winfo width  $widget] - $w)/2}]
                    set y0 [expr {[winfo rooty $widget] + ([winfo height $widget] - $h)/2}]
                } else {
                    # center to screen
                    set x0 [expr {($sw - $w)/2 - [winfo vrootx $path]}]
                    set y0 [expr {($sh - $h)/2 - [winfo vrooty $path]}]
                }
                set x "+$x0"
                set y "+$y0"
                if {$::tcl_platform(platform) != "windows"} {
                    if { $x0+$w > $sw } {set x "-0"; set x0 [expr {$sw-$w}]}
                    if { $x0 < 0 }      {set x "+0"}
                    if { $y0+$h > $sh } {set y "-0"; set y0 [expr {$sh-$h}]}
                    if { $y0 < 0 }      {set y "+0"}
                }
            } else {
                set x0 [winfo rootx $widget]
                set y0 [winfo rooty $widget]
                set x1 [expr {$x0 + [winfo width  $widget]}]
                set y1 [expr {$y0 + [winfo height $widget]}]
                if { $idx == 2 || $idx == 3 } {
                    set y "+$y0"
                    if {$::tcl_platform(platform) != "windows"} {
                        if { $y0+$h > $sh } {set y "-0"; set y0 [expr {$sh-$h}]}
                        if { $y0 < 0 }      {set y "+0"}
                    }
                    if { $idx == 2 } {
                        # try left, then right if out, then 0 if out
                        if { $x0 >= $w } {
                            set x [expr {$x0-$w}]
                        } elseif { $x1+$w <= $sw } {
                            set x "+$x1"
                        } else {
                            set x "+0"
                        }
                    } else {
                        # try right, then left if out, then 0 if out
                        if { $x1+$w <= $sw } {
                            set x "+$x1"
                        } elseif { $x0 >= $w } {
                            set x [expr {$x0-$w}]
                        } else {
                            set x "-0"
                        }
                    }
                } else {
                    set x "+$x0"
                    if {$::tcl_platform(platform) != "windows"} {
                        if { $x0+$w > $sw } {set x "-0"; set x0 [expr {$sw-$w}]}
                        if { $x0 < 0 }      {set x "+0"}
                    }
                    if { $idx == 4 } {
                        # try top, then bottom, then 0
                        if { $h <= $y0 } {
                            set y [expr {$y0-$h}]
                        } elseif { $y1+$h <= $sh } {
                            set y "+$y1"
                        } else {
                            set y "+0"
                        }
                    } else {
                        # try bottom, then top, then 0
                        if { $y1+$h <= $sh } {
                            set y "+$y1"
                        } elseif { $h <= $y0 } {
                            set y [expr {$y0-$h}]
                        } else {
                            set y "-0"
                        }
                    }
                }
            }
        }

        ## If there's not a + or - in front of the number, we need to add one.
        if {[string is integer [string index $x 0]]} { set x +$x }
        if {[string is integer [string index $y 0]]} { set y +$y }

        wm geometry $path "${w}x${h}${x}${y}"
    } else {
        wm geometry $path "${w}x${h}"
    }
    update idletasks
}


# ----------------------------------------------------------------------------
#  Command BWidget::grab
# ----------------------------------------------------------------------------
proc BWidget::grab { option path } {
    variable _gstack

    if { $option == "release" } {
        catch {::grab release $path}
        while { [llength $_gstack] } {
            set grinfo  [lindex $_gstack end]
            set _gstack [lreplace $_gstack end end]
            foreach {oldg mode} $grinfo {
                if { ![string equal $oldg $path] && [winfo exists $oldg] } {
                    if { $mode == "global" } {
                        catch {::grab -global $oldg}
                    } else {
                        catch {::grab $oldg}
                    }
                    return
                }
            }
        }
    } else {
        set oldg [::grab current]
        if { $oldg != "" } {
            lappend _gstack [list $oldg [::grab status $oldg]]
        }
        if { $option == "global" } {
            ::grab -global $path
        } else {
            ::grab $path
        }
    }
}


# ----------------------------------------------------------------------------
#  Command BWidget::focus
# ----------------------------------------------------------------------------
proc BWidget::focus { option path {refocus 1} } {
    variable _fstack

    if { $option == "release" } {
        while { [llength $_fstack] } {
            set oldf [lindex $_fstack end]
            set _fstack [lreplace $_fstack end end]
            if { ![string equal $oldf $path] && [winfo exists $oldf] } {
                if {$refocus} {catch {::focus -force $oldf}}
                return
            }
        }
    } elseif { $option == "set" } {
        lappend _fstack [::focus]
        ::focus -force $path
    }
}

# BWidget::refocus --
#
#	Helper function used to redirect focus from a container frame in 
#	a megawidget to a component widget.  Only redirects focus if
#	focus is already on the container.
#
# Arguments:
#	container	container widget to redirect from.
#	component	component widget to redirect to.
#
# Results:
#	None.

proc BWidget::refocus {container component} {
    if { [string equal $container [::focus]] } {
	::focus $component
    }
    return
}

## These mirror tk::(Set|Restore)FocusGrab

# BWidget::SetFocusGrab --
#   swap out current focus and grab temporarily (for dialogs)
# Arguments:
#   grab	new window to grab
#   focus	window to give focus to
# Results:
#   Returns nothing
#
proc BWidget::SetFocusGrab {grab {focus {}}} {
    variable _focusGrab
    set index "$grab,$focus"

    lappend _focusGrab($index) [::focus]
    set oldGrab [::grab current $grab]
    lappend _focusGrab($index) $oldGrab
    if {[winfo exists $oldGrab]} {
	lappend _focusGrab($index) [::grab status $oldGrab]
    }
    # The "grab" command will fail if another application
    # already holds the grab.  So catch it.
    catch {::grab $grab}
    if {[winfo exists $focus]} {
	::focus $focus
    }
}

# BWidget::RestoreFocusGrab --
#   restore old focus and grab (for dialogs)
# Arguments:
#   grab	window that had taken grab
#   focus	window that had taken focus
#   destroy	destroy|withdraw - how to handle the old grabbed window
# Results:
#   Returns nothing
#
proc BWidget::RestoreFocusGrab {grab focus {destroy destroy}} {
    variable _focusGrab
    set index "$grab,$focus"
    if {[info exists _focusGrab($index)]} {
	foreach {oldFocus oldGrab oldStatus} $_focusGrab($index) break
	unset _focusGrab($index)
    } else {
	set oldGrab ""
    }

    catch {::focus $oldFocus}
    ::grab release $grab
    if {[string equal $destroy "withdraw"]} {
	wm withdraw $grab
    } else {
	::destroy $grab
    }
    if {[winfo exists $oldGrab] && [winfo ismapped $oldGrab]} {
	if {[string equal $oldStatus "global"]} {
	    ::grab -global $oldGrab
	} else {
	    ::grab $oldGrab
	}
    }
}

# BWidget::badOptionString --
#
#	Helper function to return a proper error string when an option
#       doesn't match a list of given options.
#
# Arguments:
#	type	A string that represents the type of option.
#	value	The value that is in-valid.
#       list	A list of valid options.
#
# Results:
#	None.
proc BWidget::badOptionString {type value list} {
    set last [lindex $list end]
    set list [lreplace $list end end]
    return "bad $type \"$value\": must be [join $list ", "], or $last"
}


proc BWidget::wrongNumArgsString { string } {
    return "wrong # args: should be \"$string\""
}


proc BWidget::read_file { file } {
    set fp [open $file]
    set x  [read $fp [file size $file]]
    close $fp
    return $x
}


proc BWidget::classes { class } {
    variable use

    ${class}::use
    set classes [list $class]
    if {![info exists use($class)]} { return }
    foreach class $use($class) {
        if {![string equal $class "-classonly"]} {
            eval lappend classes [classes $class]
        }
    }
    return [lsort -unique $classes]
}


proc BWidget::library { args } {
    variable use

    set libs    [list widget init utils]
    set classes [list]
    foreach class $args {
	${class}::use
        eval lappend classes [classes $class]
    }

    eval lappend libs [lsort -unique $classes]

    set library ""
    foreach lib $libs {
	if {![info exists use($lib,file)]} {
	    set file [file join $::BWIDGET::LIBRARY $lib.tcl]
	} else {
	    set file [file join $::BWIDGET::LIBRARY $use($lib,file).tcl]
	}
        append library [read_file $file]
    }

    return $library
}


proc BWidget::inuse { class } {
    variable ::Widget::_inuse

    if {![info exists _inuse($class)]} { return 0 }
    return [expr $_inuse($class) > 0]
}


proc BWidget::write { filename {mode w} } {
    variable use

    if {![info exists use(classes)]} { return }

    set classes [list]
    foreach class $use(classes) {
	if {![inuse $class]} { continue }
	lappend classes $class
    }

    set fp [open $filename $mode]
    puts $fp [eval library $classes]
    close $fp

    return
}


# BWidget::bindMouseWheel --
#
#	Bind mouse wheel actions to a given widget.
#
# Arguments:
#	widget - The widget to bind.
#
# Results:
#	None.
proc BWidget::bindMouseWheel { widget } {
    if {[bind all <MouseWheel>] eq ""} {
	# style::as and Tk 8.5 have global bindings
	# Only enable these if no global binding for MouseWheel exists
	bind $widget <MouseWheel> \
	    {%W yview scroll [expr {-%D/24}]  units}
	bind $widget <Shift-MouseWheel> \
	    {%W yview scroll [expr {-%D/120}] pages}
	bind $widget <Control-MouseWheel> \
	    {%W yview scroll [expr {-%D/120}] units}
    }

    if {[bind all <Button-4>] eq ""} {
	# style::as and Tk 8.5 have global bindings
	# Only enable these if no global binding for them exists
	bind $widget <Button-4> {event generate %W <MouseWheel> -delta  120}
	bind $widget <Button-5> {event generate %W <MouseWheel> -delta -120}
    }
}

 	  	 
