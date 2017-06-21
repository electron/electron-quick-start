# ----------------------------------------------------------------------------
#  buttonbox.tcl
#  This file is part of Unifix BWidget Toolkit
# ----------------------------------------------------------------------------
#  Index of commands:
#     - ButtonBox::create
#     - ButtonBox::configure
#     - ButtonBox::cget
#     - ButtonBox::add
#     - ButtonBox::itemconfigure
#     - ButtonBox::itemcget
#     - ButtonBox::setfocus
#     - ButtonBox::invoke
#     - ButtonBox::index
#     - ButtonBox::_destroy
# ----------------------------------------------------------------------------

namespace eval ButtonBox {
    Widget::define ButtonBox buttonbox Button

    Widget::declare ButtonBox {
	{-background  TkResource ""	    0 frame}
	{-orient      Enum	 horizontal 1 {horizontal vertical}}
	{-state	      Enum	 "normal"   0 {normal disabled}}
	{-homogeneous Boolean	 1	    1}
	{-spacing     Int	 10	    0 "%d >= 0"}
	{-padx	      TkResource ""	    0 button}
	{-pady	      TkResource ""	    0 button}
	{-default     Int	 -1	    0 "%d >= -1"}
	{-bg	      Synonym	 -background}
    }

    Widget::addmap ButtonBox "" :cmd {-background {}}

    bind ButtonBox <Destroy> [list ButtonBox::_destroy %W]
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::create
# ----------------------------------------------------------------------------
proc ButtonBox::create { path args } {
    Widget::init ButtonBox $path $args

    variable $path
    upvar 0  $path data

    eval [list frame $path] [Widget::subcget $path :cmd] \
	[list -class ButtonBox -takefocus 0 -highlightthickness 0]
    # For 8.4+ we don't want to inherit the padding
    catch {$path configure -padx 0 -pady 0}

    set data(max)      0
    set data(nbuttons) 0
    set data(buttons)  [list]
    set data(default)  [Widget::getoption $path -default]

    return [Widget::create ButtonBox $path]
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::configure
# ----------------------------------------------------------------------------
proc ButtonBox::configure { path args } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -default val] } {
        if { $data(default) != -1 && $val != -1 } {
            set but $path.b$data(default)
            if { [winfo exists $but] } {
                $but configure -default normal
            }
            set but $path.b$val
            if { [winfo exists $but] } {
                $but configure -default active
            }
            set data(default) $val
        } else {
            Widget::setoption $path -default $data(default)
        }
    }

    if {[Widget::hasChanged $path -state val]} {
	foreach i $data(buttons) {
	    $path.b$i configure -state $val
	}
    }

    return $res
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::cget
# ----------------------------------------------------------------------------
proc ButtonBox::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::add
# ----------------------------------------------------------------------------
proc ButtonBox::add { path args } {
    return [eval [linsert $args 0 insert $path end]]
}


proc ButtonBox::insert { path idx args } {
    variable $path
    upvar 0  $path data

    set but     $path.b$data(nbuttons)
    set spacing [Widget::getoption $path -spacing]

    ## Save the current spacing setting for this button.  Buttons
    ## appended to the end of the box have their spacing applied
    ## to their left while all other have their spacing applied
    ## to their right.
    if {$idx == "end"} {
	set data(spacing,$data(nbuttons)) [list left $spacing]
	lappend data(buttons) $data(nbuttons)
    } else {
	set data(spacing,$data(nbuttons)) [list right $spacing]
        set data(buttons) [linsert $data(buttons) $idx $data(nbuttons)]
    }

    if { $data(nbuttons) == $data(default) } {
        set style active
    } elseif { $data(default) == -1 } {
        set style disabled
    } else {
        set style normal
    }

    array set flags $args
    set tags ""
    if { [info exists flags(-tags)] } {
	set tags $flags(-tags)
	unset flags(-tags)
	set args [array get flags]
    }

    if { $::Widget::_theme} {
        eval [list Button::create $but] \
            $args [list -default $style]
	} else {
        eval [list Button::create $but \
    	      -background [Widget::getoption $path -background]\
	          -padx       [Widget::getoption $path -padx] \
	          -pady       [Widget::getoption $path -pady]] \
            $args [list -default $style]
	}

    # ericm@scriptics.com:  set up tags, just like the menu items
    foreach tag $tags {
	lappend data(tags,$tag) $but
	if { ![info exists data(tagstate,$tag)] } {
	    set data(tagstate,$tag) 0
	}
    }
    set data(buttontags,$but) $tags
    # ericm@scriptics.com

    _redraw $path

    incr data(nbuttons)

    return $but
}


proc ButtonBox::delete { path idx } {
    variable $path
    upvar 0  $path data

    set i [lindex $data(buttons) $idx]
    set data(buttons) [lreplace $data(buttons) $idx $idx]
    destroy $path.b$i
}


# ButtonBox::setbuttonstate --
#
#	Set the state of a given button tag.  If this makes any buttons
#       enable-able (ie, all of their tags are TRUE), enable them.
#
# Arguments:
#	path        the button box widget name
#	tag         the tag to modify
#	state       the new state of $tag (0 or 1)
#
# Results:
#	None.

proc ButtonBox::setbuttonstate {path tag state} {
    variable $path
    upvar 0  $path data
    # First see if this is a real tag
    if { [info exists data(tagstate,$tag)] } {
	set data(tagstate,$tag) $state
	foreach but $data(tags,$tag) {
	    set expression "1"
	    foreach buttontag $data(buttontags,$but) {
		append expression " && $data(tagstate,$buttontag)"
	    }
	    if { [expr $expression] } {
		set state normal
	    } else {
		set state disabled
	    }
	    $but configure -state $state
	}
    }
    return
}

# ButtonBox::getbuttonstate --
#
#	Retrieve the state of a given button tag.
#
# Arguments:
#	path        the button box widget name
#	tag         the tag to modify
#
# Results:
#	None.

proc ButtonBox::getbuttonstate {path tag} {
    variable $path
    upvar 0  $path data
    # First see if this is a real tag
    if { [info exists data(tagstate,$tag)] } {
	return $data(tagstate,$tag)
    } else {
	error "unknown tag $tag"
    }
}

# ----------------------------------------------------------------------------
#  Command ButtonBox::itemconfigure
# ----------------------------------------------------------------------------
proc ButtonBox::itemconfigure { path index args } {
    if { [set idx [lsearch $args -default]] != -1 } {
        set args [lreplace $args $idx [expr {$idx+1}]]
    }
    return [eval [list Button::configure $path.b[index $path $index]] $args]
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::itemcget
# ----------------------------------------------------------------------------
proc ButtonBox::itemcget { path index option } {
    return [Button::cget $path.b[index $path $index] $option]
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::setfocus
# ----------------------------------------------------------------------------
proc ButtonBox::setfocus { path index } {
    set but $path.b[index $path $index]
    if { [winfo exists $but] } {
        focus $but
    }
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::invoke
# ----------------------------------------------------------------------------
proc ButtonBox::invoke { path index } {
    set but $path.b[index $path $index]
    if { [winfo exists $but] } {
        Button::invoke $but
    }
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::index
# ----------------------------------------------------------------------------
proc ButtonBox::index { path index } {
    variable $path
    upvar 0  $path data

    set n [expr {$data(nbuttons) - 1}]

    if {[string equal $index "default"]} {
        set res [Widget::getoption $path -default]
    } elseif {$index == "end" || $index == "last"} {
	set res $n
    } elseif {![string is integer -strict $index]} {
	## It's not an integer.  Search the text of each button
	## in the box and return the index that matches.
	foreach i $data(buttons) {
	    set w $path.b$i
	    lappend text  [$w cget -text]
	    lappend names [$w cget -name]
	}
	set res [lsearch -exact [concat $names $text] $index]
    } else {
        set res $index
	if {$index > $n} { set res $n }
    }
    return $res
}


# ButtonBox::gettags --
#
#	Return a list of all the tags on all the buttons in a buttonbox.
#
# Arguments:
#	path      the buttonbox to query.
#
# Results:
#	taglist   a list of tags on the buttons in the buttonbox

proc ButtonBox::gettags {path} {
    upvar ::ButtonBox::$path data
    set taglist {}
    foreach tag [array names data "tags,*"] {
	lappend taglist [string range $tag 5 end]
    }
    return $taglist
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::_redraw
# ----------------------------------------------------------------------------
proc ButtonBox::_redraw { path } {
    variable $path
    upvar 0  $path data
    Widget::getVariable $path buttons

    # For tk >= 8.4, -uniform gridding option is used.
    # Otherwise, there is the constraint, that button size may not change after
    # creation.
    set uniformAvailable [expr {0 <= [package vcompare [info patchlevel] 8.4.0]}]

    ## We re-grid the buttons from left-to-right.  As we go through
    ## each button, we check its spacing and which direction the
    ## spacing applies to.  Once spacing has been applied to an index,
    ## it is not changed.  This means spacing takes precedence from
    ## left-to-right.

    set idx  0
    set idxs [list]
    foreach i $data(buttons) {
	set dir     [lindex $data(spacing,$i) 0]
	set spacing [lindex $data(spacing,$i) 1]
        set but $path.b$i
        if {[string equal [Widget::getoption $path -orient] "horizontal"]} {
            grid $but -column $idx -row 0 -sticky nsew
            if { [Widget::getoption $path -homogeneous] } {
                if {$uniformAvailable} {
                    grid columnconfigure $path $idx -uniform koen -weight 1
                } else {
                    set req [winfo reqwidth $but]
                    if { $req > $data(max) } {
                        grid columnconfigure $path [expr {2*$i}] -minsize $req
                        set data(max) $req
                    }
                    grid columnconfigure $path $idx -weight 1
                }
            } else {
                grid columnconfigure $path $idx -weight 0
            }

	    set col [expr {$idx - 1}]
	    if {[string equal $dir "right"]} { set col [expr {$idx + 1}] }
	    if {$col > 0 && [lsearch $idxs $col] < 0} {
		lappend idxs $col
		grid columnconfigure $path $col -minsize $spacing
	    }
        } else {
            grid $but -column 0 -row $idx -sticky nsew
            grid rowconfigure $path $idx -weight 0

	    set row [expr {$idx - 1}]
	    if {[string equal $dir "right"]} { set row [expr {$idx + 1}] }
	    if {$row > 0 && [lsearch $idxs $row] < 0} {
		lappend idxs $row
		grid rowconfigure $path $row -minsize $spacing
	    }
        }
        incr idx 2
    }

    if {!$uniformAvailable} {
        # Now that the maximum size has been calculated, go back through
        # and correctly set the size for homogeneous horizontal buttons.
        if { [string equal [Widget::getoption $path -orient] "horizontal"] && [Widget::getoption $path -homogeneous] } {
            set idx 0
            foreach i $data(buttons) {
                grid columnconfigure $path $idx -minsize $data(max)
                incr idx 2
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command ButtonBox::_destroy
# ----------------------------------------------------------------------------
proc ButtonBox::_destroy { path } {
    variable $path
    upvar 0  $path data
    Widget::destroy $path
    unset data
}
