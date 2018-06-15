# ------------------------------------------------------------------------------
#  dragsite.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: dragsite.tcl,v 1.8 2003/10/20 21:23:52 damonc Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - DragSite::include
#     - DragSite::setdrag
#     - DragSite::register
#     - DragSite::_begin_drag
#     - DragSite::_init_drag
#     - DragSite::_end_drag
#     - DragSite::_update_operation
# ----------------------------------------------------------------------------

namespace eval DragSite {
    Widget::define DragSite dragsite -classonly

    Widget::declare DragSite [list \
	    [list	-dragevent	Enum	1	0	[list 1 2 3]] \
	    [list	-draginitcmd	String	""	0] \
	    [list	-dragendcmd	String	""	0] \
	    ]

    variable _topw ".drag"
    variable _tabops
    variable _state
    variable _x0
    variable _y0

    bind BwDrag1 <ButtonPress-1> {DragSite::_begin_drag press  %W %s %X %Y}
    bind BwDrag1 <B1-Motion>     {DragSite::_begin_drag motion %W %s %X %Y}
    bind BwDrag2 <ButtonPress-2> {DragSite::_begin_drag press  %W %s %X %Y}
    bind BwDrag2 <B2-Motion>     {DragSite::_begin_drag motion %W %s %X %Y}
    bind BwDrag3 <ButtonPress-3> {DragSite::_begin_drag press  %W %s %X %Y}
    bind BwDrag3 <B3-Motion>     {DragSite::_begin_drag motion %W %s %X %Y}

    proc use {} {}
}


# ----------------------------------------------------------------------------
#  Command DragSite::include
# ----------------------------------------------------------------------------
proc DragSite::include { class type event } {
    set dragoptions [list \
	    [list	-dragenabled	Boolean	0	0] \
	    [list	-draginitcmd	String	""	0] \
	    [list	-dragendcmd	String	""	0] \
	    [list	-dragtype	String	$type	0] \
	    [list	-dragevent	Enum	$event	0	[list 1 2 3]] \
	    ]
    Widget::declare $class $dragoptions
}


# ----------------------------------------------------------------------------
#  Command DragSite::setdrag
#  Widget interface to register
# ----------------------------------------------------------------------------
proc DragSite::setdrag { path subpath initcmd endcmd {force 0}} {
    set cen       [Widget::hasChanged $path -dragenabled en]
    set cdragevt  [Widget::hasChanged $path -dragevent   dragevt]
    if { $en } {
        if { $force || $cen || $cdragevt } {
            register $subpath \
                -draginitcmd $initcmd \
                -dragendcmd  $endcmd  \
                -dragevent   $dragevt
        }
    } else {
        register $subpath
    }
}


# ----------------------------------------------------------------------------
#  Command DragSite::register
# ----------------------------------------------------------------------------
proc DragSite::register { path args } {
    upvar \#0 DragSite::$path drag

    if { [info exists drag] } {
        bind $path $drag(evt) {}
        unset drag
    }
    Widget::init DragSite .drag$path $args
    set event   [Widget::getMegawidgetOption .drag$path -dragevent]
    set initcmd [Widget::getMegawidgetOption .drag$path -draginitcmd]
    set endcmd  [Widget::getMegawidgetOption .drag$path -dragendcmd]
    set tags    [bindtags $path]
    set idx     [lsearch $tags "BwDrag*"]
    Widget::destroy .drag$path
    if { $initcmd != "" } {
        if { $idx != -1 } {
            bindtags $path [lreplace $tags $idx $idx BwDrag$event]
        } else {
            bindtags $path [concat $tags BwDrag$event]
        }
        set drag(initcmd) $initcmd
        set drag(endcmd)  $endcmd
        set drag(evt)     $event
    } elseif { $idx != -1 } {
        bindtags $path [lreplace $tags $idx $idx]
    }
}


# ----------------------------------------------------------------------------
#  Command DragSite::_begin_drag
# ----------------------------------------------------------------------------
proc DragSite::_begin_drag { event source state X Y } {
    variable _x0
    variable _y0
    variable _state

    switch -- $event {
        press {
            set _x0    $X
            set _y0    $Y
            set _state "press"
        }
        motion {
            if { ![info exists _state] } {
                # This is just extra protection. There seem to be
                # rare cases where the motion comes before the press.
                return
            }
            if { [string equal $_state "press"] } {
                if { abs($_x0-$X) > 3 || abs($_y0-$Y) > 3 } {
                    set _state "done"
                    _init_drag $source $state $X $Y
                }
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command DragSite::_init_drag
# ----------------------------------------------------------------------------
proc DragSite::_init_drag { source state X Y } {
    variable _topw
    upvar \#0 DragSite::$source drag

    destroy  $_topw
    toplevel $_topw
    wm withdraw $_topw
    wm overrideredirect $_topw 1

    set info [uplevel \#0 $drag(initcmd) [list $source $X $Y .drag]]
    if { $info != "" } {
        set type [lindex $info 0]
        set ops  [lindex $info 1]
        set data [lindex $info 2]

        if { [winfo children $_topw] == "" } {
            if { [string equal $type "BITMAP"] || [string equal $type "IMAGE"] } {
                label $_topw.l -image [Bitmap::get dragicon] -relief flat -bd 0
            } else {
                label $_topw.l -image [Bitmap::get dragfile] -relief flat -bd 0
            }
            pack  $_topw.l
        }
        wm geometry $_topw +[expr {$X+1}]+[expr {$Y+1}]
        wm deiconify $_topw
        if {[catch {tkwait visibility $_topw}]} {
            return
        }
        BWidget::grab  set $_topw
        BWidget::focus set $_topw

        bindtags $_topw [list $_topw DragTop]
        DropSite::_init_drag $_topw $drag(evt) $source $state $X $Y $type $ops $data
    } else {
        destroy $_topw
    }
}


# ----------------------------------------------------------------------------
#  Command DragSite::_end_drag
# ----------------------------------------------------------------------------
proc DragSite::_end_drag { source target op type data result } {
    variable _topw
    upvar \#0 DragSite::$source drag

    BWidget::grab  release $_topw
    BWidget::focus release $_topw
    destroy $_topw
    if { $drag(endcmd) != "" } {
        uplevel \#0 $drag(endcmd) [list $source $target $op $type $data $result]
    }
}


