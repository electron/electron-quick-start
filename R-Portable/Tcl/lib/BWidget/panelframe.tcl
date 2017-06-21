# ----------------------------------------------------------------------------
#  panelframe.tcl
#	Create PanelFrame widgets.
#	A PanelFrame is a boxed frame that allows you to place items
#	in the label area (liked combined frame+toolbar).  It uses the
#	highlight colors the default frame color.
#  $Id: panelframe.tcl,v 1.1 2004/09/09 22:17:51 hobbs Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - PanelFrame::create
#     - PanelFrame::configure
#     - PanelFrame::cget
#     - PanelFrame::getframe
#     - PanelFrame::add
#     - PanelFrame::remove
#     - PanelFrame::items
# ----------------------------------------------------------------------------

namespace eval PanelFrame {
    Widget::define PanelFrame panelframe

    Widget::declare PanelFrame {
	{-background	   TkResource "" 0 frame}
	{-borderwidth	   TkResource 1	 0 frame}
	{-relief	   TkResource flat 0 frame}
	{-panelbackground  TkResource "" 0 {entry -selectbackground}}
	{-panelforeground  TkResource "" 0 {entry -selectforeground}}
	{-width		   Int	      0	 0}
	{-height	   Int	      0	 0}
	{-font		   TkResource "" 0 label}
	{-text		   String     "" 0}
	{-textvariable	   String     "" 0}
	{-ipad		   String      1 0}
	{-bg		   Synonym    -background}
	{-bd		   Synonym    -borderwidth}
    }
    # Should we have automatic state handling?
    #{-state            TkResource "" 0 label}

    Widget::addmap PanelFrame "" :cmd {
	-panelbackground -background
	-width {} -height {} -borderwidth {} -relief {}
    }
    Widget::addmap PanelFrame "" .title	  {
	-panelbackground -background
    }
    Widget::addmap PanelFrame "" .title.text   {
	-panelbackground -background
	-panelforeground -foreground
	-text {} -textvariable {} -font {}
    }
    Widget::addmap PanelFrame "" .frame {
	-background {}
    }

    if {0} {
	# This would be code to have an automated close button
	#{-closebutton	   Boolean    0	 0}
	Widget::addmap PanelFrame "" .title.close   {
	    -panelbackground -background
	    -panelforeground -foreground
	}
	variable HaveMarlett \
	    [expr {[lsearch -exact [font families] "Marlett"] != -1}]

	variable imgdata {
	    #define close_width 16
	    #define close_height 16
	    static char close_bits[] = {
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x10, 0x08,
		0x38, 0x1c, 0x70, 0x0e,
		0xe0, 0x07, 0xc0, 0x03,
		0xc0, 0x03, 0xe0, 0x07,
		0x70, 0x0e, 0x38, 0x1c,
		0x10, 0x08, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00};
	}
	# We use the same -foreground as the default -panelbackground
	image create bitmap ::PanelFrame::X -data $imgdata \
	    -foreground [lindex $Widget::PanelFrame::opt(-panelbackground) 1]
    }

    bind PanelFrame <Destroy> [list Widget::destroy %W]
}


# ----------------------------------------------------------------------------
#  Command PanelFrame::create
# ----------------------------------------------------------------------------
proc PanelFrame::create { path args } {
    variable HaveMarlett

    Widget::init PanelFrame $path $args

    set lblopts [list -bd 0 -highlightthickness 0]
    set outer [eval [list frame $path -class PanelFrame] \
		   [Widget::subcget $path :cmd]]
    set title [eval [list frame $path.title] \
		   [Widget::subcget $path .title]]
    set tlbl  [eval [list label $path.title.text] $lblopts -anchor w \
		   [Widget::subcget $path .title.text]]
    set inner [eval [list frame $path.frame] \
		   [Widget::subcget $path .frame]]

    foreach {ipadx ipady} [_padval [Widget::cget $path -ipad]] { break }

    if {0} {
	set btnopts [list -padx 0 -pady 0 -relief flat -overrelief raised \
			 -bd 1 -highlightthickness 0]
	set clbl  [eval [list button $path.title.close] $btnopts \
		       [Widget::subcget $path .title.close]]
	set close [Widget::cget $path -closebutton]
	if {$HaveMarlett} {
	    $clbl configure -font "Marlett -14" -text \u0072
	} else {
	    $clbl configure -image ::PanelFrame::X
	}
	if {$close} {
	    pack $path.title.close -side right -padx $ipadx -pady $ipady
	}
    }

    grid $path.title -row 0 -column 0 -sticky ew
    grid $path.frame -row 1 -column 0 -sticky news
    grid columnconfigure $path 0 -weight 1
    grid rowconfigure $path 1 -weight 1

    pack $path.title.text -side left -fill x -anchor w \
	-padx $ipadx -pady $ipady

    return [Widget::create PanelFrame $path]
}


# ----------------------------------------------------------------------------
#  Command PanelFrame::configure
# ----------------------------------------------------------------------------
proc PanelFrame::configure { path args } {
    set res [Widget::configure $path $args]

    if {[Widget::hasChanged $path -ipad ipad]} {
    }

    return $res
}


# ----------------------------------------------------------------------------
#  Command PanelFrame::cget
# ----------------------------------------------------------------------------
proc PanelFrame::cget { path option } {
    return [Widget::cget $path $option]
}

# ----------------------------------------------------------------------------
#  Command PanelFrame::getframe
# ----------------------------------------------------------------------------
proc PanelFrame::getframe { path } {
    return $path.frame
}

# ------------------------------------------------------------------------
#  Command PanelFrame::add
# ------------------------------------------------------------------------
proc PanelFrame::add {path w args} {
    variable _widget

    array set opts [list \
			-side   right \
			-fill   none \
			-expand 0 \
			-pad    [Widget::cget $path -ipad] \
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

    set f $path.title

    lappend _widget($path,items) $w
    pack $w -in $f -padx $ipadx -pady $ipady -side $opts(-side) \
	-fill $opts(-fill) -expand $opts(-expand)

    return $w
}

# ------------------------------------------------------------------------
#  Command PanelFrame::remove
# ------------------------------------------------------------------------
proc PanelFrame::remove {path args} {
    variable _widget

    set destroy [string equal [lindex $args 0] "-destroy"]
    if {$destroy} {
	set args [lrange $args 1 end]
    }
    foreach w $args {
	set idx [lsearch -exact $_widget($path,items) $w]
	if {$idx == -1} {
	    # ignore unknown
	    continue
	}
	if {$destroy} {
	    destroy $w
	} elseif {[winfo exists $w]} {
	    pack forget $w
	}
	set _widget($path,items) [lreplace $_widget($path,items) $idx $idx]
    }
}

# ------------------------------------------------------------------------
#  Command PanelFrame::delete
# ------------------------------------------------------------------------
proc PanelFrame::delete {path args} {
    return [PanelFrame::remove $path -destroy $args]
}

# ------------------------------------------------------------------------
#  Command PanelFrame::items
# ------------------------------------------------------------------------
proc PanelFrame::items {path} {
    variable _widget
    return $_widget($path,items)
}

proc PanelFrame::_padval {padval} {
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
