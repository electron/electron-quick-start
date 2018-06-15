# ----------------------------------------------------------------------------
#  mainframe.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: mainframe.tcl,v 1.24.2.3 2011/05/25 15:10:07 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - MainFrame::create
#     - MainFrame::configure
#     - MainFrame::cget
#     - MainFrame::getframe
#     - MainFrame::addtoolbar
#     - MainFrame::gettoolbar
#     - MainFrame::addindicator
#     - MainFrame::getindicator
#     - MainFrame::getmenu
#     - MainFrame::menuonly
#     - MainFrame::showtoolbar
#     - MainFrame::showstatusbar
#     - MainFrame::_create_menubar
#     - MainFrame::_create_entries
#     - MainFrame::_parse_name
#     - MainFrame::_parse_accelerator
# ----------------------------------------------------------------------------

namespace eval MainFrame {
    Widget::define MainFrame mainframe ProgressBar

    Widget::bwinclude MainFrame ProgressBar .status.prg \
	    remove {
	-fg -bg -bd -troughcolor -background -borderwidth
	-relief -orient -width -height
    } \
	    rename {
	-maximum    -progressmax
	-variable   -progressvar
	-type       -progresstype
	-foreground -progressfg
    }

    Widget::declare MainFrame {
	{-width         TkResource 0      0 frame}
	{-height        TkResource 0      0 frame}
	{-background    TkResource ""     0 frame}
	{-textvariable  String     ""     0}
	{-menu          String     {}     1}
	{-separator     Enum       both   1 {none top bottom both}}
	{-bg            Synonym    -background}

	{-menubarfont   String     ""  0}
	{-menuentryfont String     ""  0}
	{-statusbarfont String     ""  0}
	{-sizegrip      Boolean    0   1}
    }

    Widget::addmap MainFrame "" .frame  {-width {} -height {} -background {}}
    Widget::addmap MainFrame "" .topf   {-background {}}
    Widget::addmap MainFrame "" .botf   {-background {}}
    Widget::addmap MainFrame "" .status {-background {}}
    Widget::addmap MainFrame "" .status.label {-background {}}
    Widget::addmap MainFrame "" .status.indf  {-background {}}
    Widget::addmap MainFrame "" .status.prgf  {-background {}}
    Widget::addmap MainFrame ProgressBar .status.prg {-background {} -background -troughcolor}

    variable _widget
}


# ----------------------------------------------------------------------------
#  Command MainFrame::create
# ----------------------------------------------------------------------------
proc MainFrame::create { path args } {
    global   tcl_platform
    variable _widget

    if {[Widget::theme]} {
	set path [ttk::frame $path]
    } else {
	set path [frame $path -takefocus 0 -highlightthickness 0]
    }
    set top  [winfo parent $path]
    if { ![string equal [winfo toplevel $path] $top] } {
        destroy $path
        return -code error "parent must be a toplevel"
    }
    Widget::init MainFrame $path $args

    if { $tcl_platform(platform) == "unix" } {
        set relief raised
        set bd     1
    } else {
        set relief flat
        set bd     0
    }
    if {[Widget::theme]} {
	set userframe [eval [list ttk::frame $path.frame] \
			   [Widget::subcget $path .frame]]
	set topframe  [ttk::frame $path.topf]
	set botframe  [ttk::frame $path.botf]
    } else {
	set userframe [eval [list frame $path.frame] \
			   [Widget::subcget $path .frame] \
			   -relief $relief -borderwidth $bd]
	set topframe  [eval [list frame $path.topf] \
			   [Widget::subcget $path .topf]]
	set botframe  [eval [list frame $path.botf] \
			   -relief $relief -borderwidth $bd \
			   [Widget::subcget $path .botf]]
    }

    pack $topframe -fill x
    grid columnconfigure $topframe 0 -weight 1

    if {![Widget::theme]} {
	set bg [Widget::cget $path -background]
	$path configure -background $bg
    }
    if { $tcl_platform(platform) != "unix" } {
        set sepopt [Widget::getoption $path -separator]
        if { $sepopt == "both" || $sepopt == "top" } {
	    if {[Widget::theme]} {
		set sep [ttk::separator $path.sep -orient horizontal]
	    } else {
		set sep [Separator::create $path.sep -orient horizontal -background $bg]
	    }
            pack $sep -fill x
        }
        if { $sepopt == "both" || $sepopt == "bottom" } {
	    if {[Widget::theme]} {
		set sep [ttk::separator $botframe.sep -orient horizontal]
	    } else {
		set sep [Separator::create $botframe.sep -orient horizontal -background $bg]
	    }
            pack $sep -fill x
        }
    }

    # --- status bar ---------------------------------------------------------
    if {[string length [Widget::getoption $path -statusbarfont]]} {
	set sbfnt [list -font [Widget::getoption $path -statusbarfont]]
    } else {
	set sbfnt ""
    }

    if {[Widget::theme]} {
	set status   [ttk::frame $path.status]
	set label    [eval [list ttk::label $status.label \
				-textvariable [Widget::getoption $path -textvariable]] $sbfnt]
	set indframe [ttk::frame $status.indf]
	set prgframe [ttk::frame $status.prgf]
    } else {
	set status   [frame $path.status -background $bg]
	set label    [eval [list label $status.label \
				-textvariable [Widget::getoption $path -textvariable] \
				-background $bg] $sbfnt]
	set indframe [frame $status.indf -background $bg]
	set prgframe [frame $status.prgf -background $bg]
    }

    place $label    -anchor w -x 0 -rely 0.5
    place $indframe -anchor ne -relx 1 -y 0 -relheight 1
    pack  $prgframe -in $indframe -side left -padx 2
    $status configure -height [winfo reqheight $label]

    set progress [eval [list ProgressBar::create $status.prg] \
		      [Widget::subcget $path .status.prg] \
                      -width       50 \
                      -height      [expr {[winfo reqheight $label]-2}] \
                      -borderwidth 1 \
                      -relief      sunken]
    if {[Widget::theme] && [Widget::getoption $path -sizegrip]} {
	pack [ttk::sizegrip $botframe.sg] -side right -anchor se
    }
    pack $status    -in $botframe -fill x -pady 2
    pack $botframe  -side bottom -fill x
    pack $userframe -fill both -expand yes

    set _widget($path,top)      $top
    set _widget($path,ntoolbar) 0
    set _widget($path,nindic)   0

    set menu [Widget::getoption $path -menu]
    if { [llength $menu] } {
        _create_menubar $path $menu
    }

    bind $path <Destroy> [list MainFrame::_destroy %W]

    return [Widget::create MainFrame $path]
}


# ----------------------------------------------------------------------------
#  Command MainFrame::configure
# ----------------------------------------------------------------------------
proc MainFrame::configure { path args } {
    variable _widget

    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -textvariable newv] } {
        uplevel \#0 $path.status.label configure -textvariable [list $newv]
    }

    # The ttk frame has no -background
    if {![Widget::theme] && [Widget::hasChanged $path -background bg] } {
	if {($::tcl_platform(platform) == "unix")
	        && (0 != [string compare [tk windowingsystem] "aqua"])} {
	    set listmenu [$_widget($path,top) cget -menu]
	    while { [llength $listmenu] } {
		set newlist {}
		foreach menu $listmenu {
		    $menu configure -background $bg
		    set newlist [concat $newlist [winfo children $menu]]
		}
		set listmenu $newlist
	    }
	}
	foreach sep {.sep .botf.sep} {
	    if {[winfo exists $path.$sep]} {
		Separator::configure $path.$sep -background $bg
	    }
	}
	foreach w [winfo children $path.topf] {
	    $w configure -background $bg
	}
    }

    if { [Widget::hasChanged $path -menubarfont newmbfnt] } {
	if {[string length $newmbfnt]} {
	    set mbfnt [list -font $newmbfnt]
	} else {
	    set mbfnt ""
	}
	set top     $_widget($path,top)
	if {[string equal $top .]} {
	    eval [list .menubar configure] $mbfnt
	} else {
	    eval [list $top.menubar configure] $mbfnt
	}
    }
    if { [Widget::hasChanged $path -menuentryfont newmefnt] } {
	if {[string length $newmefnt]} {
	    set mefnt [list -font $newmefnt]
	} else {
	    set mefnt ""
	}
	set top     $_widget($path,top)
	if {[string equal $top .]} {
	    set mb .menubar
	} else {
	    set mb $top.menubar
	}
	set l [winfo children $mb]
	while {[llength $l]} {
	    set e [lindex $l 0]
	    set l [lrange $l 1 end]
	    if {[string length $e] == 0} {continue}
	    lappend l [winfo children $e]
	    eval [list $e configure] $mefnt
	}
    }


    if { [Widget::hasChanged $path -statusbarfont newsbfnt] } {
	if {[string length $newsbfnt]} {
	    set sbfnt [list -font $newsbfnt]
	} else {
	    set sbfnt ""
	}
	for {set index 0} {$index<$_widget($path,nindic)} {incr index} {
	    set indic $path.status.indf.f$index
	    eval [list $indic configure] $sbfnt
	}
	eval [list $path.status.label configure] $sbfnt
	$path.status configure -height [winfo reqheight $path.status.label]

	$path.status.prg configure \
		-height [expr {[winfo reqheight $path.status.label]-2}]
    }

    return $res
}


# ----------------------------------------------------------------------------
#  Command MainFrame::cget
# ----------------------------------------------------------------------------
proc MainFrame::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command MainFrame::getframe
# ----------------------------------------------------------------------------
proc MainFrame::getframe { path } {
    return $path.frame
}


# ----------------------------------------------------------------------------
#  Command MainFrame::addtoolbar
# ----------------------------------------------------------------------------
proc MainFrame::addtoolbar { path } {
    global   tcl_platform
    variable _widget

    set index     $_widget($path,ntoolbar)
    set toolframe $path.topf.f$index
    set toolbar   $path.topf.tb$index
    if { $tcl_platform(platform) == "unix" } {
	if {[Widget::theme]} {
	    ttk::frame $toolframe -padding 1
	} else {
	    set bg [Widget::getoption $path -background]
	    frame $toolframe -relief raised -borderwidth 1 \
		-takefocus 0 -highlightthickness 0 -background $bg
	}
    } else {
	if {[Widget::theme]} {
	    ttk::frame $toolframe
	    set sep [ttk::separator $toolframe.sep -orient horizontal]
	} else {
	    set bg [Widget::getoption $path -background]
	    frame $toolframe -relief flat -borderwidth 0 -takefocus 0 \
		-highlightthickness 0 -background $bg
	    set sep [Separator::create $toolframe.sep -orient horizontal -background $bg]
	}
        pack $sep -fill x
    }
    if {[Widget::theme]} {
	set toolbar [ttk::frame $toolbar -padding 2]
    } else {
	set toolbar [frame $toolbar -relief flat -borderwidth 2 \
			 -takefocus 0 -highlightthickness 0 -background $bg]
    }
    pack $toolbar -in $toolframe -anchor w -expand yes -fill x
    incr _widget($path,ntoolbar)
    grid $toolframe -column 0 -row $index -sticky ew
    return $toolbar
}


# ----------------------------------------------------------------------------
#  Command MainFrame::gettoolbar
# ----------------------------------------------------------------------------
proc MainFrame::gettoolbar { path index } {
    return $path.topf.tb$index
}


# ----------------------------------------------------------------------------
#  Command MainFrame::addindicator
# ----------------------------------------------------------------------------
proc MainFrame::addindicator { path args } {
    variable _widget

    if {[string length [Widget::getoption $path -statusbarfont]]} {
	set sbfnt [list -font [Widget::getoption $path -statusbarfont]]
    } else {
	set sbfnt ""
    }

    set index $_widget($path,nindic)
    set indic $path.status.indf.f$index
    eval [list label $indic] $args -relief sunken -borderwidth 1 \
        -takefocus 0 -highlightthickness 0 $sbfnt

    pack $indic -side left -anchor w -padx 2 -fill y -expand 1

    incr _widget($path,nindic)

    return $indic
}


# ----------------------------------------------------------------------------
#  Command MainFrame::getindicator
# ----------------------------------------------------------------------------
proc MainFrame::getindicator { path index } {
    return $path.status.indf.f$index
}


# ----------------------------------------------------------------------------
#  Command MainFrame::getmenu
# ----------------------------------------------------------------------------
proc MainFrame::getmenu { path menuid } {
    variable _widget

    if { [info exists _widget($path,menuid,$menuid)] } {
        return $_widget($path,menuid,$menuid)
    }
    return ""
}


# -----------------------------------------------------------------------------
#  Command MainFrame::setmenustate
# -----------------------------------------------------------------------------
proc MainFrame::setmenustate { path tag state } {
    variable _widget

    # Set menustate to enabled when ALL of its tags are enabled.

    # First see if this is a real tag
    if { [info exists _widget($path,tagstate,$tag)] } {
	if { ![string equal $state "disabled"] } {
	    set _widget($path,tagstate,$tag) 1
	} else {
	    set _widget($path,tagstate,$tag) 0
	}
	foreach {menu entry} $_widget($path,tags,$tag) {
	    set expression "1"
	    foreach menutag $_widget($path,menutags,[list $menu $entry]) {
		append expression " && $_widget($path,tagstate,$menutag)"
	    }
	    if { [expr $expression] } {
		set state normal
	    } else {
		set state disabled
	    }
	    $menu entryconfigure $entry -state $state
	}
    }
    return
}

# -----------------------------------------------------------------------------
#  Command MainFrame::getmenustate
# -----------------------------------------------------------------------------
proc MainFrame::getmenustate { path tag } {
    variable _widget

    if {$_widget($path,tagstate,$tag)} {
        return normal
    } else {
        return disabled
    }
}

# -----------------------------------------------------------------------------
#  Command MainFrame::menuonly
# ----------------------d------------------------------------------------------
proc MainFrame::menuonly { path } {
    variable _widget

    catch {pack forget $path.sep}
    catch {pack forget $path.botf.sep}
    catch {pack forget $path.frame}
}

# ----------------------------------------------------------------------------
#  Command MainFrame::showtoolbar
# ----------------------------------------------------------------------------
proc MainFrame::showtoolbar { path index bool } {
    variable _widget

    set toolframe $path.topf.f$index
    if { [winfo exists $toolframe] } {
        if { !$bool && [llength [grid info $toolframe]] } {
            grid forget $toolframe
            $path.topf configure -height 1
        } elseif { $bool && ![llength [grid info $toolframe]] } {
            grid $toolframe -column 0 -row $index -sticky ew
        }
    }
}


# ----------------------------------------------------------------------------
#  Command MainFrame::showstatusbar
# ----------------------------------------------------------------------------
proc MainFrame::showstatusbar { path name } {
    set status $path.status
    set botframe $path.botf
    if { [string equal $name "none"] } {
        pack forget $status
    } else {
        pack $status -fill x -in $botframe -fill x -pady 2
        switch -- $name {
            status {
                catch {pack forget $status.prg}
            }
            progression {
                pack $status.prg -in $status.prgf
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command MainFrame::_destroy
# ----------------------------------------------------------------------------
proc MainFrame::_destroy { path } {
    variable _widget

    Widget::destroy $path
    catch {destroy [$_widget($path,top) cget -menu]}
    $_widget($path,top) configure -menu {}

    # Unset all of the state vars associated with this main frame.
    foreach index [array names _widget $path,*] {
	unset _widget($index)
    }
}


# ----------------------------------------------------------------------------
#  Command MainFrame::_create_menubar
# ----------------------------------------------------------------------------
proc MainFrame::_create_menubar { path descmenu } {
    variable _widget
    global    tcl_platform

    set top $_widget($path,top)

    foreach {v x} {mbfnt -menubarfont mefnt -menuentryfont} {
	if {[string length [Widget::getoption $path $x]]} {
	    set $v [list -font [Widget::getoption $path $x]]
	} else {
	    set $v ""
	}
    }

    if { ![Widget::theme] && $tcl_platform(platform) == "unix"
        && [tk windowingsystem] !="aqua" } {
	set menuopts [list -background [Widget::getoption $path -background] \
			  -borderwidth 1]
    } else {
	set menuopts [list]
    }
    set menubar [eval [list menu $top.menubar -tearoff 0] $menuopts $mbfnt]
    $top configure -menu $menubar

    set count 0
    foreach {name tags menuid tearoff entries} $descmenu {
        set opt  [_parse_name $name]
        if {[string length $menuid]
	    && ![info exists _widget($path,menuid,$menuid)] } {
            # menu has identifier
	    # we use it for its pathname, to enable special menu entries
	    # (help, system, ...)
	    set menu $menubar.$menuid
        } else {
	    set menu $menubar.menu$count
	}
        eval [list $menubar add cascade] $opt [list -menu $menu]
        eval [list menu $menu -tearoff $tearoff] $menuopts $mefnt
        foreach tag $tags {
            lappend _widget($path,tags,$tag) $menubar $count
	    # ericm@scriptics:  Add a tagstate tracker
	    if { ![info exists _widget($path,tagstate,$tag)] } {
		set _widget($path,tagstate,$tag) 1
	    }
        }
	# ericm@scriptics:  Add mapping from menu items to tags
	set _widget($path,menutags,[list $menubar $count]) $tags

        if { [string length $menuid] } {
            # menu has identifier
            set _widget($path,menuid,$menuid) $menu
        }
        _create_entries $path $menu $menuopts $entries
        incr count
    }
}


# ----------------------------------------------------------------------------
#  Command MainFrame::_create_entries
# ----------------------------------------------------------------------------
proc MainFrame::_create_entries { path menu menuopts entries } {
    variable _widget

    set count      [$menu cget -tearoff]
    set registered 0
    foreach entry $entries {
        set len  [llength $entry]
        set type [lindex $entry 0]

        if { [string equal $type "separator"] } {
            $menu add separator
            incr count
            continue
        }

        # entry name and tags
        set opt  [_parse_name [lindex $entry 1]]
        set tags [lindex $entry 2]
        foreach tag $tags {
            lappend _widget($path,tags,$tag) $menu $count
	    # ericm@scriptics:  Add a tagstate tracker
	    if { ![info exists _widget($path,tagstate,$tag)] } {
		set _widget($path,tagstate,$tag) 1
	    }
        }
	# ericm@scriptics:  Add mapping from menu items to tags
	set _widget($path,menutags,[list $menu $count]) $tags

        if {[string equal $type "cascade"] || [string equal $type "cascad"]} {
            set menuid  [lindex $entry 3]
            set tearoff [lindex $entry 4]
            set submenu $menu.menu$count
            eval [list $menu add cascade] $opt [list -menu $submenu]
            eval [list menu $submenu -tearoff $tearoff] $menuopts
            if { [string length $menuid] } {
                # menu has identifier
                set _widget($path,menuid,$menuid) $submenu
            }
            _create_entries $path $submenu $menuopts [lindex $entry 5]
            incr count
            continue
        }

        # entry help description
        set desc [lindex $entry 3]
        if { [string length $desc] } {
            if { !$registered } {
                DynamicHelp::register $menu menu [Widget::getoption $path -textvariable]
                set registered 1
            }
            DynamicHelp::register $menu menuentry $count $desc
        }

        # entry accelerator
        set accel [_parse_accelerator [lindex $entry 4]]
        if { [llength $accel] } {
            lappend opt -accelerator [lindex $accel 0]
            foreach event [lindex $accel 1] {
                bind $_widget($path,top) $event [list $menu invoke $count]
            }
            foreach event [lindex $accel 2] {
                if {[bind $_widget($path,top) $event] == {}} {
                    bind $_widget($path,top) $event { # do nothing }
                } else {
                    # The existing binding will intercept these events.
                }
            }
        }

        # user options
        set useropt [lrange $entry 5 end]
        if { [string equal $type "command"] ||
             [string equal $type "radiobutton"] ||
             [string equal $type "checkbutton"] } {
            eval [list $menu add $type] $opt $useropt
        } else {
            return -code error "invalid menu type \"$type\""
        }
        incr count
    }
}


# ----------------------------------------------------------------------------
#  Command MainFrame::_parse_name
# ----------------------------------------------------------------------------
proc MainFrame::_parse_name { menuname } {
    set idx [string first "&" $menuname]
    if { $idx == -1 } {
        return [list -label $menuname]
    } else {
        set beg [string range $menuname 0 [expr {$idx-1}]]
        set end [string range $menuname [expr {$idx+1}] end]
        append beg $end
        return [list -label $beg -underline $idx]
    }
}


# MainFrame::_parse_accelerator --
#
#	Given a key combo description, construct an appropriate human readable
#	string (for display on as a menu accelerator), a list of the
#	corresponding bind events, and a separate list of bind events that need
#	to be blocked.
#
# 	When argument $desc does not include "Shift", the bindings to $events
# 	will in some cases also intercept events that have the modifier "Shift",
# 	unless more specific bindings $blockEvents exist to the latter.  This
# 	situation occurs, for example, when a Cmd binding exists without a
# 	corresponding ShiftCmd binding.  The list of events that need to be
#       blocked is returned as the third element of the result.
#
# Arguments:
#	desc	a list with the following format:
#			?sequence? key
#		sequence may be None, Ctrl, Alt, CtrlAlt, Shift, Cmd or
#			ShiftCmd
#		key may be any key
#
# Results:
#	{accel events blockEvents}  a list containing the accelerator string and
#	                            two lists of events

proc MainFrame::_parse_accelerator { desc } {
    variable _widget

    set fKey 0
    if { [llength $desc] == 1 } {
	set seq None
	set key [string tolower [lindex $desc 0]]
	# If the key is an F key (ie, F1, F2, etc), it has to be capitalized
	if {[regexp {^f([1-9]|([12][0-9]|3[0-5]))$} $key]} {
	    set key [string toupper $key]
	    set fKey 1
	}
    } elseif { [llength $desc] == 2 } {
        set seq [lindex $desc 0]
        set key [string tolower [lindex $desc 1]]
	# If the key is an F key (ie, F1, F2, etc), it has to be capitalized
	if {[regexp {^f([1-9]|([12][0-9]|3[0-5]))$} $key]} {
	    set key [string toupper $key]
	    set fKey 1
	}
    } else {
	return {}
    }

    # Plain "Shift" can be used only with F keys, but "ShiftCmd" is allowed.
    if {[string equal $seq "Shift"] && (!$fKey)} {
        return -code error {Shift accelerator can be used only with F keys}
    }

    set blockEvents {}
    set upc [string toupper $key]

    switch -- $seq {
	None {
	    set accel "$upc"
	    set events [list "<Key-$key>"]
	    if {$fKey} {
		set blockEvents [list "<Shift-Key-$key>"]
	    }
	}
	Shift {
	    # Used only with Function keys.
	    set accel "Shift+$upc"
	    set events [list "<Shift-Key-$key>"]
	}
	Cmd {
	    set accel "Cmd+$upc"

	    if {    [string equal [tk windowingsystem] "aqua"] &&
		   ([string first AppKit [winfo server .]] == -1)
	    } {
		# Carbon
	        set events [list "<Command-Key-$key>" \
	                    "<Lock-Command-Key-$upc>" ]
		set blockEvents [list "<Lock-Shift-Command-Key-$upc>"]
		# Both bindings must be included in $events -  the first binding
		# does not fire if "Lock" is set, and this is as bind(n) states
		# because the second binding is NOT a more specialized form of
		# the first.
	    } else {
		# Cocoa and anything else that uses Cmd
	        set events [list "<Command-Key-$key>"]
	        # A binding to "<Lock-Command-Key-$upc>" must not be included
	        # here - both events fire if "Lock" is set.
		set blockEvents [list "<Shift-Command-Key-$key>"]
	    }
	}
	ShiftCmd {
	    if {    [string equal [tk windowingsystem] "aqua"] &&
		    ([string first AppKit [winfo server .]] == -1)
	    } {
		# Carbon
		set accel "Shift+Cmd+$upc"
		set events [list "<Shift-Command-Key-$upc>" \
			    "<Lock-Shift-Command-Key-$upc>"]
		# Both bindings must be included here -  the first binding does
		# not fire if "Lock" is set, even though the second binding
		# should be recognized as a more specialized form of the first.
	    } else {
		# Cocoa and anything else that uses Cmd
		set accel "Shift+Cmd+$upc"
		set events [list "<Shift-Command-Key-$key>"]
		# A binding to "<Lock-Shift-Command-Key-$key>" must not be
		# included here - both events fire if "Lock" is set.
		# Tk/Cocoa fails to recognize
		# <Lock-Shift-Command-Key-$key> as a "more specialized" binding
		# than <Shift-Command-Key-$key>.
		# Perversely, Tk/Carbon (above) makes the opposite error.
	    }
	}
	Ctrl {
	    set accel "Ctrl+$upc"
	    set events [list "<Control-Key-$key>"]
	}
	Alt {
	    set accel "Alt+$upc"
	    set events [list "<Alt-Key-$key>"]
	}
	CtrlAlt {
	    set accel "Ctrl+Alt+$upc"
	    set events [list "<Control-Alt-Key-$key>"]
	}
	default {
	    return -code error "invalid accelerator code $seq"
	}
    }

    return [list $accel $events $blockEvents]
}
