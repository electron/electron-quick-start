# util-number.tcl --
#
#	This file implements package ::Utility::number, which  ...
#
# Copyright (c) 1997 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

#package require NAME VERSION
package provide ::Utility::number 1.0

namespace eval ::Utility::number {;

namespace export -clear *

# get_square_size --
#   gets the minimum square size for an input
# Arguments:
#   num		number
# Returns:
#   returns smallest square size that would fit number
#
;proc get_square_size num {
    set i 1
    while {[expr {$i*$i}] < $num} { incr i }
    return $i
}

# roman2dec --
#   converts a roman numeral to decimal
# Arguments:
#   x		number in roman numeral format
# Returns:
#   decimal number
#
;proc roman2dec {x} {
    set result ""
    foreach elem {
	{ 1000	m }	{ 900	cm }    
	{ 500	d }	{ 400	id }    
	{ 100	c }	{ 90	ic }    
	{ 50	l }    
	{ 10	x }	{ 9	ix }    
	{ 5	v }	{ 4	iv }    
	{ 1	i }
    } {
	set digit [lindex $elem 0]
	set roman [lindex $elem 1]
	while {$x >= $digit} {
	    append result $roman
	    incr x -$digit
	}
    }
    return $result
}

# bin2hex --
#   converts binary to hex number
# Arguments:
#   bin		number in binary format
# Returns:
#   hexadecimal number
#
;proc bin2hex bin {
    ## No sanity checking is done
    array set t {
	0000 0 0001 1 0010 2 0011 3 0100 4
	0101 5 0110 6 0111 7 1000 8 1001 9
	1010 a 1011 b 1100 c 1101 d 1110 e 1111 f
    }
    set diff [expr {4-[string length $bin]%4}]
    if {$diff != 4} {
        set bin [format %0${diff}d$bin 0]
    }
    regsub -all .... $bin {$t(&)} hex
    return [subst $hex]
}


# hex2bin --
#   converts hex number to bin
# Arguments:
#   hex		number in hex format
# Returns:
#   binary number (in chars, not binary format)
#
;proc hex2bin hex {
    array set t {
	0 0000 1 0001 2 0010 3 0011 4 0100
	5 0101 6 0110 7 0111 8 1000 9 1001
	a 1010 b 1011 c 1100 d 1101 e 1110 f 1111
	A 1010 B 1011 C 1100 D 1101 E 1110 F 1111
    }
    regsub {^0[xX]} $hex {} hex
    regsub -all . $hex {$t(&)} bin
    return [subst $bin]
}

}
