# ----------------------------------------------------------------------------
#  panedw.tcl
#  This file is part of Unifix BWidget Toolkit
# ----------------------------------------------------------------------------
#  Index of commands:
#     - PanedWindow::create
#     - PanedWindow::configure
#     - PanedWindow::cget
#     - PanedWindow::add
#     - PanedWindow::getframe
#     - PanedWindow::_apply_weights
#     - PanedWindow::_destroy
#     - PanedWindow::_beg_move_sash
#     - PanedWindow::_move_sash
#     - PanedWindow::_end_move_sash
#     - PanedWindow::_realize
# ----------------------------------------------------------------------------

# JDC: added option to choose behavior of weights
#    -weights extra : only apply weights to extra space (as current (>= 1.3.1) with grid command)
#    -weights available : apply weights to total available space (as before (<1.3.1) with place command)

namespace eval PanedWindow {
    Widget::define PanedWindow panedw

    namespace eval Pane {
        Widget::declare PanedWindow::Pane {
            {-minsize Int 0 0 "%d >= 0"}
            {-weight  Int 1 0 "%d >= 0"}
        }
    }

    Widget::declare PanedWindow {
        {-side       Enum       top   1 {top left bottom right}}
        {-width      Int        10    1 "%d >=3"}
        {-pad        Int        4     1 "%d >= 0"}
        {-background TkResource ""    0 frame}
        {-bg         Synonym    -background}
        {-activator  Enum       ""    1 {line button}}
	{-weights    Enum       extra 1 {extra available}}
    }

    variable _panedw
}



# ----------------------------------------------------------------------------
#  Command PanedWindow::create
# ----------------------------------------------------------------------------
proc PanedWindow::create { path args } {
    variable _panedw

    Widget::init PanedWindow $path $args

    frame $path -background [Widget::cget $path -background] -class PanedWindow
    set _panedw($path,nbpanes) 0
    set _panedw($path,weights) ""
    set _panedw($path,configuredone) 0

    set activator [Widget::getoption $path -activator]
    if {[string equal $activator ""]} {
        if { $::tcl_platform(platform) != "windows" } {
            Widget::setMegawidgetOption $path -activator button
        } else {
            Widget::setMegawidgetOption $path -activator line
        }
    }
    if {[string equal [Widget::getoption $path -activator] "line"]} {
        Widget::setMegawidgetOption $path -width 3
    }
    
    bind $path <Configure> [list PanedWindow::_realize $path %w %h]
    bind $path <Destroy>   [list PanedWindow::_destroy $path]

    return [Widget::create PanedWindow $path]
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::configure
# ----------------------------------------------------------------------------
proc PanedWindow::configure { path args } {
    variable _panedw

    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -background bg] && $_panedw($path,nbpanes) > 0 } {
        $path:cmd configure -background $bg
        $path.f0 configure -background $bg
        for {set i 1} {$i < $_panedw($path,nbpanes)} {incr i} {
            set frame $path.sash$i
            $frame configure -background $bg
            $frame.sep configure -background $bg
            $frame.but configure -background $bg
            $path.f$i configure -background $bg
            $path.f$i.frame configure -background $bg
        }
    }
    return $res
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::cget
# ----------------------------------------------------------------------------
proc PanedWindow::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::add
# ----------------------------------------------------------------------------
proc PanedWindow::add { path args } {
    variable _panedw

    set num $_panedw($path,nbpanes)
    Widget::init PanedWindow::Pane $path.f$num $args
    set bg [Widget::getoption $path -background]

    set wbut   [Widget::getoption $path -width]
    set pad    [Widget::getoption $path -pad]
    set width  [expr {$wbut+2*$pad}]
    set side   [Widget::getoption $path -side]
    set weight [Widget::getoption $path.f$num -weight]
    lappend _panedw($path,weights) $weight

    if { $num > 0 } {
        set frame [frame $path.sash$num -relief flat -bd 0 \
                       -highlightthickness 0 -width $width -height $width -bg $bg]
        set sep [frame $frame.sep -bd 5 -relief raised \
                     -highlightthickness 0 -bg $bg]
        set but [frame $frame.but -bd 1 -relief raised \
                     -highlightthickness 0 -bg $bg -width $wbut -height $wbut]
	set sepsize 2

        set activator [Widget::getoption $path -activator]
	if {$activator == "button"} {
	    set activator $but
	    set placeButton 1
	} else {
	    set activator $sep
	    $sep configure -bd 1
	    set placeButton 0
	}
        if {[string equal $side "top"] || [string equal $side "bottom"]} {
            place $sep -relx 0.5 -y 0 -width $sepsize -relheight 1.0 -anchor n
	    if { $placeButton } {
		if {[string equal $side "top"]} {
		    place $but -relx 0.5 -y [expr {6+$wbut/2}] -anchor c
		} else {
		    place $but -relx 0.5 -rely 1.0 -y [expr {-6-$wbut/2}] \
			    -anchor c
		}
	    }
            $activator configure -cursor sb_h_double_arrow 
            grid $frame -column [expr {2*$num-1}] -row 0 -sticky ns
            grid columnconfigure $path [expr {2*$num-1}] -weight 0
        } else {
            place $sep -x 0 -rely 0.5 -height $sepsize -relwidth 1.0 -anchor w
	    if { $placeButton } {
		if {[string equal $side "left"]} {
		    place $but -rely 0.5 -x [expr {6+$wbut/2}] -anchor c
		} else {
		    place $but -rely 0.5 -relx 1.0 -x [expr {-6-$wbut/2}] \
			    -anchor c
		}
	    }
            $activator configure -cursor sb_v_double_arrow 
            grid $frame -row [expr {2*$num-1}] -column 0 -sticky ew
            grid rowconfigure $path [expr {2*$num-1}] -weight 0
        }
        bind $activator <ButtonPress-1> \
	    [list PanedWindow::_beg_move_sash $path $num %X %Y]
    } else {
        if { [string equal $side "top"] || \
		[string equal $side "bottom"] } {
            grid rowconfigure $path 0 -weight 1
        } else {
            grid columnconfigure $path 0 -weight 1
        }
    }

    set pane [frame $path.f$num -bd 0 -relief flat \
	    -highlightthickness 0 -bg $bg]
    set user [frame $path.f$num.frame  -bd 0 -relief flat \
	    -highlightthickness 0 -bg $bg]
    if { [string equal $side "top"] || [string equal $side "bottom"] } {
        grid $pane -column [expr {2*$num}] -row 0 -sticky nsew
        grid columnconfigure $path [expr {2*$num}] -weight $weight
    } else {
        grid $pane -row [expr {2*$num}] -column 0 -sticky nsew
        grid rowconfigure $path [expr {2*$num}] -weight $weight
    }
    pack $user -fill both -expand yes
    incr _panedw($path,nbpanes)
    if {$_panedw($path,configuredone)} {
	_realize $path [winfo width $path] [winfo height $path]
    }

    return $user
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::getframe
# ----------------------------------------------------------------------------
proc PanedWindow::getframe { path index } {
    if { [winfo exists $path.f$index.frame] } {
        return $path.f$index.frame
    }
}
    

# ----------------------------------------------------------------------------
#  Command PanedWindow::_beg_move_sash
# ----------------------------------------------------------------------------
proc PanedWindow::_beg_move_sash { path num x y } {
    variable _panedw

    set fprev $path.f[expr {$num-1}]
    set fnext $path.f$num
    set wsash [expr {[Widget::getoption $path -width] + 2*[Widget::getoption $path -pad]}]

    $path.sash$num.but configure -relief sunken
    set top  [toplevel $path.sash -borderwidth 1 -relief raised]

    set minszg [Widget::getoption $fprev -minsize]
    set minszd [Widget::getoption $fnext -minsize]
    set side   [Widget::getoption $path -side]

    if { [string equal $side "top"] || [string equal $side "bottom"] } {
        $top configure -cursor sb_h_double_arrow
        set h    [winfo height $path]
        set yr   [winfo rooty $path.sash$num]
        set xmin [expr {$wsash/2+[winfo rootx $fprev]+$minszg}]
        set xmax [expr {-$wsash/2-1+[winfo rootx $fnext]+[winfo width $fnext]-$minszd}]
        wm overrideredirect $top 1
        wm geom $top "2x${h}+$x+$yr"

        update idletasks
        grab set $top
        bind $top <ButtonRelease-1> [list PanedWindow::_end_move_sash $path $top $num $xmin $xmax %X rootx width]
        bind $top <Motion>          [list PanedWindow::_move_sash $top $xmin $xmax %X +%%d+$yr]
        _move_sash $top $xmin $xmax $x "+%d+$yr"
    } else {
        $top configure -cursor sb_v_double_arrow
        set w    [winfo width $path]
        set xr   [winfo rootx $path.sash$num]
        set ymin [expr {$wsash/2+[winfo rooty $fprev]+$minszg}]
        set ymax [expr {-$wsash/2-1+[winfo rooty $fnext]+[winfo height $fnext]-$minszd}]
        wm overrideredirect $top 1
        wm geom $top "${w}x2+$xr+$y"

        update idletasks
        grab set $top
        bind $top <ButtonRelease-1> [list PanedWindow::_end_move_sash \
		$path $top $num $ymin $ymax %Y rooty height]
        bind $top <Motion>          [list PanedWindow::_move_sash \
		$top $ymin $ymax %Y +$xr+%%d]
        _move_sash $top $ymin $ymax $y "+$xr+%d"
    }
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::_move_sash
# ----------------------------------------------------------------------------
proc PanedWindow::_move_sash { top min max v form } {

    if { $v < $min } {
	set v $min
    } elseif { $v > $max } {
	set v $max
    }
    wm geom $top [format $form $v]
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::_end_move_sash
# ----------------------------------------------------------------------------
proc PanedWindow::_end_move_sash { path top num min max v rootv size } {
    variable _panedw

    destroy $top
    if { $v < $min } {
	set v $min
    } elseif { $v > $max } {
	set v $max
    }
    set fprev $path.f[expr {$num-1}]
    set fnext $path.f$num

    $path.sash$num.but configure -relief raised

    set wsash [expr {[Widget::getoption $path -width] + 2*[Widget::getoption $path -pad]}]
    set dv    [expr {$v-[winfo $rootv $path.sash$num]-$wsash/2}]
    set w1    [winfo $size $fprev]
    set w2    [winfo $size $fnext]

    for {set i 0} {$i < $_panedw($path,nbpanes)} {incr i} {
        if { $i == $num-1} {
            $fprev configure -$size [expr {[winfo $size $fprev]+$dv}]
        } elseif { $i == $num } {
            $fnext configure -$size [expr {[winfo $size $fnext]-$dv}]
        } else {
            $path.f$i configure -$size [winfo $size $path.f$i]
        }
    }
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::_realize
# ----------------------------------------------------------------------------
proc PanedWindow::_realize { path width height } {
    variable _panedw

    set x    0
    set y    0
    set hc   [winfo reqheight $path]
    set hmax 0
    for {set i 0} {$i < $_panedw($path,nbpanes)} {incr i} {
        $path.f$i configure \
            -width  [winfo reqwidth  $path.f$i.frame] \
            -height [winfo reqheight $path.f$i.frame]
        place $path.f$i.frame -x 0 -y 0 -relwidth 1 -relheight 1
    }

    bind $path <Configure> {}

    _apply_weights $path
    set _panedw($path,configuredone) 1
    return
}

# ----------------------------------------------------------------------------
#  Command PanedWindow::_apply_weights
# ----------------------------------------------------------------------------
proc PanedWindow::_apply_weights { path } {
    variable _panedw

    set weights [Widget::getoption $path -weights]
    if {[string equal $weights "extra"]} {
	return
    }

    set side   [Widget::getoption $path -side]
    if {[string equal $side "top"] || [string equal $side "bottom"] } {
	set size width
    } else {
	set size height
    }
    set wsash [expr {[Widget::getoption $path -width] + 2*[Widget::getoption $path -pad]}]
    set rs [winfo $size $path]
    set s [expr {$rs - ($_panedw($path,nbpanes) - 1) * $wsash}]
    
    set tw 0.0
    foreach w $_panedw($path,weights) { 
	set tw [expr {$tw + $w}]
    }

    for {set i 0} {$i < $_panedw($path,nbpanes)} {incr i} {
	set rw [lindex $_panedw($path,weights) $i]
	set ps [expr {int($rw / $tw * $s)}]
	$path.f$i configure -$size $ps
    }    
    return
}


# ----------------------------------------------------------------------------
#  Command PanedWindow::_destroy
# ----------------------------------------------------------------------------
proc PanedWindow::_destroy { path } {
    variable _panedw

    for {set i 0} {$i < $_panedw($path,nbpanes)} {incr i} {
        Widget::destroy $path.f$i
    }
    unset _panedw($path,nbpanes)
    Widget::destroy $path
}
