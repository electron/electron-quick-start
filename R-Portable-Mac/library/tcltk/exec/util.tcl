# util.tcl --
#
#	This file implements package ::Utility, which  ...
#
# Copyright (c) 1997-8 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

## The provide goes first to prevent the recursive provide/require
## loop for subpackages
package provide ::Utility 1.0

## This assumes that all util-*.tcl files are in the same directory
if {[lsearch -exact $auto_path [file dirname [info script]]]==-1} {
    lappend auto_path [file dirname [info script]]
}

namespace eval ::Utility {;

## Protos
namespace export -clear *

proc get_opts args {}
proc get_opts2 args {}
proc lremove args {}
proc lrandomize args {}
proc lunique args {}
proc luniqueo args {}
proc line_append args {}
proc highlight args {}
proc echo args {}
proc alias args {}
proc which args {}
proc ls args {}
proc dir args {}
proc fit_format args {}
proc validate args {}
proc allow_null_elements args {}
proc deny_null_elements args {}

}; # end of ::Utility namespace prototype headers

package require ::Utility::number
package require ::Utility::string
package require ::Utility::dump
package require ::Utility::expand
package require ::Utility::tk

namespace eval ::Utility {;

foreach namesp [namespace children [namespace current]] {
    namespace import -force ${namesp}::*
}

# psource --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
;proc psource {file namesp {import *}} {
    uplevel \#0 [subst {
	source $file
	namespace import -force ${namesp}::$import
    }
    ]
}

# get_opts --
#
#   Processes -* named options, with or w/o possible associated value
#   and returns remaining args
#
# Arguments:
#   var		variable into which option values should be stored
#   arglist	argument list to parse
#   optlist	list of valid options with default value
#   typelist	optional list of option types that can be used to
#		validate incoming options
#   nocomplain	whether to complain about unknown -switches (0 - default)
#		or not (1)
# Results:
#   Returns unprocessed arguments.
#
;proc get_opts {var arglist optlist {typelist {}} {nocomplain 0}} {
    upvar 1 $var data

    if {![llength $optlist] || ![llength $arglist]} { return $arglist }
    array set opts $optlist
    array set types $typelist
    set i 0
    while {[llength $arglist]} {
	set key [lindex $arglist $i]
	if {[string match -- $key]} {
	    set arglist [lreplace $arglist $i $i]
	    break
	} elseif {![string match -* $key]} {
	    break
	} elseif {[string match {} [set akey [array names opts $key]]]} {
	    set akey [array names opts ${key}*]
	}
	switch [llength $akey] {
	    0		{ ## oops, no keys matched
		if {$nocomplain} {
		    incr i
		} else {
		    return -code error "unknown switch '$key', must be:\
			    [join [array names opts] {, }]"
		}
	    }
	    1		{ ## Perfect, found just the right key
		if {$opts($akey)} {
		    set val [lrange $arglist [expr {$i+1}] \
			    [expr {$i+$opts($akey)}]]
		    set arglist [lreplace $arglist $i [expr {$i+$opts($akey)}]]
		    if {[info exists types($akey)] && \
			    ([string compare none $types($akey)] && \
			    ![validate $types($akey) $val])} {
			return -code error "the value for \"$akey\" is not in\
				proper $types($akey) format"
		    }
		    set data($akey) $val
		} else {
		    set arglist [lreplace $arglist $i [expr {$i+$opts($akey)}]]
		    set data($akey) 1
		}
	    }
	    default	{ ## Oops, matches too many possible keys
		return -code error "ambiguous option \"$key\",\
			must be one of: [join $akey {, }]"
	    }
	}
    }
    return $arglist
}

# get_opts2 --
#
#   Process options into an array.  -- short-circuits the processing
#
# Arguments:
#   var		variable into which option values should be stored
#   arglist	argument list to parse
#   optlist	list of valid options with default value
#   typelist	optional list of option types that can be used to
#		validate incoming options
# Results:
#   Returns unprocessed arguments.
#
;proc get_opts2 {var arglist optlist {typelist {}}} {
    upvar 1 $var data

    if {![llength $optlist] || ![llength $arglist]} { return $arglist }
    array set data $optlist
    array set types $typelist
    foreach {key val} $arglist {
	if {[string match -- $key]} {
	    set arglist [lreplace $arglist 0 0]
	    break
	}
	if {[string match {} [set akey [array names data $key]]]} {
	    set akey [array names data ${key}*]
	}
	switch [llength $akey] {
	    0		{ ## oops, no keys matched
		return -code error "unknown switch '$key', must be:\
			[join [array names data] {, }]"
	    }
	    1		{ ## Perfect, found just the right key
		if {[info exists types($akey)] && \
			![validate $types($akey) $val]} {
		    return -code error "the value for \"$akey\" is not in\
			    proper $types($akey) format"
		}
		set data($akey) $val
	    }
	    default	{ ## Oops, matches too many possible keys
		return -code error "ambiguous option \"$key\",\
			must be one of: [join $akey {, }]"
	    }
	}
	set arglist [lreplace $arglist 0 1]
    }
    return $arglist
}

# lremove --
#   remove items from a list
# Arguments:
#   ?-all?	remove all instances of said item
#   list	list to remove items from
#   args	items to remove
# Returns:
#   The list with items removed
#
;proc lremove {args} {
    set all 0
    if {[string match \-a* [lindex $args 0]]} {
	set all 1
	set args [lreplace $args 0 0]
    }
    set l [lindex $args 0]
    foreach i [join [lreplace $args 0 0]] {
	if {[set ix [lsearch -exact $l $i]] == -1} continue
	set l [lreplace $l $ix $ix]
	if {$all} {
	    while {[set ix [lsearch -exact $l $i]] != -1} {
		set l [lreplace $l $ix $ix]
	    }
	}
    }
    return $l
}

# lrandomize --
#   randomizes a list
# Arguments:
#   ls		list to randomize
# Returns:
#   returns list in with randomized items
#
;proc lrandomize ls {
    set res {}
    while {[string compare $ls {}]} {
	set i [randrng [llength $ls]]
	lappend res [lindex $ls $i]
	set ls [lreplace $ls $i $i]
    }
    return $res
}

# lunique --
#   order independent list unique proc, not most efficient.
# Arguments:
#   ls		list of items to make unique
# Returns:
#   list of only unique items, order not defined
#
;proc lunique ls {
    foreach l $ls {set ($l) x}
    return [array names {}]
}

# lunique --
#   order independent list unique proc.  most efficient, but requires
#   __LIST never be an element of the input list
# Arguments:
#   __LIST	list of items to make unique
# Returns:
#   list of only unique items, order not defined
#
;proc lunique __LIST {
    if {[llength $__LIST]} {
	foreach $__LIST $__LIST break
	unset __LIST
	return [info locals]
    }
}

# luniqueo --
#   order dependent list unique proc
# Arguments:
#   ls		list of items to make unique
# Returns:
#   list of only unique items in same order as input
#
;proc luniqueo ls {
    set rs {}
    foreach l $ls {
	if {[info exist ($l)]} { continue }
	lappend rs $l
	set ($l) 0
    }
    return $rs
}

# flist --
#
#   list open files and sockets
#
# Arguments:
#   pattern	restrictive regexp pattern for numbers
#   manum	max socket/file number to search until
# Results:
#   Returns ...
#
;proc flist {{pattern .*} {maxnum 1025}} {
    set result {}
    for {set i 1} {$i <= $maxnum} {incr i} {
	if {![regexp $pattern $i]} { continue }
        if {![catch {fconfigure file$i} conf]} {
            lappend result [list file$i $conf]
        }
        if {![catch {fconfigure sock$i} conf]} {
            array set c {-peername {} -sockname {}}
            array set c $conf
            lappend result [list sock$i $c(-peername) $c(-sockname)]
        }
    }
    return $result
}


# highlight --
#
#    searches in text widget for $str and highlights it
#    If $str is empty, it just deletes any highlighting
#    This really belongs in ::Utility::tk
#
# Arguments:
#   w			text widget
#   str			string to search for
#   -nocase		specifies to be case insensitive
#   -regexp		specifies that $str is a pattern
#   -tag   tagId	name of tag in text widget
#   -color color	color of tag in text widget
# Results:
#   Returns ...
#
;proc highlight {w str args} {
    $w tag remove __highlight 1.0 end
    array set opts {
	-nocase	0
	-regexp	0
	-tag	__highlight
	-color	yellow
    }
    set args [get_opts opts $args {-nocase 0 -regexp 0 -tag 1 -color 1}]
    if {[string match {} $str]} return
    set pass {}
    if {$opts(-nocase)} { append pass "-nocase " }
    if {$opts(-regexp)} { append pass "-regexp " }
    $w tag configure $opts(-tag) -background $opts(-color)
    $w mark set $opts(-tag) 1.0
    while {[string compare {} [set ix [eval $w search $pass -count numc -- \
	    [list $str] $opts(-tag) end]]]} {
	$w tag add $opts(-tag) $ix ${ix}+${numc}c
	$w mark set $opts(-tag) ${ix}+1c
    }
    catch {$w see $opts(-tag).first}
    return [expr {[llength [$w tag ranges $opts(-tag)]]/2}]
}


# best_match --
#   finds the best unique match in a list of names
#   The extra $e in this argument allows us to limit the innermost loop a
#   little further.
# Arguments:
#   l		list to find best unique match in
#   e		currently best known unique match
# Returns:
#   longest unique match in the list
#
;proc best_match {l {e {}}} {
    set ec [lindex $l 0]
    if {[llength $l]>1} {
	set e  [string length $e]; incr e -1
	set ei [string length $ec]; incr ei -1
	foreach l $l {
	    while {$ei>=$e && [string first $ec $l]} {
		set ec [string range $ec 0 [incr ei -1]]
	    }
	}
    }
    return $ec
}

# getrandfile --
#
#   returns a random line from a file
#
# Arguments:
#   file	filename to get line from
# Results:
#   Returns a line as a string
#
;proc getrandfile {file} {
    set fid [open $file]
    set data [split [read $fid] \n]
    close $fid
    return [lindex $data [randrng [llength $data]]]
}

# randrng --
#   gets random number within input range
# Arguments:
#   rng		range to limit output to
# Returns:
#   returns random number within range 0..$rng
;proc randrng {rng} {
    return [expr {int($rng * rand())}]
}

# grep --
#   cheap grep routine
# Arguments:
#   exp		regular expression to look for
#   args	files to search in
# Returns:
#   list of lines that in files that matched $exp
#
;proc grep {exp args} {
    if 0 {
	## To be implemented
	-count -nocase -number -names -reverse -exact
    }
    if {[string match {} $args]} return
    set output {}
    foreach file [eval glob $args] {
	set fid [open $file]
	foreach line [split [read $fid] \n] {
	    if {[regexp $exp $line]} { lappend output $line }
	}
	close $fid
    }
    return $output
}

# line_append --
#   appends a string to the end of every line of data from a file
# Arguments:
#   file	file to get data from
#   stuff	stuff to append to each line
# Returns:
#   file data with stuff appended to each line
#
;proc line_append {file stuff} {
    set fid [open $file]
    set data [read $fid]
    catch {close $fid}
    return [join [split $data \n] $stuff\n]
}


# alias --
#   akin to the csh alias command
# Arguments:
#   newcmd	(optional) command to bind alias to
#   args	command and args being aliased
# Returns:
#   If called with no args, then it dumps out all current aliases
#   If called with one arg, returns the alias of that arg (or {} if none)
#
;proc alias {{newcmd {}} args} {
    if {[string match {} $newcmd]} {
	set res {}
	foreach a [interp aliases] {
	    lappend res [list $a -> [interp alias {} $a]]
	}
	return [join $res \n]
    } elseif {[string match {} $args]} {
	interp alias {} $newcmd
    } else {
	eval interp alias [list {} $newcmd {}] $args
    }
}

# echo --
#   Relaxes the one string restriction of 'puts'
# Arguments:
#   args	any number of strings to output to stdout
# Returns:
#   Outputs all input to stdout
#
;proc echo args { puts [concat $args] }

# which --
#   tells you where a command is found
# Arguments:
#   cmd		command name
# Returns:
#   where command is found (internal / external / unknown)
#
;proc which cmd {
    ## FIX - make namespace friendly
    set lcmd [list $cmd]
    if {
	[string compare {} [uplevel info commands $lcmd]] ||
	([uplevel auto_load $lcmd] &&
	[string compare {} [uplevel info commands $lcmd]])
    } {
	set ocmd [uplevel namespace origin $lcmd]
	# First check to see if it is an alias
	# This requires two checks because interp aliases doesn't
	# canonically return fully (un)qualified names
	set aliases [interp aliases]
	if {[lsearch -exact $aliases $ocmd] > -1} {
	    set result "$cmd: aliased to \"[alias $ocmd]\""
	} elseif {[lsearch -exact $aliases $cmd] > -1} {
	    set result "$cmd: aliased to \"[alias $cmd]\""
	} elseif {[string compare {} [uplevel info procs $lcmd]] || \
		([string match ?*::* $ocmd] && \
		[string compare {} [namespace eval \
		[namespace qualifiers $ocmd] \
		[list info procs [namespace tail $ocmd]]]])} {
	    # Here we checked if the proc that has been imported before
	    # deciding it is a regular command
	    set result "$cmd: procedure $ocmd"
	} else {
	    set result "$cmd: command"
	}
	global auto_index
	if {[info exists auto_index($cmd)]} {
	    # This tells you where the command MIGHT have come from -
	    # not true if the command was redefined interactively or
	    # existed before it had to be auto_loaded.  This is just
	    # provided as a hint at where it MAY have come from
	    append result " ($auto_index($cmd))"
	}
	return $result
    } elseif {[string compare {} [auto_execok $cmd]]} {
	return [auto_execok $cmd]
    } else {
	return -code error "$cmd: command not found"
    }
}

# ls --
#   mini-ls equivalent (directory lister)
# Arguments:
#   ?-all?	list hidden files as well (Unix dot files)
#   ?-long?	list in full format "permissions size date filename"
#   ?-full?	displays / after directories and link paths for links
#   args	names/glob patterns of directories to list
# Returns:
#   a directory listing
#
interp alias {} ::Utility::dir {} namespace inscope ::Utility ls
;proc ls {args} {
    array set s {
	-all 0 -full 0 -long 0
	0 --- 1 --x 2 -w- 3 -wx 4 r-- 5 r-x 6 rw- 7 rwx
    }
    set args [get_opts s $args [array get s -*]]
    set sep [string trim [file join . .] .]
    if {[string match {} $args]} { set args . }
    foreach arg $args {
	if {[file isdir $arg]} {
	    set arg [string trimr $arg $sep]$sep
	    if {$s(-all)} {
		lappend out [list $arg [lsort [glob -nocomplain -- $arg.* $arg*]]]
	    } else {
		lappend out [list $arg [lsort [glob -nocomplain -- $arg*]]]
	    }
	} else {
	    lappend out [list [file dirname $arg]$sep \
		    [lsort [glob -nocomplain -- $arg]]]
	}
    }
    if {$s(-long)} {
	global tcl_platform
	set old [clock scan {1 year ago}]
	switch -exact -- $tcl_platform(os) {
	    windows	{ set fmt "%-5s %8d %s %s\n" }
	    default	{ set fmt "%s %-8s %-8s %8d %s %s\n" }
	}
	foreach o $out {
	    set d [lindex $o 0]
	    if {[llength $out]>1} { append res $d:\n }
	    foreach f [lindex $o 1] {
		file lstat $f st
		array set st [file attrib $f]
		set f [file tail $f]
		if {$s(-full)} {
		    switch -glob $st(type) {
			dir* { append f $sep }
			link { append f " -> [file readlink $d$sep$f]" }
			fifo { append f | }
			default { if {[file exec $d$sep$f]} { append f * } }
		    }
		}
		switch -exact -- $st(type) {
		    file	{ set mode - }
		    fifo	{ set mode p }
		    default	{ set mode [string index $st(type) 0] }
		}
		set cfmt [expr {$st(mtime)>$old?{%b %d %H:%M}:{%b %d  %Y}}]
		switch -exact -- $tcl_platform(os) {
		    windows	{
			# RHSA
			append mode $st(-readonly) $st(-hidden) \
				$st(-system) $st(-archive)
			append res [format $fmt $mode $st(size) \
				[clock format $st(mtime) -format $cfmt] $f]
		    }
		    macintosh	{
			append mode $st(-readonly) $st(-hidden)
			append res [format $fmt $mode $st(-creator) \
				$st(-type) $st(size) \
				[clock format $st(mtime) -format $cfmt] $f]
		    }
		    default	{ ## Unix is our default platform type
			foreach j [split [format %o \
				[expr {$st(mode)&0777}]] {}] {
			    append mode $s($j)
			}
			append res [format $fmt $mode $st(-owner) $st(-group) \
				$st(size) \
				[clock format $st(mtime) -format $cfmt] $f]
		    }
		}
	    }
	    append res \n
	}
    } else {
	foreach o $out {
	    set d [lindex $o 0]
	    if {[llength $out]>1} { append res $d:\n }
	    set i 0
	    foreach f [lindex $o 1] {
		if {[string len [file tail $f]] > $i} {
		    set i [string len [file tail $f]]
		}
	    }
	    set i [expr {$i+2+$s(-full)}]
	    ## Assume we have at least 70 char cols
	    set j [expr {70/$i}]
	    set k 0
	    foreach f [lindex $o 1] {
		set f [file tail $f]
		if {$s(-full)} {
		    switch -glob [file type $d$sep$f] {
			d* { append f $sep }
			l* { append f @ }
			default { if {[file exec $d$sep$f]} { append f * } }
		    }
		}
		append res [format "%-${i}s" $f]
		if {[incr k]%$j == 0} {set res [string trimr $res]\n}
	    }
	    append res \n\n
	}
    }
    return [string trimr $res]
}

# fit_format --
# This procedure attempts to format a value into a particular format string.
#
# Arguments:
# format	- The format to fit
# val		- The value to be validated
#
# Returns:	0 or 1 (whether it fits the format or not)
#
# Switches:
# -fill ?var?	- Default values will be placed to fill format to spec
#		  and the resulting value will be placed in variable 'var'.
#		  It will equal {} if the match invalid
#		  (doesn't work all that great currently)
# -best ?var?	- 'Fixes' value to fit format, placing best correct value
#		  in variable 'var'.  If current value is ok, the 'var'
#		  will equal it, otherwise it removes chars from the end
#		  until it fits the format, then adds any fixed format
#		  chars to value.  Can be slow (recursive tkFormat op).
# -strict	- Value must be an exact match for format (format && length)
# --		- End of switches

;proc fit_format {args} {
    set fill {}; set strict 0; set best {}; set result 1;
    set name [lindex [info level 0] 0]
    while {[string match {-*} [lindex $args 0]]} {
	switch -- [string index [lindex $args 0] 1] {
	    b {
		set best [lindex $args 1]
		set args [lreplace $args 0 1]
	    }
	    f {
		set fill [lindex $args 1]
		set args [lreplace $args 0 1]
	    }
	    s {
		set strict 1
		set args [lreplace $args 0 0]
	    }
	    - {
		set args [lreplace $args 0 0]
		break
	    }
	    default {
		return -code error "bad $name option \"[lindex $args 0]\",\
			must be: -best, -fill, -strict, or --"
	    }
	}
    }

    if {[llength $args] != 2} {
	return -code error "wrong \# args: should be \"$name ?-best varname?\
		?-fill varname? ?-strict? ?--? format value\""
    }
    set format [lindex $args 0]
    set val    [lindex $args 1]

    set flen [string length $format]
    set slen [string length $val]
    if {$slen > $flen} {set result 0}
    if {$strict} { if {$slen != $flen} {set result 0} }

    if {$result} {
	set regform {}
	foreach c [split $format {}] {
	    set special 0
	    if {[string match {[0AaWzZ]} $c]} {
		set special 1
		switch $c {
		    0	{set fmt {[0-9]}}
		    A	{set fmt {[A-Z]}}
		    a	{set fmt {[a-z]}}
		    W	{set fmt "\[ \t\r\n\]"}
		    z	{set fmt {[A-Za-z]}}
		    Z	{set fmt {[A-Za-z0-9]}}
		}
	    } else {
		set fmt $c
	    }
	    
	}
	echo $regform $format $val
	set result [string match $regform $val]
    }

    if [string compare $fill {}] {
	upvar $fill fvar
	if {$result} {
	    set fvar $val[string range $format $i end]
	} else {
	    set fvar {}
	}
    }

    if [string compare $best {}] {
	upvar $best bvar
	set bvar $val
	set len [string length $bvar]
	if {!$result} {
	    incr len -2
	    set bvar [string range $bvar 0 $len]
	    # Remove characters until it's in valid format
	    while {$len > 0 && ![tkFormat $format $bvar]} {
		set bvar [string range $bvar 0 [incr len -1]]
	    }
	    # Add back characters that are fixed
	    while {($len<$flen) && ![string match \
		    {[0AaWzZ]} [string index $format [incr len]]]} {
		append bvar [string index $format $len]
	    }
	} else {
	    # If it's already valid, at least we can add fixed characters
	    while {($len<$flen) && ![string match \
		    {[0AaWzZ]} [string index $format $len]]} {
		append bvar [string index $format $len]
		incr len
	    }
	}
    }

    return $result
}


# validate --
# This procedure validates particular types of numbers/formats
#
# Arguments:
# type		- The type of validation (alphabetic, alphanumeric, date,
#		hex, integer, numeric, real).  Date is always strict.
# val		- The value to be validated
#
# Returns:	0 or 1 (whether or not it resembles the type)
#
# Switches:
# -incomplete	enable less precise (strict) pattern matching on number
#		useful for when the number might be half-entered
#
# Example use:	validate real 55e-5
#		validate -incomplete integer -505
#

;proc validate {args} {
    if {[string match [lindex $args 0]* "-incomplete"]} {
	set strict 0
	set opt *
	set args [lreplace $args 0 0]
    } else {
	set strict 1
	set opt +
    }

    if {[llength $args] != 2} {
	return -code error "wrong \# args: should be\
		\"[lindex [info level 0] 0] ?-incomplete? type value\""
    } else {
	set type [lindex $args 0]
	set val  [lindex $args 1]
    }

    ## This is a big switch for speed reasons
    switch -glob -- $type {
	alphab*	{ # alphabetic
	    return [regexp -nocase "^\[a-z\]$opt\$" $val]
	}
	alphan* { # alphanumeric
	    return [regexp -nocase "^\[a-z0-9\]$opt\$" $val]
	}
	b*	{ # boolean - would be nice if it were more than 0/1
	    return [regexp "^\[01\]$opt\$" $val]
	}
	d*	{ # date - always strict
	    return [expr {![catch {clock scan $val}]}]
	}
	h*	{ # hexadecimal
	    return [regexp -nocase "^(0x)?\[0-9a-f\]$opt\$" $val]
	}
	i*	{ # integer
	    return [regexp "^\[-+\]?\[0-9\]$opt\$" $val]
	}
	n*	{ # numeric
	    return [regexp "^\[0-9\]$opt\$" $val]
	}
	rea*	{ # real
	    return [regexp -nocase [expr {$strict
	    ?{^[-+]?([0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)(e[-+]?[0-9]+)?$}
	    :{^[-+]?[0-9]*\.?[0-9]*([0-9]\.?e[-+]?[0-9]*)?$}}] $val]
	}
	reg*	{ # regexp
	    return [expr {![catch {regexp $val {}}]}]
	}
	val*	{ # value
	    return [expr {![catch {expr {1*$val}}]}]
	}
	l*	{ # list
	    return [expr {![catch {llength $val}]}]
	}
	w*	{ # widget
	    return [winfo exists $val]
	}
	default {
	    return -code error "bad [lindex [info level 0] 0] type \"$type\":\
		    \nmust be [join [lsort {alphabetic alphanumeric date \
		    hexadecimal integer numeric real value \
		    list boolean}] {, }]"
	}
    }
    return
}

# allow_null_elements --
#
#   Sets up a read trace on an array to allow reading any value
#   and ensure that some default exists
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
;proc allow_null_elements {array {default {}}} {
    uplevel 1 [list trace variable $array r [list \
	    [namespace code ensure_default] $default]]
}

;proc ensure_default {val array idx op} {
    upvar $array var
    if {[array exists var]} {
	if {![info exists var($idx)]} {
	    set var($idx) $val
	}
    } elseif {![info exists var]} {
	set var $val
    }
}

# deny_null_elements --
#
#   ADD COMMENTS HERE
#
# Arguments:
#   args	comments
# Results:
#   Returns ...
#
;proc deny_null_elements {array {default {}}} {
    ## FIX: should use vinfo and remove any *ensure_default* read traces
    uplevel 1 [list trace vdelete $array r [list \
	    [namespace code ensure_default] $default]]
}


}; # end namespace ::Utility
