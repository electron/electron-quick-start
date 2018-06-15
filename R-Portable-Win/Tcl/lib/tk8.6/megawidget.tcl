# megawidget.tcl
#
#	Basic megawidget support classes. Experimental for any use other than
#	the ::tk::IconList megawdget, which is itself only designed for use in
#	the Unix file dialogs.
#
# Copyright (c) 2009-2010 Donal K. Fellows
#
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require Tk 8.6

::oo::class create ::tk::Megawidget {
    superclass ::oo::class
    method unknown {w args} {
	if {[string match .* $w]} {
	    [self] create $w {*}$args
	    return $w
	}
	next $w {*}$args
    }
    unexport new unknown
    self method create {name superclasses body} {
	next $name [list \
		superclass ::tk::MegawidgetClass {*}$superclasses]\;$body
    }
}

::oo::class create ::tk::MegawidgetClass {
    variable w hull OptionSpecification options IdleCallbacks
    constructor args {
	# Extract the "widget name" from the object name
	set w [namespace tail [self]]

	# Configure things
	set OptionSpecification [my GetSpecs]
	my configure {*}$args

	# Move the object out of the way of the hull widget
	rename [self] _tmp

	# Make the hull widget(s)
	my CreateHull
	bind $hull <Destroy> [list [namespace which my] destroy]

	# Rename things into their final places
	rename ::$w theFrame
	rename [self] ::$w

	# Make the contents
	my Create
    }
    destructor {
	foreach {name cb} [array get IdleCallbacks] {
	    after cancel $cb
	    unset IdleCallbacks($name)
	}
	if {[winfo exists $w]} {
	    bind $hull <Destroy> {}
	    destroy $w
	}
    }

    method configure args {
	tclParseConfigSpec [my varname options] $OptionSpecification "" $args
    }
    method cget option {
	return $options($option)
    }

    method GetSpecs {} {
	return {
	    {-takefocus takeFocus TakeFocus {}}
	}
    }

    method CreateHull {} {
	return -code error -errorcode {TCL OO ABSTRACT_METHOD} \
	    "method must be overridden"
    }
    method Create {} {
	return -code error -errorcode {TCL OO ABSTRACT_METHOD} \
	    "method must be overridden"
    }

    method WhenIdle {method args} {
	if {![info exists IdleCallbacks($method)]} {
	    set IdleCallbacks($method) [after idle [list \
		    [namespace which my] DoWhenIdle $method $args]]
	}
    }
    method DoWhenIdle {method arguments} {
	unset IdleCallbacks($method)
	tailcall my $method {*}$arguments
    }
}

::tk::Megawidget create ::tk::SimpleWidget {} {
    variable w hull options
    method GetSpecs {} {
	return {
	    {-cursor cursor Cursor {}}
	    {-takefocus takeFocus TakeFocus {}}
	}
    }
    method CreateHull {} {
	set hull [::ttk::frame $w -cursor $options(-cursor)]
	trace add variable options(-cursor) write \
	    [namespace code {my UpdateCursorOption}]
    }
    method UpdateCursorOption args {
	$hull configure -cursor $options(-cursor)
    }
    method state args {
	tailcall $hull state {*}$args
    }
    method instate args {
	tailcall $hull instate {*}$args
    }
}

::tk::Megawidget create ::tk::FocusableWidget ::tk::SimpleWidget {
    variable w hull options
    method GetSpecs {} {
	return {
	    {-cursor cursor Cursor {}}
	    {-takefocus takeFocus TakeFocus ::ttk::takefocus}
	}
    }
    method CreateHull {} {
	ttk::frame $w
	set hull [ttk::entry $w.cHull -takefocus 0 -cursor $options(-cursor)]
	pack $hull -expand yes -fill both -ipadx 2 -ipady 2
	trace add variable options(-cursor) write \
	    [namespace code {my UpdateCursorOption}]
    }
}

return

# Local Variables:
# mode: tcl
# fill-column: 78
# End:
