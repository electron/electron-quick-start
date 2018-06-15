# ------------------------------------------------------------------------------
#  dropsite.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: dropsite.tcl,v 1.8 2009/06/30 16:17:37 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - DropSite::include
#     - DropSite::setdrop
#     - DropSite::register
#     - DropSite::setcursor
#     - DropSite::setoperation
#     - DropSite::_update_operation
#     - DropSite::_compute_operation
#     - DropSite::_draw_operation
#     - DropSite::_init_drag
#     - DropSite::_motion
#     - DropSite::_release
# ----------------------------------------------------------------------------


namespace eval DropSite {
    Widget::define DropSite dropsite -classonly

    Widget::declare DropSite [list \
	    [list -dropovercmd String "" 0] \
	    [list -dropcmd     String "" 0] \
	    [list -droptypes   String "" 0] \
	    ]

    proc use {} {}

    variable _top  ".drag"
    variable _opw  ".drag.\#op"
    variable _target  ""
    variable _status  0
    variable _tabops
    variable _defops
    variable _source
    variable _type
    variable _data
    variable _evt
    # key       win    unix
    # shift       1   |   1    ->  1
    # control     4   |   4    ->  4
    # alt         8   |  16    -> 24
    # meta            |  64    -> 88

    array set _tabops {
        mod,none    0
        mod,shift   1
        mod,control 4
        mod,alt     24
        ops,copy    1
        ops,move    1
        ops,link    1
    }

    if { $tcl_platform(platform) == "unix" } {
        set _tabops(mod,alt) 8
    } else {
        set _tabops(mod,alt) 16
    }
    array set _defops \
        [list \
             copy,mod  shift   \
             move,mod  control \
             link,mod  alt     \
             copy,img  @[file join $::BWIDGET::LIBRARY "images" "opcopy.xbm"] \
             move,img  @[file join $::BWIDGET::LIBRARY "images" "opmove.xbm"] \
             link,img  @[file join $::BWIDGET::LIBRARY "images" "oplink.xbm"]]

    bind DragTop <KeyPress-Shift_L>     {DropSite::_update_operation [expr %s | 1]}
    bind DragTop <KeyPress-Shift_R>     {DropSite::_update_operation [expr %s | 1]}
    bind DragTop <KeyPress-Control_L>   {DropSite::_update_operation [expr %s | 4]}
    bind DragTop <KeyPress-Control_R>   {DropSite::_update_operation [expr %s | 4]}
    if { $tcl_platform(platform) == "unix" } {
        bind DragTop <KeyPress-Alt_L>       {DropSite::_update_operation [expr %s | 8]}
        bind DragTop <KeyPress-Alt_R>       {DropSite::_update_operation [expr %s | 8]}
    } else {
        bind DragTop <KeyPress-Alt_L>       {DropSite::_update_operation [expr %s | 16]}
        bind DragTop <KeyPress-Alt_R>       {DropSite::_update_operation [expr %s | 16]}
    }

    bind DragTop <KeyRelease-Shift_L>   {DropSite::_update_operation [expr %s & ~1]}
    bind DragTop <KeyRelease-Shift_R>   {DropSite::_update_operation [expr %s & ~1]}
    bind DragTop <KeyRelease-Control_L> {DropSite::_update_operation [expr %s & ~4]}
    bind DragTop <KeyRelease-Control_R> {DropSite::_update_operation [expr %s & ~4]}
    if { $tcl_platform(platform) == "unix" } {
        bind DragTop <KeyRelease-Alt_L>     {DropSite::_update_operation [expr %s & ~8]}
        bind DragTop <KeyRelease-Alt_R>     {DropSite::_update_operation [expr %s & ~8]}
    } else {
        bind DragTop <KeyRelease-Alt_L>     {DropSite::_update_operation [expr %s & ~16]}
        bind DragTop <KeyRelease-Alt_R>     {DropSite::_update_operation [expr %s & ~16]}
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::include
# ----------------------------------------------------------------------------
proc DropSite::include { class types } {
    set dropoptions [list \
	    [list	-dropenabled	Boolean	0	0] \
	    [list	-dropovercmd	String	""	0] \
	    [list	-dropcmd	String	""	0] \
	    [list	-droptypes	String	$types	0] \
	    ]
    Widget::declare $class $dropoptions
}


# ----------------------------------------------------------------------------
#  Command DropSite::setdrop
#  Widget interface to register
# ----------------------------------------------------------------------------
proc DropSite::setdrop { path subpath dropover drop {force 0}} {
    set cen    [Widget::hasChanged $path -dropenabled en]
    set ctypes [Widget::hasChanged $path -droptypes   types]
    if { $en } {
        if { $force || $cen || $ctypes } {
            register $subpath \
                -droptypes   $types \
                -dropcmd     $drop  \
                -dropovercmd $dropover
        }
    } else {
        register $subpath
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::register
# ----------------------------------------------------------------------------
proc DropSite::register { path args } {
    variable _tabops
    variable _defops
    upvar \#0 DropSite::$path drop

    Widget::init DropSite .drop$path $args
    if { [info exists drop] } {
        unset drop
    }
    set dropcmd [Widget::getMegawidgetOption .drop$path -dropcmd]
    set types   [Widget::getMegawidgetOption .drop$path -droptypes]
    set overcmd [Widget::getMegawidgetOption .drop$path -dropovercmd]
    Widget::destroy .drop$path
    if { $dropcmd != "" && $types != "" } {
        set drop(dropcmd) $dropcmd
        set drop(overcmd) $overcmd
        foreach {type ops} $types {
            set drop($type,ops) {}
            set masklist {}
            foreach {descop lmod} $ops {
                if { ![llength $descop] || [llength $descop] > 3 } {
                    return -code error "invalid operation description \"$descop\""
                }
                foreach {subop baseop imgop} $descop {
                    set subop [string trim $subop]
                    if { ![string length $subop] } {
                        return -code error "sub operation is empty"
                    }
                    if { ![string length $baseop] } {
                        set baseop $subop
                    }
                    if { [info exists drop($type,ops,$subop)] } {
                        return -code error "operation \"$subop\" already defined"
                    }
                    if { ![info exists _tabops(ops,$baseop)] } {
                        return -code error "invalid base operation \"$baseop\""
                    }
                    if { ![string equal $subop $baseop] &&
                         [info exists _tabops(ops,$subop)] } {
                        return -code error "sub operation \"$subop\" is a base operation"
                    }
                    if { ![string length $imgop] } {
                        set imgop $_defops($baseop,img)
                    }
                }
                if { [string equal $lmod "program"] } {
                    set drop($type,ops,$subop) $baseop
                    set drop($type,img,$subop) $imgop
                } else {
                    if { ![string length $lmod] } {
                        set lmod $_defops($baseop,mod)
                    }
                    set mask 0
                    foreach mod $lmod {
                        if { ![info exists _tabops(mod,$mod)] } {
                            return -code error "invalid modifier \"$mod\""
                        }
                        set mask [expr {$mask | $_tabops(mod,$mod)}]
                    }
                    if { ($mask == 0) != ([string equal $subop "default"]) } {
                        return -code error "sub operation default can only be used with modifier \"none\""
                    }
                    set drop($type,mod,$mask)  $subop
                    set drop($type,ops,$subop) $baseop
                    set drop($type,img,$subop) $imgop
                    lappend masklist $mask
                }
            }
            if { ![info exists drop($type,mod,0)] } {
                set drop($type,mod,0)       default
                set drop($type,ops,default) copy
                set drop($type,img,default) $_defops(copy,img)
                lappend masklist 0
            }
            set drop($type,ops,force) copy
            set drop($type,img,force) $_defops(copy,img)
            foreach mask [lsort -integer -decreasing $masklist] {
                lappend drop($type,ops) $mask $drop($type,mod,$mask)
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::setcursor
# ----------------------------------------------------------------------------
proc DropSite::setcursor { cursor } {
    catch {.drag configure -cursor $cursor}
}


# ----------------------------------------------------------------------------
#  Command DropSite::setoperation
# ----------------------------------------------------------------------------
proc DropSite::setoperation { op } {
    variable _curop
    variable _dragops
    variable _target
    variable _type
    upvar \#0 DropSite::$_target drop

    if { [info exist drop($_type,ops,$op)] &&
         $_dragops($drop($_type,ops,$op)) } {
        set _curop $op
    } else {
        # force to a copy operation
        set _curop force
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::_init_drag
# ----------------------------------------------------------------------------
proc DropSite::_init_drag { top evt source state X Y type ops data } {
    variable _top
    variable _source
    variable _type
    variable _data
    variable _target
    variable _status
    variable _state
    variable _dragops
    variable _opw
    variable _evt

    if {[info exists _dragops]} {
        unset _dragops
    }
    array set _dragops {copy 1 move 0 link 0}
    foreach op $ops {
        set _dragops($op) 1
    }
    set _target ""
    set _status  0
    set _top     $top
    set _source  $source
    set _type    $type
    set _data    $data

    label $_opw -relief flat -bd 0 -highlightthickness 0 \
        -foreground black -background white

    bind $top <ButtonRelease-$evt> {DropSite::_release %X %Y}
    bind $top <B$evt-Motion>       {DropSite::_motion  %X %Y}
    bind $top <Motion>             {DropSite::_release %X %Y}
    set _state $state
    set _evt   $evt
    _motion $X $Y
}


# ----------------------------------------------------------------------------
#  Command DropSite::_update_operation
# ----------------------------------------------------------------------------
proc DropSite::_update_operation { state } {
    variable _top
    variable _status
    variable _state

    if { $_status & 3 } {
        set _state $state
        _motion [winfo pointerx $_top] [winfo pointery $_top]
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::_compute_operation
# ----------------------------------------------------------------------------
proc DropSite::_compute_operation { target state type } {
    variable  _curop
    variable  _dragops
    upvar \#0 DropSite::$target drop

    foreach {mask op} $drop($type,ops) {
        if { ($state & $mask) == $mask } {
            if { $_dragops($drop($type,ops,$op)) } {
                set _curop $op
                return
            }
        }
    }
    set _curop force
}


# ----------------------------------------------------------------------------
#  Command DropSite::_draw_operation
# ----------------------------------------------------------------------------
proc DropSite::_draw_operation { target type } {
    variable _opw
    variable _curop
    variable _dragops
    variable _tabops
    variable _status

    upvar \#0 DropSite::$target drop

    if { !($_status & 1) } {
        catch {place forget $_opw}
        return
    }

    if { 0 } {
    if { ![info exist drop($type,ops,$_curop)] ||
         !$_dragops($drop($type,ops,$_curop)) } {
        # force to a copy operation
        set _curop copy
        catch {
            $_opw configure -bitmap $_tabops(img,copy)
            place $_opw -relx 1 -rely 1 -anchor se
        }
    }
    } elseif { [string equal $_curop "default"] } {
        catch {place forget $_opw}
    } else {
        catch {
            $_opw configure -bitmap $drop($type,img,$_curop)
            place $_opw -relx 1 -rely 1 -anchor se
        }
    }
}


# ----------------------------------------------------------------------------
#  Command DropSite::_motion
# ----------------------------------------------------------------------------
proc DropSite::_motion { X Y } {
    variable _top
    variable _target
    variable _status
    variable _state
    variable _curop
    variable _type
    variable _data
    variable _source
    variable _evt

    set script [bind $_top <B$_evt-Motion>]
    bind $_top <B$_evt-Motion> {}
    bind $_top <Motion>        {}
    wm geometry $_top "+[expr {$X+1}]+[expr {$Y+1}]"
    update
    if { ![winfo exists $_top] } {
        return
    }
    set path [winfo containing $X $Y]
    if { ![string equal $path $_target] } {
        # path != current target
        if { $_status & 2 } {
            # current target is valid and has recall status
            # generate leave event
            upvar   \#0 DropSite::$_target drop
            uplevel \#0 $drop(overcmd) [list $_target $_source leave $X $Y $_curop $_type $_data]
        }
        set _target $path
        upvar \#0 DropSite::$_target drop
        if { [info exists drop($_type,ops)] } {
            # path is a valid target
            _compute_operation $_target $_state $_type
            if { $drop(overcmd) != "" } {
                set arg     [list $_target $_source enter $X $Y $_curop $_type $_data]
                set _status [uplevel \#0 $drop(overcmd) $arg]
            } else {
                set _status 1
                catch {$_top configure -cursor based_arrow_down}
            }
            _draw_operation $_target $_type
            update
            catch {
                bind $_top <B$_evt-Motion> {DropSite::_motion  %X %Y}
                bind $_top <Motion>        {DropSite::_release %X %Y}
            }
            return
        } else {
            set _status 0
            catch {$_top configure -cursor dot}
            _draw_operation "" ""
        }
    } elseif { $_status & 2 } {
        upvar \#0 DropSite::$_target drop
        _compute_operation $_target $_state $_type
        set arg     [list $_target $_source motion $X $Y $_curop $_type $_data]
        set _status [uplevel \#0 $drop(overcmd) $arg]
        _draw_operation $_target $_type
    }
    update
    catch {
        bind $_top <B$_evt-Motion> {DropSite::_motion  %X %Y}
        bind $_top <Motion>        {DropSite::_release %X %Y}
    }
}



# ----------------------------------------------------------------------------
#  Command DropSite::_release
# ----------------------------------------------------------------------------
proc DropSite::_release { X Y } {
    variable _target
    variable _status
    variable _curop
    variable _source
    variable _type
    variable _data

    if { $_status & 1 } {
        upvar \#0 DropSite::$_target drop

        set res [uplevel \#0 $drop(dropcmd) [list $_target $_source $X $Y $_curop $_type $_data]]
        DragSite::_end_drag $_source $_target $drop($_type,ops,$_curop) $_type $_data $res
    } else {
        if { $_status & 2 } {
            # notify leave event
            upvar \#0 DropSite::$_target drop
            uplevel \#0 $drop(overcmd) [list $_target $_source leave $X $Y $_curop $_type $_data]
        }
        DragSite::_end_drag $_source "" "" $_type $_data 0
    }
}
