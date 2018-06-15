# ----------------------------------------------------------------------------
#  dialog.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: dialog.tcl,v 1.15.2.1 2010/08/04 13:07:59 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - Dialog::create
#     - Dialog::configure
#     - Dialog::cget
#     - Dialog::getframe
#     - Dialog::add
#     - Dialog::itemconfigure
#     - Dialog::itemcget
#     - Dialog::invoke
#     - Dialog::setfocus
#     - Dialog::enddialog
#     - Dialog::draw
#     - Dialog::withdraw
#     - Dialog::_destroy
# ----------------------------------------------------------------------------

# JDC: added -transient and -place flag

namespace eval Dialog {
    Widget::define Dialog dialog ButtonBox

    Widget::bwinclude Dialog ButtonBox .bbox \
	remove	   {-orient} \
	initialize {-spacing 10 -padx 10}

    Widget::declare Dialog {
	{-title	      String	 ""	  0}
	{-geometry    String	 ""	  0}
	{-modal	      Enum	 local	  0 {none local global}}
	{-bitmap      TkResource ""	  1 label}
	{-image	      TkResource ""	  1 label}
	{-separator   Boolean	 0	  1}
	{-cancel      Int	 -1	  0 "%d >= -1"}
	{-parent      String	 ""	  0}
	{-side	      Enum	 bottom	  1 {bottom left top right}}
	{-anchor      Enum	 c	  1 {n e w s c}}
	{-class	      String	 Dialog	  1}
	{-transient   Boolean	 1	  1}
	{-place	      Enum	 center	  0 {none center left right above below}}
    }

    Widget::addmap Dialog "" :cmd   {-background {}}
    Widget::addmap Dialog "" .frame {-background {}}

    bind BwDialog <Destroy> [list Dialog::_destroy %W]

    variable _widget
}


# ----------------------------------------------------------------------------
#  Command Dialog::create
# ----------------------------------------------------------------------------
proc Dialog::create { path args } {
    global   tcl_platform
    variable _widget

    array set maps [list Dialog {} .bbox {}]
    array set maps [Widget::parseArgs Dialog $args]

    # Check to see if the -class flag was specified
    set dialogClass "Dialog"
    array set dialogArgs $maps(Dialog)
    if { [info exists dialogArgs(-class)] } {
	set dialogClass $dialogArgs(-class)
    }

    if { [string equal $tcl_platform(platform) "unix"] } {
	set re raised
	set bd 1
    } else {
	set re flat
	set bd 0
    }
    toplevel $path -relief $re -borderwidth $bd -class $dialogClass
    wm withdraw $path

    Widget::initFromODB Dialog $path $maps(Dialog)

    bindtags $path [list $path BwDialog all]
    wm overrideredirect $path 1
    wm title $path [Widget::cget $path -title]
    set parent [Widget::cget $path -parent]
    if { ![winfo exists $parent] } {
        set parent [winfo parent $path]
    }
    # JDC: made transient optional
    if { [Widget::getoption $path -transient] } {
	wm transient $path [winfo toplevel $parent]
    }

    set side [Widget::cget $path -side]
    if { [string equal $side "left"] || [string equal $side "right"] } {
        set orient vertical
    } else {
        set orient horizontal
    }

    set bbox  [eval [list ButtonBox::create $path.bbox] $maps(.bbox) \
		   -orient $orient]
    set frame [frame $path.frame -relief flat -borderwidth 0]
    set bg [Widget::cget $path -background]
    $path configure -background $bg
    $frame configure -background $bg
    if { [set bitmap [Widget::getoption $path -image]] != "" } {
        set label [label $path.label -image $bitmap -background $bg]
    } elseif { [set bitmap [Widget::getoption $path -bitmap]] != "" } {
        set label [label $path.label -bitmap $bitmap -background $bg]
    }
    if { [Widget::getoption $path -separator] } {
	Separator::create $path.sep -orient $orient -background $bg
    }
    set _widget($path,realized) 0
    set _widget($path,nbut)     0

    set cancel [Widget::getoption $path -cancel]
    bind $path <Escape>  [list ButtonBox::invoke $path.bbox $cancel]
    if {$cancel != -1} {
        wm protocol $path WM_DELETE_WINDOW [list ButtonBox::invoke $path.bbox $cancel]
    }
    bind $path <Return>  [list ButtonBox::invoke $path.bbox default]

    return [Widget::create Dialog $path]
}


# ----------------------------------------------------------------------------
#  Command Dialog::configure
# ----------------------------------------------------------------------------
proc Dialog::configure { path args } {
    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -title title] } {
        wm title $path $title
    }
    if { [Widget::hasChanged $path -background bg] } {
        if { [winfo exists $path.label] } {
            $path.label configure -background $bg
        }
        if { [winfo exists $path.sep] } {
            Separator::configure $path.sep -background $bg
        }
    }
    if { [Widget::hasChanged $path -cancel cancel] } {
        bind $path <Escape>  [list ButtonBox::invoke $path.bbox $cancel]
        if {$cancel == -1} {
            wm protocol $path WM_DELETE_WINDOW ""
        } else {
            wm protocol $path WM_DELETE_WINDOW [list ButtonBox::invoke $path.bbox $cancel]
        }
    }
    return $res
}


# ----------------------------------------------------------------------------
#  Command Dialog::cget
# ----------------------------------------------------------------------------
proc Dialog::cget { path option } {
    return [Widget::cget $path $option]
}


# ----------------------------------------------------------------------------
#  Command Dialog::getframe
# ----------------------------------------------------------------------------
proc Dialog::getframe { path } {
    return $path.frame
}


# ----------------------------------------------------------------------------
#  Command Dialog::add
# ----------------------------------------------------------------------------
proc Dialog::add { path args } {
    variable _widget

    if {[string equal $::tcl_platform(platform) "windows"]
	&& $::tk_version >= 8.4} {
	set width -11
    } else {
	set width 8
    }
    set cmd [list ButtonBox::add $path.bbox -width $width \
		 -command [list Dialog::enddialog $path $_widget($path,nbut)]]
    set res [eval $cmd $args]
    incr _widget($path,nbut)
    return $res
}


# ----------------------------------------------------------------------------
#  Command Dialog::itemconfigure
# ----------------------------------------------------------------------------
proc Dialog::itemconfigure { path index args } {
    return [eval [list ButtonBox::itemconfigure $path.bbox $index] $args]
}


# ----------------------------------------------------------------------------
#  Command Dialog::itemcget
# ----------------------------------------------------------------------------
proc Dialog::itemcget { path index option } {
    return [ButtonBox::itemcget $path.bbox $index $option]
}


# ----------------------------------------------------------------------------
#  Command Dialog::invoke
# ----------------------------------------------------------------------------
proc Dialog::invoke { path index } {
    ButtonBox::invoke $path.bbox $index
}


# ----------------------------------------------------------------------------
#  Command Dialog::setfocus
# ----------------------------------------------------------------------------
proc Dialog::setfocus { path index } {
    ButtonBox::setfocus $path.bbox $index
}


# ----------------------------------------------------------------------------
#  Command Dialog::enddialog
# ----------------------------------------------------------------------------
proc Dialog::enddialog { path result } {
    variable _widget

    set _widget($path,result) $result
}


# ----------------------------------------------------------------------------
#  Command Dialog::draw
# ----------------------------------------------------------------------------
proc Dialog::draw { path {focus ""} {overrideredirect 0} {geometry ""}} {
    variable _widget

    set parent [Widget::getoption $path -parent]
    if { !$_widget($path,realized) } {
        set _widget($path,realized) 1
        if { [llength [winfo children $path.bbox]] } {
            set side [Widget::getoption $path -side]
            if {[string equal $side "left"] || [string equal $side "right"]} {
                set pad  -padx
                set fill y
            } else {
                set pad  -pady
                set fill x
            }
            pack $path.bbox -side $side -padx 1m -pady 1m \
		-anchor [Widget::getoption $path -anchor]
            if { [winfo exists $path.sep] } {
                pack $path.sep -side $side -fill $fill $pad 2m
            }
        }
        if { [winfo exists $path.label] } {
            pack $path.label -side left -anchor n -padx 3m -pady 3m
        }
        pack $path.frame -padx 1m -pady 1m -fill both -expand yes
    }

    set geom [Widget::getMegawidgetOption $path -geometry]
    if { $geom != "" } {
	wm geometry $path $geom
    }

    if { [string equal $geometry ""] && ($geom == "") } {
	set place [Widget::getoption $path -place]
	if { ![string equal $place none] } {
	    if { [winfo exists $parent] } {
		BWidget::place $path 0 0 $place $parent
	    } else {
		BWidget::place $path 0 0 $place
	    }
	}
    } else {
	if { $geom != "" } {
	    wm geometry $path $geom
	} else {
	    wm geometry $path $geometry
	}
    }
    update idletasks
    wm overrideredirect $path $overrideredirect
    wm deiconify $path

    # patch by Bastien Chevreux (bach@mwgdna.com)
    # As seen on Windows systems *sigh*
    # When the toplevel is withdrawn, the tkwait command will wait forever.
    #  So, check that we are not withdrawn
    if {![winfo exists $parent] || \
	    ([wm state [winfo toplevel $parent]] != "withdrawn")} {
	tkwait visibility $path
    }
    BWidget::focus set $path
    if { [winfo exists $focus] } {
        focus -force $focus
    } else {
        ButtonBox::setfocus $path.bbox default
    }

    if { [set grab [Widget::cget $path -modal]] != "none" } {
        BWidget::grab $grab $path
        if {[info exists _widget($path,result)]} { 
            unset _widget($path,result)
        }
        tkwait variable Dialog::_widget($path,result)
        if { [info exists _widget($path,result)] } {
            set res $_widget($path,result)
            unset _widget($path,result)
        } else {
            set res -1
        }
        withdraw $path
        return $res
    }
    return ""
}


# ----------------------------------------------------------------------------
#  Command Dialog::withdraw
# ----------------------------------------------------------------------------
proc Dialog::withdraw { path } {
    BWidget::grab release $path
    BWidget::focus release $path
    if { [winfo exists $path] } {
        wm withdraw $path
    }
}


# ----------------------------------------------------------------------------
#  Command Dialog::_destroy
# ----------------------------------------------------------------------------
proc Dialog::_destroy { path } {
    variable _widget

    Dialog::enddialog $path -1

    BWidget::grab  release $path
    BWidget::focus release $path
    if {[info exists _widget($path,result)]} {
        unset _widget($path,result)
    }
    unset _widget($path,realized)
    unset _widget($path,nbut)

    Widget::destroy $path
}
