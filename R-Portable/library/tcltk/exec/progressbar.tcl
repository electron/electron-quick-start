# ----------------------------------------------------------------------------
#  progressbar.tcl
#  This file is part of Unifix BWidget Toolkit
# ----------------------------------------------------------------------------
#  Index of commands:
#     - ProgressBar::create
#     - ProgressBar::configure
#     - ProgressBar::cget
#     - ProgressBar::_destroy
#     - ProgressBar::_modify
# ----------------------------------------------------------------------------

package provide PBar 1.0

# ----------------------------------------------------------------------------
#  utils.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: utils.tcl,v 1.12 2004/09/24 23:57:13 hobbs Exp $
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
    set reqw [winfo reqwidth  $path]
    set reqh [winfo reqheight $path]
    if { $w == 0 } {set w $reqw}
    if { $h == 0 } {set h $reqh}

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
                    set x0 [expr {([winfo screenwidth  $path] - $w)/2 - [winfo vrootx $path]}]
                    set y0 [expr {([winfo screenheight $path] - $h)/2 - [winfo vrooty $path]}]
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
                            set x [expr {$x0-$sw}]
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
                            set x [expr {$x0-$sw}]
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
                            set y [expr {$y0-$sh}]
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
                            set y [expr {$y0-$sh}]
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
	eval lappend classes [classes $class]
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
    bind $widget <MouseWheel>         {%W yview scroll [expr {-%D/24}]  units}
    bind $widget <Shift-MouseWheel>   {%W yview scroll [expr {-%D/120}] pages}
    bind $widget <Control-MouseWheel> {%W yview scroll [expr {-%D/120}] units}

    bind $widget <Button-4> {event generate %W <MouseWheel> -delta  120}
    bind $widget <Button-5> {event generate %W <MouseWheel> -delta -120}
}


# ----------------------------------------------------------------------------
#  widget.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: widget.tcl,v 1.29 2005/07/28 00:40:42 hobbs Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - Widget::tkinclude
#     - Widget::bwinclude
#     - Widget::declare
#     - Widget::addmap
#     - Widget::init
#     - Widget::destroy
#     - Widget::setoption
#     - Widget::configure
#     - Widget::cget
#     - Widget::subcget
#     - Widget::hasChanged
#     - Widget::options
#     - Widget::_get_tkwidget_options
#     - Widget::_test_tkresource
#     - Widget::_test_bwresource
#     - Widget::_test_synonym
#     - Widget::_test_string
#     - Widget::_test_flag
#     - Widget::_test_enum
#     - Widget::_test_int
#     - Widget::_test_boolean
# ----------------------------------------------------------------------------
# Each megawidget gets a namespace of the same name inside the Widget namespace
# Each of these has an array opt, which contains information about the 
# megawidget options.  It maps megawidget options to a list with this format:
#     {optionType defaultValue isReadonly {additionalOptionalInfo}}
# Option types and their additional optional info are:
#	TkResource	{genericTkWidget genericTkWidgetOptionName}
#	BwResource	{nothing}
#	Enum		{list of enumeration values}
#	Int		{Boundary information}
#	Boolean		{nothing}
#	String		{nothing}
#	Flag		{string of valid flag characters}
#	Synonym		{nothing}
#	Color		{nothing}
#
# Next, each namespace has an array map, which maps class options to their
# component widget options:
#	map(-foreground) => {.e -foreground .f -foreground}
#
# Each has an array ${path}:opt, which contains the value of each megawidget
# option for a particular instance $path of the megawidget, and an array
# ${path}:mod, which stores the "changed" status of configuration options.

# Steps for creating a bwidget megawidget:
# 1. parse args to extract subwidget spec
# 2. Create frame with appropriate class and command line options
# 3. Get initialization options from optionDB, using frame
# 4. create subwidgets

# Uses newer string operations
package require Tcl 8.1.1

namespace eval Widget {
    variable _optiontype
    variable _class
    variable _tk_widget

    # This controls whether we try to use themed widgets from Tile
    variable _theme 0

    variable _aqua [expr {($::tcl_version >= 8.4) &&
			  [string equal [tk windowingsystem] "aqua"]}]

    array set _optiontype {
        TkResource Widget::_test_tkresource
        BwResource Widget::_test_bwresource
        Enum       Widget::_test_enum
        Int        Widget::_test_int
        Boolean    Widget::_test_boolean
        String     Widget::_test_string
        Flag       Widget::_test_flag
        Synonym    Widget::_test_synonym
        Color      Widget::_test_color
        Padding    Widget::_test_padding
    }

    proc use {} {}
}


# ----------------------------------------------------------------------------
#  Command Widget::tkinclude
#     Includes tk widget resources to BWidget widget.
#  class      class name of the BWidget
#  tkwidget   tk widget to include
#  subpath    subpath to configure
#  args       additionnal args for included options
# ----------------------------------------------------------------------------
proc Widget::tkinclude { class tkwidget subpath args } {
    foreach {cmd lopt} $args {
        # cmd can be
        #   include      options to include            lopt = {opt ...}
        #   remove       options to remove             lopt = {opt ...}
        #   rename       options to rename             lopt = {opt newopt ...}
        #   prefix       options to prefix             lopt = {pref opt opt ..}
        #   initialize   set default value for options lopt = {opt value ...}
        #   readonly     set readonly flag for options lopt = {opt flag ...}
        switch -- $cmd {
            remove {
                foreach option $lopt {
                    set remove($option) 1
                }
            }
            include {
                foreach option $lopt {
                    set include($option) 1
                }
            }
            prefix {
                set prefix [lindex $lopt 0]
                foreach option [lrange $lopt 1 end] {
                    set rename($option) "-$prefix[string range $option 1 end]"
                }
            }
            rename     -
            readonly   -
            initialize {
                array set $cmd $lopt
            }
            default {
                return -code error "invalid argument \"$cmd\""
            }
        }
    }

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap
    upvar 0 ${class}::optionExports exports

    set foo [$tkwidget ".ericFoo###"]
    # create resources informations from tk widget resources
    foreach optdesc [_get_tkwidget_options $tkwidget] {
        set option [lindex $optdesc 0]
        if { (![info exists include] || [info exists include($option)]) &&
             ![info exists remove($option)] } {
            if { [llength $optdesc] == 3 } {
                # option is a synonym
                set syn [lindex $optdesc 1]
                if { ![info exists remove($syn)] } {
                    # original option is not removed
                    if { [info exists rename($syn)] } {
                        set classopt($option) [list Synonym $rename($syn)]
                    } else {
                        set classopt($option) [list Synonym $syn]
                    }
                }
            } else {
                if { [info exists rename($option)] } {
                    set realopt $option
                    set option  $rename($option)
                } else {
                    set realopt $option
                }
                if { [info exists initialize($option)] } {
                    set value $initialize($option)
                } else {
                    set value [lindex $optdesc 1]
                }
                if { [info exists readonly($option)] } {
                    set ro $readonly($option)
                } else {
                    set ro 0
                }
                set classopt($option) \
			[list TkResource $value $ro [list $tkwidget $realopt]]

		# Add an option database entry for this option
		set optionDbName ".[lindex [_configure_option $option ""] 0]"
		if { ![string equal $subpath ":cmd"] } {
		    set optionDbName "$subpath$optionDbName"
		}
		option add *${class}$optionDbName $value widgetDefault
		lappend exports($option) "$optionDbName"

		# Store the forward and backward mappings for this
		# option <-> realoption pair
                lappend classmap($option) $subpath "" $realopt
		set submap($realopt) $option
            }
        }
    }
    ::destroy $foo
}


# ----------------------------------------------------------------------------
#  Command Widget::bwinclude
#     Includes BWidget resources to BWidget widget.
#  class    class name of the BWidget
#  subclass BWidget class to include
#  subpath  subpath to configure
#  args     additionnal args for included options
# ----------------------------------------------------------------------------
proc Widget::bwinclude { class subclass subpath args } {
    foreach {cmd lopt} $args {
        # cmd can be
        #   include      options to include            lopt = {opt ...}
        #   remove       options to remove             lopt = {opt ...}
        #   rename       options to rename             lopt = {opt newopt ...}
        #   prefix       options to prefix             lopt = {prefix opt opt ...}
        #   initialize   set default value for options lopt = {opt value ...}
        #   readonly     set readonly flag for options lopt = {opt flag ...}
        switch -- $cmd {
            remove {
                foreach option $lopt {
                    set remove($option) 1
                }
            }
            include {
                foreach option $lopt {
                    set include($option) 1
                }
            }
            prefix {
                set prefix [lindex $lopt 0]
                foreach option [lrange $lopt 1 end] {
                    set rename($option) "-$prefix[string range $option 1 end]"
                }
            }
            rename     -
            readonly   -
            initialize {
                array set $cmd $lopt
            }
            default {
                return -code error "invalid argument \"$cmd\""
            }
        }
    }

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap
    upvar 0 ${class}::optionExports exports
    upvar 0 ${subclass}::opt subclassopt
    upvar 0 ${subclass}::optionExports subexports

    # create resources informations from BWidget resources
    foreach {option optdesc} [array get subclassopt] {
	set subOption $option
        if { (![info exists include] || [info exists include($option)]) &&
             ![info exists remove($option)] } {
            set type [lindex $optdesc 0]
            if { [string equal $type "Synonym"] } {
                # option is a synonym
                set syn [lindex $optdesc 1]
                if { ![info exists remove($syn)] } {
                    if { [info exists rename($syn)] } {
                        set classopt($option) [list Synonym $rename($syn)]
                    } else {
                        set classopt($option) [list Synonym $syn]
                    }
                }
            } else {
                if { [info exists rename($option)] } {
                    set realopt $option
                    set option  $rename($option)
                } else {
                    set realopt $option
                }
                if { [info exists initialize($option)] } {
                    set value $initialize($option)
                } else {
                    set value [lindex $optdesc 1]
                }
                if { [info exists readonly($option)] } {
                    set ro $readonly($option)
                } else {
                    set ro [lindex $optdesc 2]
                }
                set classopt($option) \
			[list $type $value $ro [lindex $optdesc 3]]

		# Add an option database entry for this option
		foreach optionDbName $subexports($subOption) {
		    if { ![string equal $subpath ":cmd"] } {
			set optionDbName "$subpath$optionDbName"
		    }
		    # Only add the option db entry if we are overriding the
		    # normal widget default
		    if { [info exists initialize($option)] } {
			option add *${class}$optionDbName $value \
				widgetDefault
		    }
		    lappend exports($option) "$optionDbName"
		}

		# Store the forward and backward mappings for this
		# option <-> realoption pair
                lappend classmap($option) $subpath $subclass $realopt
		set submap($realopt) $option
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::declare
#    Declares new options to BWidget class.
# ----------------------------------------------------------------------------
proc Widget::declare { class optlist } {
    variable _optiontype

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::optionExports exports
    upvar 0 ${class}::optionClass optionClass

    foreach optdesc $optlist {
        set option  [lindex $optdesc 0]
        set optdesc [lrange $optdesc 1 end]
        set type    [lindex $optdesc 0]

        if { ![info exists _optiontype($type)] } {
            # invalid resource type
            return -code error "invalid option type \"$type\""
        }

        if { [string equal $type "Synonym"] } {
            # test existence of synonym option
            set syn [lindex $optdesc 1]
            if { ![info exists classopt($syn)] } {
                return -code error "unknow option \"$syn\" for Synonym \"$option\""
            }
            set classopt($option) [list Synonym $syn]
            continue
        }

        # all other resource may have default value, readonly flag and
        # optional arg depending on type
        set value [lindex $optdesc 1]
        set ro    [lindex $optdesc 2]
        set arg   [lindex $optdesc 3]

        if { [string equal $type "BwResource"] } {
            # We don't keep BwResource. We simplify to type of sub BWidget
            set subclass    [lindex $arg 0]
            set realopt     [lindex $arg 1]
            if { ![string length $realopt] } {
                set realopt $option
            }

            upvar 0 ${subclass}::opt subclassopt
            if { ![info exists subclassopt($realopt)] } {
                return -code error "unknow option \"$realopt\""
            }
            set suboptdesc $subclassopt($realopt)
            if { $value == "" } {
                # We initialize default value
                set value [lindex $suboptdesc 1]
            }
            set type [lindex $suboptdesc 0]
            set ro   [lindex $suboptdesc 2]
            set arg  [lindex $suboptdesc 3]
	    set optionDbName ".[lindex [_configure_option $option ""] 0]"
	    option add *${class}${optionDbName} $value widgetDefault
	    set exports($option) $optionDbName
            set classopt($option) [list $type $value $ro $arg]
            continue
        }

        # retreive default value for TkResource
        if { [string equal $type "TkResource"] } {
            set tkwidget [lindex $arg 0]
	    set foo [$tkwidget ".ericFoo##"]
            set realopt  [lindex $arg 1]
            if { ![string length $realopt] } {
                set realopt $option
            }
            set tkoptions [_get_tkwidget_options $tkwidget]
            if { ![string length $value] } {
                # We initialize default value
		set ind [lsearch $tkoptions [list $realopt *]]
                set value [lindex [lindex $tkoptions $ind] end]
            }
	    set optionDbName ".[lindex [_configure_option $option ""] 0]"
	    option add *${class}${optionDbName} $value widgetDefault
	    set exports($option) $optionDbName
            set classopt($option) [list TkResource $value $ro \
		    [list $tkwidget $realopt]]
	    set optionClass($option) [lindex [$foo configure $realopt] 1]
	    ::destroy $foo
            continue
        }

	set optionDbName ".[lindex [_configure_option $option ""] 0]"
	option add *${class}${optionDbName} $value widgetDefault
	set exports($option) $optionDbName
        # for any other resource type, we keep original optdesc
        set classopt($option) [list $type $value $ro $arg]
    }
}


proc Widget::define { class filename args } {
    # variable ::BWidget::use
    set use($class)      $args
    set use($class,file) $filename
    lappend use(classes) $class

    if {[set x [lsearch -exact $args "-classonly"]] > -1} {
	set args [lreplace $args $x $x]
    } else {
	interp alias {} ::${class} {} ${class}::create
	proc ::${class}::use {} {}

	bind $class <Destroy> [list Widget::destroy %W]
    }

    foreach class $args { ${class}::use }
}


proc Widget::create { class path {rename 1} } {
    if {$rename} { rename $path ::$path:cmd }
    proc ::$path { cmd args } \
    	[subst {return \[eval \[linsert \$args 0 ${class}::\$cmd [list $path]\]\]}]
    return $path
}


# ----------------------------------------------------------------------------
#  Command Widget::addmap
# ----------------------------------------------------------------------------
proc Widget::addmap { class subclass subpath options } {
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::optionExports exports
    upvar 0 ${class}::optionClass optionClass
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap

    foreach {option realopt} $options {
        if { ![string length $realopt] } {
            set realopt $option
        }
	set val [lindex $classopt($option) 1]
	set optDb ".[lindex [_configure_option $realopt ""] 0]"
	if { ![string equal $subpath ":cmd"] } {
	    set optDb "$subpath$optDb"
	}
	option add *${class}${optDb} $val widgetDefault
	lappend exports($option) $optDb
	# Store the forward and backward mappings for this
	# option <-> realoption pair
        lappend classmap($option) $subpath $subclass $realopt
	set submap($realopt) $option
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::syncoptions
# ----------------------------------------------------------------------------
proc Widget::syncoptions { class subclass subpath options } {
    upvar 0 ${class}::sync classync

    foreach {option realopt} $options {
        if { ![string length $realopt] } {
            set realopt $option
        }
        set classync($option) [list $subpath $subclass $realopt]
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::init
# ----------------------------------------------------------------------------
proc Widget::init { class path options } {
    variable _inuse

    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::$path:opt  pathopt
    upvar 0 ${class}::$path:mod  pathmod
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::$path:init pathinit

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }
    # We prefer to use the actual widget for option db queries, but if it
    # doesn't exist yet, do the next best thing:  create a widget of the
    # same class and use that.
    set fpath $path
    set rdbclass [string map [list :: ""] $class]
    if { ![winfo exists $path] } {
	set fpath ".#BWidget.#Class#$class"
	# encapsulation frame to not pollute '.' childspace
	if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
	if { ![winfo exists $fpath] } {
	    frame $fpath -class $rdbclass
	}
    }
    foreach {option optdesc} [array get classopt] {
        set pathmod($option) 0
	if { [info exists classmap($option)] } {
	    continue
	}
        set type [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
	    continue
        }
        if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set optdb [lindex [_configure_option $option $alt] 0]
        set def   [option get $fpath $optdb $rdbclass]
        if { [string length $def] } {
            set pathopt($option) $def
        } else {
            set pathopt($option) [lindex $optdesc 1]
        }
    }

    if {![info exists _inuse($class)]} { set _inuse($class) 0 }
    incr _inuse($class)

    set Widget::_class($path) $class
    foreach {option value} $options {
        if { ![info exists classopt($option)] } {
            unset pathopt
            unset pathmod
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        set pathopt($option) [$Widget::_optiontype($type) $option $value [lindex $optdesc 3]]
	set pathinit($option) $pathopt($option)
    }
}

# Bastien Chevreux (bach@mwgdna.com)
#
# copyinit performs basically the same job as init, but it uses a
#  existing template to initialize its values. So, first a perferct copy
#  from the template is made just to be altered by any existing options
#  afterwards.
# But this still saves time as the first initialization parsing block is
#  skipped.
# As additional bonus, items that differ in just a few options can be
#  initialized faster by leaving out the options that are equal.

# This function is currently used only by ListBox::multipleinsert, but other
#  calls should follow :)

# ----------------------------------------------------------------------------
#  Command Widget::copyinit
# ----------------------------------------------------------------------------
proc Widget::copyinit { class templatepath path options } {
    upvar 0 ${class}::opt classopt \
	    ${class}::$path:opt	 pathopt \
	    ${class}::$path:mod	 pathmod \
	    ${class}::$path:init pathinit \
	    ${class}::$templatepath:opt	  templatepathopt \
	    ${class}::$templatepath:mod	  templatepathmod \
	    ${class}::$templatepath:init  templatepathinit

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }

    # We use the template widget for option db copying, but it has to exist!
    array set pathmod  [array get templatepathmod]
    array set pathopt  [array get templatepathopt]
    array set pathinit [array get templatepathinit]

    set Widget::_class($path) $class
    foreach {option value} $options {
	if { ![info exists classopt($option)] } {
	    unset pathopt
	    unset pathmod
	    return -code error "unknown option \"$option\""
	}
	set optdesc $classopt($option)
	set type    [lindex $optdesc 0]
	if { [string equal $type "Synonym"] } {
	    set option	[lindex $optdesc 1]
	    set optdesc $classopt($option)
	    set type	[lindex $optdesc 0]
	}
	set pathopt($option) [$Widget::_optiontype($type) $option $value [lindex $optdesc 3]]
	set pathinit($option) $pathopt($option)
    }
}

# Widget::parseArgs --
#
#	Given a widget class and a command-line spec, cannonize and validate
#	the given options, and return a keyed list consisting of the 
#	component widget and its masked portion of the command-line spec, and
#	one extra entry consisting of the portion corresponding to the 
#	megawidget itself.
#
# Arguments:
#	class	widget class to parse for.
#	options	command-line spec
#
# Results:
#	result	keyed list of portions of the megawidget and that segment of
#		the command line in which that portion is interested.

proc Widget::parseArgs {class options} {
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    
    foreach {option val} $options {
	if { ![info exists classopt($option)] } {
	    error "unknown option \"$option\""
	}
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
	if { [string equal $type "TkResource"] } {
	    # Make sure that the widget used for this TkResource exists
	    Widget::_get_tkwidget_options [lindex [lindex $optdesc 3] 0]
	}
	set val [$Widget::_optiontype($type) $option $val [lindex $optdesc 3]]
		
	if { [info exists classmap($option)] } {
	    foreach {subpath subclass realopt} $classmap($option) {
		lappend maps($subpath) $realopt $val
	    }
	} else {
	    lappend maps($class) $option $val
	}
    }
    return [array get maps]
}

# Widget::initFromODB --
#
#	Initialize a megawidgets options with information from the option
#	database and from the command-line arguments given.
#
# Arguments:
#	class	class of the widget.
#	path	path of the widget -- should already exist.
#	options	command-line arguments.
#
# Results:
#	None.

proc Widget::initFromODB {class path options} {
    variable _inuse
    variable _class

    upvar 0 ${class}::$path:opt  pathopt
    upvar 0 ${class}::$path:mod  pathmod
    upvar 0 ${class}::map classmap

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }
    # We prefer to use the actual widget for option db queries, but if it
    # doesn't exist yet, do the next best thing:  create a widget of the
    # same class and use that.
    set fpath [_get_window $class $path]
    set rdbclass [string map [list :: ""] $class]
    if { ![winfo exists $path] } {
	set fpath ".#BWidget.#Class#$class"
	# encapsulation frame to not pollute '.' childspace
	if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
	if { ![winfo exists $fpath] } {
	    frame $fpath -class $rdbclass
	}
    }

    foreach {option optdesc} [array get ${class}::opt] {
        set pathmod($option) 0
	if { [info exists classmap($option)] } {
	    continue
	}
        set type [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
	    continue
        }
	if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set optdb [lindex [_configure_option $option $alt] 0]
        set def   [option get $fpath $optdb $rdbclass]
        if { [string length $def] } {
            set pathopt($option) $def
        } else {
            set pathopt($option) [lindex $optdesc 1]
        }
    }

    if {![info exists _inuse($class)]} { set _inuse($class) 0 }
    incr _inuse($class)

    set _class($path) $class
    array set pathopt $options
}



# ----------------------------------------------------------------------------
#  Command Widget::destroy
# ----------------------------------------------------------------------------
proc Widget::destroy { path } {
    variable _class
    variable _inuse

    if {![info exists _class($path)]} { return }

    set class $_class($path)
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod
    upvar 0 ${class}::$path:init pathinit

    if {[info exists _inuse($class)]} { incr _inuse($class) -1 }

    if {[info exists pathopt]} {
        unset pathopt
    }
    if {[info exists pathmod]} {
        unset pathmod
    }
    if {[info exists pathinit]} {
        unset pathinit
    }

    if {![string equal [info commands $path] ""]} { rename $path "" }

    ## Unset any variables used in this widget.
    foreach var [info vars ::${class}::$path:*] { unset $var }

    unset _class($path)
}


# ----------------------------------------------------------------------------
#  Command Widget::configure
# ----------------------------------------------------------------------------
proc Widget::configure { path options } {
    set len [llength $options]
    if { $len <= 1 } {
        return [_get_configure $path $options]
    } elseif { $len % 2 == 1 } {
        return -code error "incorrect number of arguments"
    }

    variable _class
    variable _optiontype

    set class $_class($path)
    upvar 0 ${class}::opt  classopt
    upvar 0 ${class}::map  classmap
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod

    set window [_get_window $class $path]
    foreach {option value} $options {
        if { ![info exists classopt($option)] } {
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        if { ![lindex $optdesc 2] } {
            set newval [$_optiontype($type) $option $value [lindex $optdesc 3]]
            if { [info exists classmap($option)] } {
		set window [_get_window $class $window]
                foreach {subpath subclass realopt} $classmap($option) {
                    if { [string length $subclass] } {
			set curval [${subclass}::cget $window$subpath $realopt]
                        ${subclass}::configure $window$subpath $realopt $newval
                    } else {
			set curval [$window$subpath cget $realopt]
                        $window$subpath configure $realopt $newval
                    }
                }
            } else {
		set curval $pathopt($option)
		set pathopt($option) $newval
	    }
	    set pathmod($option) [expr {![string equal $newval $curval]}]
        }
    }

    return {}
}


# ----------------------------------------------------------------------------
#  Command Widget::cget
# ----------------------------------------------------------------------------
proc Widget::cget { path option } {
    if { ![info exists ::Widget::_class($path)] } {
        return -code error "unknown widget $path"
    }

    set class $::Widget::_class($path)
    if { ![info exists ${class}::opt($option)] } {
        return -code error "unknown option \"$option\""
    }

    set optdesc [set ${class}::opt($option)]
    set type    [lindex $optdesc 0]
    if {[string equal $type "Synonym"]} {
        set option [lindex $optdesc 1]
    }

    if { [info exists ${class}::map($option)] } {
	foreach {subpath subclass realopt} [set ${class}::map($option)] {break}
	set path "[_get_window $class $path]$subpath"
	return [$path cget $realopt]
    }
    upvar 0 ${class}::$path:opt pathopt
    set pathopt($option)
}


# ----------------------------------------------------------------------------
#  Command Widget::subcget
# ----------------------------------------------------------------------------
proc Widget::subcget { path subwidget } {
    set class $::Widget::_class($path)
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::map$subwidget submap
    upvar 0 ${class}::$path:init pathinit

    set result {}
    foreach realopt [array names submap] {
	if { [info exists pathinit($submap($realopt))] } {
	    lappend result $realopt $pathopt($submap($realopt))
	}
    }
    return $result
}


# ----------------------------------------------------------------------------
#  Command Widget::hasChanged
# ----------------------------------------------------------------------------
proc Widget::hasChanged { path option pvalue } {
    upvar    $pvalue value
    set class $::Widget::_class($path)
    upvar 0 ${class}::$path:mod pathmod

    set value   [Widget::cget $path $option]
    set result  $pathmod($option)
    set pathmod($option) 0

    return $result
}

proc Widget::hasChangedX { path option args } {
    set class $::Widget::_class($path)
    upvar 0 ${class}::$path:mod pathmod

    set result  $pathmod($option)
    set pathmod($option) 0
    foreach option $args {
	lappend result $pathmod($option)
	set pathmod($option) 0
    }

    set result
}


# ----------------------------------------------------------------------------
#  Command Widget::setoption
# ----------------------------------------------------------------------------
proc Widget::setoption { path option value } {
#    variable _class

#    set class $_class($path)
#    upvar 0 ${class}::$path:opt pathopt

#    set pathopt($option) $value
    Widget::configure $path [list $option $value]
}


# ----------------------------------------------------------------------------
#  Command Widget::getoption
# ----------------------------------------------------------------------------
proc Widget::getoption { path option } {
#    set class $::Widget::_class($path)
#    upvar 0 ${class}::$path:opt pathopt

#    return $pathopt($option)
    return [Widget::cget $path $option]
}

# Widget::getMegawidgetOption --
#
#	Bypass the superfluous checks in cget and just directly peer at the
#	widget's data space.  This is much more fragile than cget, so it 
#	should only be used with great care, in places where speed is critical.
#
# Arguments:
#	path	widget to lookup options for.
#	option	option to retrieve.
#
# Results:
#	value	option value.

proc Widget::getMegawidgetOption {path option} {
    set class $::Widget::_class($path)
    upvar 0 ${class}::${path}:opt pathopt
    set pathopt($option)
}

# Widget::setMegawidgetOption --
#
#	Bypass the superfluous checks in cget and just directly poke at the
#	widget's data space.  This is much more fragile than configure, so it 
#	should only be used with great care, in places where speed is critical.
#
# Arguments:
#	path	widget to lookup options for.
#	option	option to retrieve.
#	value	option value.
#
# Results:
#	value	option value.

proc Widget::setMegawidgetOption {path option value} {
    set class $::Widget::_class($path)
    upvar 0 ${class}::${path}:opt pathopt
    set pathopt($option) $value
}

# ----------------------------------------------------------------------------
#  Command Widget::_get_window
#  returns the window corresponding to widget path
# ----------------------------------------------------------------------------
proc Widget::_get_window { class path } {
    set idx [string last "#" $path]
    if { $idx != -1 && [string equal [string range $path [expr {$idx+1}] end] $class] } {
        return [string range $path 0 [expr {$idx-1}]]
    } else {
        return $path
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::_get_configure
#  returns the configuration list of options
#  (as tk widget do - [$w configure ?option?])
# ----------------------------------------------------------------------------
proc Widget::_get_configure { path options } {
    variable _class

    set class $_class($path)
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod

    set len [llength $options]
    if { !$len } {
        set result {}
        foreach option [lsort [array names classopt]] {
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
            if { [string equal $type "Synonym"] } {
                set syn     $option
                set option  [lindex $optdesc 1]
                set optdesc $classopt($option)
                set type    [lindex $optdesc 0]
            } else {
                set syn ""
            }
            if { [string equal $type "TkResource"] } {
                set alt [lindex [lindex $optdesc 3] 1]
            } else {
                set alt ""
            }
            set res [_configure_option $option $alt]
            if { $syn == "" } {
                lappend result [concat $option $res [list [lindex $optdesc 1]] [list [cget $path $option]]]
            } else {
                lappend result [list $syn [lindex $res 0]]
            }
        }
        return $result
    } elseif { $len == 1 } {
        set option  [lindex $options 0]
        if { ![info exists classopt($option)] } {
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set res [_configure_option $option $alt]
        return [concat $option $res [list [lindex $optdesc 1]] [list [cget $path $option]]]
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::_configure_option
# ----------------------------------------------------------------------------
proc Widget::_configure_option { option altopt } {
    variable _optiondb
    variable _optionclass

    if { [info exists _optiondb($option)] } {
        set optdb $_optiondb($option)
    } else {
        set optdb [string range $option 1 end]
    }
    if { [info exists _optionclass($option)] } {
        set optclass $_optionclass($option)
    } elseif { [string length $altopt] } {
        if { [info exists _optionclass($altopt)] } {
            set optclass $_optionclass($altopt)
        } else {
            set optclass [string range $altopt 1 end]
        }
    } else {
        set optclass [string range $option 1 end]
    }
    return [list $optdb $optclass]
}


# ----------------------------------------------------------------------------
#  Command Widget::_get_tkwidget_options
# ----------------------------------------------------------------------------
proc Widget::_get_tkwidget_options { tkwidget } {
    variable _tk_widget
    variable _optiondb
    variable _optionclass

    set widget ".#BWidget.#$tkwidget"
    # encapsulation frame to not pollute '.' childspace
    if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
    if { ![winfo exists $widget] || ![info exists _tk_widget($tkwidget)] } {
	set widget [$tkwidget $widget]
	# JDC: Withdraw toplevels, otherwise visible
	if {[string equal $tkwidget "toplevel"]} {
	    wm withdraw $widget
	}
	set config [$widget configure]
	foreach optlist $config {
	    set opt [lindex $optlist 0]
	    if { [llength $optlist] == 2 } {
		set refsyn [lindex $optlist 1]
		# search for class
		set idx [lsearch $config [list * $refsyn *]]
		if { $idx == -1 } {
		    if { [string index $refsyn 0] == "-" } {
			# search for option (tk8.1b1 bug)
			set idx [lsearch $config [list $refsyn * *]]
		    } else {
			# last resort
			set idx [lsearch $config [list -[string tolower $refsyn] * *]]
		    }
		    if { $idx == -1 } {
			# fed up with "can't read classopt()"
			return -code error "can't find option of synonym $opt"
		    }
		}
		set syn [lindex [lindex $config $idx] 0]
		# JDC: used 4 (was 3) to get def from optiondb
		set def [lindex [lindex $config $idx] 4]
		lappend _tk_widget($tkwidget) [list $opt $syn $def]
	    } else {
		# JDC: used 4 (was 3) to get def from optiondb
		set def [lindex $optlist 4]
		lappend _tk_widget($tkwidget) [list $opt $def]
		set _optiondb($opt)    [lindex $optlist 1]
		set _optionclass($opt) [lindex $optlist 2]
	    }
	}
    }
    return $_tk_widget($tkwidget)
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_tkresource
# ----------------------------------------------------------------------------
proc Widget::_test_tkresource { option value arg } {
#    set tkwidget [lindex $arg 0]
#    set realopt  [lindex $arg 1]
    foreach {tkwidget realopt} $arg break
    set path     ".#BWidget.#$tkwidget"
    set old      [$path cget $realopt]
    $path configure $realopt $value
    set res      [$path cget $realopt]
    $path configure $realopt $old

    return $res
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_bwresource
# ----------------------------------------------------------------------------
proc Widget::_test_bwresource { option value arg } {
    return -code error "bad option type BwResource in widget"
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_synonym
# ----------------------------------------------------------------------------
proc Widget::_test_synonym { option value arg } {
    return -code error "bad option type Synonym in widget"
}

# ----------------------------------------------------------------------------
#  Command Widget::_test_color
# ----------------------------------------------------------------------------
proc Widget::_test_color { option value arg } {
    if {[catch {winfo rgb . $value} color]} {
        return -code error "bad $option value \"$value\": must be a colorname \
		or #RRGGBB triplet"
    }

    return $value
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_string
# ----------------------------------------------------------------------------
proc Widget::_test_string { option value arg } {
    set value
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_flag
# ----------------------------------------------------------------------------
proc Widget::_test_flag { option value arg } {
    set len [string length $value]
    set res ""
    for {set i 0} {$i < $len} {incr i} {
        set c [string index $value $i]
        if { [string first $c $arg] == -1 } {
            return -code error "bad [string range $option 1 end] value \"$value\": characters must be in \"$arg\""
        }
        if { [string first $c $res] == -1 } {
            append res $c
        }
    }
    return $res
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_enum
# -----------------------------------------------------------------------------
proc Widget::_test_enum { option value arg } {
    if { [lsearch $arg $value] == -1 } {
        set last [lindex   $arg end]
        set sub  [lreplace $arg end end]
        if { [llength $sub] } {
            set str "[join $sub ", "] or $last"
        } else {
            set str $last
        }
        return -code error "bad [string range $option 1 end] value \"$value\": must be $str"
    }
    return $value
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_int
# -----------------------------------------------------------------------------
proc Widget::_test_int { option value arg } {
    if { ![string is int -strict $value] || \
	    ([string length $arg] && \
	    ![expr [string map [list %d $value] $arg]]) } {
		    return -code error "bad $option value\
			    \"$value\": must be integer ($arg)"
    }
    return $value
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_boolean
# -----------------------------------------------------------------------------
proc Widget::_test_boolean { option value arg } {
    if { ![string is boolean -strict $value] } {
        return -code error "bad $option value \"$value\": must be boolean"
    }

    # Get the canonical form of the boolean value (1 for true, 0 for false)
    return [string is true $value]
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_padding
# -----------------------------------------------------------------------------
proc Widget::_test_padding { option values arg } {
    set len [llength $values]
    if {$len < 1 || $len > 2} {
        return -code error "bad pad value \"$values\":\
                        must be positive screen distance"
    }

    foreach value $values {
        if { ![string is int -strict $value] || \
            ([string length $arg] && \
            ![expr [string map [list %d $value] $arg]]) } {
                return -code error "bad pad value \"$value\":\
                                must be positive screen distance ($arg)"
        }
    }
    return $values
}


# Widget::_get_padding --
#
#       Return the requesting padding value for a padding option.
#
# Arguments:
#	path		Widget to get the options for.
#       option          The name of the padding option.
#	index		The index of the padding.  If the index is empty,
#                       the first padding value is returned.
#
# Results:
#	Return a numeric value that can be used for padding.
proc Widget::_get_padding { path option {index 0} } {
    set pad [Widget::cget $path $option]
    set val [lindex $pad $index]
    if {$val == ""} { set val [lindex $pad 0] }
    return $val
}


# -----------------------------------------------------------------------------
#  Command Widget::focusNext
#  Same as tk_focusNext, but call Widget::focusOK
# -----------------------------------------------------------------------------
proc Widget::focusNext { w } {
    set cur $w
    while 1 {

	# Descend to just before the first child of the current widget.

	set parent $cur
	set children [winfo children $cur]
	set i -1

	# Look for the next sibling that isn't a top-level.

	while 1 {
	    incr i
	    if {$i < [llength $children]} {
		set cur [lindex $children $i]
		if {[string equal [winfo toplevel $cur] $cur]} {
		    continue
		} else {
		    break
		}
	    }

	    # No more siblings, so go to the current widget's parent.
	    # If it's a top-level, break out of the loop, otherwise
	    # look for its next sibling.

	    set cur $parent
	    if {[string equal [winfo toplevel $cur] $cur]} {
		break
	    }
	    set parent [winfo parent $parent]
	    set children [winfo children $parent]
	    set i [lsearch -exact $children $cur]
	}
	if {[string equal $cur $w] || [focusOK $cur]} {
	    return $cur
	}
    }
}


# -----------------------------------------------------------------------------
#  Command Widget::focusPrev
#  Same as tk_focusPrev, except:
#	+ Don't traverse from a child to a direct ancestor
#	+ Call Widget::focusOK instead of tk::focusOK
# -----------------------------------------------------------------------------
proc Widget::focusPrev { w } {
    set cur $w
    set origParent [winfo parent $w]
    while 1 {

	# Collect information about the current window's position
	# among its siblings.  Also, if the window is a top-level,
	# then reposition to just after the last child of the window.

	if {[string equal [winfo toplevel $cur] $cur]}  {
	    set parent $cur
	    set children [winfo children $cur]
	    set i [llength $children]
	} else {
	    set parent [winfo parent $cur]
	    set children [winfo children $parent]
	    set i [lsearch -exact $children $cur]
	}

	# Go to the previous sibling, then descend to its last descendant
	# (highest in stacking order.  While doing this, ignore top-levels
	# and their descendants.  When we run out of descendants, go up
	# one level to the parent.

	while {$i > 0} {
	    incr i -1
	    set cur [lindex $children $i]
	    if {[string equal [winfo toplevel $cur] $cur]} {
		continue
	    }
	    set parent $cur
	    set children [winfo children $parent]
	    set i [llength $children]
	}
	set cur $parent
	if {[string equal $cur $w]} {
	    return $cur
	}
	# If we are just at the original parent of $w, skip it as a
	# potential focus accepter.  Extra safety in this is to see if
	# that parent is also a proc (not a C command), which is what
	# BWidgets makes for any megawidget.  Could possibly also check
	# for '[info commands ::${origParent}:cmd] != ""'.  [Bug 765667]
	if {[string equal $cur $origParent]
	    && [info procs ::$origParent] != ""} {
	    continue
	}
	if {[focusOK $cur]} {
	    return $cur
	}
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::focusOK
#  Same as tk_focusOK, but handles -editable option and whole tags list.
# ----------------------------------------------------------------------------
proc Widget::focusOK { w } {
    set code [catch {$w cget -takefocus} value]
    if { $code == 1 } {
        return 0
    }
    if {($code == 0) && ($value != "")} {
	if {$value == 0} {
	    return 0
	} elseif {$value == 1} {
	    return [winfo viewable $w]
	} else {
	    set value [uplevel \#0 $value $w]
            if {$value != ""} {
		return $value
	    }
        }
    }
    if {![winfo viewable $w]} {
	return 0
    }
    set code [catch {$w cget -state} value]
    if {($code == 0) && ($value == "disabled")} {
	return 0
    }
    set code [catch {$w cget -editable} value]
    if {($code == 0) && ($value == 0)} {
        return 0
    }

    set top [winfo toplevel $w]
    foreach tags [bindtags $w] {
        if { ![string equal $tags $top]  &&
             ![string equal $tags "all"] &&
             [regexp Key [bind $tags]] } {
            return 1
        }
    }
    return 0
}


proc Widget::traverseTo { w } {
    set focus [focus]
    if {![string equal $focus ""]} {
	event generate $focus <<TraverseOut>>
    }
    focus $w

    event generate $w <<TraverseIn>>
}


# Widget::varForOption --
#
#	Retrieve a fully qualified variable name for the option specified.
#	If the option is not one for which a variable exists, throw an error 
#	(ie, those options that map directly to widget options).
#
# Arguments:
#	path	megawidget to get an option var for.
#	option	option to get a var for.
#
# Results:
#	varname	name of the variable, fully qualified, suitable for tracing.

proc Widget::varForOption {path option} {
    variable _class
    variable _optiontype

    set class $_class($path)
    upvar 0 ${class}::$path:opt pathopt

    if { ![info exists pathopt($option)] } {
	error "unable to find variable for option \"$option\""
    }
    set varname "::Widget::${class}::$path:opt($option)"
    return $varname
}

# Widget::getVariable --
#
#       Get a variable from within the namespace of the widget.
#
# Arguments:
#	path		Megawidget to get the variable for.
#	varName		The variable name to retrieve.
#       newVarName	The variable name to refer to in the calling proc.
#
# Results:
#	Creates a reference to newVarName in the calling proc.
proc Widget::getVariable { path varName {newVarName ""} } {
    variable _class
    set class $_class($path)
    if {![string length $newVarName]} { set newVarName $varName }
    uplevel 1 [list upvar \#0 ${class}::$path:$varName $newVarName]
}

# Widget::options --
#
#       Return a key-value list of options for a widget.  This can
#       be used to serialize the options of a widget and pass them
#       on to a new widget with the same options.
#
# Arguments:
#	path		Widget to get the options for.
#	args		A list of options.  If empty, all options are returned.
#
# Results:
#	Returns list of options as: -option value -option value ...
proc Widget::options { path args } {
    if {[llength $args]} {
        foreach option $args {
            lappend options [_get_configure $path $option]
        }
    } else {
        set options [_get_configure $path {}]
    }

    set result [list]
    foreach list $options {
        if {[llength $list] < 5} { continue }
        lappend result [lindex $list 0] [lindex $list end]
    }
    return $result
}


# Widget::getOption --
#
#	Given a list of widgets, determine which option value to use.
#	The widgets are given to the command in order of highest to
#	lowest.  Starting with the lowest widget, whichever one does
#	not match the default option value is returned as the value.
#	If all the widgets are default, we return the highest widget's
#	value.
#
# Arguments:
#	option		The option to check.
#	default		The default value.  If any widget in the list
#			does not match this default, its value is used.
#	args		A list of widgets.
#
# Results:
#	Returns the value of the given option to use.
#
proc Widget::getOption { option default args } {
    for {set i [expr [llength $args] -1]} {$i >= 0} {incr i -1} {
	set widget [lindex $args $i]
	set value  [Widget::cget $widget $option]
	if {[string equal $value $default]} { continue }
	return $value
    }
    return $value
}


proc Widget::nextIndex { path node } {
    Widget::getVariable $path autoIndex
    if {![info exists autoIndex]} { set autoIndex -1 }
    return [string map [list #auto [incr autoIndex]] $node]
}


proc Widget::exists { path } {
    variable _class
    return [info exists _class($path)]
}

proc Widget::theme {{bool {}}} {
    # Private, *experimental* API that may change at any time - JH
    variable _theme
    if {[llength [info level 0]] == 2} {
	# set theme-ability
	if {[catch {package require tile 0.6}]
	    && [catch {package require tile 1}]} {
	    return -code error "BWidget's theming requires tile 0.6+"
	} else {
	    catch {style default BWSlim.Toolbutton -padding 0}
	}
	set _theme [string is true -strict $bool]
    }
    return $_theme
}


namespace eval ProgressBar {
    Widget::define ProgressBar progressbar

    Widget::declare ProgressBar {
        {-type        Enum       normal     0
                      {normal incremental infinite nonincremental_infinite}}
        {-maximum     Int        100        0 "%d > 0"}
        {-background  TkResource ""         0 frame}
        {-foreground  TkResource "blue"     0 label}
        {-borderwidth TkResource 2          0 frame}
        {-troughcolor TkResource ""         0 scrollbar}
        {-relief      TkResource sunken     0 label}
        {-orient      Enum       horizontal 1 {horizontal vertical}}
        {-variable    String     ""         0}
        {-idle        Boolean    0          0}
        {-width       TkResource 100        0 frame}
        {-height      TkResource 4m         0 frame}
        {-bg          Synonym    -background}
        {-fg          Synonym    -foreground}
        {-bd          Synonym    -borderwidth}
    }

    Widget::addmap ProgressBar "" :cmd {-background {} -width {} -height {}}
    Widget::addmap ProgressBar "" .bar {
	-troughcolor -background -borderwidth {} -relief {}
    }

    variable _widget
}


# ----------------------------------------------------------------------------
#  Command ProgressBar::create
# ----------------------------------------------------------------------------
proc ProgressBar::create { path args } {
    variable _widget

    array set maps [list ProgressBar {} :cmd {} .bar {}]
    array set maps [Widget::parseArgs ProgressBar $args]
    eval frame $path $maps(:cmd) -class ProgressBar -bd 0 \
	    -highlightthickness 0 -relief flat
    Widget::initFromODB ProgressBar $path $maps(ProgressBar)

    set c  [eval [list canvas $path.bar] $maps(.bar) -highlightthickness 0]
    set fg [Widget::cget $path -foreground]
    if { [string equal [Widget::cget $path -orient] "horizontal"] } {
        $path.bar create rectangle -1 0 0 0 -fill $fg -outline $fg -tags rect
    } else {
        $path.bar create rectangle 0 1 0 0 -fill $fg -outline $fg -tags rect
    }

    set _widget($path,val) 0
    set _widget($path,dir) 1
    set _widget($path,var) [Widget::cget $path -variable]
    if {$_widget($path,var) != ""} {
        GlobalVar::tracevar variable $_widget($path,var) w \
		[list ProgressBar::_modify $path]
        set _widget($path,afterid) \
	    [after idle [list ProgressBar::_modify $path]]
    }

    bind $path.bar <Destroy>   [list ProgressBar::_destroy $path]
    bind $path.bar <Configure> [list ProgressBar::_modify $path]

    return [Widget::create ProgressBar $path]
}


# ----------------------------------------------------------------------------
#  Command ProgressBar::configure
# ----------------------------------------------------------------------------
proc ProgressBar::configure { path args } {
    variable _widget

    set res [Widget::configure $path $args]

    if { [Widget::hasChangedX $path -variable] } {
	set newv [Widget::cget $path -variable]
        if { $_widget($path,var) != "" } {
            GlobalVar::tracevar vdelete $_widget($path,var) w \
		    [list ProgressBar::_modify $path]
        }
        if { $newv != "" } {
            set _widget($path,var) $newv
            GlobalVar::tracevar variable $newv w \
		    [list ProgressBar::_modify $path]
	    if {![info exists _widget($path,afterid)]} {
		set _widget($path,afterid) \
		    [after idle [list ProgressBar::_modify $path]]
	    }
        } else {
            set _widget($path,var) ""
        }
    }

    foreach {cbd cor cma} [Widget::hasChangedX $path -borderwidth \
	    -orient -maximum] break

    if { $cbd || $cor || $cma } {
	if {![info exists _widget($path,afterid)]} {
	    set _widget($path,afterid) \
		[after idle [list ProgressBar::_modify $path]]
	}
    }
    if { [Widget::hasChangedX $path -foreground] } {
	set fg [Widget::cget $path -foreground]
        $path.bar itemconfigure rect -fill $fg -outline $fg
    }
    return $res
}


# ----------------------------------------------------------------------------
#  Command ProgressBar::cget
# ----------------------------------------------------------------------------
proc ProgressBar::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command ProgressBar::_modify
# ----------------------------------------------------------------------------
proc ProgressBar::_modify { path args } {
    variable _widget

    catch {unset _widget($path,afterid)}
    if { ![GlobalVar::exists $_widget($path,var)] ||
	 [set val [GlobalVar::getvar $_widget($path,var)]] < 0 } {
        catch {place forget $path.bar}
    } else {
	place $path.bar -relx 0 -rely 0 -relwidth 1 -relheight 1
	set type [Widget::getoption $path -type]
	if { $val != 0 && $type != "normal" && \
		$type != "nonincremental_infinite"} {
	    set val [expr {$val+$_widget($path,val)}]
	}
	set _widget($path,val) $val
	set max [Widget::getoption $path -maximum]
	set bd  [expr {2*[$path.bar cget -bd]}]
	set w   [winfo width  $path.bar]
	set h   [winfo height $path.bar]
	if {$type == "infinite" || $type == "nonincremental_infinite"} {
	    # JDC: New infinite behaviour
	    set tval [expr {$val % $max}]
	    if { $tval < ($max / 2.0) } {
		set x0 [expr {double($tval) / double($max) * 1.5}]
	    } else {
		set x0 [expr {(1.0-(double($tval) / double($max))) * 1.5}]
	    }
	    set x1 [expr {$x0 + 0.25}]
	    # convert coords to ints to prevent triggering canvas refresh
	    # bug related to fractional coords
	    if {[Widget::getoption $path -orient] == "horizontal"} {
		$path.bar coords rect [expr {int($x0*$w)}] 0 \
		    [expr {int($x1*$w)}] $h
	    } else {
		$path.bar coords rect 0 [expr {int($h-$x0*$h)}] $w \
		    [expr {int($x1*$h)}]
	    }
	} else {
	    if { $val > $max } {set val $max}
	    if {[Widget::getoption $path -orient] == "horizontal"} {
		$path.bar coords rect -1 0 [expr {int(double($val)*$w/$max)}] $h
	    } else {
		$path.bar coords rect 0 [expr {$h+1}] $w \
		    [expr {int($h*(1.0 - double($val)/$max))}]
	    }
	}
    }
    if {![Widget::cget $path -idle]} {
	update idletasks
    }
}


# ----------------------------------------------------------------------------
#  Command ProgressBar::_destroy
# ----------------------------------------------------------------------------
proc ProgressBar::_destroy { path } {
    variable _widget

    if {[info exists _widget($path,afterid)]} {
	after cancel $_widget($path,afterid)
	unset _widget($path,afterid)
    }
    if {[info exists _widget($path,var)]} {
	if {$_widget($path,var) != ""} {
	    GlobalVar::tracevar vdelete $_widget($path,var) w \
		[list ProgressBar::_modify $path]
	}
	unset _widget($path,var)
    }
    unset _widget($path,dir)
    Widget::destroy $path
}
