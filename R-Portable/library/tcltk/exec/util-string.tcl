# util-string.tcl --
#
#	This file implements package ::Utility::string, which  ...
#
# Copyright (c) 1997 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#

#package require NAME VERSION
package provide ::Utility::string 1.0; # SET VERSION

namespace eval ::Utility::string {;

namespace export -clear *

# string_cap --
#
#   Capitalize a string, or one char in it
#
# Arguments:
#   str		input string
#   idx		idx to capitalize
# Results:
#   Returns string with specified capitalization
#
proc string_cap {str {idx -1}} {
    if {$i>-1} {
	if {[string length $str]>$i} {
	    return $str
	} else {
	}
    } else {
	return [string toupper [string index $str 0]][string tolower \
		[string range $str 1 end]]
    }
}

# string_reverse --
#   reverses input string
# Arguments:
#   s		input string to reverse
# Returns:
#   string with chars reversed
#
;proc string_reverse s {
    if {[set i [string len $s]]} {
	while {$i} {append r [string index $s [incr i -1]]}
	return $r
    }
}

# obfuscate --
#   If I describe it, it ruins it...
# Arguments:
#   s		input string
# Returns:
#   output
#
;proc obfuscate s {
    if {[set len [string len $s]]} {
	set i -1
	while {[incr i]<$len} {
	    set c [string index $s $i]
	    if {[regexp "\[\]\\\[ \{\}\t\n\"\]" $c]} {
		append r $c
	    } else {
		scan $c %c c
		append r \\[format %0.3o $c]
	    }
	}
	return $r
    }
}

# untabify --
#   removes tabs from a string, replacing with appropriate number of spaces
# Arguments:
#   str		input string
#   tablen	tab length, defaults to 8
# Returns:
#   string sans tabs
#
;proc untabify {str {tablen 8}} {
    set out {}
    while {[set i [string first "\t" $str]] != -1} {
	set j [expr {$tablen-($i%$tablen)}]
	append out [string range $str 0 [incr i -1]][format %*s $j { }]
	set str [string range $str [incr i 2] end]
    }
    return $out$str
}

# tabify --
#   converts excess spaces to tab chars
# Arguments:
#   str		input string
#   tablen	tab length, defaults to 8
# Returns:
#   string with tabs replacing excess space where appropriate
#
;proc tabify {str {tablen 8}} {
    ## We must first untabify so that \t is not interpreted to be one char
    set str [untabify $str]
    set out {}
    while {[set i [string first { } $str]] != -1} {
	## Align i to the upper tablen boundary
	set i [expr {$i+$tablen-($i%$tablen)-1}]
	set s [string range $str 0 $i]
	if {[string match {* } $s]} {
	    append out [string trimright $s { }]\t
	} else {
	    append out $s
	}
	set str [string range $str [incr i] end]
    }
    return $out$str
}

# wrap_lines --
#   wraps text to a specific max line length
# Arguments:
#   txt		input text
#   len		desired max line length+1, defaults to 75
#   P		paragraph boundary chars, defaults to \n\n
#   P2		substitute for $P while processing, defaults to \254
#		this char must not be in the input text
# Returns:
#   text with lines no longer than $len, except where a single word
#   is longer than $len chars.  does not preserve paragraph boundaries.
#
;proc wrap_lines "txt {len 75} {P \n\n} {P2 \254}" {
    regsub -all $P $txt $P2 txt
    regsub -all "\n" $txt { } txt
    incr len -1
    set out {}
    while {[string len $txt]>$len} {
	set i [string last { } [string range $txt 0 $len]]
	if {$i == -1 && [set i [string first { } $txt]] == -1} break
	append out [string trim [string range $txt 0 [incr i -1]]]\n
	set txt [string range $txt [incr i 2] end]
    }
    regsub -all $P2 $out$txt $P txt
    return $txt
}

}; # end of namespace ::Utility::string
