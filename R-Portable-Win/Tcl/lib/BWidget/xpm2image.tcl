# ----------------------------------------------------------------------------
#  xpm2image.tcl
#  Slightly modified xpm-to-image command
#  $Id: xpm2image.tcl,v 1.5 2004/09/09 22:17:03 hobbs Exp $
# ------------------------------------------------------------------------------
#
#  Copyright 1996 by Roger E. Critchlow Jr., San Francisco, California
#  All rights reserved, fair use permitted, caveat emptor.
#  rec@elf.org
# 
# ----------------------------------------------------------------------------

proc _xpm-to-image_process_line { line } {
    upvar 1 data data
    set line [string map {"\t" " "} $line]

    set idx $data(chars_per_pixel)
    incr idx -1
    set cname [string range $line 0 $idx]


    set lend [string trim [string range $line $data(chars_per_pixel) end]]

    ## now replace multiple spaces with just one..
    while {-1 != [string first  "  " $lend]} {
        set lend [string map {"  " " "} $lend]
    }
    set cl [split $lend " "]

    set idx 0
    set clen [llength $cl]

    ## scan through the line, looking for records of type c, g or m
    while { $idx < $clen } {
        set key [lindex $cl $idx]
        if { [string equal $key {}] } {
            incr idx
            continue
        }

        while { ![string equal $key "c"]
                && ![string equal $key "m"]
                && ![string equal $key "g"]
                && ![string equal $key "g4"]
                && ![string equal $key ""]
        } { 
            incr idx
            set key [lindex $cl $idx]
        }

        incr idx
        set color [string tolower [lindex $cl $idx]]

        ## one file used opaque to mean black
        if { [string equal -nocase $color "opaque"] } {
            set color "black"
        }
        set data(color-$key-$cname) $color
        if { [string equal -nocase $color "none"] } {
            set data(transparent) $cname
        }
        incr idx
    }

    
    foreach key {c g g4 m} {
        if {[info exists data(color-$key-$cname)]} {
            set color $data(color-$key-$cname)
            set data(color-$cname) $color
            set data(cname-$color) $cname
            lappend data(colors) $color
            break
        }
    }
    if { ![info exists data(color-$cname)] } {
        error "color definition {$line} failed to define a color"
    }
}

proc xpm-to-image { file } {
    set f [open $file]
    set string [read $f]
    close $f

    # parse the strings in the xpm data
    #
    set xpm {}
    foreach line [split $string "\n"] {
        ## some files have blank lines in them, skip those
        ## also, some files indent each line with spaces - remove those
        set line [string trim $line]
        if { $line eq "" } { continue }

        if {[regexp {^"([^\"]*)"} $line all meat]} {
            if {[string first XPMEXT $meat] == 0} {
                break
            }
            lappend xpm $meat
        }
    }
    #
    # extract the sizes in the xpm data
    #
    set sizes  [lindex $xpm 0]
    set nsizes [llength $sizes]
    if { $nsizes == 4 || $nsizes == 6 || $nsizes == 7 } {
        set data(width)   [lindex $sizes 0]
        set data(height)  [lindex $sizes 1]
        set data(ncolors) [lindex $sizes 2]
        set data(chars_per_pixel) [lindex $sizes 3]
        set data(x_hotspot) 0
        set data(y_hotspot) 0
        if {[llength $sizes] >= 6} {
            set data(x_hotspot) [lindex $sizes 4]
            set data(y_hotspot) [lindex $sizes 5]
        }
    } else {
	    error "size line {$sizes} in $file did not compute"
    }

    #
    # extract the color definitions in the xpm data
    #
    foreach line [lrange $xpm 1 $data(ncolors)] {
        _xpm-to-image_process_line $line
    }

    #
    # extract the image data in the xpm data
    #
    set image [image create photo -width $data(width) -height $data(height)]
    set y 0
    set idx 0
    foreach line [lrange $xpm [expr {1+$data(ncolors)}] [expr {1+$data(ncolors)+$data(height)}]] {
        set x 0
        set pixels {}
        while { [string length $line] > 0 } {
            set pixel [string range $line 0 [expr {$data(chars_per_pixel)-1}]]
            ## see if they lied about the number of colors by not counting
            ## "none" in the color count entry
            set none 0
            if { ($idx == 0) && ([info exists data(cname-none)]) &&  \
                ![info exists data(color-$pixel)] } {
                ## it appears that way - process this line as another
                ## color entry
                _xpm-to-image_process_line $line
                incr idx
                set none 1
                break;
            }
            incr idx
            set c $data(color-$pixel)
            if { [string equal $c none] } {
                if { [string length $pixels] } {
                    $image put [list $pixels] -to [expr {$x-[llength $pixels]}] $y
                    set pixels {}
                }
            } else {
                lappend pixels $c
            }
            set line [string range $line $data(chars_per_pixel) end]
            incr x
        }
        if { $none == 1 } {
            continue
        }
        if { [llength $pixels] } {
            $image put [list $pixels] -to [expr {$x-[llength $pixels]}] $y
        }
        incr y
    }

    #
    # return the image
    #
    return $image
}
