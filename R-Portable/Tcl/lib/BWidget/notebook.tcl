# ---------------------------------------------------------------------------
#  notebook.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: notebook.tcl,v 1.25.2.2 2011/04/26 14:13:24 oehhar Exp $
# ---------------------------------------------------------------------------
#  Index of commands:
#     - NoteBook::create
#     - NoteBook::configure
#     - NoteBook::cget
#     - NoteBook::compute_size
#     - NoteBook::insert
#     - NoteBook::delete
#     - NoteBook::itemconfigure
#     - NoteBook::itemcget
#     - NoteBook::bindtabs
#     - NoteBook::raise
#     - NoteBook::see
#     - NoteBook::page
#     - NoteBook::pages
#     - NoteBook::index
#     - NoteBook::getframe
#     - NoteBook::_test_page
#     - NoteBook::_itemconfigure
#     - NoteBook::_compute_width
#     - NoteBook::_get_x_page
#     - NoteBook::_xview
#     - NoteBook::_highlight
#     - NoteBook::_select
#     - NoteBook::_redraw
#     - NoteBook::_draw_page
#     - NoteBook::_draw_arrows
#     - NoteBook::_draw_area
#     - NoteBook::_resize
# ---------------------------------------------------------------------------

namespace eval NoteBook {
    Widget::define NoteBook notebook ArrowButton DynamicHelp

    namespace eval Page {
        Widget::declare NoteBook::Page {
            {-state      Enum       normal 0 {normal disabled}}
            {-createcmd  String     ""     0}
            {-raisecmd   String     ""     0}
            {-leavecmd   String     ""     0}
            {-image      TkResource ""     0 label}
            {-text       String     ""     0}
            {-foreground         String     ""     0}
            {-background         String     ""     0}
            {-activeforeground   String     ""     0}
            {-activebackground   String     ""     0}
            {-disabledforeground String     ""     0}
        }
    }

    DynamicHelp::include NoteBook::Page balloon

    Widget::bwinclude NoteBook ArrowButton .c.fg \
	    include {-foreground -background -activeforeground \
		-activebackground -disabledforeground -repeatinterval \
		-repeatdelay -borderwidth} \
	    initialize {-borderwidth 1}
    Widget::bwinclude NoteBook ArrowButton .c.fd \
	    include {-foreground -background -activeforeground \
		-activebackground -disabledforeground -repeatinterval \
		-repeatdelay -borderwidth} \
	    initialize {-borderwidth 1}

    Widget::declare NoteBook {
	{-foreground		TkResource "" 0 button}
        {-background		TkResource "" 0 button}
        {-activebackground	TkResource "" 0 button}
        {-activeforeground	TkResource "" 0 button}
        {-disabledforeground	TkResource "" 0 button}
        {-font			TkResource "" 0 button}
        {-side			Enum       top 0 {top bottom}}
        {-homogeneous		Boolean 0   0}
        {-borderwidth		Int 1   0 "%d >= 1 && %d <= 2"}
 	{-internalborderwidth	Int 10  0 "%d >= 0"}
        {-width			Int 0   0 "%d >= 0"}
        {-height		Int 0   0 "%d >= 0"}

        {-repeatdelay        BwResource ""  0 ArrowButton}
        {-repeatinterval     BwResource ""  0 ArrowButton}

        {-fg                 Synonym -foreground}
        {-bg                 Synonym -background}
        {-bd                 Synonym -borderwidth}
        {-ibd                Synonym -internalborderwidth}

	{-arcradius          Int     2     0 "%d >= 0 && %d <= 8"}
	{-tabbevelsize       Int     0     0 "%d >= 0 && %d <= 8"}
        {-tabpady            Padding {0 6} 0 "%d >= 0"}
    }

    Widget::addmap NoteBook "" .c {-background {}}

    variable _warrow 12

    bind NoteBook <Configure> [list NoteBook::_resize  %W]
    bind NoteBook <Destroy>   [list NoteBook::_destroy %W]
}


# ---------------------------------------------------------------------------
#  Command NoteBook::create
# ---------------------------------------------------------------------------
proc NoteBook::create { path args } {
    variable $path
    upvar 0  $path data

    Widget::init NoteBook $path $args

    set data(base)     0
    set data(select)   ""
    set data(pages)    {}
    set data(pages)    {}
    set data(cpt)      0
    set data(realized) 0
    set data(wpage)    0

    _compute_height $path

    # Create the canvas
    set w [expr {[Widget::cget $path -width]+4}]
    set h [expr {[Widget::cget $path -height]+$data(hpage)+4}]

    frame $path -class NoteBook -borderwidth 0 -highlightthickness 0 \
	    -relief flat
    eval [list canvas $path.c] [Widget::subcget $path .c] \
	    [list -relief flat -borderwidth 0 -highlightthickness 0 \
	    -width $w -height $h]
    pack $path.c -expand yes -fill both

    # Removing the Canvas global bindings from our canvas as
    # application specific bindings on that tag may interfere with its
    # operation here. [SF item #459033]

    set bindings [bindtags $path.c]
    set pos [lsearch -exact $bindings Canvas]
    if {$pos >= 0} {
	set bindings [lreplace $bindings $pos $pos]
    }
    bindtags $path.c $bindings

    # Create the arrow button
    eval [list ArrowButton::create $path.c.fg] [Widget::subcget $path .c.fg] \
	    [list -highlightthickness 0 -type button -dir left \
	    -armcommand [list NoteBook::_xview $path -1]]

    eval [list ArrowButton::create $path.c.fd] [Widget::subcget $path .c.fd] \
	    [list -highlightthickness 0 -type button -dir right \
	    -armcommand [list NoteBook::_xview $path 1]]

    Widget::create NoteBook $path

    set bg [Widget::cget $path -background]
    foreach {data(dbg) data(lbg)} [BWidget::get3dcolor $path $bg] {break}

    return $path
}


# ---------------------------------------------------------------------------
#  Command NoteBook::configure
# ---------------------------------------------------------------------------
proc NoteBook::configure { path args } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path $args]
    set redraw 0
    set opts [list -font -homogeneous -tabpady]
    foreach {cf ch cp} [eval Widget::hasChangedX $path $opts] {break}
    if {$cf || $ch || $cp} {
        if { $cf || $cp } {
            _compute_height $path
        }
        _compute_width $path
        set redraw 1
    }
    set chibd [Widget::hasChanged $path -internalborderwidth ibd]
    set chbg  [Widget::hasChanged $path -background bg]
    if {$chibd || $chbg} {
        foreach page $data(pages) {
            if { ! $::Widget::_theme } {
                $path.f$page configure -background $bg
            }
            $path.f$page configure -borderwidth $ibd
        }
    }

    if {$chbg} {
        set col [BWidget::get3dcolor $path $bg]
        set data(dbg)  [lindex $col 0]
        set data(lbg)  [lindex $col 1]
        set redraw 1
    }
    if { [Widget::hasChanged $path -foreground  fg] ||
         [Widget::hasChanged $path -borderwidth bd] ||
	 [Widget::hasChanged $path -arcradius radius] ||
         [Widget::hasChanged $path -tabbevelsize bevel] ||
         [Widget::hasChanged $path -side side] } {
        set redraw 1
    }
    set wc [Widget::hasChanged $path -width  w]
    set hc [Widget::hasChanged $path -height h]
    if { $wc || $hc } {
        $path.c configure \
		-width  [expr {$w + 4}] \
		-height [expr {$h + $data(hpage) + 4}]
    }
    if { $redraw } {
        _redraw $path
    }

    return $res
}


# ---------------------------------------------------------------------------
#  Command NoteBook::cget
# ---------------------------------------------------------------------------
proc NoteBook::cget { path option } {
    return [Widget::cget $path $option]
}


# ---------------------------------------------------------------------------
#  Command NoteBook::compute_size
# ---------------------------------------------------------------------------
proc NoteBook::compute_size { path } {
    variable $path
    upvar 0  $path data

    set wmax 0
    set hmax 0
    update idletasks
    foreach page $data(pages) {
        set w    [winfo reqwidth  $path.f$page]
        set h    [winfo reqheight $path.f$page]
        set wmax [expr {$w>$wmax ? $w : $wmax}]
        set hmax [expr {$h>$hmax ? $h : $hmax}]
    }
    configure $path -width $wmax -height $hmax
    # Sven... well ok so this is called twice in some cases...
    NoteBook::_redraw $path
    # Sven end
}


# ---------------------------------------------------------------------------
#  Command NoteBook::insert
# ---------------------------------------------------------------------------
proc NoteBook::insert { path index page args } {
    variable $path
    upvar 0  $path data

    if { [lsearch -exact $data(pages) $page] != -1 } {
        return -code error "page \"$page\" already exists"
    }

    set f $path.f$page
    Widget::init NoteBook::Page $f $args

    set data(pages) [linsert $data(pages) $index $page]
    # If the page doesn't exist, create it; if it does reset its bg and ibd
    if { ![winfo exists $f] } {
        if {$::Widget::_theme} {
            ttk::frame $f
        } else {
            frame $f \
                -relief      flat \
                -background  [Widget::cget $path -background] \
                -borderwidth [Widget::cget $path -internalborderwidth]
        }
        set data($page,realized) 0
    } else {
        if { ! $::Widget::_theme} {
            $f configure -background  [Widget::cget $path -background]
        }
        $f configure -borderwidth [Widget::cget $path -internalborderwidth]
    }
    _compute_height $path
    _compute_width  $path
    _draw_page $path $page 1
    _set_help  $path $page
    _redraw $path

    return $f
}


# ---------------------------------------------------------------------------
#  Command NoteBook::delete
# ---------------------------------------------------------------------------
proc NoteBook::delete { path page {destroyframe 1} } {
    variable $path
    upvar 0  $path data

    set pos [_test_page $path $page]
    set data(pages) [lreplace $data(pages) $pos $pos]
    _compute_width $path
    $path.c delete p:$page
    if { $data(select) == $page } {
        set data(select) ""
    }
    if { $pos < $data(base) } {
        incr data(base) -1
    }
    if { $destroyframe } {
        destroy $path.f$page
        unset data($page,width) data($page,realized)
    }
    _redraw $path
}


# ---------------------------------------------------------------------------
#  Command NoteBook::itemconfigure
# ---------------------------------------------------------------------------
proc NoteBook::itemconfigure { path page args } {
    _test_page $path $page
    set res [_itemconfigure $path $page $args]
    _redraw $path

    return $res
}


# ---------------------------------------------------------------------------
#  Command NoteBook::itemcget
# ---------------------------------------------------------------------------
proc NoteBook::itemcget { path page option } {
    _test_page $path $page
    return [Widget::cget $path.f$page $option]
}


# ---------------------------------------------------------------------------
#  Command NoteBook::bindtabs
# ---------------------------------------------------------------------------
proc NoteBook::bindtabs { path event script } {
    if { $script != "" } {
	append script " \[NoteBook::_get_page_name [list $path] current 1\]"
        $path.c bind "page" $event $script
    } else {
        $path.c bind "page" $event {}
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::move
# ---------------------------------------------------------------------------
proc NoteBook::move { path page index } {
    variable $path
    upvar 0  $path data

    set pos [_test_page $path $page]
    set data(pages) [linsert [lreplace $data(pages) $pos $pos] $index $page]
    _redraw $path
}


# ---------------------------------------------------------------------------
#  Command NoteBook::raise
# ---------------------------------------------------------------------------
proc NoteBook::raise { path {page ""} } {
    variable $path
    upvar 0  $path data

    if { $page != "" } {
        _test_page $path $page
        _select $path $page
    }
    return $data(select)
}


# ---------------------------------------------------------------------------
#  Command NoteBook::see
# ---------------------------------------------------------------------------
proc NoteBook::see { path page } {
    variable $path
    upvar 0  $path data

    set pos [_test_page $path $page]
    if { $pos < $data(base) } {
        set data(base) $pos
        _redraw $path
    } else {
        set w     [expr {[winfo width $path]-1}]
        set fpage [expr {[_get_x_page $path $pos] + $data($page,width) + 6}]
        set idx   $data(base)
        while { $idx < $pos && $fpage > $w } {
            set fpage [expr {$fpage - $data([lindex $data(pages) $idx],width)}]
            incr idx
        }
        if { $idx != $data(base) } {
            set data(base) $idx
            _redraw $path
        }
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::page
# ---------------------------------------------------------------------------
proc NoteBook::page { path first {last ""} } {
    variable $path
    upvar 0  $path data

    if { $last == "" } {
        return [lindex $data(pages) $first]
    } else {
        return [lrange $data(pages) $first $last]
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::pages
# ---------------------------------------------------------------------------
proc NoteBook::pages { path {first ""} {last ""}} {
    variable $path
    upvar 0  $path data

    if { ![string length $first] } {
	return $data(pages)
    }

    if { ![string length $last] } {
        return [lindex $data(pages) $first]
    } else {
        return [lrange $data(pages) $first $last]
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::index
# ---------------------------------------------------------------------------
proc NoteBook::index { path page } {
    variable $path
    upvar 0  $path data

    return [lsearch -exact $data(pages) $page]
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_destroy
# ---------------------------------------------------------------------------
proc NoteBook::_destroy { path } {
    variable $path
    upvar 0  $path data

    foreach page $data(pages) {
        Widget::destroy $path.f$page
    }
    Widget::destroy $path
    unset data
}


# ---------------------------------------------------------------------------
#  Command NoteBook::getframe
# ---------------------------------------------------------------------------
proc NoteBook::getframe { path page } {
    return $path.f$page
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_test_page
# ---------------------------------------------------------------------------
proc NoteBook::_test_page { path page } {
    variable $path
    upvar 0  $path data

    if { [set pos [lsearch -exact $data(pages) $page]] == -1 } {
        return -code error "page \"$page\" does not exists"
    }
    return $pos
}

proc NoteBook::_getoption { path page option } {
    set value [Widget::cget $path.f$page $option]
    if {![string length $value]} {
        set value [Widget::cget $path $option]
    }
    return $value
}

# ---------------------------------------------------------------------------
#  Command NoteBook::_itemconfigure
# ---------------------------------------------------------------------------
proc NoteBook::_itemconfigure { path page lres } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path.f$page $lres]
    if { [Widget::hasChanged $path.f$page -text foo] } {
        _compute_width $path
    } elseif  { [Widget::hasChanged $path.f$page -image foo] } {
        _compute_height $path
        _compute_width  $path
    }
    if { [Widget::hasChanged $path.f$page -state state] &&
         $state == "disabled" && $data(select) == $page } {
        set data(select) ""
    }
    _set_help $path $page
    return $res
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_compute_width
# ---------------------------------------------------------------------------
proc NoteBook::_compute_width { path } {
    variable $path
    upvar 0  $path data

    set wmax 0
    set wtot 0
    set hmax $data(hpage)
    set font [Widget::cget $path -font]
    if { ![info exists data(textid)] } {
        set data(textid) [$path.c create text 0 -100 -font $font -anchor nw]
    }
    set id $data(textid)
    $path.c itemconfigure $id -font $font
    foreach page $data(pages) {
        $path.c itemconfigure $id -text [Widget::cget $path.f$page -text]
	# Get the bbox for this text to determine its width, then substract
	# 6 from the width to account for canvas bbox oddness w.r.t. widths of
	# simple text.
	foreach {x1 y1 x2 y2} [$path.c bbox $id] break
	set x2 [expr {$x2 - 6}]
        set wtext [expr {$x2 - $x1 + 20}]
        if { [set img [Widget::cget $path.f$page -image]] != "" } {
            set wtext [expr {$wtext + [image width $img] + 4}]
            set himg  [expr {[image height $img] + 6}]
            if { $himg > $hmax } {
                set hmax $himg
            }
        }
        set  wmax  [expr {$wtext > $wmax ? $wtext : $wmax}]
        incr wtot  $wtext
        set  data($page,width) $wtext
    }
    if { [Widget::cget $path -homogeneous] } {
        foreach page $data(pages) {
            set data($page,width) $wmax
        }
        set wtot [expr {$wmax * [llength $data(pages)]}]
    }
    set data(hpage) $hmax
    set data(wpage) $wtot
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_compute_height
# ---------------------------------------------------------------------------
proc NoteBook::_compute_height { path } {
    variable $path
    upvar 0  $path data

    set font    [Widget::cget $path -font]
    set pady0   [Widget::_get_padding $path -tabpady 0]
    set pady1   [Widget::_get_padding $path -tabpady 1]
    set metrics [font metrics $font -linespace]
    set imgh    0
    set lines   1
    foreach page $data(pages) {
        set img  [Widget::cget $path.f$page -image]
        set text [Widget::cget $path.f$page -text]
        set len [llength [split $text \n]]
        if {$len > $lines} { set lines $len}
        if {$img != ""} {
            set h [image height $img]
            if {$h > $imgh} { set imgh $h }
        }
    }
    set height [expr {$metrics * $lines}]
    if {$imgh > $height} { set height $imgh }
    set data(hpage) [expr {$height + $pady0 + $pady1}]
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_get_x_page
# ---------------------------------------------------------------------------
proc NoteBook::_get_x_page { path pos } {
    variable _warrow
    variable $path
    upvar 0  $path data

    set base $data(base)
    # notebook tabs start flush with the left side of the notebook
    set x 0
    if { $pos < $base } {
        foreach page [lrange $data(pages) $pos [expr {$base-1}]] {
            incr x [expr {-$data($page,width)}]
        }
    } elseif { $pos > $base } {
        foreach page [lrange $data(pages) $base [expr {$pos-1}]] {
            incr x $data($page,width)
        }
    }
    return $x
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_xview
# ---------------------------------------------------------------------------
proc NoteBook::_xview { path inc } {
    variable $path
    upvar 0  $path data

    if { $inc == -1 } {
        set base [expr {$data(base)-1}]
        set dx $data([lindex $data(pages) $base],width)
    } else {
        set dx [expr {-$data([lindex $data(pages) $data(base)],width)}]
        set base [expr {$data(base)+1}]
    }

    if { $base >= 0 && $base < [llength $data(pages)] } {
        set data(base) $base
        $path.c move page $dx 0
        _draw_area   $path
        _draw_arrows $path
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_highlight
# ---------------------------------------------------------------------------
proc NoteBook::_highlight { type path page } {
    variable $path
    upvar 0  $path data

    if { [string equal [Widget::cget $path.f$page -state] "disabled"] } {
        return
    }

    switch -- $type {
        on {
            $path.c itemconfigure "$page:poly" \
		    -fill [_getoption $path $page -activebackground]
            $path.c itemconfigure "$page:text" \
		    -fill [_getoption $path $page -activeforeground]
        }
        off {
            $path.c itemconfigure "$page:poly" \
		    -fill [_getoption $path $page -background]
            $path.c itemconfigure "$page:text" \
		    -fill [_getoption $path $page -foreground]
        }
    }
}


# ---------------------------------------------------------------------------
#  Command NoteBook::_select
# ---------------------------------------------------------------------------
proc NoteBook::_select { path page } {
    variable $path
    upvar 0  $path data

    if {![string equal [Widget::cget $path.f$page -state] "normal"]} { return }

    set oldsel $data(select)

    if {[string equal $page $oldsel]} { return }

    if { ![string equal $oldsel ""] } {
	set cmd [Widget::cget $path.f$oldsel -leavecmd]
	if { ![string equal $cmd ""] } {
	    set code [catch {uplevel \#0 $cmd} res]
	    if { $code == 1 || $res == 0 } {
		return -code $code $res
	    }
	}
	set data(select) ""
	_draw_page $path $oldsel 0
    }

    set data(select) $page
    if { ![string equal $page ""] } {
	if { !$data($page,realized) } {
	    set data($page,realized) 1
	    set cmd [Widget::cget $path.f$page -createcmd]
	    if { ![string equal $cmd ""] } {
		uplevel \#0 $cmd
	    }
	}
	set cmd [Widget::cget $path.f$page -raisecmd]
	if { ![string equal $cmd ""] } {
	    uplevel \#0 $cmd
	}
	_draw_page $path $page 0
    }

    _draw_area $path
}


# -----------------------------------------------------------------------------
#  Command NoteBook::_redraw
# -----------------------------------------------------------------------------
proc NoteBook::_redraw { path } {
    variable $path
    upvar 0  $path data

    if { !$data(realized) } { return }

    _compute_height $path

    foreach page $data(pages) {
        _draw_page $path $page 0
    }
    _draw_area   $path
    _draw_arrows $path
}


# ----------------------------------------------------------------------------
#  Command NoteBook::_draw_page
# ----------------------------------------------------------------------------
proc NoteBook::_draw_page { path page create } {
    variable $path
    upvar 0  $path data

    # --- calcul des coordonnees et des couleurs de l'onglet ------------------
    set pos [lsearch -exact $data(pages) $page]
    set bg  [_getoption $path $page -background]

    # lookup the tab colors
    set fgt   $data(lbg)
    set fgb   $data(dbg)

    set h   $data(hpage)
    set xd  [_get_x_page $path $pos]
    set xf  [expr {$xd + $data($page,width)}]

    # Set the initial text offsets -- a few pixels down, centered left-to-right
    set textOffsetY [expr [Widget::_get_padding $path -tabpady 0] + 3]
    set textOffsetX 9

    # Coordinates of the tab corners are:
    #     c3        c4
    #
    # c2                c5
    #
    # c1                c6
    #
    # where
    # c1 = $xd,	  $h
    # c2 = $xd+$xBevel,	           $arcRadius+2
    # c3 = $xd+$xBevel+$arcRadius, $arcRadius
    # c4 = $xf+1-$xBevel,          $arcRadius
    # c5 = $xf+$arcRadius-$xBevel, $arcRadius+2
    # c6 = $xf+$arcRadius,         $h

    set top		2
    set arcRadius	[Widget::cget $path -arcradius]
    set xBevel		[Widget::cget $path -tabbevelsize]

    if { $data(select) != $page } {
	if { $pos == 0 } {
	    # The leftmost page is a special case -- it is drawn with its
	    # tab a little indented.  To achieve this, we incr xd.  We also
	    # decr textOffsetX, so that the text doesn't move left/right.
	    incr xd 2
	    incr textOffsetX -2
	}
    } else {
	# The selected page's text is raised higher than the others
	incr top -2
    }

    # Precompute some coord values that we use a lot
    set topPlusRadius	[expr {$top + $arcRadius}]
    set rightPlusRadius	[expr {$xf + $arcRadius}]
    set leftPlusRadius	[expr {$xd + $arcRadius}]

    # Sven
    set side [Widget::cget $path -side]
    set tabsOnBottom [string equal $side "bottom"]

    set h1 [expr {[winfo height $path]}]
    set bd [Widget::cget $path -borderwidth]
    if {$bd < 1} { set bd 1 }

    if { $tabsOnBottom } {
	# adjust to keep bottom edge in view
	incr h1 -1
	set top [expr {$top * -1}]
	set topPlusRadius [expr {$topPlusRadius * -1}]
	# Hrm... the canvas has an issue with drawing diagonal segments
	# of lines from the bottom to the top, so we have to draw this line
	# backwards (ie, lt is actually the bottom, drawn from right to left)
        set lt  [list \
		$rightPlusRadius			[expr {$h1-$h-1}] \
		[expr {$rightPlusRadius - $xBevel}]	[expr {$h1 + $topPlusRadius}] \
		[expr {$xf - $xBevel}]			[expr {$h1 + $top}] \
		[expr {$leftPlusRadius + $xBevel}]	[expr {$h1 + $top}] \
		]
        set lb  [list \
		[expr {$leftPlusRadius + $xBevel}]	[expr {$h1 + $top}] \
		[expr {$xd + $xBevel}]			[expr {$h1 + $topPlusRadius}] \
		$xd					[expr {$h1-$h-1}] \
		]
	# Because we have to do this funky reverse order thing, we have to
	# swap the top/bottom colors too.
	set tmp $fgt
	set fgt $fgb
	set fgb $tmp
    } else {
	set lt [list \
		$xd					$h \
		[expr {$xd + $xBevel}]			$topPlusRadius \
		[expr {$leftPlusRadius + $xBevel}]	$top \
		[expr {$xf + 1 - $xBevel}]		$top \
		]
	set lb [list \
		[expr {$xf + 1 - $xBevel}] 		[expr {$top + 1}] \
		[expr {$rightPlusRadius - $xBevel}]	$topPlusRadius \
		$rightPlusRadius			$h \
		]
    }

    set img [Widget::cget $path.f$page -image]

    set ytext $top
    if { $tabsOnBottom } {
	# The "+ 2" below moves the text closer to the bottom of the tab,
	# so it doesn't look so cramped.  I should be able to achieve the
	# same goal by changing the anchor of the text and using this formula:
	# ytext = $top + $h1 - $textOffsetY
	# but that doesn't quite work (I think the linespace from the text
	# gets in the way)
	incr ytext [expr {$h1 - $h + 2}]
    }
    incr ytext $textOffsetY

    set xtext [expr {$xd + $textOffsetX}]
    if { $img != "" } {
	# if there's an image, put it on the left and move the text right
	set ximg $xtext
	incr xtext [expr {[image width $img] + 2}]
    }
	
    if { $data(select) == $page } {
        set bd    [Widget::cget $path -borderwidth]
	if {$bd < 1} { set bd 1 }
        set fg    [_getoption $path $page -foreground]
    } else {
        set bd    1
        if { [Widget::cget $path.f$page -state] == "normal" } {
            set fg [_getoption $path $page -foreground]
        } else {
            set fg [_getoption $path $page -disabledforeground]
        }
    }

    # --- creation ou modification de l'onglet --------------------------------
    # Sven
    if { $create } {
	# Create the tab region
        eval [list $path.c create polygon] [concat $lt $lb] [list \
		-tags		[list page p:$page $page:poly] \
		-outline	$bg \
		-fill		$bg \
		]
        eval [list $path.c create line] $lt [list \
            -tags [list page p:$page $page:top top] -fill $fgt -width $bd]
        eval [list $path.c create line] $lb [list \
            -tags [list page p:$page $page:bot bot] -fill $fgb -width $bd]
        $path.c create text $xtext $ytext 			\
		-text	[Widget::cget $path.f$page -text]	\
		-font	[Widget::cget $path -font]		\
		-fill	$fg					\
		-anchor	nw					\
		-tags	[list page p:$page $page:text]

        $path.c bind p:$page <ButtonPress-1> \
		[list NoteBook::_select $path $page]
        $path.c bind p:$page <Enter> \
		[list NoteBook::_highlight on  $path $page]
        $path.c bind p:$page <Leave> \
		[list NoteBook::_highlight off $path $page]
    } else {
        $path.c coords "$page:text" $xtext $ytext

        $path.c itemconfigure "$page:text" \
            -text [Widget::cget $path.f$page -text] \
            -font [Widget::cget $path -font] \
            -fill $fg
    }
    eval [list $path.c coords "$page:poly"] [concat $lt $lb]
    eval [list $path.c coords "$page:top"]  $lt
    eval [list $path.c coords "$page:bot"]  $lb
    $path.c itemconfigure "$page:poly" -fill $bg  -outline $bg
    $path.c itemconfigure "$page:top"  -fill $fgt -width $bd
    $path.c itemconfigure "$page:bot"  -fill $fgb -width $bd
    
    # Sven end

    if { $img != "" } {
        # Sven
	set id [$path.c find withtag $page:img]
	if { [string equal $id ""] } {
	    set id [$path.c create image $ximg $ytext \
		    -anchor nw    \
		    -tags   [list page p:$page $page:img]]
        }
        $path.c coords $id $ximg $ytext
        $path.c itemconfigure $id -image $img
        # Sven end
    } else {
        $path.c delete $page:img
    }

    if { $data(select) == $page } {
        $path.c raise p:$page
    } elseif { $pos == 0 } {
        if { $data(select) == "" } {
            $path.c raise p:$page
        } else {
            $path.c lower p:$page p:$data(select)
        }
    } else {
        set pred [lindex $data(pages) [expr {$pos-1}]]
        if { $data(select) != $pred || $pos == 1 } {
            $path.c lower p:$page p:$pred
        } else {
            $path.c lower p:$page p:[lindex $data(pages) [expr {$pos-2}]]
        }
    }
}


# -----------------------------------------------------------------------------
#  Command NoteBook::_draw_arrows
# -----------------------------------------------------------------------------
proc NoteBook::_draw_arrows { path } {
    variable _warrow
    variable $path
    upvar 0  $path data

    set w       [expr {[winfo width $path]-1}]
    set h       [expr {$data(hpage)-1}]
    set nbpages [llength $data(pages)]
    set xl      0
    set xr      [expr {$w-$_warrow+1}]
    # Sven
    set side [Widget::cget $path -side]
    if { [string equal $side "bottom"] } {
        set h1 [expr {[winfo height $path]-1}]
        set bd [Widget::cget $path -borderwidth]
	if {$bd < 1} { set bd 1 }
        set y0 [expr {$h1 - $data(hpage) + $bd}]
    } else {
        set y0 1
    }
    # Sven end (all y positions where replaced with $y0 later)

    if { $data(base) > 0 } {
        # Sven 
        if { ![llength [$path.c find withtag "leftarrow"]] } {
            $path.c create window $xl $y0 \
                -width  $_warrow            \
                -height $h                  \
                -anchor nw                  \
                -window $path.c.fg            \
                -tags   "leftarrow"
        } else {
            $path.c coords "leftarrow" $xl $y0
            $path.c itemconfigure "leftarrow" -width $_warrow -height $h
        }
        # Sven end
    } else {
        $path.c delete "leftarrow"
    }

    if { $data(base) < $nbpages-1 &&
         $data(wpage) + [_get_x_page $path 0] + 6 > $w } {
        # Sven
        if { ![llength [$path.c find withtag "rightarrow"]] } {
            $path.c create window $xr $y0 \
                -width  $_warrow            \
                -height $h                  \
                -window $path.c.fd            \
                -anchor nw                  \
                -tags   "rightarrow"
        } else {
            $path.c coords "rightarrow" $xr $y0
            $path.c itemconfigure "rightarrow" -width $_warrow -height $h
        }
        # Sven end
    } else {
        $path.c delete "rightarrow"
    }
}


# -----------------------------------------------------------------------------
#  Command NoteBook::_draw_area
# -----------------------------------------------------------------------------
proc NoteBook::_draw_area { path } {
    variable $path
    upvar 0  $path data

    set w   [expr {[winfo width  $path] - 1}]
    set h   [expr {[winfo height $path] - 1}]
    set bd  [Widget::cget $path -borderwidth]
    if {$bd < 1} { set bd 1 }
    set x0  [expr {$bd - 1}]

    set arcRadius [Widget::cget $path -arcradius]

    # Sven
    set side [Widget::cget $path -side]
    if {"$side" == "bottom"} {
        set y0 0
        set y1 [expr {$h - $data(hpage)}]
        set yo $y1
    } else {
        set y0 $data(hpage)
        set y1 $h
        set yo [expr {$h-$y0}]
    }
    # Sven end
    set dbg $data(dbg)
    set sel $data(select)
    if {  $sel == "" } {
        set xd  [expr {$w/2}]
        set xf  $xd
        set lbg $data(dbg)
    } else {
        set xd [_get_x_page $path [lsearch -exact $data(pages) $data(select)]]
        set xf [expr {$xd + $data($sel,width) + $arcRadius + 1}]
        set lbg $data(lbg)
    }

    # Sven
    if { [llength [$path.c find withtag rect]] == 0} {
        $path.c create line $xd $y0 $x0 $y0 $x0 $y1 \
            -tags "rect toprect1" 
        $path.c create line $w $y0 $xf $y0 \
            -tags "rect toprect2"
        $path.c create line 1 $h $w $h $w $y0 \
            -tags "rect botrect"
    }
    if {"$side" == "bottom"} {
        $path.c coords "toprect1" $w $y0 $x0 $y0 $x0 $y1
        $path.c coords "toprect2" $x0 $y1 $xd $y1
        $path.c coords "botrect"  $xf $y1 $w $y1 $w $y0
        $path.c itemconfigure "toprect1" -fill $lbg -width $bd
        $path.c itemconfigure "toprect2" -fill $dbg -width $bd
        $path.c itemconfigure "botrect" -fill $dbg -width $bd
    } else {
        $path.c coords "toprect1" $xd $y0 $x0 $y0 $x0 $y1
        $path.c coords "toprect2" $w $y0 $xf $y0
        $path.c coords "botrect"  $x0 $h $w $h $w $y0
        $path.c itemconfigure "toprect1" -fill $lbg -width $bd
        $path.c itemconfigure "toprect2" -fill $lbg -width $bd
        $path.c itemconfigure "botrect" -fill $dbg -width $bd
    }
    $path.c raise "rect"
    # Sven end

    if { $sel != "" } {
        # Sven
        if { [llength [$path.c find withtag "window"]] == 0 } {
            $path.c create window 2 [expr {$y0+1}] \
                -width  [expr {$w-3}]           \
                -height [expr {$yo-3}]          \
                -anchor nw                      \
                -tags   "window"                \
                -window $path.f$sel
        }
        $path.c coords "window" 2 [expr {$y0+1}]
        $path.c itemconfigure "window"    \
            -width  [expr {$w-3}]           \
            -height [expr {$yo-3}]          \
            -window $path.f$sel
        # Sven end
    } else {
        $path.c delete "window"
    }
}


# -----------------------------------------------------------------------------
#  Command NoteBook::_resize
# -----------------------------------------------------------------------------
proc NoteBook::_resize { path } {
    variable $path
    upvar 0  $path data

    # Check if pages are fully initialized or if we are still initializing
    if { 0 < [llength $data(pages)] &&
	 ![info exists data([lindex $data(pages) end],width)] } {
	return
    }
    
    if {!$data(realized)} {
	set data(realized) 1
	if { [Widget::cget $path -width]  == 0 ||
	     [Widget::cget $path -height] == 0 } {
	    # This does an update allowing other events (resize) to enter
	    # In addition, it does a redraw, so first set the realized and
	    # then exit
	    compute_size $path
	    return
	}
    }

    NoteBook::_redraw $path
}


# Tree::_set_help --
#
#	Register dynamic help for a node in the tree.
#
# Arguments:
#	path		Tree to query
#	node		Node in the tree
#       force		Optional argument to force a reset of the help
#
# Results:
#	none
# Tree::_set_help --
#
#	Register dynamic help for a node in the tree.
#
# Arguments:
#	path		Tree to query
#	node		Node in the tree
#       force		Optional argument to force a reset of the help
#
# Results:
#	none
proc NoteBook::_set_help { path page } {
    Widget::getVariable $path help

    set item $path.f$page
    set opts [list -helptype -helptext -helpvar]
    foreach {cty ctx cv} [eval [list Widget::hasChangedX $item] $opts] break
    set text [Widget::getoption $item -helptext]

    ## If we've never set help for this item before, and text is not blank,
    ## we need to setup help.  We also need to reset help if any of the
    ## options have changed.
    if { (![info exists help($page)] && $text != "") || $cty || $ctx || $cv } {
	set help($page) 1
	set type [Widget::getoption $item -helptype]
        switch $type {
            balloon {
		DynamicHelp::register $path.c balloon p:$page $text
            }
            variable {
		set var [Widget::getoption $item -helpvar]
		DynamicHelp::register $path.c variable p:$page $var $text
            }
        }
    }
}


proc NoteBook::_get_page_name { path {item current} {tagindex end-1} } {
    return [string range [lindex [$path.c gettags $item] $tagindex] 2 end]
}
