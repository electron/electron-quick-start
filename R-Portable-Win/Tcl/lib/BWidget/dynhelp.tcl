# ----------------------------------------------------------------------------
#  dynhelp.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: dynhelp.tcl,v 1.20.2.1 2009/08/12 07:20:21 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - DynamicHelp::configure
#     - DynamicHelp::include
#     - DynamicHelp::sethelp
#     - DynamicHelp::register
#     - DynamicHelp::_motion_balloon
#     - DynamicHelp::_motion_info
#     - DynamicHelp::_leave_info
#     - DynamicHelp::_menu_info
#     - DynamicHelp::_show_help
#     - DynamicHelp::_init
# ----------------------------------------------------------------------------

namespace eval DynamicHelp {
    Widget::define DynamicHelp dynhelp -classonly

    if {$::tcl_version >= 8.5} {
        set fontdefault TkTooltipFont
    } elseif {$Widget::_aqua} {
        set fontdefault {helvetica 11}
    } else {
        set fontdefault {helvetica 8}
    }

    Widget::declare DynamicHelp [list\
        {-foreground     TkResource black         0 label}\
        {-topbackground  TkResource black         0 {label -foreground}}\
        {-background     TkResource "#FFFFC0"     0 label}\
        {-borderwidth    TkResource 1             0 label}\
        {-justify        TkResource left          0 label}\
        [list -font      TkResource $fontdefault  0 label]\
        {-delay          Int        600           0 "%d >= 100 & %d <= 2000"}\
	{-state          Enum       "normal"      0 {normal disabled}}\
        {-padx           TkResource 1             0 label}\
        {-pady           TkResource 1             0 label}\
        {-bd             Synonym    -borderwidth}\
        {-bg             Synonym    -background}\
        {-fg             Synonym    -foreground}\
        {-topbg          Synonym    -topbackground}\
    ]

    proc use {} {}

    variable _registered
    variable _canvases
    variable _texts

    variable _top     ".help_shell"
    variable _id      ""
    variable _delay   600
    variable _current_balloon ""
    variable _current_variable ""
    variable _saved

    Widget::init DynamicHelp $_top {}

    bind BwHelpBalloon <Enter>   {DynamicHelp::_motion_balloon enter  %W %X %Y}
    bind BwHelpBalloon <Motion>  {DynamicHelp::_motion_balloon motion %W %X %Y}
    bind BwHelpBalloon <Leave>   {DynamicHelp::_motion_balloon leave  %W %X %Y}
    bind BwHelpBalloon <Button>  {DynamicHelp::_motion_balloon button %W %X %Y}
    bind BwHelpBalloon <Destroy> {DynamicHelp::_unset_help %W}

    bind BwHelpVariable <Enter>   {DynamicHelp::_motion_info %W}
    bind BwHelpVariable <Leave>   {DynamicHelp::_leave_info  %W}
    bind BwHelpVariable <Destroy> {DynamicHelp::_unset_help  %W}

    bind BwHelpMenu <<MenuSelect>> {DynamicHelp::_menu_info select %W}
    bind BwHelpMenu <Unmap>        {DynamicHelp::_menu_info unmap  %W}
    bind BwHelpMenu <Destroy>      {DynamicHelp::_unset_help %W}
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::configure
# ----------------------------------------------------------------------------
proc DynamicHelp::configure { args } {
    variable _top
    variable _delay

    set res [Widget::configure $_top $args]
    if { [Widget::hasChanged $_top -delay val] } {
        set _delay $val
    }

    return $res
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::include
# ----------------------------------------------------------------------------
proc DynamicHelp::include { class type } {
    set helpoptions [list \
	    [list -helptext String "" 0] \
	    [list -helpvar  String "" 0] \
	    [list -helpcmd  String "" 0] \
	    [list -helptype Enum $type 0 [list balloon variable]] \
	    ]
    Widget::declare $class $helpoptions
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::sethelp
# ----------------------------------------------------------------------------
proc DynamicHelp::sethelp { path subpath {force 0}} {
    foreach {ctype ctext cvar} [Widget::hasChangedX $path \
	    -helptype -helptext -helpvar] break
    if { $force || $ctype || $ctext || $cvar } {
	set htype [Widget::cget $path -helptype]
        switch $htype {
            balloon {
                return [register $subpath balloon \
			[Widget::cget $path -helptext]]
            }
            variable {
                return [register $subpath variable \
			[Widget::cget $path -helpvar] \
			[Widget::cget $path -helptext]]
            }
        }
        return [register $subpath $htype]
    }
}

# ----------------------------------------------------------------------------
#  Command DynamicHelp::register
#
#  DynamicHelp::register path balloon  ?itemOrTag? text
#  DynamicHelp::register path variable ?itemOrTag? text varName
#  DynamicHelp::register path menu varName
#  DynamicHelp::register path menuentry index text
# ----------------------------------------------------------------------------
proc DynamicHelp::register { path type args } {
    variable _registered

    set len [llength $args]
    if {$type == "balloon"  && $len > 1} { 
	switch -exact -- [winfo class $path] {
	    "Canvas" { set type canvasBalloon  }
	    "Text" -
	    "Ctext" { set type textBalloon }
	}
    }
    if {$type == "variable" && $len > 2} { 
	switch -exact -- [winfo class $path] {
	    "Canvas" { set type canvasVariable }
	    "Text" -
	    "Ctext" { set type textVariable }
	}
    }

    if { ![winfo exists $path] } {
        _unset_help $path
        return 0
    }

    switch $type {
        balloon {
            set text [lindex $args 0]
	    if {$text == ""} {
		if {[info exists _registered($path,balloon)]} {
		    unset _registered($path,balloon)
		}
		return 0
	    }

	    _add_balloon $path $text
        }

        canvasBalloon {
            set tagOrItem  [lindex $args 0]
            set text       [lindex $args 1]
	    if {$text == ""} {
		if {[info exists _registered($path,$tagOrItem,balloon)]} {
		    unset _registered($path,$tagOrItem,balloon)
		}
		return 0
	    }

	    _add_canvas_balloon $path $text $tagOrItem
        }

        textBalloon {
            set tagOrItem  [lindex $args 0]
            set text       [lindex $args 1]
	    if {$text == ""} {
		if {[info exists _registered($path,$tagOrItem,balloon)]} {
		    unset _registered($path,$tagOrItem,balloon)
		}
		return 0
	    }

	    _add_text_balloon $path $text $tagOrItem
        }

        variable {
            set var  [lindex $args 0]
            set text [lindex $args 1]
	    if {$text == "" || $var == ""} {
		if {[info exists _registered($path,variable)]} {
		    unset _registered($path,variable)
		}
		return 0
	    }

	    _add_variable $path $text $var
        }

        canvasVariable {
            set tagOrItem  [lindex $args 0]
            set var        [lindex $args 1]
            set text       [lindex $args 2]
	    if {$text == "" || $var == ""} {
		if {[info exists _registered($path,$tagOrItem,variable)]} {
		    unset _registered($path,$tagOrItem,variable)
		}
		return 0
	    }

	    _add_canvas_variable $path $text $var $tagOrItem
        }

        textVariable {
            set tagOrItem  [lindex $args 0]
            set var        [lindex $args 1]
            set text       [lindex $args 2]
	    if {$text == "" || $var == ""} {
		if {[info exists _registered($path,$tagOrItem,variable)]} {
		    unset _registered($path,$tagOrItem,variable)
		}
		return 0
	    }

	    _add_text_variable $path $text $var $tagOrItem
        }

        menu {
            set var [lindex $args 0]
	    if {$var == ""} {
		set cpath [BWidget::clonename $path]
		if {[winfo exists $cpath]} { set path $cpath }
		if {[info exists _registered($path)]} {
		    unset _registered($path)
		}
		return 0
	    }

	    _add_menu $path $var
        }

        menuentry {
            set cpath [BWidget::clonename $path]
            if { [winfo exists $cpath] } { set path $cpath }
            if {![info exists _registered($path)]} { return 0 }

            set text  [lindex $args 1]
            set index [lindex $args 0]
	    if {$text == "" || $index == ""} {
		set idx [lsearch $_registered($path) [list $index *]]
		set _registered($path) [lreplace $_registered($path) $idx $idx]
		return 0
	    }

	    _add_menuentry $path $text $index
        }

        default {
            _unset_help $path
	    return 0
        }
    }

    return 1
}


proc DynamicHelp::add { path args } {
    variable _registered

    array set data {
        -type     balloon
        -text     ""
        -item     ""
        -index    -1
        -command  ""
        -variable ""
    }
    if {[winfo exists $path] && [winfo class $path] == "Menu"} {
	set data(-type) menu
    }
    array set data $args

    set item $path

    switch -- $data(-type) {
        "balloon" {
            if {$data(-item) != ""} {
		switch -exact -- [winfo class $path] {
		    "Canvas" {
			_add_canvas_balloon $path $data(-text) $data(-item)
			set item $path,$data(-item)
		    }
		    "Text" -
		    "Ctext" {
			_add_text_balloon $path $data(-text) $data(-item)
			set item $path,$data(-item)
		    }
		    default {
			_add_balloon $path $data(-text)
		    }
		}
            } else {
                _add_balloon $path $data(-text)
            }

	    if {$data(-variable) != ""} {
		set _registered($item,balloonVar) $data(-variable)
	    }
        }

        "variable" {
            set var $data(-variable)
            if {$data(-item) != ""} {
		switch -exact -- [winfo class $path] {
		    "Canvas" {
			_add_canvas_variable $path $data(-text) $var $data(-item)
			set item $path,$data(-item)
		    } 
		    "Text" -
		    "Ctext" {
			_add_text_variable $path $data(-text) $var $data(-item)
			set item $path,$data(-item)
		    }
		    default {
			_add_variable $path $data(-text) $var
		    }
		}
            } else {
                _add_variable $path $data(-text) $var
            }
        }

        "menu" {
            if {$data(-index) != -1} {
                set cpath [BWidget::clonename $path]
                if { [winfo exists $cpath] } { set path $cpath }
                if {![info exists _registered($path)]} { return 0 }
                _add_menuentry $path $data(-text) $data(-index)
                set item $path,$data(-index)
            } else {
                _add_menu $path $data(-variable)
            }
        }

        default {
            return 0
        }
    }

    if {$data(-command) != ""} {set _registered($item,command) $data(-command)}

    return 1
}


proc DynamicHelp::delete { path } {
    _unset_help $path
}


proc DynamicHelp::_add_bind_tag { path tag } {
    set evt [bindtags $path]
    set idx [lsearch $evt $tag]
    set evt [lreplace $evt $idx $idx]
    lappend evt $tag
    bindtags $path $evt
}


proc DynamicHelp::_add_balloon { path text } {
    variable _registered
    set _registered($path,balloon) $text
    _add_bind_tag $path BwHelpBalloon
}


proc DynamicHelp::_add_canvas_balloon { path text tagOrItem } {
    variable _canvases
    variable _registered

    set _registered($path,$tagOrItem,balloon) $text

    if {![info exists _canvases($path,balloon)]} {
        ## This canvas doesn't have the bindings yet.

        _add_bind_tag $path BwHelpBalloon

        $path bind BwHelpBalloon <Enter> \
            {DynamicHelp::_motion_balloon enter  %W %X %Y 1}
        $path bind BwHelpBalloon <Motion> \
            {DynamicHelp::_motion_balloon motion %W %X %Y 1}
        $path bind BwHelpBalloon <Leave> \
            {DynamicHelp::_motion_balloon leave  %W %X %Y 1}
        $path bind BwHelpBalloon <Button> \
            {DynamicHelp::_motion_balloon button %W %X %Y 1}

        set _canvases($path,balloon) 1
    }

    $path addtag BwHelpBalloon withtag $tagOrItem
}


proc DynamicHelp::_add_text_balloon { path text tagOrItem } {
    variable _texts
    variable _registered

    set _registered($path,$tagOrItem,balloon) $text

    if { ![info exists _texts($path,$tagOrItem,balloon)] } {
        $path tag bind $tagOrItem <Enter> \
            [list DynamicHelp::_motion_balloon enter  $path %X %Y 0 1]
        $path tag bind $tagOrItem <Motion> \
            [list DynamicHelp::_motion_balloon motion $path %X %Y 0 1]
        $path tag bind $tagOrItem <Leave> \
            [list DynamicHelp::_motion_balloon leave  $path %X %Y 0 1]
        $path tag bind $tagOrItem <Button> \
            [list DynamicHelp::_motion_balloon button $path %X %Y 0 1]

        set _texts($path,$tagOrItem,balloon) 1
    }
}


proc DynamicHelp::_add_variable { path text varName } {
    variable _registered
    set _registered($path,variable) [list $varName $text]
    _add_bind_tag $path BwHelpVariable
}


proc DynamicHelp::_add_canvas_variable { path text varName tagOrItem } {
    variable _canvases
    variable _registered

    set _registered($path,$tagOrItem,variable) [list $varName $text]

    if {![info exists _canvases($path,variable)]} {
        ## This canvas doesn't have the bindings yet.

        _add_bind_tag $path BwHelpVariable

        $path bind BwHelpVariable <Enter> \
            {DynamicHelp::_motion_info %W 1}
        $path bind BwHelpVariable <Motion> \
            {DynamicHelp::_motion_info %W 1}
        $path bind BwHelpVariable <Leave> \
            {DynamicHelp::_leave_info  %W 1}

        set _canvases($path,variable) 1
    }

    $path addtag BwHelpVariable withtag $tagOrItem
}


proc DynamicHelp::_add_text_variable { path text varName tagOrItem } {
    variable _texts
    variable _registered

    set _registered($path,$tagOrItem,variable) [list $varName $text]

    if {![info exists _texts($path,$tagOrItem,variable)]} {

        $path tag bind $tagOrItem <Enter> \
            [list DynamicHelp::_motion_info $path 0 1]
        $path tag bind $tagOrItem <Motion> \
            [list DynamicHelp::_motion_info $path 0 1]
        $path tag bind $tagOrItem <Leave> \
            [list DynamicHelp::_leave_info  $path 0 1]

        set _texts($path,$tagOrItem,variable) 1
    }
}


proc DynamicHelp::_add_menu { path varName } {
    variable _registered

    set cpath [BWidget::clonename $path]
    if { [winfo exists $cpath] } { set path $cpath }

    set _registered($path) [list $varName]
    _add_bind_tag $path BwHelpMenu
}


proc DynamicHelp::_add_menuentry { path text index } {
    variable _registered

    set idx  [lsearch $_registered($path) [list $index *]]
    set list [list $index $text]
    if { $idx == -1 } {
	lappend _registered($path) $list
    } else {
	set _registered($path) \
	    [lreplace $_registered($path) $idx $idx $list]
    }
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::_motion_balloon
# ----------------------------------------------------------------------------
proc DynamicHelp::_motion_balloon { type path x y {isCanvasItem 0} {isTextItem 0} } {
    variable _top
    variable _id
    variable _delay
    variable _current_balloon

    set w $path
    if {$isCanvasItem} { 
	set path [_get_canvas_path $path balloon] 
    } elseif {$isTextItem} {
	set path [_get_text_path $path balloon] 
    }

    if { $_current_balloon != $path && $type == "enter" } {
        set _current_balloon $path
        set type "motion"
        destroy $_top
    }
    if { $_current_balloon == $path } {
        if { $_id != "" } {
            after cancel $_id
            set _id ""
        }
        if { $type == "motion" } {
            if { ![winfo exists $_top] } {
                set cmd [list DynamicHelp::_show_help $path $w $x $y]
                set _id [after $_delay $cmd]
            }
            # Bug 923942 proposes to destroy on motion to remove dynhelp on motion.
            # this might be an optional behaviour in future versions
        } else {
            destroy $_top
            set _current_balloon ""
        }
    }
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::_motion_info
# ----------------------------------------------------------------------------
proc DynamicHelp::_motion_info { path {isCanvasItem 0} {isTextItem 0} } {
    variable _saved
    variable _registered
    variable _current_variable

    if {$isCanvasItem} { 
	set path [_get_canvas_path $path variable] 
    } elseif {$isTextItem} {
	set path [_get_text_path $path variable] 
    }

    if { $_current_variable != $path
        && [info exists _registered($path,variable)] } {

        set varName [lindex $_registered($path,variable) 0]
        if {![info exists _saved]} { set _saved [GlobalVar::getvar $varName] }
        set string [lindex $_registered($path,variable) 1]
        if {[info exists _registered($path,command)]} {
            set string [uplevel #0 $_registered($path,command)]
        }
        GlobalVar::setvar $varName $string
        set _current_variable $path
    }
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::_leave_info
#    Leave event may be called twice (in case of pointer grab)
# ----------------------------------------------------------------------------
proc DynamicHelp::_leave_info { path {isCanvasItem 0} {isTextItem 0} } {
    variable _saved
    variable _registered
    variable _current_variable

    if {$isCanvasItem} { 
	set path [_get_canvas_path $path variable] 
    } elseif {$isTextItem} { 
	set path [_get_text_path $path variable] 
    }

    if { [string equal $_current_variable $path] \
         && [info exists _registered($path,variable)] } {
        set varName [lindex $_registered($path,variable) 0]
        GlobalVar::setvar $varName $_saved
        unset _saved
        set _current_variable ""
    }
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::_menu_info
# ----------------------------------------------------------------------------
# We have to check for unmap event on Unix. On Windows, unmap
# is not delivered, but <<MenuSelect>> is triggered appropriately when menu
# is unmapped.
proc DynamicHelp::_menu_info { event path } {
    variable _registered

    if { [info exists _registered($path)] } {
        set index   [$path index active]
        set varName [lindex $_registered($path) 0]
        if { ![string equal $event "unmap"] &&
             ![string equal $index "none"] &&
             [set idx [lsearch $_registered($path) [list $index *]]] != -1 } {
	    set string [lindex [lindex $_registered($path) $idx] 1]
	    if {[info exists _registered($path,$index,command)]} {
		set string [uplevel #0 $_registered($path,$index,command)]
	    }
            GlobalVar::setvar $varName $string
        } else {
            GlobalVar::setvar $varName ""
        }
    }
}


# ----------------------------------------------------------------------------
#  Command DynamicHelp::_show_help
# ----------------------------------------------------------------------------
proc DynamicHelp::_show_help { path w x y } {
    variable _top
    variable _registered
    variable _id
    variable _delay

    if { [Widget::getoption $_top -state] == "disabled" } { return }

    if { [info exists _registered($path,balloon)] } {
        destroy  $_top

        set string $_registered($path,balloon)

	if {[info exists _registered($path,balloonVar)]} {
	    upvar #0 $_registered($path,balloonVar) var
	    if {[info exists var]} { set string $var }
	}

        if {[info exists _registered($path,command)]} {
            set string [uplevel #0 $_registered($path,command)]
        }

	if {$string == ""} { return }

        toplevel $_top -relief flat \
            -bg [Widget::getoption $_top -topbackground] \
            -bd [Widget::getoption $_top -borderwidth] \
            -screen [winfo screen $w]

        wm withdraw $_top
	if { $Widget::_aqua } {
	    ::tk::unsupported::MacWindowStyle style $_top help none
	} else {
	    wm overrideredirect $_top 1
	}

	catch { wm attributes $_top -topmost 1 }

        label $_top.label -text $string \
            -relief flat -bd 0 -highlightthickness 0 \
	    -padx       [Widget::getoption $_top -padx] \
	    -pady       [Widget::getoption $_top -pady] \
            -foreground [Widget::getoption $_top -foreground] \
            -background [Widget::getoption $_top -background] \
            -font       [Widget::getoption $_top -font] \
            -justify    [Widget::getoption $_top -justify]


        pack $_top.label -side left
        update idletasks

	if {![winfo exists $_top]} {return}

        set  scrwidth  [winfo vrootwidth  .]
        set  scrheight [winfo vrootheight .]
        set  width     [winfo reqwidth  $_top]
        set  height    [winfo reqheight $_top]

        # On windows multi screen configurations, coordinates may get outside
        # the main screen. We suppose that all screens have the same size
        # because it is not possible to query the size of the other screens.
        
        set screenx [expr {$x % $scrwidth} ]
        set screeny [expr {$y % $scrheight} ]
        
        # Increment the required size by the deplacement from the passed point
        incr width 8
        incr height 12
        
        if { $screenx+$width > $scrwidth } {
            set x [expr {$x + ($scrwidth - $screenx) - ($width - 8)}]
        } else {
            incr x 8
        }
        if { $screeny+$height > $scrheight } {
            set y [expr {$y - $height}]
        } else {
            incr y 12
        }

        wm geometry  $_top "+$x+$y"
        update idletasks

	if {![winfo exists $_top]} { return }
        wm deiconify $_top
        raise $_top
        # Sometimes the tooltip does not occur under
        # gnome/metacity on ubuntu.
        after 5;
    }
}

# ----------------------------------------------------------------------------
#  Command DynamicHelp::_unset_help
# ----------------------------------------------------------------------------
proc DynamicHelp::_unset_help { path } {
    variable _canvases
    variable _texts
    variable _registered
    variable _top
    variable _current_balloon

    if {[info exists _registered($path)]} { unset _registered($path) }
    if {[winfo exists $path]} {
	set cpath [BWidget::clonename $path]
	if {[info exists _registered($cpath)]} { unset _registered($cpath) }
    }
    array unset _canvases   $path,*
    array unset _texts      $path,*
    array unset _registered $path,*
    if {[string equal $path $_current_balloon]} {destroy $_top}
}

# ----------------------------------------------------------------------------
#  Command DynamicHelp::_get_canvas_path
# ----------------------------------------------------------------------------
proc DynamicHelp::_get_canvas_path { path type {item ""} } {
    variable _registered

    if {$item == ""} { set item [$path find withtag current] }

    ## Check the tags related to this item for the one that
    ## represents our text.  If we have text specific to this
    ## item or for 'all' items, they override any other tags.
    eval [list lappend tags $item all] [$path itemcget $item -tags]
    foreach tag $tags {
	set check $path,$tag
	if {![info exists _registered($check,$type)]} { continue }
	return $check
    }

    return $path
}

# ----------------------------------------------------------------------------
#  Command DynamicHelp::_get_text_path
# ----------------------------------------------------------------------------
proc DynamicHelp::_get_text_path { path type {item ""} } {
    variable _registered

    if {$item == ""} { set item [$path tag names current] }

    ## Check the tags related to this item for the one that
    ## represents our text.  If we have text specific to this
    ## item or for 'all' items, they override any other tags.
    eval [list lappend tags $item all] $item
    foreach tag $tags {
	set check $path,$tag
	if {![info exists _registered($check,$type)]} { continue }
	return $check
    }

    return $path
}
