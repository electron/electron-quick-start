
#   IGraph R package
#   Copyright (C) 2009-2012  Gabor Csardi <csardi.gabor@gmail.com>
#   334 Harvard street, Cambridge, MA 02139 USA
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301 USA
#
###################################################################

proc render_real {win href} {
    global tkigraph_help_root 
    set Url $tkigraph_help_root/$href
    $win configure -state normal
    HMreset_win $win
    HMparse_html [get_html $Url] "HMrender $win"
    $win tag add indented 1.0 insert
    $win tag configure indented -lmargin1 20 -lmargin2 20
    $win configure -state disabled
    update
}

proc render {win href} {
    global tkigraph_help_history tkigraph_help_history_pos
    global browser_button browser_url
    if { [ regexp ^http:// "$href" ] } { 
	set browser_url $href
	$browser_button invoke
	return
    }
    lappend tkigraph_help_history($win) $href
    incr tkigraph_help_history_pos($win)
    render_real $win $href
}

proc start_history {win} {
    global tkigraph_help_history tkigraph_help_history_pos
    set tkigraph_help_history($win) [ list ]
    set tkigraph_help_history_pos($win) -1
}

proc render_back {win} {
    global tkigraph_help_history tkigraph_help_history_pos
    if { $tkigraph_help_history_pos($win) > 0 } { 
	set pos [ incr tkigraph_help_history_pos($win) -1 ]
	render_real $win [ lindex $tkigraph_help_history($win) $pos ]
    }
}

proc render_forw {win} {
    global tkigraph_help_history tkigraph_help_history_pos
    if { [ expr $tkigraph_help_history_pos($win) + 1 ] < 
	 [ llength $tkigraph_help_history($win) ] } {
	set pos [ incr tkigraph_help_history_pos($win) ]
	render_real $win [ lindex $tkigraph_help_history($win) $pos ]
    }
}

proc HMlink_callback {win href} {
    render $win $href
}

proc get_html {file} {
    global tkigraph_help_root
    if {[catch {set fd [open $file]} msg]} {
	return "
                        <title>Bad file $file</title>
                        <h1>Error reading $file</h1><p>
                        $msg<hr>
                        <a href=$tkigraph_help_root>Go home</a>
                "
    }
    set result [read $fd]
    close $fd
    return $result
}

proc HMset_image {win handle src} {
    global tkigraph_help_root
    set image $tkigraph_help_root/$src
    update
    if {[string first " $image " " [image names] "] >= 0} {
	HMgot_image $handle $image
    } else {
	set type photo
	if {[file extension $image] == ".bmp"} {set type bitmap}
	catch {image create $type $image -file $image} image
	HMgot_image $handle $image
    }
}
