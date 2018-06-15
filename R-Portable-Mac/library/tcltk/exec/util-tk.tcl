# util-tk.tcl --
#
#	This file implements package ::Utility::tk, which  ...
#
# Copyright (c) 1997-8 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require Tk
package require ::Utility
package provide ::Utility::tk 1.0

namespace eval ::Utility::tk {;

namespace export -clear *

## PROBLEM HERE
## 
## Only uncomment one of the following namespace import lines
##

## This is what I theoretically need, but it causes the Abort in
## regular wish.  This works for wish with TCL_MEM_DEBUG.
#namespace import -force ::Utility::get_opts ::Utility::highlight

## This works, but is essentially useless in my situation
#namespace import -force ::Utility::expand::* ::Utility::dump::*

## This works too, but is silly
after idle [namespace code [list namespace import -force \
	::Utility::highlight ::Utility::get_opts]]

## This causes constant Bus Error on startup with regular wish
## but the Abort with debugging wish.
#namespace import -force ::Utility::*

## The abort message mentioned above is:

#DeleteImportedCmd: did not find cmd in real cmd's list of import references
#Abort

## If I try loading the above interactively as opposed to the tour at
## command line, I get a seg fault instead of a bus error.

##
## YOU CAN IGNORE THE REST
##

# warn --
#
#   Simple warning alias to ease programming
#
# Arguments:
#   msg		The warning message to display
# Results:
#   Returns nothing important.
#
proc warn {msg} {
    bell
    tk_dialog .__warning Warning $msg warning 0 OK
}

# place_window --
#   place a toplevel at a particular position
# Arguments:
#   toplevel	name of toplevel window
#   ?placement?	pointer ?center? ; places $w centered on the pointer
#		widget widget_name ; centers $w over widget_name
#		defaults to placing toplevel in the middle of the screen
#   ?anchor?
# Results:
#   Returns nothing
#
proc place_window {w {placement ""} {anchor ""}} {
    wm withdraw $w
    update idletasks
    switch -glob -- $placement {
	p*	{ ## place at POINTER (centered is $anchor == center)
	    if {[string match "c*" $anchor]} {
		wm geometry $w +[expr \
			{[winfo pointerx $w]-[winfo width $w]/2}]+[expr \
			{[winfo pointery $w]-[winfo height $w]/2}]
	    } else {
		wm geometry $w +[winfo pointerx $w]+[winfo pointery $w]
	    }
	}
	w*	{ ## center about WIDGET $anchor
	    wm geometry $w +[expr {[winfo rootx $anchor]+([winfo width \
		    $anchor]-[winfo width $w])/2}]+[expr {[winfo rooty \
		    $anchor]+([winfo height $anchor]-[winfo height $w])/2}]
	}
	default	{
	    wm geometry $w +[expr {([winfo screenwidth $w]-\
		    [winfo reqwidth $w])/2}]+[expr \
		    {([winfo screenheight $w]-[winfo reqheight $w])/2}]
	}
    }
    wm deiconify $w
}

## Centers the canvas around points x & y
##
## Unoptimized, this looks like:
##    set xtenth [expr .10 * [winfo width $w]]
##    set ytenth [expr .10 * [winfo height $w]]
##    set X [expr [winfo width $w] / 2]
##    set Y [expr [winfo height $w] / 2]
##    set x1 [expr round(($x-$X)/$xtenth)]
##    set y1 [expr round(($y-$Y)/$ytenth)]
##    $w xview scroll $x1 units
##    $w yview scroll $y1 units
##
proc canvas_center {w x y} {
    $w xview scroll [expr {round(10.0*$x/[winfo width $w]-5)}] units
    $w yview scroll [expr {round(10.0*$y/[winfo height $w]-5)}] units
}

## "see" method alternative for canvas
## Aligns the named item as best it can in the middle of the screen
## Behavior depends on whether -scrollregion is set
##
## c    - a canvas widget
## item - a canvas tagOrId
proc canvas_see {c item} {
    set box [$c bbox $item]
    if {[string match {} $box]} return
    if {[string match {} [$c cget -scrollregion]]} {
	## People really should set -scrollregion you know...
	foreach {x y x1 y1} $box {
	    set x [expr {round(2.5*($x1+$x)/[winfo width $c])}]
	    set y [expr {round(2.5*($y1+$y)/[winfo height $c])}]
	}
	$c xview moveto 0
	$c yview moveto 0
	$c xview scroll $x units
	$c yview scroll $y units
    } else {
	## If -scrollregion is set properly, use this
	foreach {x y x1 y1} $box {top btm} [$c yview] {left right} [$c xview] \
		{p q xmax ymax} [$c cget -scrollregion] {
	    set xpos [expr {(($x1+$x)/2.0)/$xmax - ($right-$left)/2.0}]
	    set ypos [expr {(($y1+$y)/2.0)/$ymax - ($btm-$top)/2.0}]
	}
	$c xview moveto $xpos
	$c yview moveto $ypos
    }
}

## Set cursor of widget $w and its descendants to $cursor
## Ignores {} cursors
proc cursor_set {w cursor} {
    variable CURSOR
    if {[string compare {} [set CURSOR($w) [$w cget -cursor]]]} {
	$w config -cursor $cursor
    } else {
	unset CURSOR($w)
    }
    foreach child [winfo children $w] { cursor_set $child $cursor }
}

## Restore cursor based on CURSOR($w) for $w and its descendants
## $cursor is the default cursor (if none was cached)
proc cursor_restore {w {cursor {}}} {
    variable CURSOR
    if {[info exists CURSOR($w)]} {
	$w config -cursor $CURSOR($w)
    } else {
	$w config -cursor $cursor
    }
    foreach child [winfo children $w] { cursor_restore $child $cursor }
}

# highlight_dialog --
#
#   creates minimal dialog interface to highlight
#
# Arguments:
#   w	text widget
#   str	optional seed string for HIGHLIGHT(string)
# Results:
#   Returns null.
#
proc highlight_dialog {w {str {}}} {
    variable HIGHLIGHT

    set namesp [namespace current]
    set var ${namesp}::HIGHLIGHT
    set base $w.__highlight
    if {![winfo exists $base]} {
	toplevel $base
	wm withdraw $base
	wm title $base "Find String"

	pack [frame $base.f] -fill x -expand 1
	label $base.f.l -text "Find:"
	entry $base.f.e -textvariable ${var}($w,string)
	pack [frame $base.opt] -fill x
	checkbutton $base.opt.c -text "Case Sensitive" \
		-variable ${var}($w,nocase)
	checkbutton $base.opt.r -text "Use Regexp" -variable ${var}($w,regexp)
	pack $base.f.l -side left
	pack $base.f.e $base.opt.c $base.opt.r -side left -fill both -expand 1
	pack [frame $base.sep -bd 2 -relief sunken -height 4] -fill x
	pack [frame $base.btn] -fill both
	button $base.btn.fnd -text "Find" -width 6
	button $base.btn.clr -text "Clear" -width 6
	button $base.btn.dis -text "Dismiss" -width 6
	eval pack [winfo children $base.btn] -padx 4 -pady 2 \
		-side left -fill both

	focus $base.f.e

	bind $base.f.e <Return> [list $base.btn.fnd invoke]
	bind $base.f.e <Escape> [list $base.btn.dis invoke]
    }
    ## FIX namespace
    $base.btn.fnd config -command [namespace code \
	    "highlight [list $w] \[set ${var}($w,string)\] \
	    \[expr {\[set ${var}($w,nocase)\]?{}:{-nocase}}] \
	    \[expr {\[set ${var}($w,regexp)\]?{-regexp}:{}}] \
	    -tag __highlight -color [list yellow]"]
    $base.btn.clr config -command \
	    "[list $w] tag remove __highlight 1.0 end;\
	    set [list ${var}($w,string)] {}"
    $base.btn.dis config -command \
	    "[list $w] tag remove __highlight 1.0 end;\
	    wm withdraw [list $base]"
    if {[string compare {} $str]} {
	set ${var}($w,string) $str
	$base.btn.fnd invoke
    }

    if {[string compare normal [wm state $base]]} {
	wm deiconify $base
    } else {
	raise $base
    }
    $base.f.e select range 0 end
}


}; # end namespace ::Utility::Tk
