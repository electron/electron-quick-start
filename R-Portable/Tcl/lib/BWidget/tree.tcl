# ----------------------------------------------------------------------------
#  tree.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: tree.tcl,v 1.60.2.4 2011/06/23 08:28:04 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - Tree::create
#     - Tree::configure
#     - Tree::cget
#     - Tree::insert
#     - Tree::itemconfigure
#     - Tree::itemcget
#     - Tree::bindArea
#     - Tree::bindText
#     - Tree::bindImage
#     - Tree::delete
#     - Tree::move
#     - Tree::reorder
#     - Tree::selection
#     - Tree::exists
#     - Tree::parent
#     - Tree::index
#     - Tree::nodes
#     - Tree::see
#     - Tree::opentree
#     - Tree::closetree
#     - Tree::edit
#     - Tree::xview
#     - Tree::yview
#     - Tree::_update_edit_size
#     - Tree::_destroy
#     - Tree::_see
#     - Tree::_recexpand
#     - Tree::_subdelete
#     - Tree::_update_scrollregion
#     - Tree::_cross_event
#     - Tree::_draw_node
#     - Tree::_draw_subnodes
#     - Tree::_update_nodes
#     - Tree::_draw_tree
#     - Tree::_redraw_tree
#     - Tree::_redraw_selection
#     - Tree::_redraw_idle
#     - Tree::_drag_cmd
#     - Tree::_drop_cmd
#     - Tree::_over_cmd
#     - Tree::_auto_scroll
#     - Tree::_scroll
# ----------------------------------------------------------------------------

namespace eval Tree {
    Widget::define Tree tree DragSite DropSite DynamicHelp

    namespace eval Node {
        Widget::declare Tree::Node {
            {-text       String     ""      0}
            {-font       TkResource ""      0 listbox}
            {-image      TkResource ""      0 label}
            {-window     String     ""      0}
            {-fill       TkResource black   0 {listbox -foreground}}
            {-data       String     ""      0}
            {-open       Boolean    0       0}
	    {-selectable Boolean    1       0}
            {-drawcross  Enum       auto    0 {auto always never allways}}
	    {-padx       Int        -1      0 "%d >= -1"}
	    {-deltax     Int        -1      0 "%d >= -1"}
	    {-anchor     String     "w"     0 ""}
        }
    }

    DynamicHelp::include Tree::Node balloon

    Widget::tkinclude Tree canvas .c \
	    remove     {
	-insertwidth -insertbackground -insertborderwidth -insertofftime
	-insertontime -selectborderwidth -closeenough -confine -scrollregion
	-xscrollincrement -yscrollincrement -width -height
    } \
	    initialize {
	-relief sunken -borderwidth 2 -takefocus 1
	-highlightthickness 1 -width 200
    }

    Widget::declare Tree {
        {-deltax           Int 10 0 "%d >= 0"}
        {-deltay           Int 15 0 "%d >= 0"}
        {-padx             Int 20 0 "%d >= 0"}
        {-background       TkResource "" 0 listbox}
        {-selectbackground TkResource "" 0 listbox}
        {-selectforeground TkResource "" 0 listbox}
	{-selectcommand    String     "" 0}
        {-width            TkResource "" 0 listbox}
        {-height           TkResource "" 0 listbox}
        {-selectfill       Boolean 0  0}
        {-showlines        Boolean 1  0}
        {-linesfill        TkResource black  0 {listbox -foreground}}
        {-linestipple      TkResource ""     0 {label -bitmap}}
	{-crossfill        TkResource black  0 {listbox -foreground}}
        {-redraw           Boolean 1  0}
        {-opencmd          String  "" 0}
        {-closecmd         String  "" 0}
        {-dropovermode     Flag    "wpn" 0 "wpn"}
        {-bg               Synonym -background}

        {-crossopenimage    String  ""  0}
        {-crosscloseimage   String  ""  0}
        {-crossopenbitmap   String  ""  0}
        {-crossclosebitmap  String  ""  0}
    }

    DragSite::include Tree "TREE_NODE" 1
    DropSite::include Tree {
        TREE_NODE {copy {} move {}}
    }

    Widget::addmap Tree "" .c {-deltay -yscrollincrement}

    # Trees on windows have a white (system window) background
    if { $::tcl_platform(platform) == "windows" } {
	option add *Tree.c.background SystemWindow widgetDefault
	option add *TreeNode.fill SystemWindowText widgetDefault
    }

    bind Tree <FocusIn>   [list after idle {BWidget::refocus %W %W.c}]
    bind Tree <Destroy>   [list Tree::_destroy %W]
    bind Tree <Configure> [list Tree::_update_scrollregion %W]


    bind TreeSentinalStart <Button-1> {
	if { $::Tree::sentinal(%W) } {
	    set ::Tree::sentinal(%W) 0
	    break
	}
    }

    bind TreeSentinalEnd <Button-1> {
	set ::Tree::sentinal(%W) 0
    }

    bind TreeFocus <Button-1> [list focus %W]

    variable _edit
}


# ----------------------------------------------------------------------------
#  Command Tree::create
# ----------------------------------------------------------------------------
proc Tree::create { path args } {
    variable $path
    upvar 0  $path data

    Widget::init Tree $path $args
    set ::Tree::sentinal($path.c) 0

    if {[Widget::cget $path -crossopenbitmap] == ""} {
        set file [file join $::BWIDGET::LIBRARY images "minus.xbm"]
        Widget::configure $path [list -crossopenbitmap @$file]
    }
    if {[Widget::cget $path -crossclosebitmap] == ""} {
        set file [file join $::BWIDGET::LIBRARY images "plus.xbm"]
        Widget::configure $path [list -crossclosebitmap @$file]
    }

    set data(root)         {{}}
    set data(selnodes)     {}
    set data(upd,level)    0
    set data(upd,nodes)    {}
    set data(upd,afterid)  ""
    set data(dnd,scroll)   ""
    set data(dnd,afterid)  ""
    set data(dnd,selnodes) {}
    set data(dnd,node)     ""

    frame $path -class Tree -bd 0 -highlightthickness 0 -relief flat \
	    -takefocus 0
    # For 8.4+ we don't want to inherit the padding
    catch {$path configure -padx 0 -pady 0}
    eval [list canvas $path.c] [Widget::subcget $path .c] -xscrollincrement 8
    bindtags $path.c [list TreeSentinalStart TreeFocus $path.c Canvas \
	    [winfo toplevel $path] all TreeSentinalEnd]
    pack $path.c -expand yes -fill both
    $path.c bind cross <ButtonPress-1> [list Tree::_cross_event $path]

    # Added by ericm@scriptics.com
    # These allow keyboard traversal of the tree
    bind $path.c <KeyPress-Up>    [list Tree::_keynav up $path]
    bind $path.c <KeyPress-Down>  [list Tree::_keynav down $path]
    bind $path.c <KeyPress-Right> [list Tree::_keynav right $path]
    bind $path.c <KeyPress-Left>  [list Tree::_keynav left $path]
    bind $path.c <KeyPress-space> [list +Tree::_keynav space $path]

    # These allow keyboard control of the scrolling
    bind $path.c <Control-KeyPress-Up>    [list $path.c yview scroll -1 units]
    bind $path.c <Control-KeyPress-Down>  [list $path.c yview scroll  1 units]
    bind $path.c <Control-KeyPress-Left>  [list $path.c xview scroll -1 units]
    bind $path.c <Control-KeyPress-Right> [list $path.c xview scroll  1 units]
    # ericm@scriptics.com

    BWidget::bindMouseWheel $path.c

    DragSite::setdrag $path $path.c Tree::_init_drag_cmd \
	    [Widget::cget $path -dragendcmd] 1
    DropSite::setdrop $path $path.c Tree::_over_cmd Tree::_drop_cmd 1

    Widget::create Tree $path

    set w [Widget::cget $path -width]
    set h [Widget::cget $path -height]
    set dy [Widget::cget $path -deltay]
    $path.c configure -width [expr {$w*8}] -height [expr {$h*$dy}]

    # ericm
    # Bind <Button-1> to select the clicked node -- no reason not to, right?

    ## Bind button 1 to select the node via the _mouse_select command.
    ## This command will generate the proper <<TreeSelect>> virtual event
    ## when necessary.
    set selectcmd Tree::_mouse_select
    Tree::bindText  $path <Button-1>         [list $selectcmd $path set]
    Tree::bindImage $path <Button-1>         [list $selectcmd $path set]
    Tree::bindText  $path <Control-Button-1> [list $selectcmd $path toggle]
    Tree::bindImage $path <Control-Button-1> [list $selectcmd $path toggle]

    # Add sentinal bindings for double-clicking on items, to handle the 
    # gnarly Tk bug wherein:
    # ButtonClick
    # ButtonClick
    # On a canvas item translates into button click on the item, button click
    # on the canvas, double-button on the item, single button click on the
    # canvas (which can happen if the double-button on the item causes some
    # other event to be handled in between when the button clicks are examined
    # for the canvas)
    $path.c bind TreeItemSentinal <Double-Button-1> \
	[list set ::Tree::sentinal($path.c) 1]
    # ericm

    return $path
}


# ----------------------------------------------------------------------------
#  Command Tree::configure
# ----------------------------------------------------------------------------
proc Tree::configure { path args } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path $args]

    set ch1 [expr {[Widget::hasChanged $path -deltax val] |
                   [Widget::hasChanged $path -deltay dy]  |
                   [Widget::hasChanged $path -padx val]   |
                   [Widget::hasChanged $path -showlines val]}]

    set ch2 [expr {[Widget::hasChanged $path -selectbackground val] |
                   [Widget::hasChanged $path -selectforeground val]}]

    if { [Widget::hasChanged $path -linesfill   fill] |
         [Widget::hasChanged $path -linestipple stipple] } {
        $path.c itemconfigure line  -fill $fill -stipple $stipple
    }

    if { [Widget::hasChanged $path -crossfill fill] } {
        $path.c itemconfigure cross -foreground $fill
    }

    if {[Widget::hasChanged $path -selectfill fill]} {
	# Make sure that the full-width boxes have either all or none
	# of the standard node bindings
	if {$fill} {
	    foreach event [$path.c bind "node"] {
		$path.c bind "box" $event [$path.c bind "node" $event]
	    }
	} else {
	    foreach event [$path.c bind "node"] {
		$path.c bind "box" $event {}
	    }
	}
    }

    if { $ch1 } {
        _redraw_idle $path 3
    } elseif { $ch2 } {
        _redraw_idle $path 1
    }

    if { [Widget::hasChanged $path -height h] } {
        $path.c configure -height [expr {$h*$dy}]
    }
    if { [Widget::hasChanged $path -width w] } {
        $path.c configure -width [expr {$w*8}]
    }

    if { [Widget::hasChanged $path -redraw bool] && $bool } {
        set upd $data(upd,level)
        set data(upd,level) 0
        _redraw_idle $path $upd
    }

    set force [Widget::hasChanged $path -dragendcmd dragend]
    DragSite::setdrag $path $path.c Tree::_init_drag_cmd $dragend $force
    DropSite::setdrop $path $path.c Tree::_over_cmd Tree::_drop_cmd

    return $res
}


# ----------------------------------------------------------------------------
#  Command Tree::cget
# ----------------------------------------------------------------------------
proc Tree::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command Tree::insert
# ----------------------------------------------------------------------------
proc Tree::insert { path index parent node args } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    set node [Widget::nextIndex $path $node]

    if { [info exists data($node)] } {
        return -code error "node \"$node\" already exists"
    }
    set parent [_node_name $path $parent]
    if { ![info exists data($parent)] } {
        return -code error "node \"$parent\" does not exist"
    }

    Widget::init Tree::Node $path.$node $args
    if {[string equal $index "end"]} {
        lappend data($parent) $node
    } else {
        incr index
        set data($parent) [linsert $data($parent) $index $node]
    }
    set data($node) [list $parent]

    if { [string equal $parent "root"] } {
        _redraw_idle $path 3
    } elseif { [visible $path $parent] } {
        # parent is visible...
        if { [Widget::getMegawidgetOption $path.$parent -open] } {
            # ...and opened -> redraw whole
            _redraw_idle $path 3
        } else {
            # ...and closed -> redraw cross
            MergeFlag $path $parent 8
            _redraw_idle $path 2
        }
    }

    return $node
}


# ----------------------------------------------------------------------------
#  Command Tree::itemconfigure
# ----------------------------------------------------------------------------
proc Tree::itemconfigure { path node args } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [string equal $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    set result [Widget::configure $path.$node $args]

    _set_help $path $node

    if { [visible $path $node] } {
        set lopt   {}
        set flag   0
        foreach opt {-window -image -drawcross -font -text -fill} {
            set flag [expr {$flag << 1}]
            if { [Widget::hasChanged $path.$node $opt val] } {
                set flag [expr {$flag | 1}]
            }
        }

        if { [Widget::hasChanged $path.$node -open val] } {
            if {[llength $data($node)] > 1} {
                # node have subnodes - full redraw
                _redraw_idle $path 3
            } else {
                # force a redraw of the plus/minus sign
                set flag [expr {$flag | 8}]
            }
        }

	if {$data(upd,level) < 3 && [Widget::hasChanged $path.$node -padx x]} {
	    _redraw_idle $path 3
	}

	if { $data(upd,level) < 3 && $flag } {
	    MergeFlag $path $node $flag
            _redraw_idle $path 2
        }
    }
    return $result
}

proc Tree::MergeFlag { path node flag } {
    variable $path
    upvar 0  $path data

    # data(upd,nodes) is a key-val list: emulate a dict by an array
    array set n $data(upd,nodes)
    if {![info exists n($node)]} {
	lappend data(upd,nodes) $node $flag
    } else {
	set n($node) [expr {$n($node) | $flag}]
	set data(upd,nodes) [array get n]
    }
    return
}

# ----------------------------------------------------------------------------
#  Command Tree::itemcget
# ----------------------------------------------------------------------------
proc Tree::itemcget { path node option } {
    # Instead of upvar'ing $path as data for this test, just directly refer to
    # it, as that is faster.
    set node [_node_name $path $node]
    if { [string equal $node "root"] || \
	    ![info exists ::Tree::${path}($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    return [Widget::cget $path.$node $option]
}

# ----------------------------------------------------------------------------
# Command Tree::bindArea
# ----------------------------------------------------------------------------
proc Tree::bindArea { path event script } {
    bind $path.c $event $script
}

# ----------------------------------------------------------------------------
#  Command Tree::bindText
# ----------------------------------------------------------------------------
proc Tree::bindText { path event script } {
    if {[string length $script]} {
	append script " \[Tree::_get_node_name [list $path] current 2 1\]"
    }
    $path.c bind "node" $event $script
    if {[Widget::getoption $path -selectfill]} {
	$path.c bind "box" $event $script
    } else {
	$path.c bind "box" $event {}
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::bindImage
# ----------------------------------------------------------------------------
proc Tree::bindImage { path event script } {
    if {[string length $script]} {
	append script " \[Tree::_get_node_name [list $path] current 2 1\]"
    }
    $path.c bind "img" $event $script
    if {[Widget::getoption $path -selectfill]} {
	$path.c bind "box" $event $script
    } else {
	$path.c bind "box" $event {}
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::delete
# ----------------------------------------------------------------------------
proc Tree::delete { path args } {
    variable $path
    upvar 0  $path data

    set sel 0
    foreach lnodes $args {
	foreach node $lnodes {
            set node [_node_name $path $node]
	    if { ![string equal $node "root"] && [info exists data($node)] } {
		set parent [lindex $data($node) 0]
		set idx	   [lsearch -exact $data($parent) $node]
		set data($parent) [lreplace $data($parent) $idx $idx]
		incr sel [_subdelete $path [list $node]]
	    }
	}
    }
    if {$sel} {
	# if selection changed, call the selectcommand
	__call_selectcmd $path
    }

    _redraw_idle $path 3
}


# ----------------------------------------------------------------------------
#  Command Tree::move
# ----------------------------------------------------------------------------
proc Tree::move { path parent node index } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [string equal $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    if { ![info exists data($parent)] } {
        return -code error "node \"$parent\" does not exist"
    }
    set p $parent
    while { ![string equal $p "root"] } {
        if { [string equal $p $node] } {
            return -code error "node \"$parent\" is a descendant of \"$node\""
        }
        set p [parent $path $p]
    }

    set oldp        [lindex $data($node) 0]
    set idx         [lsearch -exact $data($oldp) $node]
    set data($oldp) [lreplace $data($oldp) $idx $idx]
    set data($node) [concat [list $parent] [lrange $data($node) 1 end]]
    if { [string equal $index "end"] } {
        lappend data($parent) $node
    } else {
        incr index
        set data($parent) [linsert $data($parent) $index $node]
    }
    if { ([string equal $oldp "root"] ||
          ([visible $path $oldp] && [Widget::getoption $path.$oldp   -open])) ||
         ([string equal $parent "root"] ||
          ([visible $path $parent] && [Widget::getoption $path.$parent -open])) } {
        _redraw_idle $path 3
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::reorder
# ----------------------------------------------------------------------------
proc Tree::reorder { path node neworder } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    set children [lrange $data($node) 1 end]
    if { [llength $children] } {
        set children [BWidget::lreorder $children $neworder]
        set data($node) [linsert $children 0 [lindex $data($node) 0]]
        if { [visible $path $node] && [Widget::getoption $path.$node -open] } {
            _redraw_idle $path 3
        }
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::selection
# ----------------------------------------------------------------------------
proc Tree::selection { path cmd args } {
    variable $path
    upvar 0  $path data

    switch -- $cmd {
	toggle {
            foreach node $args {
                set node [_node_name $path $node]
                if {![info exists data($node)]} {
		    return -code error \
			    "$path selection toggle: Cannot toggle unknown node \"$node\"."
		}
	    }
            foreach node $args {
                set node [_node_name $path $node]
		if {[$path selection includes $node]} {
		    $path selection remove $node
		} else {
		    $path selection add $node
		}
            }
	}
        set {
            foreach node $args {
                set node [_node_name $path $node]
                if {![info exists data($node)]} {
		    return -code error \
			    "$path selection set: Cannot select unknown node \"$node\"."
		}
	    }
            set data(selnodes) {}
            foreach node $args {
                set node [_node_name $path $node]
		if { [Widget::getoption $path.$node -selectable] } {
		    if { [lsearch -exact $data(selnodes) $node] == -1 } {
			lappend data(selnodes) $node
		    }
		}
            }
	    __call_selectcmd $path
        }
        add {
            foreach node $args {
                set node [_node_name $path $node]
                if {![info exists data($node)]} {
		    return -code error \
			    "$path selection add: Cannot select unknown node \"$node\"."
		}
	    }
            foreach node $args {
                set node [_node_name $path $node]
		if { [Widget::getoption $path.$node -selectable] } {
		    if { [lsearch -exact $data(selnodes) $node] == -1 } {
			lappend data(selnodes) $node
		    }
		}
            }
	    __call_selectcmd $path
        }
	range {
	    # Here's our algorithm:
	    #    make a list of all nodes, then take the range from node1
	    #    to node2 and select those nodes
	    #
	    # This works because of how this widget handles redraws:
	    #    The tree is always completely redrawn, and always from
	    #    top to bottom. So the list of visible nodes *is* the
	    #    list of nodes, and we can use that to decide which nodes
	    #    to select.

	    if {[llength $args] != 2} {
		return -code error \
			"wrong#args: Expected $path selection range node1 node2"
	    }

	    foreach {node1 node2} $args break

            set node1 [_node_name $path $node1]
            set node2 [_node_name $path $node2]
	    if {![info exists data($node1)]} {
		return -code error \
			"$path selection range: Cannot start range at unknown node \"$node1\"."
	    }
	    if {![info exists data($node2)]} {
		return -code error \
			"$path selection range: Cannot end range at unknown node \"$node2\"."
	    }

	    set nodes {}
	    foreach nodeItem [$path.c find withtag node] {
		set node [Tree::_get_node_name $path $nodeItem 2]
		if { [Widget::getoption $path.$node -selectable] } {
		    lappend nodes $node
		}
	    }
	    # surles: Set the root string to the first element on the list.
	    if {$node1 == "root"} {
		set node1 [lindex $nodes 0]
	    }
	    if {$node2 == "root"} {
		set node2 [lindex $nodes 0]
	    }

	    # Find the first visible ancestor of node1, starting with node1
	    while {[set index1 [lsearch -exact $nodes $node1]] == -1} {
		set node1 [lindex $data($node1) 0]
	    }
	    # Find the first visible ancestor of node2, starting with node2
	    while {[set index2 [lsearch -exact $nodes $node2]] == -1} {
		set node2 [lindex $data($node2) 0]
	    }
	    # If the nodes were given in backwards order, flip the
	    # indices now
	    if { $index2 < $index1 } {
		incr index1 $index2
		set index2 [expr {$index1 - $index2}]
		set index1 [expr {$index1 - $index2}]
	    }
	    set data(selnodes) [lrange $nodes $index1 $index2]
	    __call_selectcmd $path
	}
        remove {
            foreach node $args {
                set node [_node_name $path $node]
                if { [set idx [lsearch -exact $data(selnodes) $node]] != -1 } {
                    set data(selnodes) [lreplace $data(selnodes) $idx $idx]
                }
            }
	    __call_selectcmd $path
        }
        clear {
	    if {[llength $args] != 0} {
		return -code error \
			"wrong#args: Expected $path selection clear"
	    }
            set data(selnodes) {}
	    __call_selectcmd $path
        }
        get {
	    if {[llength $args] != 0} {
		return -code error \
			"wrong#args: Expected $path selection get"
	    }
            set nodes [list]
	    foreach node $data(selnodes) {
		lappend nodes [_node_name_rev $path $node]
	    }
	    return $nodes
        }
        includes {
	    if {[llength $args] != 1} {
		return -code error \
			"wrong#args: Expected $path selection includes node"
	    }
	    set node [lindex $args 0]
            set node [_node_name $path $node]
            return [expr {[lsearch -exact $data(selnodes) $node] != -1}]
        }
        default {
            return
        }
    }
    _redraw_idle $path 1
}


proc Tree::getcanvas { path } {
    return $path.c
}


proc Tree::__call_selectcmd { path } {
    variable $path
    upvar 0  $path data

    set selectcmd [Widget::getoption $path -selectcommand]
    if {[llength $selectcmd]} {
	lappend selectcmd $path
	lappend selectcmd $data(selnodes)
	uplevel \#0 $selectcmd
    }
    return
}

# ----------------------------------------------------------------------------
#  Command Tree::exists
# ----------------------------------------------------------------------------
proc Tree::exists { path node } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    return [info exists data($node)]
}


# ----------------------------------------------------------------------------
#  Command Tree::visible
# ----------------------------------------------------------------------------
proc Tree::visible { path node } {
    set node [_node_name $path $node]
    set idn [$path.c find withtag n:$node]
    return [llength $idn]
}


# ----------------------------------------------------------------------------
#  Command Tree::parent
# ----------------------------------------------------------------------------
proc Tree::parent { path node } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    return [lindex $data($node) 0]
}


# ----------------------------------------------------------------------------
#  Command Tree::index
# ----------------------------------------------------------------------------
proc Tree::index { path node } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [string equal $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    set parent [lindex $data($node) 0]
    return [expr {[lsearch -exact $data($parent) $node] - 1}]
}


# ----------------------------------------------------------------------------
#  Tree::find
#     Returns the node given a position.
#  findInfo     @x,y ?confine?
#               lineNumber
# ----------------------------------------------------------------------------
proc Tree::find {path findInfo {confine ""}} {
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

    set found  0
    set region [$path.c bbox all]
    if {[llength $region]} {
        set xi [lindex $region 0]
        set xs [lindex $region 2]
        foreach id [$path.c find overlapping $xi $y $xs $y] {
            set ltags [$path.c gettags $id]
            set item  [lindex $ltags 1]
            if { [string equal $item "node"] ||
                 [string equal $item "img"]  ||
                 [string equal $item "win"] } {
                # item is the label or image/window of the node
                set node  [Tree::_get_node_name $path $id 2]
                set found 1
                break
            }
        }
    }

    if {$found} {
        if {![string equal $confine ""]} {
            # test if x stand inside node bbox
	    set padx [_get_node_padx $path $node]
            set xi [expr {[lindex [$path.c coords n:$node] 0] - $padx}]
            set xs [lindex [$path.c bbox n:$node] 2]
            if {$x >= $xi && $x <= $xs} {
                return [_node_name_rev $path $node]
            }
        } else {
            return [_node_name_rev $path $node]
        }
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command Tree::line
#     Returns the line where a node was drawn.
# ----------------------------------------------------------------------------
proc Tree::line {path node} {
    set node [_node_name $path $node]
    set item [$path.c find withtag n:$node]
    if {[string length $item]} {
        set dy   [Widget::getoption $path -deltay]
        set y    [lindex [$path.c coords $item] 1]
        set line [expr {int($y/$dy)}]
    } else {
        set line -1
    }
    return $line
}


# ----------------------------------------------------------------------------
#  Command Tree::nodes
# ----------------------------------------------------------------------------
proc Tree::nodes { path node {first ""} {last ""} } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    if { ![string length $first] } {
        return [lrange $data($node) 1 end]
    }

    if { ![string length $last] } {
        return [lindex [lrange $data($node) 1 end] $first]
    } else {
        return [lrange [lrange $data($node) 1 end] $first $last]
    }
}


# Tree::visiblenodes --
#
#	Retrieve a list of all the nodes in a tree.
#
# Arguments:
#	path	tree to retrieve nodes for.
#
# Results:
#	nodes	list of nodes in the tree.

proc Tree::visiblenodes { path } {
    variable $path
    upvar 0  $path data

    # Root is always open (?), so all of its children automatically get added
    # to the result, and to the stack.
    set st [lrange $data(root) 1 end]
    set result $st

    while {[llength $st]} {
	set node [lindex $st end]
	set st [lreplace $st end end]
	# Danger, danger!  Using getMegawidgetOption is fragile, but much
	# much faster than going through cget.
	if { [Widget::getMegawidgetOption $path.$node -open] } {
	    set nodes [lrange $data($node) 1 end]
	    set result [concat $result $nodes]
	    set st [concat $st $nodes]
	}
    }
    return $result
}

# ----------------------------------------------------------------------------
#  Command Tree::see
# ----------------------------------------------------------------------------
proc Tree::see { path node } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [Widget::getoption $path -redraw] && $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
        _redraw_tree $path
    }
    set idn [$path.c find withtag n:$node]
    if { $idn != "" } {
        Tree::_see $path $idn
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::opentree
# ----------------------------------------------------------------------------
# JDC: added option recursive
proc Tree::opentree { path node {recursive 1} } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [string equal $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    _recexpand $path $node 1 $recursive [Widget::getoption $path -opencmd]
    _redraw_idle $path 3
}


# ----------------------------------------------------------------------------
#  Command Tree::closetree
# ----------------------------------------------------------------------------
proc Tree::closetree { path node {recursive 1} } {
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [string equal $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    _recexpand $path $node 0 $recursive [Widget::getoption $path -closecmd]
    _redraw_idle $path 3
}


proc Tree::toggle { path node } {
    if {[$path itemcget $node -open]} {
        $path closetree $node 0
    } else {
        $path opentree $node 0
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::edit
# ----------------------------------------------------------------------------
proc Tree::edit { path node text {verifycmd ""} {clickres 0} {select 1}} {
    variable _edit
    variable $path
    upvar 0  $path data

    set node [_node_name $path $node]
    if { [Widget::getoption $path -redraw] && $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
        _redraw_tree $path
    }
    set idn [$path.c find withtag n:$node]
    if { $idn != "" } {
        Tree::_see $path $idn

        set oldfg  [$path.c itemcget $idn -fill]
        set sbg    [Widget::getoption $path -selectbackground]
        set coords [$path.c coords $idn]
        set x      [lindex $coords 0]
        set y      [lindex $coords 1]
        set bd     [expr {[$path.c cget -borderwidth]+[$path.c cget -highlightthickness]}]
        set w      [expr {[winfo width $path] - 2*$bd}]
        set wmax   [expr {[$path.c canvasx $w]-$x}]

        set _edit(text) $text
        set _edit(wait) 0

        $path.c itemconfigure $idn    -fill [Widget::getoption $path -background]
        $path.c itemconfigure s:$node -fill {} -outline {}

        set frame  [frame $path.edit \
                        -relief flat -borderwidth 0 -highlightthickness 0 \
                        -background [Widget::getoption $path -background]]
        set ent    [entry $frame.edit \
                        -width              0     \
                        -relief             solid \
                        -borderwidth        1     \
                        -highlightthickness 0     \
                        -foreground         [Widget::getoption $path.$node -fill] \
                        -background         [Widget::getoption $path -background] \
                        -selectforeground   [Widget::getoption $path -selectforeground] \
                        -selectbackground   $sbg  \
                        -font               [Widget::getoption $path.$node -font] \
                        -textvariable       Tree::_edit(text)]
        pack $ent -ipadx 8 -anchor w

        set idw [$path.c create window $x $y -window $frame -anchor w]
        trace variable Tree::_edit(text) w \
	    [list Tree::_update_edit_size $path $ent $idw $wmax]
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
        bind $ent <Escape> {set Tree::_edit(wait) 0}
        bind $ent <Return> {set Tree::_edit(wait) 1}
        if { $clickres == 0 || $clickres == 1 } {
            bind $frame <Button>  [list set Tree::_edit(wait) $clickres]
        }

        set ok 0
        while { !$ok } {
            tkwait variable Tree::_edit(wait)
            if { !$_edit(wait) || [llength $verifycmd]==0 ||
                 [uplevel \#0 $verifycmd [list $_edit(text)]] } {
                set ok 1
            }
        }

        trace vdelete Tree::_edit(text) w \
	    [list Tree::_update_edit_size $path $ent $idw $wmax]
        grab release $frame
        BWidget::focus release $ent
        destroy $frame
        $path.c delete $idw
        $path.c itemconfigure $idn    -fill $oldfg
        $path.c itemconfigure s:$node -fill $sbg -outline $sbg

        if { $_edit(wait) } {
            return $_edit(text)
        }
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command Tree::xview
# ----------------------------------------------------------------------------
proc Tree::xview { path args } {
    return [eval [linsert $args 0 $path.c xview]]
}


# ----------------------------------------------------------------------------
#  Command Tree::yview
# ----------------------------------------------------------------------------
proc Tree::yview { path args } {
    return [eval [linsert $args 0 $path.c yview]]
}


# ----------------------------------------------------------------------------
#  Command Tree::_update_edit_size
# ----------------------------------------------------------------------------
proc Tree::_update_edit_size { path entry idw wmax args } {
    set entw [winfo reqwidth $entry]
    if { $entw+8 >= $wmax } {
        $path.c itemconfigure $idw -width $wmax
    } else {
        $path.c itemconfigure $idw -width 0
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_see
# ----------------------------------------------------------------------------
proc Tree::_see { path idn } {
    set bbox [$path.c bbox $idn]
    set scrl [$path.c cget -scrollregion]

    set ymax [lindex $scrl 3]
    set dy   [$path.c cget -yscrollincrement]
    set yv   [$path yview]
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
    set xv   [$path xview]
    set x0   [expr {int([lindex $bbox 0]/$dx)}]
    set xv0  [expr {round([lindex $xv 0]*$xmax/$dx)}]
    set xv1  [expr {round([lindex $xv 1]*$xmax/$dx)}]
    if { $x0 >= $xv1 || $x0 < $xv0 } {
	$path.c xview scroll [expr {$x0-$xv0}] units
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_recexpand
# ----------------------------------------------------------------------------
# JDC : added option recursive
proc Tree::_recexpand { path node expand recursive cmd } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path.$node -open] != $expand } {
        Widget::setoption $path.$node -open $expand
        if {[llength $cmd]} {
            uplevel \#0 $cmd [list $node]
        }
    }

    if { $recursive } {
	foreach subnode [lrange $data($node) 1 end] {
	    _recexpand $path $subnode $expand $recursive $cmd
	}
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_subdelete
# ----------------------------------------------------------------------------
proc Tree::_subdelete { path lnodes } {
    variable $path
    upvar 0  $path data

    set sel $data(selnodes)
    set selchanged 0

    while { [llength $lnodes] } {
        set lsubnodes [list]
        foreach node $lnodes {
            foreach subnode [lrange $data($node) 1 end] {
                lappend lsubnodes $subnode
            }
            unset data($node)
	    set idx [lsearch -exact $sel $node]
	    if { $idx >= 0 } {
		set sel [lreplace $sel $idx $idx]
		incr selchanged
	    }
            if { [set win [Widget::getoption $path.$node -window]] != "" } {
                destroy $win
            }
            Widget::destroy $path.$node
        }
        set lnodes $lsubnodes
    }

    set data(selnodes) $sel
    # return number of sel items changes
    return $selchanged
}


# ----------------------------------------------------------------------------
#  Command Tree::_update_scrollregion
# ----------------------------------------------------------------------------
proc Tree::_update_scrollregion { path } {
    set bd   [expr {2*([$path.c cget -borderwidth]+[$path.c cget -highlightthickness])}]
    set w    [expr {[winfo width  $path] - $bd}]
    set h    [expr {[winfo height $path] - $bd}]
    set xinc [$path.c cget -xscrollincrement]
    set yinc [$path.c cget -yscrollincrement]
    set bbox [$path.c bbox node]
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

    if {[Widget::getoption $path -selectfill]} {
        _redraw_selection $path
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_cross_event
# ----------------------------------------------------------------------------
proc Tree::_cross_event { path } {
    variable $path
    upvar 0  $path data

    set node [Tree::_get_node_name $path current 1]
    if { [Widget::getoption $path.$node -open] } {
        Tree::itemconfigure $path $node -open 0
        if {[llength [set cmd [Widget::getoption $path -closecmd]]]} {
            uplevel \#0 $cmd [list $node]
        }
    } else {
        Tree::itemconfigure $path $node -open 1
        if {[llength [set cmd [Widget::getoption $path -opencmd]]]} {
            uplevel \#0 $cmd [list $node]
        }
    }
}


proc Tree::_draw_cross { path node open x y } {
    set idc [$path.c find withtag c:$node]

    if { $open } {
        set img [Widget::cget $path -crossopenimage]
        set bmp [Widget::cget $path -crossopenbitmap]
    } else {
        set img [Widget::cget $path -crosscloseimage]
        set bmp [Widget::cget $path -crossclosebitmap]
    }

    ## If we already have a cross for this node, we just adjust the image.
    if {$idc != ""} {
        if {$img == ""} {
            $path.c itemconfigure $idc -bitmap $bmp
        } else {
            $path.c itemconfigure $idc -image $img
        }
        return
    }

    ## Create a new image for the cross.  If the user has specified an
    ## image, it overrides a bitmap.
    if {$img == ""} {
        $path.c create bitmap $x $y \
            -bitmap     $bmp \
            -background [$path.c cget -background] \
            -foreground [Widget::getoption $path -crossfill] \
            -tags       [list cross c:$node] -anchor c
    } else {
        $path.c create image $x $y \
            -image      $img \
            -tags       [list cross c:$node] -anchor c
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_draw_node
# ----------------------------------------------------------------------------
proc Tree::_draw_node { path node x0 y0 deltax deltay padx showlines } {
    variable $path
    upvar 0  $path data

    set x1 [expr {$x0+$deltax+5}]
    set y1 $y0
    if { $showlines } {
        $path.c create line $x0 $y0 $x1 $y0 \
            -fill    [Widget::getoption $path -linesfill]   \
            -stipple [Widget::getoption $path -linestipple] \
            -tags    line
    }
    $path.c create text [expr {$x1+$padx}] $y0 \
        -text   [Widget::getoption $path.$node -text] \
        -fill   [Widget::getoption $path.$node -fill] \
        -font   [Widget::getoption $path.$node -font] \
        -anchor w \
    	-tags   [Tree::_get_node_tags $path $node [list node n:$node]]
    set len [expr {[llength $data($node)] > 1}]
    set dc  [Widget::getoption $path.$node -drawcross]
    set exp [Widget::getoption $path.$node -open]

    if { $len && $exp } {
        set y1 [_draw_subnodes $path [lrange $data($node) 1 end] \
                    [expr {$x0+$deltax}] $y0 $deltax $deltay $padx $showlines]
    }

    if {![string equal $dc "never"]
	&& ($len || [string equal $dc "always"] || [string equal $dc "allways"])} {
        _draw_cross $path $node $exp $x0 $y0
    }

    if { [set win [Widget::getoption $path.$node -window]] != "" } {
	set a [Widget::cget $path.$node -anchor]
        $path.c create window $x1 $y0 -window $win -anchor $a \
		-tags [Tree::_get_node_tags $path $node [list win i:$node]]
    } elseif { [set img [Widget::getoption $path.$node -image]] != "" } {
	set a [Widget::cget $path.$node -anchor]
        $path.c create image $x1 $y0 -image $img -anchor $a \
		-tags   [Tree::_get_node_tags $path $node [list img i:$node]]
    }
    set box [$path.c bbox n:$node i:$node]
    set id [$path.c create rect 0 [lindex $box 1] \
		[winfo screenwidth $path] [lindex $box 3] \
		-tags [Tree::_get_node_tags $path $node [list box b:$node]] \
		-fill {} -outline {}]
    $path.c lower $id

    _set_help $path $node

    return $y1
}


# ----------------------------------------------------------------------------
#  Command Tree::_draw_subnodes
# ----------------------------------------------------------------------------
proc Tree::_draw_subnodes { path nodes x0 y0 deltax deltay padx showlines } {
    set y1 $y0
    foreach node $nodes {
	set padx   [_get_node_padx $path $node]
	set deltax [_get_node_deltax $path $node]
        set yp $y1
        set y1 [_draw_node $path $node $x0 [expr {$y1+$deltay}] $deltax $deltay $padx $showlines]
    }
    # Only draw a line to the invisible root node above the tree widget when
    # there are multiple top nodes.
    set len [llength $nodes]
    if { $showlines && $len && !($y0 < 0 && $len < 2) } {
        set id [$path.c create line $x0 $y0 $x0 [expr {$yp+$deltay}] \
                    -fill    [Widget::getoption $path -linesfill]   \
                    -stipple [Widget::getoption $path -linestipple] \
                    -tags    line]

        $path.c lower $id
    }
    return $y1
}


# ----------------------------------------------------------------------------
#  Command Tree::_update_nodes
# ----------------------------------------------------------------------------
proc Tree::_update_nodes { path } {
    variable $path
    upvar 0  $path data

    foreach {node flag} $data(upd,nodes) {
	set idn [$path.c find withtag "n:$node"]
	if { $idn == "" } {
	    continue
	}
	set padx   [_get_node_padx $path $node]
	set deltax [_get_node_deltax $path $node]
	set c  [$path.c coords $idn]
	set x1 [expr {[lindex $c 0]-$padx}]
	set x0 [expr {$x1-$deltax-5}]
	set y0 [lindex $c 1]
	if { $flag & 48 } {
	    # -window or -image modified
	    set win  [Widget::getoption $path.$node -window]
	    set img  [Widget::getoption $path.$node -image]
	    set anc  [Widget::cget $path.$node -anchor]
	    set idi  [$path.c find withtag i:$node]
	    set type [lindex [$path.c gettags $idi] 1]
	    if { [string length $win] } {
		if { [string equal $type "win"] } {
		    $path.c itemconfigure $idi -window $win
		} else {
		    $path.c delete $idi
		    $path.c create window $x1 $y0 -window $win -anchor $anc \
			-tags [_get_node_tags $path $node [list win i:$node]]
		}
	    } elseif { [string length $img] } {
		if { [string equal $type "img"] } {
		    $path.c itemconfigure $idi -image $img
		} else {
		    $path.c delete $idi
		    $path.c create image $x1 $y0 -image $img -anchor $anc \
			-tags [_get_node_tags $path $node [list img i:$node]]
		}
	    } else {
		$path.c delete $idi
	    }
	}

	if { $flag & 8 } {
	    # -drawcross modified
	    set len [expr {[llength $data($node)] > 1}]
	    set dc  [Widget::getoption $path.$node -drawcross]
	    set exp [Widget::getoption $path.$node -open]

	    if {![string equal $dc "never"]
		&& ($len || [string equal $dc "always"] || [string equal $dc "allways"])} {
		_draw_cross $path $node $exp $x0 $y0
	    } else {
		set idc [$path.c find withtag c:$node]
		$path.c delete $idc
	    }
	}

	if { $flag & 7 } {
	    # -font, -text or -fill modified
	    $path.c itemconfigure $idn \
		-text [Widget::getoption $path.$node -text] \
		-fill [Widget::getoption $path.$node -fill] \
		-font [Widget::getoption $path.$node -font]
	}
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_draw_tree
# ----------------------------------------------------------------------------
proc Tree::_draw_tree { path } {
    variable $path
    upvar 0  $path data

    $path.c delete all
    set cursor [$path.c cget -cursor]
    $path.c configure -cursor watch
    _draw_subnodes $path [lrange $data(root) 1 end] 8 \
        [expr {-[Widget::getoption $path -deltay]/2}] \
        [Widget::getoption $path -deltax] \
        [Widget::getoption $path -deltay] \
        [Widget::getoption $path -padx]   \
        [Widget::getoption $path -showlines]
    $path.c configure -cursor $cursor
}


# ----------------------------------------------------------------------------
#  Command Tree::_redraw_tree
# ----------------------------------------------------------------------------
proc Tree::_redraw_tree { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] } {
        if { $data(upd,level) == 2 } {
            _update_nodes $path
        } elseif { $data(upd,level) == 3 } {
            _draw_tree $path
        }
        _redraw_selection $path
        _update_scrollregion $path
        set data(upd,nodes)   {}
        set data(upd,level)   0
        set data(upd,afterid) ""
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_redraw_selection
# ----------------------------------------------------------------------------
proc Tree::_redraw_selection { path } {
    variable $path
    upvar 0  $path data

    set selbg [Widget::getoption $path -selectbackground]
    set selfg [Widget::getoption $path -selectforeground]
    set fill  [Widget::getoption $path -selectfill]
    if {$fill} {
        set scroll [$path.c cget -scrollregion]
        if {[llength $scroll]} {
            set xmax [expr {[lindex $scroll 2]-1}]
        } else {
            set xmax [winfo width $path]
        }
    }
    foreach id [$path.c find withtag sel] {
        set node [Tree::_get_node_name $path $id 1]
        $path.c itemconfigure "n:$node" -fill [Widget::getoption $path.$node -fill]
    }
    $path.c delete sel
    foreach node $data(selnodes) {
        set bbox [$path.c bbox "n:$node"]
        if { [llength $bbox] } {
            if {$fill} {
		# get the image to (if any), as it may have different height
		set bbox [$path.c bbox "n:$node" "i:$node"]
                set bbox [list 0 [lindex $bbox 1] $xmax [lindex $bbox 3]]
            }
            set id [$path.c create rectangle $bbox -tags [list sel s:$node] \
			-fill $selbg -outline $selbg]
	    if {$selfg != ""} {
		# Don't allow an empty fill - that would be transparent
		$path.c itemconfigure "n:$node" -fill $selfg
	    }
            $path.c lower $id
        }
    }
}


# ----------------------------------------------------------------------------
#  Command Tree::_redraw_idle
# ----------------------------------------------------------------------------
proc Tree::_redraw_idle { path level } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] && $data(upd,afterid) == "" } {
        set data(upd,afterid) [after idle [list Tree::_redraw_tree $path]]
    }
    if { $level > $data(upd,level) } {
        set data(upd,level) $level
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command Tree::_init_drag_cmd
# ----------------------------------------------------------------------------
proc Tree::_init_drag_cmd { path X Y top } {
    set path [winfo parent $path]
    set ltags [$path.c gettags current]
    set item  [lindex $ltags 1]
    if { [string equal $item "node"] ||
         [string equal $item "img"]  ||
         [string equal $item "win"] } {
        set node [Tree::_get_node_name $path current 2]
        if {[llength [set cmd [Widget::getoption $path -draginitcmd]]]} {
            return [uplevel \#0 $cmd [list $path $node $top]]
        }
        if { [set type [Widget::getoption $path -dragtype]] == "" } {
            set type "TREE_NODE"
        }
        if { [set img [Widget::getoption $path.$node -image]] != "" } {
            pack [label $top.l -image $img -padx 0 -pady 0]
        }
        return [list $type {copy move link} $node]
    }
    return {}
}


# ----------------------------------------------------------------------------
#  Command Tree::_drop_cmd
# ----------------------------------------------------------------------------
proc Tree::_drop_cmd { path source X Y op type dnddata } {
    set path [winfo parent $path]
    variable $path
    upvar 0  $path data

    $path.c delete drop
    if { [string length $data(dnd,afterid)] } {
        after cancel $data(dnd,afterid)
        set data(dnd,afterid) ""
    }
    set data(dnd,scroll) ""
    if {[llength [set cmd [Widget::getoption $path -dropcmd]]]} {
	return [uplevel \#0 $cmd \
		    [list $path $source $data(dnd,node) $op $type $dnddata]]
    }
    return 0
}


# ----------------------------------------------------------------------------
#  Command Tree::_over_cmd
# ----------------------------------------------------------------------------
proc Tree::_over_cmd { path source event X Y op type dnddata } {
    set path [winfo parent $path]
    variable $path
    upvar 0  $path data

    if { [string equal $event "leave"] } {
        # we leave the window tree
        $path.c delete drop
        if { [string length $data(dnd,afterid)] } {
            after cancel $data(dnd,afterid)
            set data(dnd,afterid) ""
        }
        set data(dnd,scroll) ""
        return 0
    }

    if { [string equal $event "enter"] } {
        # we enter the window tree - dnd data initialization
        set mode [Widget::getoption $path -dropovermode]
        set data(dnd,mode) 0
        foreach c {w p n} {
            set data(dnd,mode) [expr {($data(dnd,mode) << 1) | ([string first $c $mode] != -1)}]
        }
        set bbox [$path.c bbox all]
        if { [llength $bbox] } {
            set data(dnd,xs) [lindex $bbox 2]
            set data(dnd,empty) 0
        } else {
            set data(dnd,xs) 0
            set data(dnd,empty) 1
        }
        set data(dnd,node) {}
    }

    set x [expr {$X-[winfo rootx $path]}]
    set y [expr {$Y-[winfo rooty $path]}]
    $path.c delete drop
    set data(dnd,node) {}

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
    if { ($data(dnd,mode) & 2) && $data(dnd,empty) } {
        # dropovermode includes position and tree is empty
        lappend target [list root 0]
        set vmode  [expr {$vmode | 2}]
    }

    set xc [$path.c canvasx $x]
    set xs $data(dnd,xs)
    if { $xc <= $xs } {
        set yc   [$path.c canvasy $y]
        set dy   [$path.c cget -yscrollincrement]
        set line [expr {int($yc/$dy)}]
        set xi   0
        set yi   [expr {$line*$dy}]
        set ys   [expr {$yi+$dy}]
        set found 0
        foreach id [$path.c find overlapping $xi $yi $xs $ys] {
            set ltags [$path.c gettags $id]
            set item  [lindex $ltags 1]
            if { [string equal $item "node"] ||
                 [string equal $item "img"]  ||
                 [string equal $item "win"] } {
                # item is the label or image/window of the node
                set node [Tree::_get_node_name $path $id 2]
		set found 1
		break
	    }
	}
	if {$found} {
	    set padx   [_get_node_padx $path $node]
	    set deltax [_get_node_deltax $path $node]
            set xi [expr {[lindex [$path.c coords n:$node] 0] - $padx - 1}]
                if { $data(dnd,mode) & 1 } {
                    # dropovermode includes node
                    lappend target $node
                    set vmode [expr {$vmode | 1}]
                } else {
                    lappend target ""
                }

                if { $data(dnd,mode) & 2 } {
                    # dropovermode includes position
                    if { $yc >= $yi+$dy/2 } {
                        # position is after $node
                        if { [Widget::getoption $path.$node -open] &&
                             [llength $data($node)] > 1 } {
                            # $node is open and have subnodes
                            # drop position is 0 in children of $node
                            set parent $node
                            set index  0
                            set xli    [expr {$xi-5}]
                        } else {
                            # $node is not open and doesn't have subnodes
                            # drop position is after $node in children of parent of $node
                            set parent [lindex $data($node) 0]
                            set index  [lsearch -exact $data($parent) $node]
                            set xli    [expr {$xi - $deltax - 5}]
                        }
                        set yl $ys
                    } else {
                        # position is before $node
                        # drop position is before $node in children of parent of $node
                        set parent [lindex $data($node) 0]
                        set index  [expr {[lsearch -exact $data($parent) $node] - 1}]
                        set xli    [expr {$xi - $deltax - 5}]
                        set yl     $yi
                    }
                    lappend target [list $parent $index]
                    set vmode  [expr {$vmode | 2}]
                } else {
                    lappend target {}
                }

                if { ($vmode & 3) == 3 } {
                    # result have both node and position
                    # we compute what is the preferred method
                    if { $yc-$yi <= 3 || $ys-$yc <= 3 } {
                        lappend target "position"
                    } else {
                        lappend target "node"
                    }
                }
            }
        }

    if {$vmode && [llength [set cmd [Widget::getoption $path -dropovercmd]]]} {
        # user-defined dropover command
        set res     [uplevel \#0 $cmd [list $path $source $target $op $type $dnddata]]
        set code    [lindex $res 0]
        set newmode 0
        if { $code & 1 } {
            # update vmode
            set mode [lindex $res 1]
            if { ($vmode & 1) && [string equal $mode "node"] } {
                set newmode 1
            } elseif { ($vmode & 2) && [string equal $mode "position"] } {
                set newmode 2
            } elseif { ($vmode & 4) && [string equal $mode "widget"] } {
                set newmode 4
            }
        }
        set vmode $newmode
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

    if {!$data(dnd,empty)} {
	# draw dnd visual following vmode
	if { $vmode & 1 } {
	    set data(dnd,node) [list "node" [lindex $target 1]]
	    $path.c create rectangle $xi $yi $xs $ys -tags drop
	} elseif { $vmode & 2 } {
	    set data(dnd,node) [concat "position" [lindex $target 2]]
	    $path.c create line $xli [expr {$yl-$dy/2}] $xli $yl $xs $yl -tags drop
	} elseif { $vmode & 4 } {
	    set data(dnd,node) [list "widget"]
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
#  Command Tree::_auto_scroll
# ----------------------------------------------------------------------------
proc Tree::_auto_scroll { path x y } {
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
    if { [string length $scroll] && ![string length $data(dnd,afterid)] } {
        set data(dnd,afterid) [after 200 [list Tree::_scroll $path $scroll]]
    }
    return $data(dnd,afterid)
}


# ----------------------------------------------------------------------------
#  Command Tree::_scroll
# ----------------------------------------------------------------------------
proc Tree::_scroll { path scroll } {
    variable $path
    upvar 0  $path data
    set cmd [lindex $scroll 0]
    set dir [lindex $scroll 1]
    if { ($dir == -1 && [lindex [$path.c $cmd] 0] > 0) ||
         ($dir == 1  && [lindex [$path.c $cmd] 1] < 1) } {
        $path.c $cmd scroll $dir units
        set data(dnd,afterid) [after 50 [list Tree::_scroll $path $scroll]]
    } else {
        set data(dnd,afterid) ""
        DropSite::setcursor dot
    }
}

# Tree::_keynav --
#
#	Handle navigational keypresses on the tree.
#
# Arguments:
#	which      tag indicating the direction of motion:
#                  up         move to the node graphically above current
#                  down       move to the node graphically below current
#                  left       close current if open, else move to parent
#                  right      open current if closed, else move to child
#                  open       open current if closed, close current if open
#       win        name of the tree widget
#
# Results:
#	None.

proc Tree::_keynav {which win} {
    # check for an empty tree
    if {[$win nodes root] eq ""} {
        return
    }

    # Keyboard navigation is riddled with special cases.  In order to avoid
    # the complex logic, we will instead make a list of all the visible,
    # selectable nodes, then do a simple next or previous operation.

    # One easy way to get all of the visible nodes is to query the canvas
    # object for all the items with the "node" tag; since the tree is always
    # completely redrawn, this list will be in vertical order.
    set nodes {}
    foreach nodeItem [$win.c find withtag node] {
	set node [Tree::_get_node_name $win $nodeItem 2]
	if { [Widget::cget $win.$node -selectable] } {
	    lappend nodes $node
	}
    }

    # Keyboard navigation is all relative to the current node
    # surles: Get the current node for single or multiple selection schemas.
    set node [_get_current_node $win]

    switch -exact -- $which {
	"up" {
	    # Up goes to the node that is vertically above the current node
	    # (NOT necessarily the current node's parent)
	    if { [string equal $node ""] } {
		return
	    }
	    set index [lsearch -exact $nodes $node]
	    incr index -1
	    if { $index >= 0 } {
		$win selection set [lindex $nodes $index]
		_set_current_node $win [lindex $nodes $index]
		$win see [lindex $nodes $index]
		event generate $win <<TreeSelect>>
		return
	    }
	}
	"down" {
	    # Down goes to the node that is vertically below the current node
	    if { [string equal $node ""] } {
		$win selection set [lindex $nodes 0]
		_set_current_node $win [lindex $nodes 0]
		$win see [lindex $nodes 0]
		event generate $win <<TreeSelect>>
		return
	    }

	    set index [lsearch -exact $nodes $node]
	    incr index
	    if { $index < [llength $nodes] } {
		$win selection set [lindex $nodes $index]
		_set_current_node $win [lindex $nodes $index]
		$win see [lindex $nodes $index]
		event generate $win <<TreeSelect>>
		return
	    }
	}
	"right" {
	    # On a right arrow, if the current node is closed, open it.
	    # If the current node is open, go to its first child
	    if { [string equal $node ""] } {
		return
	    }
	    set open [$win itemcget $node -open]
            if { $open } {
                if { [llength [$win nodes $node]] } {
		    set index [lsearch -exact $nodes $node]
		    incr index
		    if { $index < [llength $nodes] } {
			$win selection set [lindex $nodes $index]
			_set_current_node $win [lindex $nodes $index]
			$win see [lindex $nodes $index]
			event generate $win <<TreeSelect>>
			return
		    }
                }
            } else {
                $win itemconfigure $node -open 1
                if {[llength [set cmd [Widget::getoption $win -opencmd]]]} {
                    uplevel \#0 $cmd [list $node]
                }
                return
            }
	}
	"left" {
	    # On a left arrow, if the current node is open, close it.
	    # If the current node is closed, go to its parent.
	    if { [string equal $node ""] } {
		return
	    }
	    set open [$win itemcget $node -open]
	    if { $open } {
		$win itemconfigure $node -open 0
                if {[llength [set cmd [Widget::getoption $win -closecmd]]]} {
                    uplevel \#0 $cmd [list $node]
                }
		return
	    } else {
		set parent [$win parent $node]
	        if { [string equal $parent "root"] } {
		    set parent $node
                } else {
                    while { ![$win itemcget $parent -selectable] } {
		        set parent [$win parent $parent]
		        if { [string equal $parent "root"] } {
			    set parent $node
			    break
		        }
                    }
		}
		$win selection set $parent
		_set_current_node $win $parent
		$win see $parent
		event generate $win <<TreeSelect>>
		return
	    }
	}
	"space" {
	    if { [string equal $node ""] } {
		return
	    }
	    set open [$win itemcget $node -open]
	    if { [llength [$win nodes $node]] } {

		# Toggle the open status of the chosen node.

		$win itemconfigure $node -open [expr {$open?0:1}]

		if {$open} {
		    # Node was open, is now closed. Call the close-cmd

		    if {[llength [set cmd [Widget::getoption $win -closecmd]]]} {
			uplevel \#0 $cmd [list $node]
		    }
		} else {
		    # Node was closed, is now open. Call the open-cmd

		    if {[llength [set cmd [Widget::getoption $win -opencmd]]]} {
			uplevel \#0 $cmd [list $node]
		    }
                }
	    }
	}
    }
    return
}

# Tree::_get_current_node --
#
#	Get the current node for either single or multiple
#	node selection trees.  If the tree allows for 
#	multiple selection, return the cursor node.  Otherwise,
#	if there is a selection, return the first node in the
#	list.  If there is no selection, return the root node.
#
# arguments:
#       win        name of the tree widget
#
# Results:
#	The current node.

proc Tree::_get_current_node {win} {
    if {[info exists selectTree::selectCursor($win)]} {
	set result $selectTree::selectCursor($win)
    } elseif {[llength [set selList [$win selection get]]]} {
	set result [lindex $selList 0]
    } else {
	set result ""
    }
    return $result
}

# Tree::_set_current_node --
#
#	Set the current node for either single or multiple
#	node selection trees.
#
# arguments:
#       win        Name of the tree widget
#	node	   The current node.
#
# Results:
#	None.

proc Tree::_set_current_node {win node} {
    if {[info exists selectTree::selectCursor($win)]} {
	set selectTree::selectCursor($win) $node
    }
    return
}

# Tree::_get_node_name --
#
#	Given a canvas item, get the name of the tree node represented by that
#	item.
#
# Arguments:
#	path		tree to query
#	item		Optional canvas item to examine; if omitted, 
#			defaults to "current"
#	tagindex	Optional tag index, since the n:nodename tag is not
#			in the same spot for all canvas items.  If omitted,
#			defaults to "end-1", so it works with "current" item.
#
# Results:
#	node	name of the tree node.

proc Tree::_get_node_name {path {item current} {tagindex end-1} {truename 0}} {
    set node [string range [lindex [$path.c gettags $item] $tagindex] 2 end]
    if {$truename} {
	return [_node_name_rev $path $node]
    }
    return $node
}

# Tree::_get_node_padx --
#
#	Given a node in the tree, return it's padx value.  If the value is
#	less than 0, default to the padx of the entire tree.
#
# Arguments:
#	path		Tree to query
#	node		Node in the tree
#
# Results:
#	padx		The numeric padx value
proc Tree::_get_node_padx {path node} {
    set padx [Widget::getoption $path.$node -padx]
    if {$padx < 0} { set padx [Widget::getoption $path -padx] }
    return $padx
}

# Tree::_get_node_deltax --
#
#	Given a node in the tree, return it's deltax value.  If the value is
#	less than 0, default to the deltax of the entire tree.
#
# Arguments:
#	path		Tree to query
#	node		Node in the tree
#
# Results:
#	deltax		The numeric deltax value
proc Tree::_get_node_deltax {path node} {
    set deltax [Widget::getoption $path.$node -deltax]
    if {$deltax < 0} { set deltax [Widget::getoption $path -deltax] }
    return $deltax
}


# Tree::_get_node_tags --
#
#	Given a node in the tree, return a list of tags to apply to its
#       canvas item.
#
# Arguments:
#	path		Tree to query
#	node		Node in the tree
#	tags		A list of tags to add to the final list
#
# Results:
#	list		The list of tags to apply to the canvas item
proc Tree::_get_node_tags {path node {tags ""}} {
    eval [linsert $tags 0 lappend list TreeItemSentinal]
    if {[Widget::getoption $path.$node -helptext] == "" &&
        [Widget::getoption $path.$node -helpcmd]  == ""} { return $list }

    switch -- [Widget::getoption $path.$node -helptype] {
	balloon {
	    lappend list BwHelpBalloon
	}
	variable {
	    lappend list BwHelpVariable
	}
    }
    return $list
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
proc Tree::_set_help { path node } {
    Widget::getVariable $path help

    set item $path.$node
    set opts [list -helptype -helptext -helpvar -helpcmd]
    foreach {cty ctx cv cc} [eval [linsert $opts 0 Widget::hasChangedX $item]] break
    set text [Widget::getoption $item -helptext]
    set cmd  [Widget::getoption $item -helpcmd]

    ## If we've never set help for this item before, and text or cmd is not
    ## blank, we need to setup help. We also need to reset help if any of the
    ## options have changed.
    if { (![info exists help($node)] && ($text != "" || $cmd != ""))
         || $cty || $ctx || $cv } {
	set help($node) 1
	set type [Widget::getoption $item -helptype]
        set var [Widget::getoption $item -helpvar]
        DynamicHelp::add $path.c -item n:$node -type $type -text $text -variable $var -command $cmd
        DynamicHelp::add $path.c -item i:$node -type $type -text $text -variable $var -command $cmd
        DynamicHelp::add $path.c -item b:$node -type $type -text $text -variable $var -command $cmd
    }
}

proc Tree::_mouse_select { path cmd args } {
    eval [linsert $args 0 selection $path $cmd]
    switch -- $cmd {
        "add" - "clear" - "remove" - "set" - "toggle" {
            event generate $path <<TreeSelect>>
        }
    }
}

proc Tree::_node_name { path node } {
    # Make sure node names are safe as tags and variable names
    set map [list & \1 | \2 ^ \3 ! \4 :: \5]
    return  [string map $map $node]
}

proc Tree::_node_name_rev { path node } {
    # Allow reverse interpretation of node names
    set map [list \1 & \2 | \3 ^ \4 ! \5 ::]
    return  [string map $map $node]
}


# ----------------------------------------------------------------------------
#  Command Tree::_destroy
# ----------------------------------------------------------------------------
proc Tree::_destroy { path } {
    variable $path
    upvar 0  $path data

    if { $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
    }
    if { $data(dnd,afterid) != "" } {
        after cancel $data(dnd,afterid)
    }
    _subdelete $path [lrange $data(root) 1 end]
    Widget::destroy $path
    unset data
}
