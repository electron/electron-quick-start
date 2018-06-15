# util-expand.tcl --
#
#	This file implements package ::Utility::expand, which  ...
#
# Copyright (c) 1997-8 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require ::Utility
package provide ::Utility::expand 1.0

namespace eval ::Utility::expand {;

namespace export -clear expand*
namespace import -force ::Utility::*

##
## NOTE: In places where uplevel is used, it is highly likely that
## a further eval redirect is otherwise necessary for foreign interps
##

# expand --
#
#	The string to match is expanded to the longest possible match.
#	If data(-showmultiple) is non-zero and the user longest match
#	equaled the string to expand, then all possible matches are
#	output to stdout.  Triggers bell if no matches are found.
#
# Arguments:
#    type	type of expansion (path / proc / variable)
#
# Returns:
#	number of matches found
#
proc expand {args} {
    array set opts {
	-type any -widget {}
    }
    set args [get_opts opts $args {-type 1 -widget 1} {-widget widget}]
    if {[string match {} $opts(-widget)] && [llength $args]!=1} {
	return -code error "wrong # args: should be\
		\"[lindex [info level 0] 0] ?-type type?\
		?-widget widget || str?"
    }
    set prefix [namespace current]::expand_
    if {[string match {} [set arg [info commands $prefix$opts(-type)]]]} {
	set arg [info commands $prefix$opts(-type)*]
    }
    set result {}
    set code ok
    if 0 {
	set exp "\[^\\]\[ \t\n\r\[\{\"\$]"
	set tmp [$w search -backwards -regexp $exp insert-1c limit-1c]
	if {[string compare {} $tmp]} {append tmp +2c} else {set tmp limit}
	if {[$w compare $tmp >= insert]} return
	set str [$w get $tmp insert]
    }
    switch [llength $arg] {
	1 { set code [catch {uplevel $arg $args} result] }
	0 {
	    set arg [info commands $prefix*]
	    regsub -all $prefix $arg {} arg
	    return -code error "unknown [lindex [info level 0] 0] type\
		    \"$opts(-type)\", must be one of: [join [lsort $arg] {, }]"
	}
	default {
	    regsub -all $prefix $arg {} arg
	    return -code error "ambiguous type \"$opts(-type)\",\
		    could be one of: [join [lsort $arg] {, }]"
	}
    }
    if 0 {
	set len [llength $res]
	if {$len} {
	    $w delete $tmp insert
	    $w insert $tmp [lindex $res 0]
	    if {$len > 1} {
		upvar \#0 [namespace current]::[winfo parent $w] data
		if {$data(-showmultiple) && \
			![string compare [lindex $res 0] $str]} {
		    puts stdout [lsort [lreplace $res 0 0]]
		}
	    }
	} else { bell }
	return [incr len -1]
    }
    return -code $code [string trimright $result \n]
}

# expand_pathname --
#
#    expand a file pathname based on $str
#    This is based on UNIX file name conventions
#
# Arguments:
#   str		partial file pathname to expand
# Results:
#   Returns list containing longest unique match followed by all the
#   possible further matches
#
proc expand_pathname {str} {
    #reval pwd, cd, glob and final cd
    set pwd [pwd]
    if {[catch {cd [file dirname $str]} err]} {
	return -code error $err
    }
    if {[catch {glob [file tail $str]*} m]} {
	set match {}
    } else {
	if {[llength $m] > 1} {
	    global tcl_platform
	    if {[string match windows $tcl_platform(platform)]} {
		## Windows is screwy because it can be case insensitive
		set tmp [best_match [string tolower [lsort $m]] \
			[string tolower [file tail $str]]]
	    } else {
		set tmp [best_match [lsort $m] [file tail $str]]
	    }
	    if {[string match ?*/* $str]} {
		set tmp [file dirname $str]/$tmp
	    } elseif {[string match /* $str]} {
		set tmp /$tmp
	    }
	    regsub -all { } $tmp {\\ } tmp
	    set match [linsert $m 0 $tmp]
	} else {
	    ## This may look goofy, but it handles spaces in path names
	    eval append match $m
	    if {[file isdir $match]} {append match /}
	    if {[string match ?*/* $str]} {
		set match [file dirname $str]/$match
	    } elseif {[string match /* $str]} {
		set match /$match
	    }
	    regsub -all { } $match {\\ } match
	    ## Why is this one needed and the ones below aren't!!
	    set match [list $match]
	}
    }
    cd $pwd
    return $match
}

# expand_proc --
#
## ExpandProcname - expand a tcl proc name based on $str
# ARGS:	str	- partial proc name to expand
# Calls:	best_match
# Returns:	list containing longest unique match followed by all the
#		possible further matches
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc expand_proc {str} {
    #reval info
    set match [uplevel info commands [list $str]*]
    if {[llength $match] > 1} {
	regsub -all { } [best_match $match $str] {\\ } str
	set match [linsert $match 0 $str]
    } else {
	regsub -all { } $match {\\ } match
    }
    return $match
}

# expand_variable --
#
## ExpandVariable - expand a tcl variable name based on $str
# ARGS:	str	- partial tcl var name to expand
# Calls:	best_match
# Returns:	list containing longest unique match followed by all the
#		possible further matches
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
proc expand_variable {str} {
    #reval "array names", "info vars"
    if {[regexp {([^\(]*)\((.*)} $str junk ary str]} {
	## Looks like they're trying to expand an array.
	set match [array names $ary $str*]
	if {[llength $match] > 1} {
	    set vars $ary\([best_match $match $str]
	    foreach var $match {lappend vars $ary\($var\)}
	    return $vars
	} else {set match $ary\($match\)}
	## Space transformation avoided for array names.
    } else {
	set match [info vars $str*]
	if {[llength $match] > 1} {
	    regsub -all { } [best_match $match $str] {\\ } str
	    set match [linsert $match 0 $str]
	} else {
	    regsub -all { } $match {\\ } match
	}
    }
    return $match
}

}; # end of namespace ::Utility::expand
