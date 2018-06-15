# ------------------------------------------------------------------------
#  statusbar.tcl
#	Create a status bar Tk widget
#
#  Provides a status bar to be placed at the bottom of a toplevel.
#  Currently does not support being placed in a toplevel that has
#  gridding applied (via widget -setgrid or wm grid).
#
#  Ensure that the widget is placed at the very bottom of the toplevel,
#  otherwise the resize behavior may behave oddly.
# ------------------------------------------------------------------------

package require Tk 8.3

if {0} {
    proc sample {} {
    # sample usage
    eval destroy [winfo children .]
    pack [text .t -width 0 -height 0] -fill both -expand 1

    set sbar .s
    StatusBar $sbar
    pack $sbar -side bottom -fill x
    set f [$sbar getframe]

    # Specify -width 1 for the label widget so it truncates nicely
    # instead of requesting large sizes for long messages
    set w [label $f.status -width 1 -anchor w -textvariable ::STATUS]
    set ::STATUS "This is a status message"
    # give the entry weight, as we want it to be the one that expands
    $sbar add $w -weight 1

    # BWidget's progressbar
    set w [ProgressBar $f.bpbar -orient horizontal \
	       -variable ::PROGRESS -bd 1 -relief sunken]
    set ::PROGRESS 50
    $sbar add $w
    }
}

namespace eval StatusBar {
    Widget::define StatusBar statusbar

    Widget::declare StatusBar {
	{-background  TkResource ""	0 frame}
	{-borderwidth TkResource 0	0 frame}
	{-relief      TkResource flat	0 frame}
	{-showseparator Boolean	 1	0}
	{-showresizesep Boolean	 0	0}
	{-showresize  Boolean	 1	0}
	{-width	      TkResource 100	0 frame}
	{-height      TkResource 18	0 frame}
	{-ipad	      String	 1	0}
	{-pad	      String	 0	0}
	{-bg	      Synonym	 -background}
	{-bd	      Synonym	 -borderwidth}
    }

    # -background, -borderwidth and -relief apply to outer frame, but relief
    # should be left flat for proper look
    Widget::addmap StatusBar "" :cmd {
	-background {} -width {} -height {} -borderwidth {} -relief {}
    }
    Widget::addmap StatusBar "" .sbar {
	-background {}
    }
    Widget::addmap StatusBar "" .resize {
	-background {}
    }
    Widget::addmap StatusBar "" .hsep {
	-background {}
    }

    # -pad provides general padding around the status bar
    # -ipad provides padding around each status bar item
    # Padding can be a list of {padx pady}

    variable HaveMarlett \
	[expr {[lsearch -exact [font families] "Marlett"] != -1}]

    bind StatusResize <1> \
	[namespace code [list begin_resize %W %X %Y]]
    bind StatusResize <B1-Motion> \
	[namespace code [list continue_resize %W %X %Y]]
    bind StatusResize <ButtonRelease-1> \
	[namespace code [list end_resize %W %X %Y]]

    bind StatusBar <Destroy> [list StatusBar::_destroy %W]

    # PNG version has partial alpha transparency for better look
    variable pngdata {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAFM0aXcAAAABGdBTUEAAYagM
	eiWXwAAAGJJREFUGJW9kVEOgCAMQzs8GEezN69fkKlbUAz2r3l5NGTA+pCU+Q
	IA5sv39wGgZKClZGBhJMVTklRr3VNwMz04mVfQzQiEm79EkrYZycxIkq8kkv2
	v6RFGku9TUrj8RGr9AGy6mhv2ymLwAAAAAElFTkSuQmCC
    }
    variable gifdata {
	R0lGODlhDwAPAJEAANnZ2f///4CAgD8/PyH5BAEAAAAALAAAAAAPAA8AAAJEh
	I+py+1IQvh4IZlG0Qg+QshkAokGQfAvZCBIhG8hA0Ea4UPIQJBG+BAyEKQhCH
	bIQAgNEQCAIA0hAyE0AEIGgjSEDBQAOw==
    }
    if {[package provide img::png] != ""} {
	image create photo ::StatusBar::resizer -format PNG -data $pngdata
    } else {
	image create photo ::StatusBar::resizer -format GIF -data $gifdata
    }
}


# ------------------------------------------------------------------------
#  Command StatusBar::create
# ------------------------------------------------------------------------
proc StatusBar::create { path args } {
    variable _widget
    variable HaveMarlett

    # Allow for img::png loaded after initial source
    if {[package provide img::png] != ""} {
	variable pngdata
	::StatusBar::resizer configure -format PNG -data $pngdata
    }

    Widget::init StatusBar $path $args

    eval [list frame $path -class StatusBar] [Widget::subcget $path :cmd]

    foreach {padx pady} [_padval [Widget::cget $path -pad]] \
	{ipadx ipady} [_padval [Widget::cget $path -ipad]] { break }

    if {[Widget::theme]} {
	set sbar   [ttk::frame $path.sbar -padding [list $padx $pady]]
    } else {
	set sbar   [eval [list frame $path.sbar -padx $padx -pady $pady] \
			[Widget::subcget $path .sbar]]
    }
    if {[string equal $::tcl_platform(platform) "windows"]} {
	set cursor size_nw_se
    } else {
	set cursor sizing; # bottom_right_corner ??
    }
    set resize [eval [list label $path.resize] \
		    [Widget::subcget $path .resize] \
		    [list -borderwidth 0 -relief flat -anchor se \
			 -cursor $cursor -anchor se -padx 0 -pady 0]]
    if {$HaveMarlett} {
	$resize configure -font "Marlett -16" -text \u006f
    } else {
	$resize configure -image ::StatusBar::resizer
    }
    bindtags $resize [list all [winfo toplevel $path] StatusResize $resize]

    if {[Widget::theme]} {
	set fsep [ttk::separator $path.hsep -orient horizontal]
    } else {
	set fsep [eval [list frame $path.hsep -bd 1 -height 2 -relief sunken] \
		      [Widget::subcget $path .hsep]]
    }
    set sep  [_sep $path sepresize {}]

    grid $fsep   -row 0 -column 0 -columnspan 3 -sticky ew
    grid $sbar   -row 1 -column 0 -sticky news
    grid $sep    -row 1 -column 1 -sticky ns -padx $ipadx -pady $ipady
    grid $resize -row 1 -column 2 -sticky news
    grid columnconfigure $path 0 -weight 1
    if {![Widget::cget $path -showseparator]} {
	grid remove $fsep
    }
    if {![Widget::cget $path -showresize]} {
	grid remove $sep $resize
    } elseif {![Widget::cget $path -showresizesep]} {
	grid remove $sep
    }
    set _widget($path,items) {}

    return [Widget::create StatusBar $path]
}


# ------------------------------------------------------------------------
#  Command StatusBar::configure
# ------------------------------------------------------------------------
proc StatusBar::configure { path args } {
    variable _widget

    set res [Widget::configure $path $args]

    foreach {chshow chshowrsep chshowsep chipad chpad} \
	[Widget::hasChangedX $path -showresize -showresizesep -showseparator \
	     -ipad -pad] { break }

    if {$chshow} {
	set show [Widget::cget $path -showresize]
	set showrsep [Widget::cget $path -showresizesep]
        if {$show} {
	    if {$showrsep} {
		grid $path.sepresize
	    }
	    grid $path.resize
        } else {
	    grid remove $path.sepresize $path.resize
	}
    }
    if {$chshowsep} {
        if {$show} {
	    grid $path.hsep
        } else {
	    grid remove $path.hsep
	}
    }
    if {$chipad} {
	foreach {ipadx ipady} [_padval [Widget::cget $path -ipad]] { break }
	foreach w [grid slaves $path.sbar] {
	    grid configure $w -padx $ipadx -pady $ipady
	}
    }
    if {$chpad} {
	foreach {padx pady} [_padval [Widget::cget $path -pad]] { break }
	if {[string equal [winfo class $path.sbar] "TFrame"]} {
	    $path.sbar configure -padding [list $padx $pady]
	} else {
	    $path.sbar configure -padx $padx -pady $pady
	}
    }
    return $res
}


# ------------------------------------------------------------------------
#  Command StatusBar::cget
# ------------------------------------------------------------------------
proc StatusBar::cget { path option } {
    return [Widget::cget $path $option]
}

# ------------------------------------------------------------------------
#  Command StatusBar::getframe
# ------------------------------------------------------------------------
proc StatusBar::getframe {path} {
    # This is the frame that users should place their statusbar widgets in
    return $path.sbar
}

# ------------------------------------------------------------------------
#  Command StatusBar::add
# ------------------------------------------------------------------------
proc StatusBar::add {path w args} {
    variable _widget

    array set opts [list \
			-weight    0 \
			-separator 1 \
			-sticky    news \
			-pad       [Widget::cget $path -ipad] \
			]
    foreach {key val} $args {
	if {[info exists opts($key)]} {
	    set opts($key) $val
	} else {
	    set msg "unknown option \"$key\", must be one of: "
	    append msg [join [lsort [array names opts]] {, }]
	    return -code error $msg
	}
    }
    foreach {ipadx ipady} [_padval $opts(-pad)] { break }

    set sbar $path.sbar
    foreach {cols rows} [grid size $sbar] break
    # Add separator if requested, and we aren't the first element
    if {$opts(-separator) && $cols != 0} {
	set sep [_sep $path sep[winfo name $w]]
	# only append name, to distinguish us from them
	lappend _widget($path,items) [winfo name $sep]
	grid $sep -in $sbar -row 0 -column $cols \
	    -sticky ns -padx $ipadx -pady $ipady
	incr cols
    }

    lappend _widget($path,items) $w
    grid $w -in $sbar -row 0 -column $cols -sticky $opts(-sticky) \
	-padx $ipadx -pady $ipady
    grid columnconfigure $sbar $cols -weight $opts(-weight)

    return $w
}

# ------------------------------------------------------------------------
#  Command StatusBar::delete
# ------------------------------------------------------------------------
proc StatusBar::remove {path args} {
    variable _widget

    set destroy [string equal [lindex $args 0] "-destroy"]
    if {$destroy} {
	set args [lrange $args 1 end]
    }
    foreach w $args {
	set idx [lsearch -exact $_widget($path,items) $w]
	if {$idx == -1 || ![winfo exists $w]} {
	    # ignore unknown or non-widget items (like our separators)
	    continue
	}
	# separator is always previous item
	set sidx [expr {$idx - 1}]
	set sep  [lindex $_widget($path,items) $sidx]
	if {[string match .* $sep]} {
	    # not one of our separators
	    incr sidx
	} elseif {$sep != ""} {
	    # destroy separator too
	    set sep $path.sbar.$sep
	    destroy $sep
	}
	if {$destroy} {
	    destroy $w
	} else {
	    grid forget $w
	}
	if {$idx == 0} {
	    # separator of next item is no longer necessary
	    set sep [lindex $_widget($path,items) [expr {$idx + 1}]]
	    if {$sep != "" && ![string match .* $sep]} {
		incr idx
		set sep $path.sbar.$sep
		destroy $sep
	    }
	}
	set _widget($path,items) [lreplace $_widget($path,items) $sidx $idx]
    }
}

# ------------------------------------------------------------------------
#  Command StatusBar::delete
# ------------------------------------------------------------------------
proc StatusBar::delete {path args} {
    return [StatusBar::remove $path -destroy $args]
}

# ------------------------------------------------------------------------
#  Command StatusBar::items
# ------------------------------------------------------------------------
proc StatusBar::items {path} {
    variable _widget
    return $_widget($path,items)
}

proc StatusBar::_sep {path name {sub .sbar}} {
    if {[Widget::theme]} {
	return [ttk::separator $path$sub.$name -orient vertical]
    } else {
	return [frame $path$sub.$name -bd 1 -width 2 -relief sunken]
    }
}

proc StatusBar::_padval {padval} {
    set len [llength $padval]
    foreach {a b} $padval { break }
    if {$len == 0 || $len > 2} {
	return -code error \
	    "invalid pad value \"$padval\", must be 1 or 2 pixel values"
    } elseif {$len == 1} {
	return [list $a $a]
    } elseif {$len == 2} {
	return $padval
    }
}

# ------------------------------------------------------------------------
#  Command StatusBar::_destroy
# ------------------------------------------------------------------------
proc StatusBar::_destroy { path } {
    variable _widget
    variable resize
    array unset widget $path,*
    array unset resize $path.resize,*
    Widget::destroy $path
}

# The following proc handles the mouse click on the resize control. It stores
# the original size of the window and the initial coords of the mouse relative
# to the root.

proc StatusBar::begin_resize {w rootx rooty} {
    variable resize
    set t    [winfo toplevel $w]
    set relx [expr {$rootx - [winfo rootx $t]}]
    set rely [expr {$rooty - [winfo rooty $t]}]
    set resize($w,x) $relx
    set resize($w,y) $rely
    set resize($w,w) [winfo width $t]
    set resize($w,h) [winfo height $t]
    set resize($w,winc) 1
    set resize($w,hinc) 1
    set resize($w,grid) [wm grid $t]
}

# The following proc handles mouse motion on the resize control by asking the
# wm to adjust the size of the window.

proc StatusBar::continue_resize {w rootx rooty} {
    variable resize
    if {[llength $resize($w,grid)]} {
	# at this time, we don't know how to handle gridded resizing
	return
    }
    set t      [winfo toplevel $w]
    set relx   [expr {$rootx - [winfo rootx $t]}]
    set rely   [expr {$rooty - [winfo rooty $t]}]
    set width  [expr {$relx - $resize($w,x) + $resize($w,w)}]
    set height [expr {$rely - $resize($w,y) + $resize($w,h)}]
    if {$width  < 0} { set width 0 }
    if {$height < 0} { set height 0 }
    wm geometry $t ${width}x${height}
}

# The following proc cleans up when the user releases the mouse button.

proc StatusBar::end_resize {w rootx rooty} {
    variable resize
    #continue_resize $w $rootx $rooty
    #wm grid $t $resize($w,grid)
    array unset resize $w,*
}
