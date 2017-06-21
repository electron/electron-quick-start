namespace eval SelectColor {
    Widget::define SelectColor color Dialog

    Widget::declare SelectColor {
        {-title     String     "Select a color" 0}
        {-parent    String     ""               0}
        {-color     TkResource ""               0 {label -background}}
	{-type      Enum       "dialog"         1 {dialog popup}}
	{-placement String     "center"         1}
    }

    variable _baseColors {
        \#0000ff \#00ff00 \#00ffff \#ff0000 \#ff00ff \#ffff00
        \#000099 \#009900 \#009999 \#990000 \#990099 \#999900
        \#000000 \#333333 \#666666 \#999999 \#cccccc \#ffffff
    }

    variable _userColors {
        \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff
        \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff
    }

    if {[string equal $::tcl_platform(platform) "unix"]} {
        set useTkDialogue 0
    } else {
        set useTkDialogue 1
    }

    variable _selectype
    variable _selection
    variable _wcolor
    variable _image
    variable _hsv
}

proc SelectColor::create { path args } {
    Widget::init SelectColor $path $args

    set type [Widget::cget $path -type]

    switch -- [Widget::cget $path -type] {
	"dialog" {
	    return [eval [list SelectColor::dialog $path] $args]
	}

	"popup" {
	    set list      [list at center left right above below]
	    set placement [Widget::cget $path -placement]
	    set where     [lindex $placement 0]

	    if {[lsearch $list $where] < 0} {
		return -code error \
		    [BWidget::badOptionString placement $placement $list]
	    }

	    ## If they specified a parent and didn't pass a second argument
	    ## in the placement, set the placement relative to the parent.
	    set parent [Widget::cget $path -parent]
	    if {[string length $parent]} {
		if {[llength $placement] == 1} { lappend placement $parent }
	    }
	    return [eval [list SelectColor::menu $path $placement] $args]
	}
    }
}

proc SelectColor::menu {path placement args} {
    variable _baseColors
    variable _userColors
    variable _wcolor
    variable _selectype
    variable _selection

    Widget::init SelectColor $path $args
    set top [toplevel $path]
    set parent [winfo toplevel [winfo parent $top]]
    wm withdraw  $top
    wm transient $top $parent
    wm overrideredirect $top 1
    catch { wm attributes $top -topmost 1 }

    set frame [frame $top.frame \
                   -highlightthickness 0 \
                   -relief raised -borderwidth 2]
    set col    0
    set row    0
    set count  0
    set colors [concat $_baseColors $_userColors]
    foreach color $colors {
        set f [frame $frame.c$count \
                   -highlightthickness 2 \
                   -highlightcolor white \
                   -relief solid -borderwidth 1 \
                   -width 16 -height 16 -background $color]
        bind $f <1>     "set SelectColor::_selection $count; break"
        bind $f <Enter> {focus %W}
        grid $f -column $col -row $row
        incr count
        if {[incr col] == 6 } {
            set  col 0
            incr row
        }
    }
    set f [label $frame.c$count \
               -highlightthickness 2 \
               -highlightcolor white \
               -relief flat -borderwidth 0 \
               -width 16 -height 16 -image [Bitmap::get palette]]
    grid $f -column $col -row $row
    bind $f <1>     "set SelectColor::_selection $count; break"
    bind $f <Enter> {focus %W}
    pack $frame

    bind $top <1>      {set SelectColor::_selection -1}
    bind $top <Escape> {set SelectColor::_selection -2}
    bind $top <FocusOut> [subst {if {"%W" == "$top"} \
				     {set SelectColor::_selection -2}}]
    eval [list BWidget::place $top 0 0] $placement

    wm deiconify $top
    raise $top
    if {$::tcl_platform(platform) == "unix"} {
	tkwait visibility $top
	update
    }
    BWidget::SetFocusGrab $top $frame.c0

    vwait SelectColor::_selection
    BWidget::RestoreFocusGrab $top $frame.c0 destroy
    Widget::destroy $top
    if {$_selection == $count} {
	array set opts {
	    -parent -parent
	    -title  -title
	    -color  -initialcolor
	}
	if {[Widget::theme]} {
	    set native 1
	    set nativecmd [list tk_chooseColor -parent $parent]
	    foreach {key val} $args {
		if {![info exists opts($key)]} {
		    set native 0
		    break
		}
		lappend nativecmd $opts($key) $val
	    }
	    if {$native} {
		return [eval $nativecmd]
	    }
	}
	return [eval [list dialog $path] $args]
    } else {
        return [lindex $colors $_selection]
    }
}


proc SelectColor::dialog {path args} {
    variable _baseColors
    variable _userColors
    variable _widget
    variable _selection
    variable _image
    variable _hsv

    Widget::init SelectColor $path:SelectColor $args
    set top   [Dialog::create $path \
                   -title  [Widget::cget $path:SelectColor -title]  \
                   -parent [Widget::cget $path:SelectColor -parent] \
                   -separator 1 -default 0 -cancel 1 -anchor e]
    wm resizable $top 0 0
    set dlgf  [$top getframe]
    set fg    [frame $dlgf.fg]
    set desc  [list \
                   base _baseColors "Base colors" \
                   user _userColors "User colors"]
    set count 0
    foreach {type varcol defTitle} $desc {
        set col   0
        set lin   0
        set title [lindex [BWidget::getname "${type}Colors"] 0]
        if {![string length $title]} {
            set title $defTitle
        }
        set titf  [TitleFrame $fg.$type -text $title]
        set subf  [$titf getframe]
        foreach color [set $varcol] {
            set fround [frame $fg.round$count \
                            -highlightthickness 1 \
                            -relief sunken -borderwidth 2]
            set fcolor [frame $fg.color$count -width 16 -height 12 \
                            -highlightthickness 0 \
                            -relief flat -borderwidth 0 \
                            -background $color]
            pack $fcolor -in $fround
            grid $fround -in $subf -row $lin -column $col -padx 1 -pady 1

            bind $fround <ButtonPress-1> [list SelectColor::_select_rgb $count]
            bind $fcolor <ButtonPress-1> [list SelectColor::_select_rgb $count]

	    bind $fround <Double-1> \
	    	"SelectColor::_select_rgb [list $count]; [list $top] invoke 0"
	    bind $fcolor <Double-1> \
	    	"SelectColor::_select_rgb [list $count]; [list $top] invoke 0"

            incr count
            if {[incr col] == 6} {
                incr lin
                set  col 0
            }
        }
        pack $titf -anchor w -pady 2
    }
    set fround [frame $fg.round \
                    -highlightthickness 0 \
                    -relief sunken -borderwidth 2]
    set fcolor [frame $fg.color \
                    -width 50 \
                    -highlightthickness 0 \
                    -relief flat -borderwidth 0]
    pack $fcolor -in $fround -fill y -expand yes
    pack $fround -anchor e -pady 2 -fill y -expand yes

    set fd  [frame $dlgf.fd]
    set f1  [frame $fd.f1 -relief sunken -borderwidth 2]
    set f2  [frame $fd.f2 -relief sunken -borderwidth 2]
    set c1  [canvas $f1.c -width 200 -height 200 -bd 0 -highlightthickness 0]
    set c2  [canvas $f2.c -width 15  -height 200 -bd 0 -highlightthickness 0]

    for {set val 0} {$val < 40} {incr val} {
        $c2 create rectangle 0 [expr {5*$val}] 15 [expr {5*$val+5}] -tags val[expr {39-$val}]
    }
    $c2 create polygon 0 0 10 5 0 10 -fill black -outline white -tags target

    pack $c1 $c2
    pack $f1 $f2 -side left -padx 10 -anchor n

    pack $fg $fd -side left -anchor n -fill y

    bind $c1 <ButtonPress-1> [list SelectColor::_select_hue_sat %x %y]
    bind $c1 <B1-Motion>     [list SelectColor::_select_hue_sat %x %y]

    bind $c2 <ButtonPress-1> [list SelectColor::_select_value %x %y]
    bind $c2 <B1-Motion>     [list SelectColor::_select_value %x %y]

    if {![info exists _image] || [catch {image type $_image}]} {
        set _image [image create photo -width 200 -height 200]
        for {set x 0} {$x < 200} {incr x 4} {
            for {set y 0} {$y < 200} {incr y 4} {
                $_image put \
		    [eval [list format "\#%04x%04x%04x"] \
			[hsvToRgb [expr {$x/196.0}] [expr {(196-$y)/196.0}] 0.85]] \
			-to $x $y [expr {$x+4}] [expr {$y+4}]
            }
        }
    }
    $c1 create image  0 0 -anchor nw -image $_image
    $c1 create bitmap 0 0 \
        -bitmap @[file join $::BWIDGET::LIBRARY "images" "target.xbm"] \
        -anchor nw -tags target

    set _selection -1
    set _widget(fcolor) $fg
    set _widget(chs)    $c1
    set _widget(cv)     $c2
    set rgb             [winfo rgb $path [Widget::cget $path:SelectColor -color]]
    set _hsv            [eval rgbToHsv $rgb]
    _set_rgb     [eval [list format "\#%04x%04x%04x"] $rgb]
    _set_hue_sat [lindex $_hsv 0] [lindex $_hsv 1]
    _set_value   [lindex $_hsv 2]

    $top add -name ok
    $top add -name cancel
    set res [$top draw]
    if {$res == 0} {
        set color [$fg.color cget -background]
    } else {
        set color ""
    }
    destroy $top
    return $color
}

proc SelectColor::setcolor { idx color } {
    variable _userColors
    set _userColors [lreplace $_userColors $idx $idx $color]
}

proc SelectColor::_select_rgb {count} {
    variable _baseColors
    variable _userColors
    variable _selection
    variable _widget
    variable _hsv

    set frame $_widget(fcolor)
    if {$_selection >= 0} {
        $frame.round$_selection configure \
            -relief sunken -highlightthickness 1 -borderwidth 2
    }
    $frame.round$count configure \
        -relief flat -highlightthickness 2 -borderwidth 1
    focus $frame.round$count
    set _selection $count
    set bg   [$frame.color$count cget -background]
    set user [expr {$_selection-[llength $_baseColors]}]
    if {$user >= 0 &&
        [string equal \
              [winfo rgb $frame.color$_selection $bg] \
              [winfo rgb $frame.color$_selection white]]} {
        set bg [$frame.color cget -bg]
        $frame.color$_selection configure -background $bg
        set _userColors [lreplace $_userColors $user $user $bg]
    } else {
        set _hsv [eval rgbToHsv [winfo rgb $frame.color$count $bg]]
        _set_hue_sat [lindex $_hsv 0] [lindex $_hsv 1]
        _set_value   [lindex $_hsv 2]
        $frame.color configure -background $bg
    }
}


proc SelectColor::_set_rgb {rgb} {
    variable _selection
    variable _baseColors
    variable _userColors
    variable _widget

    set frame $_widget(fcolor)
    $frame.color configure -background $rgb
    set user [expr {$_selection-[llength $_baseColors]}]
    if {$user >= 0} {
        $frame.color$_selection configure -background $rgb
        set _userColors [lreplace $_userColors $user $user $rgb]
    }
}


proc SelectColor::_select_hue_sat {x y} {
    variable _widget
    variable _hsv

    if {$x < 0} {
        set x 0
    } elseif {$x > 200} {
        set x 200
    }
    if {$y < 0 } {
        set y 0
    } elseif {$y > 200} {
        set y 200
    }
    set hue  [expr {$x/200.0}]
    set sat  [expr {(200-$y)/200.0}]
    set _hsv [lreplace $_hsv 0 1 $hue $sat]
    $_widget(chs) coords target [expr {$x-9}] [expr {$y-9}]
    _draw_values $hue $sat
    _set_rgb [eval [list format "\#%04x%04x%04x"] [eval [list hsvToRgb] $_hsv]]
}


proc SelectColor::_set_hue_sat {hue sat} {
    variable _widget

    set x [expr {$hue*200-9}]
    set y [expr {(1-$sat)*200-9}]
    $_widget(chs) coords target $x $y
    _draw_values $hue $sat
}



proc SelectColor::_select_value {x y} {
    variable _widget
    variable _hsv

    if {$y < 0} {
        set y 0
    } elseif {$y > 200} {
        set y 200
    }
    $_widget(cv) coords target 0 [expr {$y-5}] 10 $y 0 [expr {$y+5}]
    set _hsv [lreplace $_hsv 2 2 [expr {(200-$y)/200.0}]]
    _set_rgb [eval [list format "\#%04x%04x%04x"] [eval [list hsvToRgb] $_hsv]]
}


proc SelectColor::_draw_values {hue sat} {
    variable _widget

    for {set val 0} {$val < 40} {incr val} {
        set l   [hsvToRgb $hue $sat [expr {$val/39.0}]]
        set col [eval [list format "\#%04x%04x%04x"] $l]
        $_widget(cv) itemconfigure val$val -fill $col -outline $col
    }
}


proc SelectColor::_set_value {value} {
    variable _widget

    set y [expr {int((1-$value)*200)}]
    $_widget(cv) coords target 0 [expr {$y-5}] 10 $y 0 [expr {$y+5}]
}


# --
#  Taken from tk8.0/demos/tcolor.tcl
# --
# The procedure below converts an HSB value to RGB.  It takes hue, saturation,
# and value components (floating-point, 0-1.0) as arguments, and returns a
# list containing RGB components (integers, 0-65535) as result.  The code
# here is a copy of the code on page 616 of "Fundamentals of Interactive
# Computer Graphics" by Foley and Van Dam.

proc SelectColor::hsvToRgb {hue sat val} {
    set v [expr {round(65535.0*$val)}]
    if {$sat == 0} {
	return [list $v $v $v]
    } else {
	set hue [expr {$hue*6.0}]
	if {$hue >= 6.0} {
	    set hue 0.0
	}
	set i [expr {int($hue)}]
	set f [expr {$hue-$i}]
	set p [expr {round(65535.0*$val*(1 - $sat))}]
        set q [expr {round(65535.0*$val*(1 - ($sat*$f)))}]
        set t [expr {round(65535.0*$val*(1 - ($sat*(1 - $f))))}]
        switch $i {
	    0 {return [list $v $t $p]}
	    1 {return [list $q $v $p]}
	    2 {return [list $p $v $t]}
	    3 {return [list $p $q $v]}
	    4 {return [list $t $p $v]}
            5 {return [list $v $p $q]}
        }
    }
}


# --
#  Taken from tk8.0/demos/tcolor.tcl
# --
# The procedure below converts an RGB value to HSB.  It takes red, green,
# and blue components (0-65535) as arguments, and returns a list containing
# HSB components (floating-point, 0-1) as result.  The code here is a copy
# of the code on page 615 of "Fundamentals of Interactive Computer Graphics"
# by Foley and Van Dam.

proc SelectColor::rgbToHsv {red green blue} {
    if {$red > $green} {
	set max $red.0
	set min $green.0
    } else {
	set max $green.0
	set min $red.0
    }
    if {$blue > $max} {
	set max $blue.0
    } else {
	if {$blue < $min} {
	    set min $blue.0
	}
    }
    set range [expr {$max-$min}]
    if {$max == 0} {
	set sat 0
    } else {
	set sat [expr {($max-$min)/$max}]
    }
    if {$sat == 0} {
	set hue 0
    } else {
	set rc [expr {($max - $red)/$range}]
	set gc [expr {($max - $green)/$range}]
	set bc [expr {($max - $blue)/$range}]
	if {$red == $max} {
	    set hue [expr {.166667*($bc - $gc)}]
	} else {
	    if {$green == $max} {
		set hue [expr {.166667*(2 + $rc - $bc)}]
	    } else {
		set hue [expr {.166667*(4 + $gc - $rc)}]
	    }
	}
	if {$hue < 0.0} {
	    set hue [expr {$hue + 1.0}]
	}
    }
    return [list $hue $sat [expr {$max/65535}]]
}

