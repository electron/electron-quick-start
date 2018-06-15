# ----------------------------------------------------------------------------
#  listbox.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: listbox.tcl,v 1.29.2.7 2012/04/12 12:46:47 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - ListBox::create
#     - ListBox::configure
#     - ListBox::cget
#     - ListBox::insert
#     - ListBox::itemconfigure
#     - ListBox::itemcget
#     - ListBox::bindText
#     - ListBox::bindImage
#     - ListBox::delete
#     - ListBox::move
#     - ListBox::reorder
#     - ListBox::selection
#     - ListBox::exists
#     - ListBox::index
#     - ListBox::item - deprecated
#     - ListBox::items
#     - ListBox::see
#     - ListBox::edit
#     - ListBox::xview
#     - ListBox::yview
#     - ListBox::_update_edit_size
#     - ListBox::_destroy
#     - ListBox::_see
#     - ListBox::_update_scrollregion
#     - ListBox::_draw_item
#     - ListBox::_redraw_items
#     - ListBox::_redraw_selection
#     - ListBox::_redraw_listbox
#     - ListBox::_redraw_idle
#     - ListBox::_resize
#     - ListBox::_init_drag_cmd
#     - ListBox::_drop_cmd
#     - ListBox::_over_cmd
#     - ListBox::_auto_scroll
#     - ListBox::_scroll
# ----------------------------------------------------------------------------

namespace eval ListBox {
    Widget::define ListBox listbox DragSite DropSite DynamicHelp

    namespace eval Item {
        Widget::declare ListBox::Item {
            {-indent     Int        0   0 "%d >= 0"}
            {-text       String     ""  0}
            {-font       String     ""  0}
            {-foreground String     ""  0}
            {-image      TkResource ""  0 label}
            {-window     String     ""  0}
            {-data       String     ""  0}

            {-fill       Synonym    -foreground}
            {-fg         Synonym    -foreground}
        }
    }

    DynamicHelp::include ListBox::Item balloon

    Widget::tkinclude ListBox canvas .c \
        remove {
            -insertwidth -insertbackground -insertborderwidth -insertofftime
            -insertontime -selectborderwidth -closeenough -confine -scrollregion
            -xscrollincrement -yscrollincrement -width -height
        } \
        initialize {
            -relief sunken -borderwidth 2 -takefocus 1
            -highlightthickness 1 -width 200
        }

    DragSite::include ListBox "LISTBOX_ITEM" 1
    DropSite::include ListBox {
        LISTBOX_ITEM {copy {} move {}}
    }

    Widget::declare ListBox {
        {-deltax           Int 10 0 "%d >= 0"}
        {-deltay           Int 15 0 "%d >= 0"}
        {-padx             Int 20 0 "%d >= 0"}
        {-foreground       TkResource "" 0 listbox}
        {-background       TkResource "" 0 listbox}
        {-selectbackground TkResource "" 0 listbox}
        {-selectforeground TkResource "" 0 listbox}
        {-font             TkResource "" 0 listbox}
        {-width            TkResource "" 0 listbox}
        {-height           TkResource "" 0 listbox}
        {-redraw           Boolean 1  0}
        {-multicolumn      Boolean 0  0}
        {-dropovermode     Flag    "wpi" 0 "wpi"}
        {-selectmode       Enum none 0 {none single multiple}}
        {-fg               Synonym -foreground}
        {-bg               Synonym -background}
        {-dropcmd          String  "ListBox::_drag_and_drop" 0}
        {-autofocus        Boolean  1  1}
        {-selectfill       Boolean  0  1}
    }

    Widget::addmap ListBox "" .c {-deltay -yscrollincrement}

    bind ListBox <FocusIn>   [list after idle {BWidget::refocus %W %W.c}]
    bind ListBox <Destroy>   [list ListBox::_destroy %W]
    bind ListBox <Configure> [list ListBox::_resize  %W]
    bind ListBoxFocus <1>    [list focus %W]
    bind ListBox <Key-Up>    [list ListBox::_keyboard_navigation %W -1]
    bind ListBox <Key-Down>  [list ListBox::_keyboard_navigation %W  1]

    variable _edit
}


# ----------------------------------------------------------------------------
#  Command ListBox::create
# ----------------------------------------------------------------------------
proc ListBox::create { path args } {
    Widget::init ListBox $path $args

    variable $path
    upvar 0  $path data

    frame $path -class ListBox -bd 0 -highlightthickness 0 -relief flat \
	-takefocus 0
    # For 8.4+ we don't want to inherit the padding
    catch {$path configure -padx 0 -pady 0}
    # widget informations
    set data(nrows) -1

    # items informations
    set data(items)    {}
    set data(selitems) {}

    # update informations
    set data(upd,level)   0
    set data(upd,afterid) ""
    set data(upd,level)   0
    set data(upd,delete)  {}

    # drag and drop informations
    set data(dnd,scroll)   ""
    set data(dnd,afterid)  ""
    set data(dnd,item)     ""

    eval [list canvas $path.c] [Widget::subcget $path .c] \
	[list -xscrollincrement 8]
    pack $path.c -expand yes -fill both

    DragSite::setdrag $path $path.c ListBox::_init_drag_cmd \
	    [Widget::cget $path -dragendcmd] 1
    DropSite::setdrop $path $path.c ListBox::_over_cmd ListBox::_drop_cmd 1

    Widget::create ListBox $path

    set w [Widget::cget $path -width]
    set h [Widget::cget $path -height]
    set dy [Widget::cget $path -deltay]
    $path.c configure -width [expr {$w*8}] -height [expr {$h*$dy}]

    # Insert $path into the canvas bindings, so that anyone binding
    # directly onto the widget will see their bindings activated when
    # the canvas has focus.
    set bindtags [bindtags $path.c]
    set bindtags [linsert $bindtags 1 $path]
    # Let any click within the canvas focus on the canvas so that
    # MouseWheel scroll events will be properly handled by the canvas.
    if {[Widget::cget $path -autofocus]} {
	lappend bindtags ListBoxFocus
	BWidget::bindMouseWheel $path.c
    }
    bindtags $path.c $bindtags

    # Add slightly modified up/down bindings to the canvas, in case
    # it gets the focus (like with -autofocus).
    bind $path.c <Key-Up> {ListBox::_keyboard_navigation [winfo parent %W] -1}
    bind $path.c <Key-Down> {ListBox::_keyboard_navigation [winfo parent %W] 1}

    _configureSelectmode $path [Widget::getoption $path -selectmode]

    return $path
}


# ----------------------------------------------------------------------------
#  Command ListBox::_configureSelectmode
# ----------------------------------------------------------------------------
# Configure the selectmode
proc ListBox::_configureSelectmode { path selectmode {previous none} } {
    # clear current binding
    switch -exact -- $previous {
        single {
            $path _bindText  <Button-1> ""
            $path _bindImage <Button-1> ""
        }
        multiple {
            $path _bindText <ButtonRelease-1>          ""
            $path _bindText <Shift-ButtonRelease-1>    ""
            $path _bindText <Control-ButtonRelease-1>  ""

            $path _bindImage <ButtonRelease-1>         ""
            $path _bindImage <Shift-ButtonRelease-1>   ""
            $path _bindImage <Control-ButtonRelease-1> ""
        }
    }
    # set new bindings
    switch -exact -- $selectmode {
        single {
            $path _bindText  <Button-1> [list ListBox::_mouse_select $path set]
            $path _bindImage <Button-1> [list ListBox::_mouse_select $path set]
            if {1 < [llength [ListBox::selection $path get]]} {
                ListBox::selection $path clear
            }
        }
        multiple {
            set cmd ListBox::_multiple_select
            $path _bindText <ButtonRelease-1>          [list $cmd $path n %x %y]
            $path _bindText <Shift-ButtonRelease-1>    [list $cmd $path s %x %y]
            $path _bindText <Control-ButtonRelease-1>  [list $cmd $path c %x %y]

            $path _bindImage <ButtonRelease-1>         [list $cmd $path n %x %y]
            $path _bindImage <Shift-ButtonRelease-1>   [list $cmd $path s %x %y]
            $path _bindImage <Control-ButtonRelease-1> [list $cmd $path c %x %y]
        }
        default {
            if {0 < [llength [ListBox::selection $path get]]} {
                ListBox::selection $path clear
            }
        }
    }
}
# ----------------------------------------------------------------------------
#  Command ListBox::configure
# ----------------------------------------------------------------------------
proc ListBox::configure { path args } {
    set selectmodePrevious [Widget::getoption $path -selectmode]
    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -selectmode selectmode] } {
        _configureSelectmode $path $selectmode $selectmodePrevious
    }

    set ch0 [expr {[Widget::hasChanged $path -deltay dy]}]
    set ch1 [expr {$ch0  |
                   [Widget::hasChanged $path -padx val]   |
                   [Widget::hasChanged $path -multicolumn val]}]

    set ch2 [expr {[Widget::hasChanged $path -selectbackground val] |
                   [Widget::hasChanged $path -selectforeground val]}]

    set redraw 0
    if { [Widget::hasChanged $path -height h] || $ch0 } {
        $path.c configure -height [expr {$h*$dy}]
        if {!$ch0} {
            set redraw 1
        }
    }
    if { [Widget::hasChanged $path -width w] } {
        $path.c configure -width [expr {$w*8}]
        set redraw 1
    }

    if { [Widget::hasChanged $path -background bg] } {
        $path.c itemconfigure box -fill $bg
    }

    if { !$redraw } {
        if { $ch1 } {
            _redraw_idle $path 2
        } elseif { $ch2 } {
            _redraw_idle $path 1
        }
    }

    if { [Widget::hasChanged $path -redraw bool] && $bool } {
        variable $path
        upvar 0  $path data
        set lvl $data(upd,level)
        set data(upd,level) 0
        _redraw_idle $path $lvl
    }
    set force [Widget::hasChanged $path -dragendcmd dragend]
    DragSite::setdrag $path $path.c ListBox::_init_drag_cmd $dragend $force
    DropSite::setdrop $path $path.c ListBox::_over_cmd ListBox::_drop_cmd

    return $res
}


# ----------------------------------------------------------------------------
#  Command ListBox::cget
# ----------------------------------------------------------------------------
proc ListBox::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command ListBox::insert
# ----------------------------------------------------------------------------
proc ListBox::insert { path index item args } {
    variable $path
    upvar 0  $path data

    set item [Widget::nextIndex $path $item]

    if {[info exists data(exists,$item)]} {
        return -code error "item \"$item\" already exists"
    }

    Widget::init ListBox::Item $path.$item $args

    set data(items) [linsert $data(items) $index $item]
    set data(exists,$item) 1
    set data(upd,create,$item) $item

    _redraw_idle $path 2
    return $item
}

# Bastien Chevreux (bach@mwgdna.com)
# The multipleinsert command performs inserts several items at once into
#  the list. It is faster than calling insert multiple times as it uses the
#  Widget::copyinit command for initializing all items after the 1st. The 
#  speedup factor is between 2 and 3 for typical usage, but could be higher
#  for inserts with many options.
#
# Syntax: path and index are as in the insert command
#	args is a list of even numbered elements where the 1st of each pair
#	corresponds to the item of 'insert' and the second to args of 'insert'.
# ----------------------------------------------------------------------------
#  Command ListBox::multipleinsert
# ----------------------------------------------------------------------------
proc ListBox::multipleinsert { path index args } {
    variable $path
    upvar 0  $path data

    # If we got only one list as arg, take the first element as args
    # This enables callers to use 
    #	$list multipleinsert index $thelist
    # instead of
    #	eval $list multipleinsert index $thelist

    if {[llength $args] == 1} {
	set args [lindex $args 0]
    }

    set count 0
    foreach {item iargs} $args {
	if {[info exists data(exists,$item)]} {
	    return -code error "item \"$item\" already exists"
	}

	if {$count==0} {
	    Widget::init ListBox::Item $path.$item $iargs
	    set firstpath $path.$item
	} else {
	    Widget::copyinit ListBox::Item $firstpath $path.$item $iargs
	}

	set data(items) [linsert $data(items) $index $item]
	set data(exists,$item) 1
	set data(upd,create,$item) $item

	incr count
    }

    _redraw_idle $path 2
    return $item
}

# ----------------------------------------------------------------------------
#  Command ListBox::itemconfigure
# ----------------------------------------------------------------------------
proc ListBox::itemconfigure { path item args } {
    variable $path
    upvar 0  $path data

    if { [lsearch -exact $data(items) $item] == -1 } {
        return -code error "item \"$item\" does not exist"
    }

    set oldind [Widget::getoption $path.$item -indent]

    set res   [Widget::configure $path.$item $args]
    set chind [Widget::hasChanged $path.$item -indent indent]
    set chw   [Widget::hasChanged $path.$item -window win]
    set chi   [Widget::hasChanged $path.$item -image  img]
    set cht   [Widget::hasChanged $path.$item -text txt]
    set chf   [Widget::hasChanged $path.$item -font fnt]
    set chfg  [Widget::hasChanged $path.$item -foreground fg]
    set idn   [$path.c find withtag n:$item]

    _set_help $path $item

    if { $idn == "" } {
        # item is not drawn yet
        _redraw_idle $path 2
        return $res
    }

    set oldb   [$path.c bbox $idn]
    set coords [$path.c coords $idn]
    set padx   [Widget::getoption $path -padx]
    set x0     [expr {[lindex $coords 0]-$padx-$oldind+$indent}]
    set y0     [lindex $coords 1]
    if { $chw || $chi } {
        # -window or -image modified
        set idi  [$path.c find withtag i:$item]
        set type [lindex [$path.c gettags $idi] 0]
        if { [string length $win] } {
            if { [string equal $type "win"] } {
                $path.c itemconfigure $idi -window $win
            } else {
                $path.c delete $idi
                $path.c create window $x0 $y0 -window $win -anchor w \
		    -tags [list win i:$item]
            }
        } elseif { [string length $img] } {
            if { [string equal $type "img"] } {
                $path.c itemconfigure $idi -image $img
            } else {
                $path.c delete $idi
                $path.c create image $x0 $y0 -image $img -anchor w \
		    -tags [list img imgbind i:$item]
            }
        } else {
            $path.c delete $idi
        }
    }

    if { $cht || $chf || $chfg } {
        # -text or -font modified, or -foreground modified
        set fnt [_getoption $path $item -font]
        set fg  [_getoption $path $item -foreground]
        $path.c itemconfigure $idn -text $txt -font $fnt -fill $fg
        _redraw_idle $path 1
    }

    if { $chind } {
        # -indent modified
        $path.c coords $idn [expr {$x0+$padx}] $y0
        $path.c coords i:$item $x0 $y0
        _redraw_idle $path 1
    }

    if { [Widget::getoption $path -multicolumn] && ($cht || $chf || $chind) } {
        set bbox [$path.c bbox $idn]
        if { [lindex $bbox 2] > [lindex $oldb 2] } {
            _redraw_idle $path 2
        }
    }

    return $res
}


# ----------------------------------------------------------------------------
#  Command ListBox::itemcget
# ----------------------------------------------------------------------------
proc ListBox::itemcget { path item option } {
    return [Widget::cget $path.$item $option]
}


# ----------------------------------------------------------------------------
#  Command ListBox::_bindText
# ----------------------------------------------------------------------------
proc ListBox::_bindText { path event script {tag click} } {
    if { $script != "" } {
        set map [list %W $path]
        set script [string map $map $script]
	append script " \[ListBox::_get_current [list $path]\]"
    }
    $path.c bind $tag $event $script
}

# ----------------------------------------------------------------------------
#  Command ListBox::bindText
# ----------------------------------------------------------------------------
proc ListBox::bindText { path event script } {
    _bindText $path $event $script clickbind
}

# ----------------------------------------------------------------------------
#  Command ListBox::_bindImage
# ----------------------------------------------------------------------------
proc ListBox::_bindImage { path event script {tag img} } {
    if { $script != "" } {
        set map [list %W $path]
        set script [string map $map $script]
	append script " \[ListBox::_get_current [list $path]\]"
    }
    $path.c bind $tag $event $script
}

# ----------------------------------------------------------------------------
#  Command ListBox::bindImage
# ----------------------------------------------------------------------------
proc ListBox::bindImage { path event script } {
    _bindImage $path $event $script imgbind
}

# ----------------------------------------------------------------------------
#  Command ListBox::delete
# ----------------------------------------------------------------------------
proc ListBox::delete { path args } {
    variable $path
    upvar 0  $path data
    Widget::getVariable $path help

    foreach litems $args {
        foreach item $litems {
            set idx [lsearch -exact $data(items) $item]
            if { $idx != -1 } {
                set data(items) [lreplace $data(items) $idx $idx]
                array unset help $item
                Widget::destroy $path.$item
		if { [info exists data(exists,$item)] } {
		    unset data(exists,$item)
		}
                if { [info exists data(upd,create,$item)] } {
                    unset data(upd,create,$item)
                } else {
                    lappend data(upd,delete) $item
                }
            }
        }
    }

    set sel $data(selitems)
    set data(selitems) {}
    eval [list selection $path set] $sel
    _redraw_idle $path 2
}


# ----------------------------------------------------------------------------
#  Command ListBox::move
# ----------------------------------------------------------------------------
proc ListBox::move { path item index } {
    variable $path
    upvar 0  $path data

    if { [set idx [lsearch -exact $data(items) $item]] == -1 } {
        return -code error "item \"$item\" does not exist"
    }

    set data(items) [linsert [lreplace $data(items) $idx $idx] $index $item]

    _redraw_idle $path 2
}


# ----------------------------------------------------------------------------
#  Command ListBox::reorder
# ----------------------------------------------------------------------------
proc ListBox::reorder { path neworder } {
    variable $path
    upvar 0  $path data

    set data(items) [BWidget::lreorder $data(items) $neworder]
    _redraw_idle $path 2
}


# ----------------------------------------------------------------------------
#  Command ListBox::selection
# ----------------------------------------------------------------------------
proc ListBox::selection { path cmd args } {
    variable $path
    upvar 0  $path data

    set oldsel $data(selitems);
    switch -- $cmd {
        set {
            set data(selitems) {}
            foreach item $args {
                if { [lsearch -exact $data(selitems) $item] == -1 } {
                    if { [lsearch -exact $data(items) $item] != -1 } {
                        lappend data(selitems) $item
                    }
                }
            }
        }
        add {
            foreach item $args {
                if { [lsearch -exact $data(selitems) $item] == -1 } {
                    if { [lsearch -exact $data(items) $item] != -1 } {
                        lappend data(selitems) $item
                    }
                }
            }
        }
        remove {
            foreach item $args {
                if { [set idx [lsearch -exact $data(selitems) $item]] != -1 } {
                    set data(selitems) [lreplace $data(selitems) $idx $idx]
                }
            }
        }
        clear {
            set data(selitems) {}
        }
        get {
            return $data(selitems)
        }
        includes {
            return [expr {[lsearch -exact $data(selitems) $args] != -1}]
        }
        default {
            return
        }
    }
    if {[string compare $oldsel $data(selitems)]} {
        _redraw_idle $path 1
    }
    return;
}


# ----------------------------------------------------------------------------
#  Command ListBox::exists
# ----------------------------------------------------------------------------
proc ListBox::exists { path item } {
    variable $path
    upvar 0  $path data

    return [expr {[lsearch -exact $data(items) $item] != -1}]
}


# ----------------------------------------------------------------------------
#  Command ListBox::index
# ----------------------------------------------------------------------------
proc ListBox::index { path item } {
    variable $path
    upvar 0  $path data
    if {[string equal $item "active"]} { return [$path selection get] }
    return [lsearch -exact $data(items) $item]
}


# ----------------------------------------------------------------------------
#  ListBox::find
#     Returns the item given a position.
#  findInfo     @x,y ?confine?
#               lineNumber
# ----------------------------------------------------------------------------
proc ListBox::find {path findInfo {confine ""}} {
    variable $path
    upvar 0  $path widgetData

    if {[regexp -- {^@([0-9]+),([0-9]+)$} $findInfo match x y]} {
        set x [$path.c canvasx $x]
        set y [$path.c canvasy $y]
    } elseif {[regexp -- {^[0-9]+$} $findInfo lineNumber]} {
        set dy [Widget::getoption $path -deltay]
        set y  [expr {$dy*($lineNumber+0.5)}]
        set confine ""
    } else {
        return -code error "invalid find spec \"$findInfo\""
    }

    set found 0
    set xi    0
    foreach xs $widgetData(xlist) {
        if {$x <= $xs} {
            foreach id [$path.c find overlapping $xi $y $xs $y] {
                set ltags [$path.c gettags $id]
                set item  [lindex $ltags 0]
                if { [string equal $item "item"] ||
                     [string equal $item "img"]  ||
                     [string equal $item "win"] } {
                    # item is the label or image/window of the node
                    set item [ListBox::_get_node_name $path $id]
                    set found 1
                    break
                }
            }
            break
        }
        set  xi  $xs
    }

    if {$found} {
        if {[string equal $confine "confine"]} {
            # test if x stand inside node bbox
            set xi [expr {[lindex [$path.c coords n:$item] 0]-[Widget::getoption $path -padx]}]
            set xs [lindex [$path.c bbox n:$item] 2]
            if {$x >= $xi && $x <= $xs} {
                return $item
            }
        } else {
            return $item
        }
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command ListBox::item - deprecated
# ----------------------------------------------------------------------------
proc ListBox::item { path first {last ""} } {
    variable $path
    upvar 0  $path data

    if { ![string length $last] } {
        return [lindex $data(items) $first]
    } else {
        return [lrange $data(items) $first $last]
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::items
# ----------------------------------------------------------------------------
proc ListBox::items { path {first ""} {last ""}} {
    variable $path
    upvar 0  $path data

    if { ![string length $first] } {
	return $data(items)
    }

    if { ![string length $last] } {
        return [lindex $data(items) $first]
    } else {
        return [lrange $data(items) $first $last]
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::see
# ----------------------------------------------------------------------------
proc ListBox::see { path item } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] && $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
        _redraw_listbox $path
    }
    set idn [$path.c find withtag n:$item]
    if { $idn != "" } {
        set idi [$path.c find withtag i:$item]
        if { $idi == "" } { set idi $idn }
        ListBox::_see $path $idn right
        ListBox::_see $path $idi left
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::edit
# ----------------------------------------------------------------------------
proc ListBox::edit { path item text {verifycmd ""} {clickres 0} {select 1}} {
    variable _edit
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] && $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
        _redraw_listbox $path
    }
    set idn [$path.c find withtag n:$item]
    if { $idn != "" } {
        ListBox::_see $path $idn right
        ListBox::_see $path $idn left

        set oldfg  [$path.c itemcget $idn -fill]
        set sbg    [Widget::getoption $path -selectbackground]
        set coords [$path.c coords $idn]
        set x      [lindex $coords 0]
        set y      [lindex $coords 1]
        set bd     [expr {[$path.c cget -borderwidth]+[$path.c cget -highlightthickness]}]
        set w      [expr {[winfo width $path] - 2*$bd}]
        set wmax   [expr {[$path.c canvasx $w]-$x}]

	$path.c itemconfigure $idn    -fill [Widget::getoption $path -background]
        $path.c itemconfigure s:$item -fill {} -outline {}

        set _edit(text) $text
        set _edit(wait) 0

        set frame  [frame $path.edit \
                        -relief flat -borderwidth 0 -highlightthickness 0 \
                        -background [Widget::getoption $path -background]]
        set ent    [entry $frame.edit \
                        -width              0     \
                        -relief             solid \
                        -borderwidth        1     \
                        -highlightthickness 0     \
                        -foreground         [_getoption $path $item -foreground] \
                        -background         [Widget::getoption $path -background] \
                        -selectforeground   [Widget::getoption $path -selectforeground] \
                        -selectbackground   $sbg  \
                        -font               [_getoption $path $item -font] \
                        -textvariable       ListBox::_edit(text)]
        pack $ent -ipadx 8 -anchor w

        set idw [$path.c create window $x $y -window $frame -anchor w]
        trace variable ListBox::_edit(text) w [list ListBox::_update_edit_size $path $ent $idw $wmax]
        tkwait visibility $ent
        grab  $frame
        BWidget::focus set $ent
        _update_edit_size $path $ent $idw $wmax
        update
        if { $select } {
            $ent selection range 0 end
            $ent icursor end
            $ent xview end
        }

        bindtags $ent [list $ent Entry]
        bind $ent <Escape> {set ListBox::_edit(wait) 0}
        bind $ent <Return> {set ListBox::_edit(wait) 1}
	if { $clickres == 0 || $clickres == 1 } {
	    bind $frame <Button>  [list set ListBox::_edit(wait) $clickres]
	}

        set ok 0
        while { !$ok } {
            tkwait variable ListBox::_edit(wait)
            if { !$_edit(wait) || [llength $verifycmd]==0 ||
                 [uplevel \#0 $verifycmd [list $_edit(text)]] } {
                set ok 1
            }
        }
        trace vdelete ListBox::_edit(text) w [list ListBox::_update_edit_size $path $ent $idw $wmax]
        grab release $frame
        BWidget::focus release $ent
        destroy $frame
        $path.c delete $idw
        $path.c itemconfigure $idn    -fill $oldfg
        $path.c itemconfigure s:$item -fill $sbg -outline $sbg

        if { $_edit(wait) } {
            return $_edit(text)
        }
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command ListBox::xview
# ----------------------------------------------------------------------------
proc ListBox::xview { path args } {
    return [eval [linsert $args 0 $path.c xview]]
}


# ----------------------------------------------------------------------------
#  Command ListBox::yview
# ----------------------------------------------------------------------------
proc ListBox::yview { path args } {
    return [eval [linsert $args 0 $path.c yview]]
}


proc ListBox::getcanvas { path } {
    return $path.c
}


proc ListBox::curselection { path } {
    return [$path selection get]
}


# ----------------------------------------------------------------------------
#  Command ListBox::_update_edit_size
# ----------------------------------------------------------------------------
proc ListBox::_update_edit_size { path entry idw wmax args } {
    set entw [winfo reqwidth $entry]
    if { $entw >= $wmax } {
        $path.c itemconfigure $idw -width $wmax
    } else {
        $path.c itemconfigure $idw -width 0
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_getoption
#     Returns the value of option for node. If empty, returned value is those
#  of the ListBox.
# ----------------------------------------------------------------------------
proc ListBox::_getoption { path item option } {
    set value [Widget::getoption $path.$item $option]
    if {![string length $value]} {
        set value [Widget::getoption $path $option]
    }
    return $value
}


# ----------------------------------------------------------------------------
#  Command ListBox::_destroy
# ----------------------------------------------------------------------------
proc ListBox::_destroy { path } {
    variable $path
    upvar 0  $path data

    if { $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
    }
    if { $data(dnd,afterid) != "" } {
        after cancel $data(dnd,afterid)
    }
    foreach item $data(items) {
        Widget::destroy $path.$item
    }

    Widget::destroy $path
    unset data
}


# ----------------------------------------------------------------------------
#  Command ListBox::_see
# ----------------------------------------------------------------------------
proc ListBox::_see { path idn side } {
    set bbox [$path.c bbox $idn]
    set scrl [$path.c cget -scrollregion]

    set ymax [lindex $scrl 3]
    set dy   [$path.c cget -yscrollincrement]
    set yv   [$path.c yview]
    set yv0  [expr {round([lindex $yv 0]*$ymax/$dy)}]
    set yv1  [expr {round([lindex $yv 1]*$ymax/$dy)}]
    set y    [expr {int([lindex [$path.c coords $idn] 1]/$dy)}]
    if { $y < $yv0 } {
        $path.c yview scroll [expr {$y-$yv0}] units
    } elseif { $y >= $yv1 } {
        $path.c yview scroll [expr {$y-$yv1+1}] units
    }

    set xmax [lindex $scrl 2]
    set dx   [$path.c cget -xscrollincrement]
    set xv   [$path.c xview]
    if { [string equal $side "right"] } {
        set xv1 [expr {round([lindex $xv 1]*$xmax/$dx)}]
        set x1  [expr {int([lindex $bbox 2]/$dx)}]
        if { $x1 >= $xv1 } {
            $path.c xview scroll [expr {$x1-$xv1+1}] units
        }
    } else {
        set xv0 [expr {round([lindex $xv 0]*$xmax/$dx)}]
        set x0  [expr {int([lindex $bbox 0]/$dx)}]
        if { $x0 < $xv0 } {
            $path.c xview scroll [expr {$x0-$xv0}] units
        }
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_update_scrollregion
# ----------------------------------------------------------------------------
proc ListBox::_update_scrollregion { path } {
    set bd   [$path.c cget -borderwidth]
    set ht   [$path.c cget -highlightthickness]
    set bd   [expr {2*($bd + $ht)}]
    set w    [expr {[winfo width  $path] - $bd}]
    set h    [expr {[winfo height $path] - $bd}]
    set xinc [$path.c cget -xscrollincrement]
    set yinc [$path.c cget -yscrollincrement]
    set bbox [$path.c bbox item win img]
    if { [llength $bbox] } {
        set xs [lindex $bbox 2]
        set ys [lindex $bbox 3]

        if { $w < $xs } {
            set w [expr {$xs + $w % $xinc}]
        }
        if { $h < $ys } {
            set h [expr {$ys + $h % $yinc}]
        }
    }

    $path.c configure -scrollregion [list 0 0 $w $h]
}


proc ListBox::_update_select_fill { path } {
    variable $path
    upvar 0  $path data

    set width [winfo width $path]

    foreach item $data(items) {
        set bbox [$path.c bbox n:$item]
        set bbox [list 0 [lindex $bbox 1] $width [lindex $bbox 3]]
        $path.c coords b:$item $bbox
    }

    _redraw_selection $path
}


# ----------------------------------------------------------------------------
#  Command ListBox::_draw_item
# ----------------------------------------------------------------------------
proc ListBox::_draw_item {path item x0 x1 y bg selfill multi ww} {
    set indent  [Widget::getoption $path.$item -indent]
    set i [$path.c create text [expr {$x1+$indent}] $y \
        -text   [Widget::getoption $path.$item -text] \
        -fill   [_getoption        $path $item -foreground] \
        -font   [_getoption        $path $item -font] \
        -anchor w \
        -tags   [list item n:$item click clickbind]]

    if { $selfill && !$multi } {
        set bbox  [$path.c bbox n:$item]
        set bbox  [list 0 [lindex $bbox 1] $ww [lindex $bbox 3]]
        set tags  [list box b:$item click clickbind]
        $path.c create rect $bbox -fill $bg -width 0 -tags $tags
        $path.c raise $i
    }

    if { [set win [Widget::getoption $path.$item -window]] != "" } {
        $path.c create window [expr {$x0+$indent}] $y \
            -window $win -anchor w -tags [list win i:$item]
    } elseif { [set img [Widget::getoption $path.$item -image]] != "" } {
        $path.c create image [expr {$x0+$indent}] $y \
            -image $img -anchor w -tags [list img imgbind i:$item]
    }

    _set_help $path $item
}


# ----------------------------------------------------------------------------
#  Command ListBox::_redraw_items
# ----------------------------------------------------------------------------
proc ListBox::_redraw_items { path } {
    variable $path
    upvar 0  $path data

    set cursor [$path.c cget -cursor]
    $path.c configure -cursor watch
    update idletasks ; # make sure watch cursor is reflected
    set dx   [Widget::getoption $path -deltax]
    set dy   [Widget::getoption $path -deltay]
    set padx [Widget::getoption $path -padx]
    set y0   [expr {$dy/2}]
    # Changed from 4 to 2 to make highlight work and look nice for listbox with image as well
    set x0   2
    set x1   [expr {$x0+$padx}]
    set nitem 0
    set width 0
    set drawn {}
    set data(xlist) {}
    if { [Widget::cget $path -multicolumn] } {
        set nrows $data(nrows)
    } else {
        set nrows [llength $data(items)]
    }
    foreach item $data(upd,delete) {
        $path.c delete i:$item n:$item s:$item b:$item
    }
    # Pass these to _draw_item so it doesn't have to request them
    # for each item.
    set bg      [Widget::cget $path -background]
    set selfill [Widget::cget $path -selectfill]
    set multi   [Widget::cget $path -multicolumn]
    set ww      [winfo width $path]
    foreach item $data(items) {
        if { [info exists data(upd,create,$item)] } {
            _draw_item $path $item $x0 $x1 $y0 $bg $selfill $multi $ww
            unset data(upd,create,$item)
        } else {
            set indent [Widget::getoption $path.$item -indent]
            $path.c coords n:$item [expr {$x1+$indent}] $y0
            $path.c coords i:$item [expr {$x0+$indent}] $y0
        }
	set font [_getoption $path $item -font]
	set text [Widget::getoption $path.$item -text]
	set tw [font measure $font $text]
	if {$tw > $width} { set width $tw }
        incr y0 $dy
        incr nitem
        lappend drawn n:$item
        if { $nitem == $nrows } {
	    set x2    [expr {$x1 + $width}]
            set y0    [expr {$dy/2}]
            set drawn {}
            set x0    [expr {$x2+$dx}]
            set x1    [expr {$x0+$padx}]
            set nitem 0
            lappend data(xlist) $x2
	    set width 0
        }
    }
    if { $nitem && $nitem < $nrows } {
        lappend data(xlist) [expr {$x1 + $width}]
    }
    set data(upd,delete) {}
    $path.c configure -cursor $cursor
}


# ----------------------------------------------------------------------------
#  Command ListBox::_redraw_selection
# ----------------------------------------------------------------------------
proc ListBox::_redraw_selection { path } {
    variable $path
    upvar 0  $path data

    set selbg   [Widget::getoption $path -selectbackground]
    set selfg   [Widget::getoption $path -selectforeground]
    set selfill [Widget::getoption $path -selectfill]
    set multi   [Widget::getoption $path -multicolumn]
    foreach id [$path.c find withtag sel] {
        set item [ListBox::_get_node_name $path $id]
        if {-1 == [lsearch -exact $data(upd,delete) $item]} {
            $path.c itemconfigure "n:$item" \
                -fill [_getoption $path $item -foreground]
        }
    }
    $path.c delete sel
    if {$selfill && !$multi} {
	# cache window width for use below
	set width [winfo width $path]
    }
    foreach item $data(selitems) {
        set bbox [$path.c bbox "n:$item"]
        if { [llength $bbox] } {
            set imgbox [$path.c bbox i:$item]
            lassign $bbox x0 y0 x1 y1;
            if {[string compare "" $imgbox]} {
                # image may exist and may be heigher than text!
                lassign $imgbox ix0 iy0 ix1 iy1;
                set bbox [list $x0 [expr {min($iy0,$y0)}] $x1 [expr {max($iy1,$y1)}]];
            } else {
                set bbox [list $x0 [lindex $bbox 1] $x1 [lindex $bbox 3]]
            }
	    if { $selfill && !$multi } {
		# With -selectfill, make box occupy full width of widget
		set bbox [list 0 [lindex $bbox 1] $width [lindex $bbox 3]]
	    }
            set tags [list sel s:$item click clickbind]
            set id [$path.c create rectangle $bbox \
                -fill $selbg -outline $selbg -tags $tags]
	    if {$selfg != ""} {
		# Don't allow an empty fill - that would be transparent
		$path.c itemconfigure "n:$item" -fill $selfg
	    }
            $path.c lower $id
            $path.c lower b:$item
        }
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_redraw_listbox
# ----------------------------------------------------------------------------
proc ListBox::_redraw_listbox { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] } {
        if { $data(upd,level) == 2 } {
            _redraw_items $path
        }
        _redraw_selection $path
        _update_scrollregion $path
        if {[Widget::cget $path -selectfill]} {
            _update_select_fill $path
        }
        set data(upd,level)   0
        set data(upd,afterid) ""
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_redraw_idle
# ----------------------------------------------------------------------------
proc ListBox::_redraw_idle { path level } {
    variable $path
    upvar 0  $path data

    if { $data(nrows) != -1 } {
        # widget is realized
        if { [Widget::getoption $path -redraw] && $data(upd,afterid) == "" } {
            set data(upd,afterid) \
		[after idle [list ListBox::_redraw_listbox $path]]
        }
    }
    if { $level > $data(upd,level) } {
        set data(upd,level) $level
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command ListBox::_resize
# ----------------------------------------------------------------------------
proc ListBox::_resize { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -multicolumn] } {
        set bd    [expr {[$path.c cget -borderwidth]+[$path.c cget -highlightthickness]}]
        set h     [expr {[winfo height $path] - 2*$bd}]
        set nrows [expr {$h/[$path.c cget -yscrollincrement]}]
        if { $nrows == 0 } {
            set nrows 1
        }
        if { $nrows != $data(nrows) } {
            set data(nrows) $nrows
            _redraw_idle $path 2
        } else {
            _update_scrollregion $path
        }
    } elseif { $data(nrows) == -1 } {
        # first Configure event
        set data(nrows) 0
        ListBox::_redraw_listbox $path
        if {[Widget::cget $path -selectfill]} {
            _update_select_fill $path
        }
    } else {
        if {[Widget::cget $path -selectfill]} {
            _update_select_fill $path
        }

        _update_scrollregion $path
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_init_drag_cmd
# ----------------------------------------------------------------------------
proc ListBox::_init_drag_cmd { path X Y top } {
    set path [winfo parent $path]
    set ltags [$path.c gettags current]
    set item  [lindex $ltags 0]
    if { [string equal $item "item"] ||
         [string equal $item "img"]  ||
         [string equal $item "win"] } {
        set item [ListBox::_get_node_name $path]
        if {[llength [set cmd [Widget::getoption $path -draginitcmd]]]} {
            return [uplevel \#0 $cmd [list $path $item $top]]
        }
        if { [set type [Widget::getoption $path -dragtype]] == "" } {
            set type "LISTBOX_ITEM"
        }
        if { [set img [Widget::getoption $path.$item -image]] != "" } {
            pack [label $top.l -image $img -padx 0 -pady 0]
        }
        return [list $type {copy move link} $item]
    }
    return {}
}


# ----------------------------------------------------------------------------
#  Command ListBox::_drop_cmd
# ----------------------------------------------------------------------------
proc ListBox::_drop_cmd { path source X Y op type dnddata } {
    set path [winfo parent $path]
    variable $path
    upvar 0  $path data

    if { [string length $data(dnd,afterid)] } {
        after cancel $data(dnd,afterid)
        set data(dnd,afterid) ""
    }
    $path.c delete drop
    set data(dnd,scroll) ""
    if { [llength $data(dnd,item)] || ![llength $data(items)] } {
        if {[llength [set cmd [Widget::getoption $path -dropcmd]]]} {
            return [uplevel \#0 $cmd [list $path $source $data(dnd,item) $op $type $dnddata]]
        }
    }
    return 0
}


# ----------------------------------------------------------------------------
#  Command ListBox::_over_cmd
# ----------------------------------------------------------------------------
proc ListBox::_over_cmd { path source event X Y op type dnddata } {
    set path [winfo parent $path]
    variable $path
    upvar 0  $path data

    if { [string equal $event "leave"] } {
        # we leave the window listbox
        $path.c delete drop
        if { [string length $data(dnd,afterid)] } {
            after cancel $data(dnd,afterid)
            set data(dnd,afterid) ""
        }
        set data(dnd,scroll) ""
        return 0
    }

    if { [string equal $event "enter"] } {
        # we enter the window listbox - dnd data initialization
        set mode [Widget::getoption $path -dropovermode]
        set data(dnd,mode) 0
        foreach c {w p i} {
            set data(dnd,mode) [expr {($data(dnd,mode) << 1) | ([string first $c $mode] != -1)}]
        }
    }

    set x [expr {$X-[winfo rootx $path]}]
    set y [expr {$Y-[winfo rooty $path]}]
    $path.c delete drop
    set data(dnd,item) ""

    # test for auto-scroll unless mode is widget only
    if { $data(dnd,mode) != 4 && [_auto_scroll $path $x $y] != "" } {
        return 2
    }

    if { $data(dnd,mode) & 4 } {
        # dropovermode includes widget
        set target [list widget]
        set vmode  4
    } else {
        set target [list ""]
        set vmode  0
    }
    if { ($data(dnd,mode) & 2) && ![llength $data(items)] } {
        # dropovermode includes position and listbox is empty
        lappend target "" 0
        set vmode [expr {$vmode | 2}]
    }

    if { ($data(dnd,mode) & 3) && [llength $data(items)]} {
        # dropovermode includes item or position
        # we extract the box (xi,yi,xs,ys) where we can find item around x,y
        set len  [llength $data(items)]
        set xc   [$path.c canvasx $x]
        set yc   [$path.c canvasy $y]
        set dy   [$path.c cget -yscrollincrement]
        set line [expr {int($yc/$dy)}]
        set yi   [expr {$line*$dy}]
        set ys   [expr {$yi+$dy}]
        set xi   0
        set pos  $line
        if { [Widget::getoption $path -multicolumn] } {
            set nrows $data(nrows)
        } else {
            set nrows $len
        }
        if { $line < $nrows } {
            foreach xs $data(xlist) {
                if { $xc <= $xs } {
                    break
                }
                set  xi  $xs
                incr pos $nrows
            }
            if { $pos < $len } {
                set item [lindex $data(items) $pos]
                set xi   [expr {[lindex [$path.c coords n:$item] 0]-[Widget::getoption $path -padx]-1}]
                if { $data(dnd,mode) & 1 } {
                    # dropovermode includes item
                    lappend target $item
                    set vmode [expr {$vmode | 1}]
                } else {
                    lappend target ""
                }

                if { $data(dnd,mode) & 2 } {
                    # dropovermode includes position
                    if { $yc >= $yi+$dy/2 } {
                        # position is after $item
                        incr pos
                        set yl $ys
                    } else {
                        # position is before $item
                        set yl $yi
                    }
                    lappend target $pos
                    set vmode [expr {$vmode | 2}]
                } else {
                    lappend target ""
                }
            } else {
                lappend target "" ""
            }
        } else {
            lappend target "" ""
        }

        if { ($vmode & 3) == 3 } {
            # result have both item and position
            # we compute what is the preferred method
            if { $yc-$yi <= 3 || $ys-$yc <= 3 } {
                lappend target "position"
            } else {
                lappend target "item"
            }
        }
    }

    if {$vmode && [llength [set cmd [Widget::getoption $path -dropovercmd]]]} {
        # user-defined dropover command
        set res   [uplevel \#0 $cmd [list $source $target $op $type $dnddata]]
        set code  [lindex $res 0]
        set vmode 0
        if {$code & 1} {
            # update vmode
            switch -exact -- [lindex $res 1] {
                item     {set vmode 1}
                position {set vmode 2}
                widget   {set vmode 4}
            }
        }
    } else {
        if { ($vmode & 3) == 3 } {
            # result have both item and position
            # we choose the preferred method
            if { [string equal [lindex $target 3] "position"] } {
                set vmode [expr {$vmode & ~1}]
            } else {
                set vmode [expr {$vmode & ~2}]
            }
        }

        if { $data(dnd,mode) == 4 || $data(dnd,mode) == 0 } {
            # dropovermode is widget or empty - recall is not necessary
            set code 1
        } else {
            set code 3
        }
    }

    # draw dnd visual following vmode
    if {[llength $data(items)]} {
        if { $vmode & 1 } {
            set data(dnd,item) [list "item" [lindex $target 1]]
            $path.c create rectangle $xi $yi $xs $ys -tags drop
        } elseif { $vmode & 2 } {
            set data(dnd,item) [concat "position" [lindex $target 2]]
            $path.c create line $xi $yl $xs $yl -tags drop
        } elseif { $vmode & 4 } {
            set data(dnd,item) [list "widget"]
        } else {
            set code [expr {$code & 2}]
        }
    }

    if { $code & 1 } {
        DropSite::setcursor based_arrow_down
    } else {
        DropSite::setcursor dot
    }
    return $code
}


# ----------------------------------------------------------------------------
#  Command ListBox::_auto_scroll
# ----------------------------------------------------------------------------
proc ListBox::_auto_scroll { path x y } {
    variable $path
    upvar 0  $path data

    set xmax   [winfo width  $path]
    set ymax   [winfo height $path]
    set scroll {}
    if { $y <= 6 } {
        if { [lindex [$path.c yview] 0] > 0 } {
            set scroll [list yview -1]
            DropSite::setcursor sb_up_arrow
        }
    } elseif { $y >= $ymax-6 } {
        if { [lindex [$path.c yview] 1] < 1 } {
            set scroll [list yview 1]
            DropSite::setcursor sb_down_arrow
        }
    } elseif { $x <= 6 } {
        if { [lindex [$path.c xview] 0] > 0 } {
            set scroll [list xview -1]
            DropSite::setcursor sb_left_arrow
        }
    } elseif { $x >= $xmax-6 } {
        if { [lindex [$path.c xview] 1] < 1 } {
            set scroll [list xview 1]
            DropSite::setcursor sb_right_arrow
        }
    }

    if { [string length $data(dnd,afterid)] && ![string equal $data(dnd,scroll) $scroll] } {
        after cancel $data(dnd,afterid)
        set data(dnd,afterid) ""
    }

    set data(dnd,scroll) $scroll
    if { [llength $scroll] && ![string length $data(dnd,afterid)] } {
        set data(dnd,afterid) [after 200 [list ListBox::_scroll $path $scroll]]
    }
    return $data(dnd,afterid)

}

# -----------------------------------------------------------------------------
#  Command ListBox::_multiple_select
# -----------------------------------------------------------------------------
proc ListBox::_multiple_select { path mode x y idx } {

    variable $path
    upvar 0  $path data


    if { ![info exists data(anchor)] || ![info exists data(sel_anchor)] } {
	set data(anchor) $idx
	set data(sel_anchor) {}
    }

    switch -exact -- $mode {
	n {
	    _mouse_select $path set $idx
	    set data(anchor) $idx
	    set data(sel_anchor) {}
	}
	c {
	    set l [$path selection get]
	    if { [lsearch -exact $l $idx] >= 0 } {
		_mouse_select $path remove $idx
	    } else {
		_mouse_select $path add $idx
	    }
	    set data(anchor) $idx
	    set data(sel_anchor) {}
	}
	s {
	    eval [list $path _mouse_select remove] $data(sel_anchor)

	    set ix [$path index $idx]
	    set ia [$path index $data(anchor)]
	    if { $ix > $ia } {
		set istart $ia
		set iend $ix
  	    } else {
		set istart $ix
		set iend $ia
  	    }

  	    for { set i $istart } { $i <= $iend } { incr i } {
		set l [$path selection get]
		set t [$path items $i]
		set li [lsearch -exact $l $t]
		if { $li < 0 } {
		    _mouse_select $path add $t
		    lappend data(sel_anchor) $t
 		}
  	    }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command ListBox::_scroll
# ----------------------------------------------------------------------------
proc ListBox::_scroll { path scroll} {
    variable $path
    upvar 0  $path data
    set cmd [lindex $scroll 0]
    set dir [lindex $scroll 1]
    if { ($dir == -1 && [lindex [$path.c $cmd] 0] > 0) ||
         ($dir == 1  && [lindex [$path.c $cmd] 1] < 1) } {
        $path $cmd scroll $dir units
        set data(dnd,afterid) \
	    [after 50 [list ListBox::_scroll $path $scroll]]
    } else {
        set data(dnd,afterid) ""
        DropSite::setcursor dot
    }
}

# ListBox::_set_help --
#
#	Register dynamic help for an item in the listbox.
#
# Arguments:
#	path		ListBox to query
#	item		Item in the listbox
#       force		Optional argument to force a reset of the help
#
# Results:
#	none
proc ListBox::_set_help { path node } {
    Widget::getVariable $path help

    set item $path.$node
    set opts [list -helptype -helptext -helpvar]
    foreach {cty ctx cv} [eval [linsert $opts 0 Widget::hasChangedX $item]] break
    set text [Widget::getoption $item -helptext]

    ## If we've never set help for this item before, and text is not blank,
    ## we need to setup help.  We also need to reset help if any of the
    ## options have changed.
    if { (![info exists help($node)] && $text != "") || $cty || $ctx || $cv } {
	set help($node) 1
	set type [Widget::getoption $item -helptype]
        switch $type {
            balloon {
		DynamicHelp::register $path.c balloon n:$node $text
		DynamicHelp::register $path.c balloon i:$node $text
		DynamicHelp::register $path.c balloon b:$node $text
            }
            variable {
		set var [Widget::getoption $item -helpvar]
		DynamicHelp::register $path.c variable n:$node $var $text
		DynamicHelp::register $path.c variable i:$node $var $text
		DynamicHelp::register $path.c variable b:$node $var $text
            }
        }
    }
}

# ListBox::_mouse_select --
#
#       Handle selection commands that are done by the mouse.  If the
#       selection command returns true, we generate a <<ListboxSelect>>
#       event for the listbox.
#
# Arguments:
#       Standard arguments passed to a selection command.
#
# Results:
#	none
proc ListBox::_mouse_select { path cmd args } {
    eval [linsert $args 0 selection $path $cmd]
    switch -- $cmd {
        "add" - "clear" - "remove" - "set" {
            event generate $path <<ListboxSelect>>
        }
    }
}


# ListBox::_get_node_name --
#
#	Given a listbox item, get the name of the node represented by that
#	item.
#
# Arguments:
#	path		listbox to query
#	item		Optional item to examine; if omitted, 
#			defaults to "current"
#
# Results:
#	node	name of the listbox node.
proc ListBox::_get_node_name {path {item current}} {
    set tags [$path.c gettags $item]
    if {[lindex $tags 0] == "img"} {
        set node [string range [lindex $tags 2] 2 end]
    } else {
        set node [string range [lindex $tags 1] 2 end]
    }
    return $node
}


proc ListBox::_get_current { path } {
    return [ListBox::_get_node_name $path]
}


# ListBox::_drag_and_drop --
#
#	A default command to handle drag-and-drop functions local to this
#       listbox.  With this as the default -dropcmd, the user can simply
#       enable drag-and-drop and be able to move items within this list
#       with no further code.
#
# Arguments:
#       Standard arguments passed to a dropcmd.
#
# Results:
#	none
proc ListBox::_drag_and_drop { path from endItem operation type startItem } {
    set items [$path items]

    ## This proc only handles drag-and-drop commands within itself.
    ## If the widget this came from is not our widget (minus the canvas),
    ## we don't want to do anything.  They need to handle this themselves.
    if {[winfo parent $from] != $path} { return }

    set place [lindex $endItem 0]
    set i     [lindex $endItem 1]

    switch -- $place {
        "position" {
            set idx $i
        } 
        "item" {
            set idx [$path index $i]
        }
        "widget" {
            set idx [llength $items]
        }
    }

    # Check if startItem is part of the current selection and process the
    # whole selection if so
    set selItems [selection $path get]
    if {-1 != [lsearch -exact $selItems $startItem]} {
        set dragItems $selItems
    } else {
        set dragItems [list $startItem]
    }

    # get drag indexes (to sort them)
	foreach dragItem $dragItems {
        lappend dragIdx [$path index $dragItem]
    }
    foreach pos [lsort -integer -indices $dragIdx] {
        set dragItem [lindex $dragItems $pos]
        set dragIdx [$path index $dragItem]
        if {$idx > $dragIdx} { incr idx -1 }
        if {[string equal $operation "copy"]} {
            set options [Widget::options $path.$dragItem]
            eval [linsert $options 0 $path insert $idx $dragItem\#auto]
            incr idx
        } else {
            $path move $dragItem $idx
            set idx [$path index $dragItem]
            incr idx
        }
    }
}


proc ListBox::_keyboard_navigation { path dir } {
    variable $path
    upvar 0  $path data

    set sel [$path index [lindex [$path selection get] end]]
    if {$dir > 0} {
	incr sel
	if {$sel >= [llength $data(items)]} { return }
    } else {
	incr sel -1
	if {$sel < 0} { return }
    }
    set item [lindex $data(items) $sel]
    $path see $item
    _mouse_select $path set $item
}
