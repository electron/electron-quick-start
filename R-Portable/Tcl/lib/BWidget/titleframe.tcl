# ------------------------------------------------------------------------------
#  titleframe.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#     - TitleFrame::create
#     - TitleFrame::configure
#     - TitleFrame::cget
#     - TitleFrame::getframe
#     - TitleFrame::_place
# ------------------------------------------------------------------------------

namespace eval TitleFrame {
    Widget::define TitleFrame titleframe

    Widget::declare TitleFrame {
        {-relief      TkResource groove 0 frame}
        {-borderwidth TkResource 2      0 frame}
        {-font        TkResource ""     0 label}
        {-foreground  TkResource ""     0 label}
        {-state       TkResource ""     0 label}
        {-background  TkResource ""     0 frame}
        {-text        String     ""     0}
        {-ipad        Int        4      0 "%d >=0"}
        {-side        Enum       left   0 {left center right}}
        {-baseline    Enum       center 0 {top center bottom}}
        {-fg          Synonym    -foreground}
        {-bg          Synonym    -background}
        {-bd          Synonym    -borderwidth}
    }

    Widget::addmap TitleFrame "" :cmd {-background {}}
    Widget::addmap TitleFrame "" .l   {
    	-background {} -foreground {} -text {} -font {}
    }
    Widget::addmap TitleFrame "" .l   {-state {}}
    Widget::addmap TitleFrame "" .p   {-background {}}
    Widget::addmap TitleFrame "" .b   {
    	-background {} -relief {} -borderwidth {}
    }
    Widget::addmap TitleFrame "" .b.p {-background {}}
    Widget::addmap TitleFrame "" .f   {-background {}}
}


# ------------------------------------------------------------------------------
#  Command TitleFrame::create
# ------------------------------------------------------------------------------
proc TitleFrame::create { path args } {
    Widget::init TitleFrame $path $args

    set frame  [eval [list frame $path] [Widget::subcget $path :cmd] \
	    -class TitleFrame -relief flat -bd 0 -highlightthickness 0]

    set padtop [eval [list frame $path.p] [Widget::subcget $path :cmd] \
	    -relief flat -borderwidth 0]
    set border [eval [list frame $path.b] [Widget::subcget $path .b] -highlightthickness 0]
    set label  [eval [list label $path.l] [Widget::subcget $path .l] \
                    -highlightthickness 0 \
                    -relief flat \
                    -bd     0 -padx 2 -pady 0]
    set padbot [eval [list frame $border.p] [Widget::subcget $path .p] \
	    -relief flat -bd 0 -highlightthickness 0]
    set frame  [eval [list frame $path.f] [Widget::subcget $path .f] \
	    -relief flat -bd 0 -highlightthickness 0]
    set height [winfo reqheight $label]

    switch [Widget::getoption $path -side] {
        left   { set relx 0.0; set x 5;  set anchor nw }
        center { set relx 0.5; set x 0;  set anchor n  }
        right  { set relx 1.0; set x -5; set anchor ne }
    }
    set bd [Widget::getoption $path -borderwidth]
    switch [Widget::getoption $path -baseline] {
        top    {
	    set y    0
	    set htop $height
	    set hbot 1
	}
        center {
	    set y    0
	    set htop [expr {$height/2}]
	    set hbot [expr {$height/2+$height%2+1}]
	}
        bottom {
	    set y    [expr {$bd+1}]
	    set htop 1
	    set hbot $height
	}
    }
    $padtop configure -height $htop
    $padbot configure -height $hbot

    set pad [Widget::getoption $path -ipad]
    pack $padbot -side top -fill x
    pack $frame  -in $border -fill both -expand yes -padx $pad -pady $pad

    pack $padtop -side top -fill x
    pack $border -fill both -expand yes

    place $label -relx $relx -x $x -anchor $anchor -y $y

    bind $label <Configure> [list TitleFrame::_place $path]
    bind $path  <Destroy>   [list Widget::destroy %W]

    return [Widget::create TitleFrame $path]
}


# ------------------------------------------------------------------------------
#  Command TitleFrame::configure
# ------------------------------------------------------------------------------
proc TitleFrame::configure { path args } {
    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -ipad pad] } {
        pack configure $path.f -padx $pad -pady $pad
    }
    if { [Widget::hasChanged $path -borderwidth val] |
         [Widget::hasChanged $path -font        val] |
         [Widget::hasChanged $path -side        val] |
         [Widget::hasChanged $path -baseline    val] } {
        _place $path
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command TitleFrame::cget
# ------------------------------------------------------------------------------
proc TitleFrame::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command TitleFrame::getframe
# ------------------------------------------------------------------------------
proc TitleFrame::getframe { path } {
    return $path.f
}


# ------------------------------------------------------------------------------
#  Command TitleFrame::_place
# ------------------------------------------------------------------------------
proc TitleFrame::_place { path } {
    set height [winfo height $path.l]
    switch [Widget::getoption $path -side] {
        left    { set relx 0.0; set x 10;  set anchor nw }
        center  { set relx 0.5; set x 0;   set anchor n  }
        right   { set relx 1.0; set x -10; set anchor ne }
    }
    set bd [Widget::getoption $path -borderwidth]
    switch [Widget::getoption $path -baseline] {
        top    { set htop $height; set hbot 1; set y 0 }
        center { set htop [expr {$height/2}]; set hbot [expr {$height/2+$height%2+1}]; set y 0 }
        bottom { set htop 1; set hbot $height; set y [expr {$bd+1}] }
    }
    $path.p   configure -height $htop
    $path.b.p configure -height $hbot

    place $path.l -relx $relx -x $x -anchor $anchor -y $y
}




