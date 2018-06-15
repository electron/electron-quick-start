# util-dump.tcl --
#
#	This file implements package ::Utility::dump, which  ...
#
# Copyright (c) 1997-8 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require ::Utility
package provide ::Utility::dump 1.0

namespace eval ::Utility::dump {;

namespace export -clear dump*
namespace import -force ::Utility::get_opts*

# dump --
#   outputs recognized item info in source'able form.
#   Accepts glob style pattern matching for the names
# Arguments:
#   type	type of item to dump
#   -nocomplain	
#   -filter	pattern
#		specifies a glob filter pattern to be used by the variable
#		method as an array filter pattern (it filters down for
#		nested elements) and in the widget method as a config
#		option filter pattern
#   -procs	
#   -vars	
#   -recursive	
#   -imports	
#   --		forcibly ends options recognition
# Results:
#	the values of the requested items in a 'source'able form
;proc dump {type arg
s} {
    if {![llength $args]} {
	## If no args, assume they gave us something to dump and
	## we'll try anything
	set args [list $type]
	set type multi
    }
    ## Args are handled individually by the routines because of the
    ## variable parameters for each type
    set prefix [namespace current]::dump_
    if {[string match {} [set arg [info commands $prefix$type]]]} {
	set arg [info commands $prefix$type*]
    }
    set result {}
    set code ok
    switch [llength $arg] {
	1 { set code [catch {uplevel $arg $args} result] }
	0 {
	    set arg [info commands $prefix*]
	    regsub -all $prefix $arg {} arg
	    return -code error "unknown [lindex [info level 0] 0] type\
		    \"$type\", must be one of: [join [lsort $arg] {, }]"
	}
	default {
	    regsub -all $prefix $arg {} arg
	    return -code error "ambiguous type \"$type\",\
		    could be one of: [join [lsort $arg] {, }]"
	}
    }
    return -code $code $result
}

# dump_multi --
#
#   Tries to work the args into one of the main dump types:
#   variable, command, widget, namespace
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_multi {args} {
    array set opts {
	-nocomplain 0
    }
    set namesp [namespace current]
    set args [get_opts opts $args {-nocomplain 0} {} 1]
    set code ok
    if {
	[catch {uplevel ${namesp}::dump var $args} err] &&
	[catch {uplevel ${namesp}::dump com $args} err] &&
	[catch {uplevel ${namesp}::dump wid $args} err] &&
	[catch {uplevel ${namesp}::dump nam $args} err]
    } {
	set result "# unable to resolve type for \"$args\"\n"
	if {!$opts(-nocomplain)} {
	    set code error
	}
    } else {
	set result $err
    }
    return -code $code [string trimright $result \n]
}

# dump_command --
#
# outputs commands by figuring out, as well as possible,
# it does not attempt to auto-load anything
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_command {args} {
    array set opts {
	-nocomplain 0 -origin 0
    }
    set args [get_opts opts $args {-nocomplain 0 -origin 0}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump command ?-nocomplain?"
	}
    }
    set code ok
    set result {}
    set namesp [namespace current]
    foreach arg $args {
	if {[string compare {} [set cmds \
		[uplevel info command [list $arg]]]]} {
	    foreach cmd [lsort $cmds] {
		if {[lsearch -exact [interp aliases] $cmd] > -1} {
		    append result "\#\# ALIAS:   $cmd =>\
			    [interp alias {} $cmd]\n"
		} elseif {![catch {uplevel ${namesp}::dump_proc \
			[expr {$opts(-origin)?{-origin}:{}}] \
			-- [list $cmd]} msg]} {
		    append result $msg\n
		} else {
		    if {$opts(-origin) || [string compare $namesp \
			    [uplevel namespace current]]} {
			set cmd [uplevel namespace origin [list $cmd]]
		    }
		    append result "\#\# COMMAND: $cmd\n"
		}
	    }
	} elseif {!$opts(-nocomplain)} {
	    append result "\#\# No known command $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_proc --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_proc {args} {
    array set opts {
	-nocomplain 0 -origin 0
    }
    set args [get_opts opts $args {-nocomplain 0 -origin 0}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump proc ?-nocomplain?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	set procs [uplevel info command [list $arg]]
	set count 0
	if {[string compare $procs {}]} {
	    foreach p [lsort $procs] {
		set cmd [uplevel namespace origin [list $p]]
		set namesp [namespace qualifiers $cmd]
		if {[string match {} $namesp]} { set namesp :: }
		if {[string compare [namespace eval $namesp \
			info procs [list [namespace tail $cmd]]] {}]} {
		    incr count
		} else {
		    continue
		}
		set pargs {}
		foreach a [info args $cmd] {
		    if {[info default $cmd $a tmp]} {
			lappend pargs [list $a $tmp]
		    } else {
			lappend pargs $a
		    }
		}
		if {$opts(-origin) || [string compare $namesp \
			[uplevel namespace current]]} {
		    ## This is ideal, but list can really screw with the
		    ## format of the body for some procs with odd whitespacing
		    ## (everything comes out backslashed)
		    #append result [list proc $cmd $pargs [info body $cmd]]
		    append result [list proc $cmd $pargs]
		} else {
		    ## We don't include the full namespace qualifiers
		    ## if we are in the namespace of origin
		    #append result [list proc $p $pargs [info body $cmd]]
		    append result [list proc $p $pargs]
		}
		append result " \{[info body $cmd]\}\n\n"
	    }
	}
	if {!$count && !$opts(-nocomplain)} {
	    append result "\#\# No known proc $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_variable --
#
# outputs variable value(s), whether array or simple, namespaced or otherwise
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
## FIX perhaps a little namespace which is necessary here
proc dump_variable {args} {
    array set opts {
	-nocomplain 0 -filter *
    }
    set args [get_opts opts $args {-nocomplain 0 -filter 1}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump variable ?-nocomplain?\
		    ?-filter glob? ?--? pattern ?pattern ...?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	if {[string match {} [set vars [uplevel info vars [list $arg]]]]} {
	    if {[uplevel info exists $arg]} {
		set vars $arg
	    } elseif {!$opts(-nocomplain)} {
		append result "\#\# No known variable $arg\n"
		set code error
		continue
	    } else { continue }
	}
	foreach var [lsort -dictionary $vars] {
	    set var [uplevel [list namespace which -variable $var]]
	    upvar $var v
	    if {[array exists v] || [catch {string length $v}]} {
		set nest {}
		append result "array set $var \{\n"
		foreach i [lsort -dictionary [array names v $opts(-filter)]] {
		    upvar 0 v\($i\) __ary
		    if {[array exists __ary]} {
			append nest "\#\# NESTED ARRAY ELEMENT: $i\n"
			append nest "upvar 0 [list $var\($i\)] __ary;\
				[dump v -filter $opts(-filter) __ary]\n"
		    } else {
			append result "    [list $i]\t[list $v($i)]\n"
		    }
		}
		append result "\}\n$nest"
	    } else {
		append result [list set $var $v]\n
	    }
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_namespace --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_namespace {args} {
    array set opts {
	-nocomplain 0 -filter *	-procs 1 -vars 1 -recursive 0 -imports 1
    }
    set args [get_opts opts $args {-nocomplain 0 -procs 1 -vars 1 \
	    -recursive 0 -imports 1} {-procs boolean -vars boolean \
	    -imports boolean}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump namespace ?-nocomplain?\
		    ?-procs 0/1? ?-vars 0/1? ?-recursive? ?-imports 0/1?\
		    ?--? pattern ?pattern ...?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	set cur [uplevel namespace current]
	# Namespace search order:
	# If it starts with ::, try and break it apart and see if we find
	# children matching the pattern
	# Then do the same in $cur if it has :: anywhere in it
	# Then look in the calling namespace for children matching $arg
	# Then look in the global namespace for children matching $arg
	if {
	    ([string match ::* $arg] &&
	    [catch [list namespace children [namespace qualifiers $arg] \
		    [namespace tail $arg]] names]) &&
	    ([string match *::* $arg] &&
	    [catch [list namespace eval $cur [list namespace children \
		    [namespace qualifiers $arg] \
		    [namespace tail $arg]] names]]) &&
	    [catch [list namespace children $cur $arg] names] && 
	    [catch [list namespace children :: $arg] names]
	} {
	    if {!$opts(-nocomplain)} {
		append result "\#\# No known namespace $arg\n"
		set code error
	    }
	}
	if {[string compare $names {}]} {
	    set count 0
	    foreach name [lsort $names] {
		append result "namespace eval $name \{;\n\n"
		if {$opts(-vars)} {
		    set vars [lremove [namespace eval $name info vars] \
			    [info globals]]
		    append result [namespace eval $name \
			    [namespace current]::dump_variable [lsort $vars]]\n
		}
		set procs [namespace eval $name info procs]
		if {$opts(-procs)} {
		    set export [namespace eval $name namespace export]
		    if {[string compare $export {}]} {
			append result "namespace export -clear $export\n\n"
		    }
		    append result [namespace eval $name \
			    [namespace current]::dump_proc [lsort $procs]]
		}
		if {$opts(-imports)} {
		    set cmds [info commands ${name}::*]
		    regsub -all ${name}:: $cmds {} cmds
		    set cmds [lremove $cmds $procs]
		    foreach cmd [lsort $cmds] {
			set cmd [namespace eval $name \
				[list namespace origin $cmd]]
			if {[string compare $name \
				[namespace qualifiers $cmd]]} {
			    ## Yup, it comes from somewhere else
			    append result [list namespace import -force $cmd]
			} else {
			    ## It is probably an alias
			    set alt [interp alias {} $cmd]
			    if {[string compare $alt {}]} {
				append result "interp alias {} $cmd {} $alt"
			    } else {
				append result "# CANNOT HANDLE $cmd"
			    }
			}
			append result \n
		    }
		    append result \n
		}
		if {$opts(-recursive)} {
		    append result [uplevel [namespace current]::dump_namespace\
			    [namespace children $name]]
		}
		append result "\}; # end of namespace $name\n\n"
	    }
	} elseif {!$opts(-nocomplain)} {
	    append result "\#\# No known namespace $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_widget --
#   Outputs a widget configuration in source'able but human readable form.
# Arguments:
#   args	comments
# Results:
#   Returns widget configuration in "source"able form.
#
proc dump_widget {args} {
    if {[string match {} [info command winfo]]} {
	return -code error "winfo not present, cannot dump widgets"
    }
    array set opts {
	-nocomplain 0 -filter .* -default 0
    }
    set args [get_opts opts $args {-nocomplain 0 -filter 1 -default 0} \
	    {-filter regexp}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump widget ?-nocomplain?\
		    ?-default? ?-filter regexp? ?--? pattern ?pattern ...?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	if {[string compare {} [set ws [info command $arg]]]} {
	    foreach w [lsort $ws] {
		if {[winfo exists $w]} {
		    if {[catch {$w configure} cfg]} {
			append result "\#\# Widget $w\
				does not support configure method"
			if {!$opts(-nocomplain)} {
			    set code error
			}
		    } else {
			append result "\#\# [winfo class $w] $w\n$w configure"
			foreach c $cfg {
			    if {[llength $c] != 5} continue
			    ## Filter options according to user provided
			    ## filter, and then check to see that they
			    ## are a default
			    if {[regexp -nocase -- $opts(-filter) $c] && \
				    ($opts(-default) || [string compare \
				    [lindex $c 3] [lindex $c 4]])} {
				append result " \\\n\t[list [lindex $c 0]\
					[lindex $c 4]]"
			    }
			}
			append result \n
		    }
		}
	    }
	} elseif {!$opts(-nocomplain)} {
	    append result "\#\# No known widget $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_canvas --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_canvas {args} {
    if {[string match {} [info command winfo]]} {
	return -code error "winfo not present, cannot dump widgets"
    }
    array set opts {
	-nocomplain 0 -default 0 -configure 0 -filter .*
    }
    set args [get_opts opts $args {-nocomplain 0 -filter 1 -default 0 \
	    -configure 0} {-filter regexp}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump canvas ?-nocomplain?\
		    ?-configure? ?-default? ?-filter regexp? ?--? pattern\
		    ?pattern ...?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	if {[string compare {} [set ws [info command $arg]]]} {
	    foreach w [lsort $ws] {
		if {[winfo exists $w]} {
		    if {[string compare Canvas [winfo class $w]]} {
			append result "\#\# Widget $w is not a canvas widget"
			if {!$opts(-nocomplain)} {
			    set code error
			}
		    } else {
			if {$opts(-configure)} {
			    append result [dump_widget -filter $opts(-filter) \
				    [expr {$opts(-default)?{-default}:{-no}}] \
				    $w]
			    append result \n
			} else {
			    append result "\#\# Canvas $w items\n"
			}
			## Output canvas items in numerical order
			foreach i [lsort -integer [$w find all]] {
			    append result "\#\# Canvas item $i\n" \
				    "$w create [$w type $i] [$w coords $i]"
			    foreach c [$w itemconfigure $i] {
				if {[llength $c] != 5} continue
				if {$opts(-default) || [string compare \
					[lindex $c 3] [lindex $c 4]]} {
				    append result " \\\n\t[list [lindex $c 0]\
					    [lindex $c 4]]"
				}
			    }
			    append result \n
			}
		    }
		}
	    }
	} elseif {!$opts(-nocomplain)} {
	    append result "\#\# No known widget $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_text --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_text {args} {
    if {[string match {} [info command winfo]]} {
	return -code error "winfo not present, cannot dump widgets"
    }
    array set opts {
	-nocomplain 0 -default 0 -configure 0 -start 1.0 -end end
    }
    set args [get_opts opts $args {-nocomplain 0 -default 0 \
	    -configure 0 -start 1 -end 1}]
    if {[string match {} $args]} {
	if {$opts(-nocomplain)} {
	    return
	} else {
	    return -code error "wrong \# args: dump text ?-nocomplain?\
		    ?-configure? ?-default? ?-filter regexp? ?--? pattern\
		    ?pattern ...?"
	}
    }
    set code ok
    set result {}
    foreach arg $args {
	if {[string compare {} [set ws [info command $arg]]]} {
	    foreach w [lsort $ws] {
		if {[winfo exists $w]} {
		    if {[string compare Text [winfo class $w]]} {
			append result "\#\# Widget $w is not a text widget"
			if {!$opts(-nocomplain)} {
			    set code error
			}
		    } else {
			if {$opts(-configure)} {
			    append result [dump_widget -filter $opts(-filter) \
				    [expr {$opts(-default)?{-default}:{-no}}] \
				    $w]
			    append result \n
			} else {
			    append result "\#\# Text $w dump\n"
			}
			catch {unset tags}
			catch {unset marks}
			set text {}
			foreach {k v i} [$w dump $opts(-start) $opts(-end)] {
			    switch -exact $k {
				text {
				    append text $v
				}
				window {
				    # must do something with windows
				    # will require extra options to determine
				    # whether to rebuild the window or to
				    # just reference it
				    append result "#[list $w] window create\
					    $i [$w window configure $i]\n"
				}
				mark {set marks($v) $i}
				tagon {lappend tags($v) $i}
				tagoff {lappend tags($v) $i}
				default {
				    error "[info level 0]:\
					    should not be in this switch arm"
				}
			    }
			}
			append result "[list $w insert $opts(-start) $text]\n"
			foreach i [$w tag names] {
			    append result "[list $w tag configure $i]\
				    [$w tag configure $i]\n"
			    if {[info exists tags($i)]} {
				append result "[list $w tag add $i]\
					$tags($i)\n"
			    }
			    foreach seq [$w tag bind $i] {
				append result "[list $w tag bind $i $seq \
					[$w tag bind $i $seq]]\n"
			    }
			}
			foreach i [array names marks] {
			    append result "[list $w mark set $i $marks($i)]\n"
			}
		    }
		}
	    }
	} elseif {!$opts(-nocomplain)} {
	    append result "\#\# No known widget $arg\n"
	    set code error
	}
    }
    return -code $code [string trimright $result \n]
}

# dump_interface -- NOT FUNCTIONAL
#
#   the end-all-be-all of Tk dump commands.  This should dump the widgets
#   of an interface with all the geometry management.
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_interface {args} {

}

# dump_state --
#
#   This dumps the state of an interpreter.  This is primarily a wrapper
#   around other dump commands with special options.
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc dump_state {args} {

}


## Force the parent namespace to include the exported commands
##
catch {namespace eval ::Utility namespace import -force ::Utility::dump::*}

}; # end of namespace ::Utility::dump

return
