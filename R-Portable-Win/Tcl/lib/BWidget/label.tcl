# ------------------------------------------------------------------------------
#  label.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: label.tcl,v 1.10.2.3 2011/04/26 08:24:28 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - Label::create
#     - Label::configure
#     - Label::cget
#     - Label::setfocus
#     - Label::_drag_cmd
#     - Label::_drop_cmd
#     - Label::_over_cmd
# ------------------------------------------------------------------------------

namespace eval Label {
    Widget::define Label label DragSite DropSite DynamicHelp

    if {$::Widget::_theme} {
        Widget::tkinclude Label label .l \
            remove { -foreground -text -textvariable -underline -state}
	} else {
        Widget::tkinclude Label label .l \
            remove { -foreground -text -textvariable -underline }
	}

    Widget::declare Label {
        {-name               String     ""     0}
        {-text               String     ""     0}
        {-textvariable       String     ""     0}
        {-underline          Int        -1     0 "%d >= -1"}
        {-focus              String     ""     0}
        {-foreground         TkResource ""     0 label}
        {-disabledforeground TkResource ""     0 button}
        {-state              Enum       normal 0  {normal disabled}}

        {-fg                 Synonym    -foreground}
    }

    DynamicHelp::include Label balloon
    DragSite::include    Label "" 1
    DropSite::include    Label {
        TEXT    {move {}}
        IMAGE   {move {}}
        BITMAP  {move {}}
        FGCOLOR {move {}}
        BGCOLOR {move {}}
        COLOR   {move {}}
    }

    bind BwLabel <FocusIn> [list Label::setfocus %W]
    bind BwLabel <Destroy> [list Label::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command Label::create
# ------------------------------------------------------------------------------
proc Label::create { path args } {
    array set maps [list Label {} .l {}]
    array set maps [Widget::parseArgs Label $args]
    frame $path -class Label -borderwidth 0 -highlightthickness 0 -relief flat -padx 0 -pady 0
    Widget::initFromODB Label $path $maps(Label)

    if {$::Widget::_theme} {
        eval [list ttk::label $path.l] $maps(.l)
    } else {
        eval [list label $path.l] $maps(.l)
	}

    if {$::Widget::_theme} {
        if { [Widget::cget $path -state] != "normal" } {
            $path.l state disabled
		}
    } else {
        if { [Widget::cget $path -state] == "normal" } {
            set fg [Widget::cget $path -foreground]
        } else {
            set fg [Widget::cget $path -disabledforeground]
        }
        $path.l configure -foreground $fg
	}

    set var [Widget::cget $path -textvariable]
    if {  $var == "" &&
          [Widget::cget $path -image] == "" &&
          ($::Widget::_theme || [Widget::cget $path -bitmap] == "")} {
        set desc [BWidget::getname [Widget::cget $path -name]]
        if { $desc != "" } {
            set text  [lindex $desc 0]
            set under [lindex $desc 1]
        } else {
            set text  [Widget::cget $path -text]
            set under [Widget::cget $path -underline]
        }
    } else {
        set under -1
        set text  ""
    }

    $path.l configure -text $text -textvariable $var \
	    -underline $under

    set accel [string tolower [string index $text $under]]
    if { $accel != "" } {
        bind [winfo toplevel $path] <Alt-$accel> "Label::setfocus $path"
    }

    bindtags $path   [list BwLabel [winfo toplevel $path] all]
    bindtags $path.l [list $path.l $path Label [winfo toplevel $path] all]
    pack $path.l -expand yes -fill both

    set dragendcmd [Widget::cget $path -dragendcmd]
    DragSite::setdrag $path $path.l Label::_init_drag_cmd $dragendcmd 1
    DropSite::setdrop $path $path.l Label::_over_cmd Label::_drop_cmd 1
    DynamicHelp::sethelp $path $path.l 1

    return [Widget::create Label $path]
}


# ------------------------------------------------------------------------------
#  Command Label::configure
# ------------------------------------------------------------------------------
proc Label::configure { path args } {
    set oldunder [$path.l cget -underline]
    if { $oldunder != -1 } {
        set oldaccel [string tolower [string index [$path.l cget -text] $oldunder]]
    } else {
        set oldaccel ""
    }
    set res [Widget::configure $path $args]

    set cfg  [Widget::hasChanged $path -foreground fg]
    set cst  [Widget::hasChanged $path -state state]

    if {$::Widget::_theme} {
        if { $cfg } {
            $path.l configure -foreground $fg
        }
        if { $cst } {
            if { $state == "normal" } {
                $path.l state !disabled
            } else {
                $path.l state disabled
            }
        }
    } else {
        set cdfg [Widget::hasChanged $path -disabledforeground dfg]
        if { $cst || $cfg || $cdfg } {
            if { $state == "normal" } {
                $path.l configure -fg $fg
            } else {
                $path.l configure -fg $dfg
            }
        }
	}

    set cv [Widget::hasChanged $path -textvariable var]
    set cb [Widget::hasChanged $path -image img]
    if {$::Widget::_theme} {
        set ci 0
        set bmp ""
	} else {
        set ci [Widget::hasChanged $path -bitmap bmp]
	}
    set cn [Widget::hasChanged $path -name name]
    set ct [Widget::hasChanged $path -text text]
    set cu [Widget::hasChanged $path -underline under]

    if { $cv || $cb || $ci || $cn || $ct || $cu } {
        if {  $var == "" && $img == "" && $bmp == "" } {
            set desc [BWidget::getname $name]
            if { $desc != "" } {
                set text  [lindex $desc 0]
                set under [lindex $desc 1]
            }
        } else {
            set under -1
            set text  ""
        }
        set top [winfo toplevel $path]
        if { $oldaccel != "" } {
            bind $top <Alt-$oldaccel> {}
        }
        set accel [string tolower [string index $text $under]]
        if { $accel != "" } {
            bind $top <Alt-$accel> [list Label::setfocus $path]
        }
        $path.l configure -text $text -underline $under -textvariable $var
    }

    set force [Widget::hasChanged $path -dragendcmd dragend]
    DragSite::setdrag $path $path.l Label::_init_drag_cmd $dragend $force
    DropSite::setdrop $path $path.l Label::_over_cmd Label::_drop_cmd
    DynamicHelp::sethelp $path $path.l

    return $res
}


# ------------------------------------------------------------------------------
#  Command Label::cget
# ------------------------------------------------------------------------------
proc Label::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command Label::identify
# ----------------------------------------------------------------------------
proc Label::identify { path args } {
    eval $path.l identify $args
}


# ----------------------------------------------------------------------------
#  Command Label::instate
# ----------------------------------------------------------------------------
proc Label::instate { path args } {
    eval $path.l instate $args
}


# ----------------------------------------------------------------------------
#  Command Label::state
# ----------------------------------------------------------------------------
proc Label::state { path args } {
    eval $path.l state $args
}


# ------------------------------------------------------------------------------
#  Command Label::setfocus
# ------------------------------------------------------------------------------
proc Label::setfocus { path } {
    if { [string equal [Widget::cget $path -state] "normal"] } {
        set w [Widget::cget $path -focus]
        if { [winfo exists $w] && [Widget::focusOK $w] } {
            focus $w
        }
    }
}


# ------------------------------------------------------------------------------
#  Command Label::_init_drag_cmd
# ------------------------------------------------------------------------------
proc Label::_init_drag_cmd { path X Y top } {
    set path [winfo parent $path]
    if { [set cmd [Widget::cget $path -draginitcmd]] != "" } {
        return [uplevel \#0 $cmd [list $path $X $Y $top]]
    }
    if { [set data [$path.l cget -image]] != "" } {
        set type "IMAGE"
        pack [label $top.l -image $data]
    } elseif { [set data [$path.l cget -bitmap]] != "" } {
        set type "BITMAP"
        pack [label $top.l -bitmap $data]
    } else {
        set data [$path.l cget -text]
        set type "TEXT"
    }
    set usertype [Widget::getoption $path -dragtype]
    if { $usertype != "" } {
        set type $usertype
    }
    return [list $type {copy} $data]
}


# ------------------------------------------------------------------------------
#  Command Label::_drop_cmd
# ------------------------------------------------------------------------------
proc Label::_drop_cmd { path source X Y op type data } {
    set path [winfo parent $path]
    if { [set cmd [Widget::cget $path -dropcmd]] != "" } {
        return [uplevel \#0 $cmd [list $path $source $X $Y $op $type $data]]
    }
    if { $type == "COLOR" || $type == "FGCOLOR" } {
        configure $path -foreground $data
    } elseif { $type == "BGCOLOR" } {
        configure $path -background $data
    } else {
        set text   ""
        set image  ""
        set bitmap ""
        switch -- $type {
            IMAGE   {set image $data}
            BITMAP  {set bitmap $data}
            default {
                set text $data
                if { [set var [$path.l cget -textvariable]] != "" } {
                    configure $path -image "" -bitmap ""
                    GlobalVar::setvar $var $data
                    return
                }
            }
        }
        configure $path -text $text -image $image -bitmap $bitmap
    }
    return 1
}


# ------------------------------------------------------------------------------
#  Command Label::_over_cmd
# ------------------------------------------------------------------------------
proc Label::_over_cmd { path source event X Y op type data } {
    set path [winfo parent $path]
    if { [set cmd [Widget::cget $path -dropovercmd]] != "" } {
        return [uplevel \#0 $cmd [list $path $source $event $X $Y $op $type $data]]
    }
    if { [Widget::getoption $path -state] == "normal" ||
         $type == "COLOR" || $type == "FGCOLOR" || $type == "BGCOLOR" } {
        DropSite::setcursor based_arrow_down
        return 1
    }
    DropSite::setcursor dot
    return 0
}


proc Label::_destroy { path } {
    Widget::destroy $path
}
