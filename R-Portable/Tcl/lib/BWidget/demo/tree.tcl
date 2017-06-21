
namespace eval DemoTree {
    variable count
    variable dblclick
}


proc DemoTree::create { nb } {
    set frame [$nb insert end demoTree -text "Tree"]
    set pw    [PanedWindow $frame.pw -side top]

    set pane  [$pw add -weight 1]
    set title [TitleFrame $pane.lf -text "Directory tree"]
    set sw    [ScrolledWindow [$title getframe].sw \
                  -relief sunken -borderwidth 2]
    set tree  [Tree $sw.tree \
                   -relief flat -borderwidth 0 -width 15 -highlightthickness 0\
		   -redraw 0 -dropenabled 1 -dragenabled 1 \
                   -dragevent 3 \
                   -droptypes {
                       TREE_NODE    {copy {} move {} link {}}
                       LISTBOX_ITEM {copy {} move {} link {}}
                   } \
                   -opencmd   "DemoTree::moddir 1 $sw.tree" \
                   -closecmd  "DemoTree::moddir 0 $sw.tree"]
    $sw setwidget $tree

    pack $sw    -side top  -expand yes -fill both
    pack $title -fill both -expand yes

    set pane [$pw add -weight 2]
    set lf   [TitleFrame $pane.lf -text "Content"]
    set sw   [ScrolledWindow [$lf getframe].sw \
                  -scrollbar horizontal -auto none -relief sunken -borderwidth 2]
    set list [ListBox::create $sw.lb \
                  -relief flat -borderwidth 0 \
                  -dragevent 3 \
                  -dropenabled 1 -dragenabled 1 \
                  -width 20 -highlightthickness 0 -multicolumn true \
                  -redraw 0 -dragenabled 1 \
                  -droptypes {
                      TREE_NODE    {copy {} move {} link {}}
                      LISTBOX_ITEM {copy {} move {} link {}}}]
    $sw setwidget $list

    pack $sw $lf -fill both -expand yes

    pack $pw -fill both -expand yes

    $tree bindText  <ButtonPress-1>        "DemoTree::select tree 1 $tree $list"
    $tree bindText  <Double-ButtonPress-1> "DemoTree::select tree 2 $tree $list"
    $list bindText  <ButtonPress-1>        "DemoTree::select list 1 $tree $list"
    $list bindText  <Double-ButtonPress-1> "DemoTree::select list 2 $tree $list"
    $list bindImage <Double-ButtonPress-1> "DemoTree::select list 2 $tree $list"

    $nb itemconfigure demoTree \
        -createcmd "DemoTree::init $tree $list" \
        -raisecmd  {
            # on windows you can get 100x100+-200+200 [PT]
            regexp {[0-9]+x[0-9]+([+-]{1,2}[0-9]+)([+-]{1,2}[0-9]+)} \
                [wm geom .] global_foo global_w global_h
            # {}'s left off on purpose. [PT]
            BWidget::place .top 0 0 at [expr $global_w-[winfo screenwidth .]] $global_h
            wm deiconify .top
            bind . <Unmap> {wm withdraw .top}
            bind . <Map>   {wm deiconify .top}
            bind . <Configure> {
                if { ![string compare %W "."] } {
                    # see above re: windows geometry
                    regexp {[0-9]+x[0-9]+([+-]{1,2}[0-9]+)([+-]{1,2}[0-9]+)} \
                        [wm geom .] global_foo global_w global_h
                    BWidget::place .top 0 0 at [expr $global_w-[winfo screenwidth .]] $global_h
                }
            }
        } \
        -leavecmd {
            wm withdraw .top
            bind . <Unmap> {}
            bind . <Map>   {}
            bind . <Configure> {}
            return 1
        }
}


proc DemoTree::init { tree list args } {
    global   tcl_platform
    variable count

    set count 0
    if { $tcl_platform(platform) == "unix" } {
        set rootdir [glob "~"]
    } else {
        set rootdir "c:\\"
    }
    $tree insert end root home -text $rootdir -data $rootdir -open 1 \
        -image [Bitmap::get openfold]
    getdir $tree home $rootdir
    DemoTree::select tree 1 $tree $list home
    $tree configure -redraw 1
    $list configure -redraw 1

    # ScrollView
    set w .top
    toplevel $w
    wm withdraw $w
    wm protocol $w WM_DELETE_WINDOW {
        # don't kill me
    }
    wm resizable $w 0 0 
    wm title $w "Drag rectangle to scroll directory tree"
    wm transient $w .
    ScrollView $w.sv -window $tree -fill white -relief sunken -bd 1 \
	    -width 300 -height 300
    pack $w.sv -fill both -expand yes
}


proc DemoTree::getdir { tree node path } {
    variable count

    set lentries [glob -nocomplain [file join $path "*"]]
    set lfiles   {}
    foreach f $lentries {
        set tail [file tail $f]
        if { [file isdirectory $f] } {
            $tree insert end $node n:$count \
                -text      $tail \
                -image     [Bitmap::get folder] \
                -drawcross allways \
                -data      $f
            incr count
        } else {
            lappend lfiles $tail
        }
    }
    $tree itemconfigure $node -drawcross auto -data $lfiles
}


proc DemoTree::moddir { idx tree node } {
    if { $idx && [$tree itemcget $node -drawcross] == "allways" } {
        getdir $tree $node [$tree itemcget $node -data]
        if { [llength [$tree nodes $node]] } {
            $tree itemconfigure $node -image [Bitmap::get openfold]
        } else {
            $tree itemconfigure $node -image [Bitmap::get folder]
        }
    } else {
        $tree itemconfigure $node -image [Bitmap::get [lindex {folder openfold} $idx]]
    }
}


proc DemoTree::select { where num tree list node } {
    variable dblclick

    set dblclick 1
    if { $num == 1 } {
        if { $where == "tree" && [lsearch [$tree selection get] $node] != -1 } {
            unset dblclick
            after 500 "DemoTree::edit tree $tree $list $node"
            return
        }
        if { $where == "list" && [lsearch [$list selection get] $node] != -1 } {
            unset dblclick
            after 500 "DemoTree::edit list $tree $list $node"
            return
        }
        if { $where == "tree" } {
            select_node $tree $list $node
        } else {
            $list selection set $node
        }
    } elseif { $where == "list" && [$tree exists $node] } {
	set parent [$tree parent $node]
	while { $parent != "root" } {
	    $tree itemconfigure $parent -open 1
	    set parent [$tree parent $parent]
	}
	select_node $tree $list $node
    }
}


proc DemoTree::select_node { tree list node } {
    $tree selection set $node
    update
    eval $list delete [$list item 0 end]

    set dir [$tree itemcget $node -data]
    if { [$tree itemcget $node -drawcross] == "allways" } {
        getdir $tree $node $dir
        set dir [$tree itemcget $node -data]
    }

    foreach subnode [$tree nodes $node] {
        $list insert end $subnode \
            -text  [$tree itemcget $subnode -text] \
            -image [Bitmap::get folder]
    }
    set num 0
    foreach f $dir {
        $list insert end f:$num \
            -text  $f \
            -image [Bitmap::get file]
        incr num
    }
}


proc DemoTree::edit { where tree list node } {
    variable dblclick

    if { [info exists dblclick] } {
        return
    }

    if { $where == "tree" && [lsearch [$tree selection get] $node] != -1 } {
        set res [$tree edit $node [$tree itemcget $node -text]]
        if { $res != "" } {
            $tree itemconfigure $node -text $res
            if { [$list exists $node] } {
                $list itemconfigure $node -text $res
            }
            $tree selection set $node
        }
        return
    }

    if { $where == "list" } {
        set res [$list edit $node [$list itemcget $node -text]]
        if { $res != "" } {
            $list itemconfigure $node -text $res
            if { [$tree exists $node] } {
                $tree itemconfigure $node -text $res
            } else {
                set cursel [$tree selection get]
                set index  [expr {[$list index $node]-[llength [$tree nodes $cursel]]}]
                set data   [$tree itemcget $cursel -data]
                set data   [lreplace $data $index $index $res]
                $tree itemconfigure $cursel -data $data
            }
            $list selection set $node
        }
    }
}


proc DemoTree::expand { tree but } {
    if { [set cur [$tree selection get]] != "" } {
        if { $but == 0 } {
            $tree opentree $cur
        } else {
            $tree closetree $cur
        }
    }
}


