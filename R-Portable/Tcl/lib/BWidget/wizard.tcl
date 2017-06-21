# ------------------------------------------------------------------------------
#  wizard.tcl
#
# ------------------------------------------------------------------------------
#  Index of commands:
#
#   Public commands
#     - Wizard::create
#     - Wizard::configure
#     - Wizard::cget
#
#   Private commands (event bindings)
#     - Wizard::_destroy
# ------------------------------------------------------------------------------

namespace eval Wizard {
    Widget::define Wizard wizard ButtonBox Separator PagesManager

    namespace eval Step {
	Widget::declare Wizard::Step {
            {-type            String     "step"   1  }
	    {-data            String     ""       0  }
	    {-title           String     ""       0  }
	    {-default         String     "next"   0  }
	    {-text1           String     ""       0  }
	    {-text2           String     ""       0  }
	    {-text3           String     ""       0  }
	    {-text4           String     ""       0  }
	    {-text5           String     ""       0  }
	    {-icon            String     ""       0  }
	    {-image           String     ""       0  }
	    {-bitmap          String     ""       0  }
	    {-iconbitmap      String     ""       0  }

            {-create          Boolean    "0"      1  }
            {-appendorder     Boolean    "1"      0  }

            {-nexttext        String     "Next >" 0  }
            {-backtext        String     "< Back" 0  }
            {-helptext        String     "Help"   0  }
            {-canceltext      String     "Cancel" 0  }
            {-finishtext      String     "Finish" 0  }
            {-separatortext   String     ""       0  }

            {-createcommand   String     ""       0  }
            {-raisecommand    String     ""       0  }
	    {-nextcommand     String     ""       0  }
	    {-backcommand     String     ""       0  }
	    {-helpcommand     String     ""       0  }
	    {-cancelcommand   String     ""       0  }
	    {-finishcommand   String     ""       0  }

	}
    }

    namespace eval Branch {
	Widget::declare Wizard::Branch {
            {-type            String     "branch" 1  }
            {-command         String     ""       0  }
            {-action          Enum       "merge"  0  {merge terminate} }
        }
    }

    namespace eval Widget {
	Widget::declare Wizard::Widget {
            {-type            String     "widget" 1  }
            {-step            String     ""       1  }
            {-widget          String     ""       1  }
	}
    }

    namespace eval layout {}

    Widget::tkinclude Wizard frame :cmd \
    	include    { -width -height -background -foreground -cursor }

    Widget::declare Wizard {
   	{-type            Enum       "dialog" 1 {dialog frame} }
   	{-width           TkResource "450"    0 frame}
	{-height          TkResource "300"    0 frame}
	{-relief          TkResource "flat"   0 frame}
	{-borderwidth     TkResource "0"      0 frame}
	{-background      TkResource ""       0 frame}
	{-foreground      String     "black"  0      }
	{-title           String     "Wizard" 0      }

	{-autobuttons     Boolean    "1"      0      }
	{-helpbutton      Boolean    "0"      1      }
	{-finishbutton    Boolean    "0"      1      }
        {-resizable       String     "0 0"    0      }
	{-separator       Boolean    "1"      1      }
        {-parent          String     "."      1      }
        {-transient       Boolean    "1"      1      }
        {-place           Enum       "center" 1
                                     {none center left right above below}}

        {-icon            String     ""       0      }
        {-image           String     ""       0      }
	{-bitmap          String     ""       0      }
	{-iconbitmap      String     ""       0      }
        {-raisecommand    String     ""       0      }
        {-createcommand   String     ""       0      }
        {-separatortext   String     ""       0      }

        {-fg              Synonym    -foreground     }
        {-bg              Synonym    -background     }
        {-bd              Synonym    -borderwidth    }
    }

    image create photo Wizard::none

    Widget::addmap Wizard "" :cmd { -background {} -relief {} -borderwidth {} }

    Widget::addmap Wizard "" .steps { -width {} -height {} }

    bind Wizard <Destroy> [list Wizard::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command Wizard::create
# ------------------------------------------------------------------------------
proc Wizard::create { path args } {
    array set maps [list Wizard {} :cmd {}]
    array set maps [Widget::parseArgs Wizard $args]

    Widget::initFromODB Wizard $path $maps(Wizard)

    Widget::getVariable $path data
    Widget::getVariable $path branches

    array set data {
        steps   ""
        buttons ""
        order   ""
	current ""
    }

    array set branches {
        root    ""
    }

    set frame $path

    set type [Widget::cget $path -type]

    if {[string equal $type "dialog"]} {
        set top $path
        eval [list toplevel $path] $maps(:cmd) -class Wizard
        wm withdraw   $path
        wm protocol   $path WM_DELETE_WINDOW [list $path cancel]
        if {[Widget::cget $path -transient]} {
	    wm transient  $path [Widget::cget $path -parent]
        }
        eval wm resizable $path [Widget::cget $path -resizable]

        bind $path <Escape>         [list $path cancel]
        bind $path <<WizardFinish>> [list destroy $path]
        bind $path <<WizardCancel>> [list destroy $path]
    } else {
        set top [winfo toplevel $path]
        eval [list frame $path] $maps(:cmd) -class Wizard
    }

    wm title $top [Widget::cget $path -title]

    PagesManager $path.steps
    pack $path.steps -expand 1 -fill both

    widgets $path set steps -widget $path.steps

    if {[Widget::cget $path -separator]} {
        frame $path.separator
        pack $path.separator -fill x

        label $path.separator.l -text [Widget::cget $path -separatortext]
        pack  $path.separator.l -side left

        Separator $path.separator.s -orient horizontal
        pack $path.separator.s -side left -expand 1 -fill x -pady 2

	widgets $path set separator      -widget $path.separator.s
	widgets $path set separatortext  -widget $path.separator.l
	widgets $path set separatorframe -widget $path.separator
    }

    ButtonBox $path.buttons -spacing 2 -homogeneous 1
    pack $path.buttons -anchor se -padx 10 -pady 5

    widgets $path set buttons -widget $path.buttons

    insert $path button end back  -text "< Back" -command "$path back" -width 12
    insert $path button end next  -text "Next >" -command "$path next"
    if {[Widget::cget $path -finishbutton]} {
	insert $path button end finish -text "Finish" -command "$path finish"
    }
    insert $path button end cancel -text "Cancel" -command "$path cancel"

    if {[Widget::cget $path -helpbutton]} {
	$path.buttons configure -spacing 10
	insert $path button 0 help -text "Help" -command "$path help"
	$path.buttons configure -spacing 2
    }

    return [Widget::create Wizard $path]
}


# ------------------------------------------------------------------------------
#  Command Wizard::configure
# ------------------------------------------------------------------------------
proc Wizard::configure { path args } {
    set res [Widget::configure $path $args]

    if {[Widget::hasChanged $path -title title]} {
	wm title [winfo toplevel $path] $title
    }

    if {[Widget::hasChanged $path -resizable resize]} {
	eval wm resizable [winfo toplevel $path] $resize
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command Wizard::cget
# ------------------------------------------------------------------------------
proc Wizard::cget { path option } {
    return [Widget::cget $path $option]
}


proc Wizard::itemcget { path item option } {
    Widget::getVariable $path items
    Widget::getVariable $path steps
    Widget::getVariable $path buttons
    Widget::getVariable $path widgets

    if {![exists $path $item]} {
	## It's not an item.  Just pass the configure to the widget.
	set item [$path widgets get $item]
	return [eval $item configure $args] 
    }

    if {[_is_step $path $item]} {
        ## It's a step
        return [Widget::cget $items($item) $option]
    }

    if {[_is_branch $path $item]} {
        ## It's a branch
        return [Widget::cget $items($item) $option]
    }

    if {[info exists buttons($item)]} {
        ## It's a button
        return [$path.buttons itemcget $items($item) $option]
    }

    return -code error "item \"$item\" does not exist"
}


proc Wizard::itemconfigure { path item args } {
    Widget::getVariable $path items
    Widget::getVariable $path steps
    Widget::getVariable $path buttons
    Widget::getVariable $path widgets

    if {![exists $path $item]} {
	## It's not an item.  Just pass the configure to the widget.
	set item [$path widgets get $item]
	return [eval $item configure $args] 
    }

    if {[info exists steps($item)]} {
        ## It's a step.
        set res [Widget::configure $items($item) $args]

	if {$item == [$path step current]} {
	    if {[Widget::hasChanged $items($item) -title title]} {
		wm title [winfo toplevel $path] $title
	    }
	}

	return $res
    }

    if {[_is_branch $path $item]} {
        ## It's a branch
        return [Widget::configure $items($item) $args]
    }

    if {[info exists buttons($item)]} {
        ## It's a button.
        return [eval $path.buttons itemconfigure [list $items($item)] $args]
    }

    return -code error "item \"$item\" does not exist"
}


proc Wizard::show { path } {
    wm deiconify [winfo toplevel $path]
}


proc Wizard::invoke { path button } {
    Widget::getVariable $path buttons
    if {![info exists buttons($button)]} {
        return -code error "button \"$button\" does not exist"
    }
    [$path widgets get $button] invoke
}


proc Wizard::insert { path type idx args } {
    Widget::getVariable $path items
    Widget::getVariable $path widgets
    Widget::getVariable $path branches

    switch -- $type {
        "button" {
            set node [lindex $args 0]
        }

        "step" - "branch" {
            set node   [lindex $args 1]
            set branch [lindex $args 0]

            if {![info exists branches($branch)]} {
                return -code error "branch \"$branch\" does not exist"
            }
	}

	default {
	    set types [list button branch step]
	    set err [BWidget::badOptionString option $type $types]
	    return -code error $err
	}
    }

    if {[exists $path $node]} {
        return -code error "item \"$node\" already exists"
    }

    eval _insert_$type $path $idx $args
}


proc Wizard::back { path } {
    Widget::getVariable $path data
    Widget::getVariable $path items
    set step [$path raise]
    if {![string equal $step ""]} {
        set cmd [Widget::cget $items($step) -backcommand]
        if {![string equal $cmd ""]} {
            set res [uplevel #0 $cmd]
            if {!$res} { return }
        }
    }

    set data(order) [lreplace $data(order) end end]
    set item [lindex $data(order) end]

    $path raise $item

    event generate $path <<WizardStep>>
    event generate $path <<WizardBack>>

    return $item
}


proc Wizard::next { path } {
    Widget::getVariable $path data
    Widget::getVariable $path items

    set step [$path raise]
    if {![string equal $step ""]} {
        set cmd [Widget::cget $items($step) -nextcommand]
        if {![string equal $cmd ""]} {
            set res [uplevel #0 $cmd]
            if {!$res} { return }
        }
    }

    set item [step $path next]

    if {[Widget::cget $items($item) -appendorder]} {
	lappend data(order) $item
    }

    $path raise $item

    event generate $path <<WizardStep>>
    event generate $path <<WizardNext>>

    return $item
}


proc Wizard::cancel { path } {
    Widget::getVariable $path items
    set step [$path raise]
    if {![string equal $step ""]} {
        set cmd [Widget::cget $items($step) -cancelcommand]
        if {![string equal $cmd ""]} {
            set res [uplevel #0 $cmd]
            if {!$res} { return }
        }
    }

    event generate $path <<WizardCancel>>
}


proc Wizard::finish { path } {
    Widget::getVariable $path items
    set step [$path raise]
    if {![string equal $step ""]} {
        set cmd [Widget::cget $items($step) -finishcommand]
        if {![string equal $cmd ""]} {
            set res [uplevel #0 $cmd]
            if {!$res} { return }
        }
    }
        
    event generate $path <<WizardFinish>>
}


proc Wizard::help { path } {
    Widget::getVariable $path items
    set step [$path raise]
    if {![string equal $step ""]} {
        set cmd [Widget::cget $items($step) -helpcommand]
        if {![string equal $cmd ""]} {
            uplevel #0 $cmd
        }
    }
        
    event generate $path <<WizardHelp>>
}


proc Wizard::step { path node {start ""} {traverse 1} } {
    Widget::getVariable $path data
    Widget::getVariable $path items
    Widget::getVariable $path branches

    if {![string equal $start ""]} {
        if {![exists $path $start]} {
            return -code error "item \"$start\" does not exist"
        }
    }

    switch -- $node {
        "current" {
            set item [$path raise]
        }

        "end" - "last" {
            ## Keep looping through 'next' until we hit the end.
            set item [$path step next]
            while {![string equal $item ""]} {
                set last $item
                set item [$path step next $item] 
            }
            set item $last
        }

        "back" - "previous" {
            if {[string equal $start ""]} {
                set item [lindex $data(order) end-1]
            } else {
                set idx [lsearch $data(order) $start]
                incr idx -1
                if {$idx < 0} { return }
                set item [lindex $data(order) $idx]
            }
        }

        "next" {
            set step [$path raise]
            if {![string equal $start ""]} { set step $start }

            set branch [$path branch $step]
            if {$traverse && [_is_branch $path $step]} {
                ## This step is a branch.  Let's figure out where to go next.
                if {[traverse $path $step]} {
                    ## It's ok to traverse into this branch.
                    ## Set step to null so that we'll end up finding the
                    ## first step in the branch.
                    set branch $step
                    set step   ""
                }
            }

            set  idx [lsearch $branches($branch) $step]
            incr idx

            set item [lindex $branches($branch) $idx]

            if {$idx >= [llength $branches($branch)]} {
                ## We've reached the end of this branch.
                ## If it's the root branch, or this branch terminates we return.
                if {[string equal $branch "root"]
                    || [Widget::cget $items($branch) -action] == "terminate"} {
                    return
                }

                ## We want to merge back with our parent branch.
                set item [step $path next $branch 0]
            }

            ## If this step is a branch, find the next step after it.
            if {$traverse && [_is_branch $path $item]} {
                set item [$path step next $item]
            }
        }

        default {
            if {![exists $path $node]} {
                return -code error "item \"$node\" does not exist"
            }
            set item $node
        }
    }

    return $item
}


proc Wizard::nodes { path branch {first ""} {last ""} } {
    Widget::getVariable $path data
    Widget::getVariable $path branches
    if {$first == ""} { return $branches($branch) }
    if {$last == ""}  { return [lindex $branches($branch) $first] }
    return [lrange $data(steps) $first $last]
}


proc Wizard::index { path item } {
    Widget::getVariable $path branches
    set branch [$path branch $item]
    return [lsearch $branches($branch) $item]
}


proc Wizard::raise { path {item ""} } {
    Widget::getVariable $path data
    Widget::getVariable $path items

    set steps   $path.steps
    set buttons $path.buttons

    if {[string equal $item ""]} { return $data(current) }

    $path createStep $item

    ## Eval the global raisecommand if we have one, appending the item.
    set cmd [Widget::cget $path -raisecommand]
    if {![string equal $cmd ""]} {
        uplevel #0 $cmd [list $item]
    }

    ## Eval this item's raisecommand if we have one.
    set cmd [Widget::cget $items($item) -raisecommand]
    if {![string equal $cmd ""]} {
        uplevel #0 $cmd
    }

    set title [getoption $path $item -title]
    wm title [winfo toplevel $path] $title

    if {[Widget::cget $path -separator]} {
	set txt [getoption $path $item -separatortext]
	$path itemconfigure separatortext -text $txt
    }

    set default [Widget::cget $items($item) -default]
    set button  [lsearch $data(buttons) $default]
    $buttons setfocus $button

    $steps raise $item

    set data(current) $item

    set back [$path step back]
    set next [$path step next]

    if {[Widget::cget $path -autobuttons]} {
        set txt [Widget::cget $items($item) -backtext]
        $path itemconfigure back   -text $txt -state normal
        set txt [Widget::cget $items($item) -nexttext]
        $path itemconfigure next   -text $txt -state normal
        set txt [Widget::cget $items($item) -canceltext]
        $path itemconfigure cancel -text $txt -state normal
	if {[Widget::cget $path -helpbutton]} {
	    set txt [Widget::cget $items($item) -helptext]
	    $path itemconfigure help -text $txt
	}

	if {[Widget::cget $path -finishbutton]} {
	    set txt [Widget::cget $items($item) -finishtext]
	    $path itemconfigure finish -text $txt -state disabled
	}

	if {[string equal $back ""]} {
            $path itemconfigure back -state disabled
        }

	if {[string equal $next ""]} {
	    if {[Widget::cget $path -finishbutton]} {
		$path itemconfigure next   -state disabled
		$path itemconfigure finish -state normal
	    } else {
		set txt [Widget::cget $items($item) -finishtext]
		$path itemconfigure next -text $txt -command [list $path finish]
	    }
            $path itemconfigure back   -state disabled
            $path itemconfigure cancel -state disabled
        } else {
            set txt [Widget::cget $items($item) -nexttext]
            $path itemconfigure next -text $txt -command [list $path next]
        }
    }

    event generate $path <<WizardStep>>

    if {[string equal $next ""]} { event generate $path <<WizardLastStep>>  }
    if {[string equal $back ""]} { event generate $path <<WizardFirstStep>> }

    return $item
}


proc Wizard::widgets { path command args } {
    Widget::getVariable $path items
    Widget::getVariable $path widgets
    Widget::getVariable $path stepWidgets

    switch -- $command {
	"set" {
	    set node [lindex $args 0]
	    if {[string equal $node ""]} {
		set err [BWidget::wrongNumArgsString \
			"$path widgets set <name> ?option ..?"]
		return -code error $err
	    }
	    set args [lreplace $args 0 0]
	    set item $path.#widget#$node

	    Widget::init Wizard::Widget $item $args
	    set step   [Widget::cget $item -step]
	    set widget [Widget::cget $item -widget]
	    if {[string equal $step ""]} {
		set widgets($node) $widget
	    } else {
		set stepWidgets($step,$node) $widget
	    }
	    return $widget
	}

	"get" {
	    set node [lindex $args 0]
	    if {[string equal $node ""]} {
		return [array names widgets]
	    }
	    set args [lreplace $args 0 0]

	    array set map  [list Wizard::Widget {}]
	    array set map  [Widget::parseArgs Wizard::Widget $args]
	    array set data $map(Wizard::Widget)

	    if {[info exists data(-step)]} {
	    	set step $data(-step)
	    } else {
		set step [$path step current]
	    }

	    ## If a widget exists for this step, return it.
	    if {[info exists stepWidgets($step,$node)]} {
		return $stepWidgets($step,$node)
	    }

	    ## See if a widget exists on the global level.
	    if {![info exists widgets($node)]} {
		return -code error "item \"$node\" does not exist"
	    }
	    return $widgets($node)
	}

	default {
	    set err [BWidget::badOptionString option $command [list get set]]
	    return -code error $err
	}
    }
}


proc Wizard::variable { path step option } {
    set item $path.$step
    return [Widget::varForOption $item $option]
}


proc Wizard::branch { path {node "current"} } {
    Widget::getVariable $path data
    if {[string equal $node "current"]} { set item [$path step current] }
    if {[string equal $node ""]} { return "root" }
    if {[info exists data($node,branch)]} { return $data($node,branch) }
    return -code error "item \"$node\" does not exist"
}


proc Wizard::traverse { path node } {
    Widget::getVariable $path items

    if {$node == "root"} { return 1 }

    if {![_is_branch $path $node]} {
        return -code error "branch \"$node\" does not exist"
    }

    set cmd [Widget::cget $items($node) -command]
    if {[string equal $cmd ""]} { return 1 }
    return [uplevel #0 $cmd]
}


proc Wizard::exists { path item } {
    Widget::getVariable $path items
    return [info exists items($item)]
}


proc Wizard::createStep { path item {delete 0} } {
    Widget::getVariable $path data
    Widget::getVariable $path items
    Widget::getVariable $path steps

    if {![_is_step $path $item]} { return }

    if {$delete} {
        if {[$path.steps exists $item]} {
            $path.steps delete $item
        }
        if {[info exists data($item,realized)]} {
            unset data($item,realized)
        }
    }

    if {![info exists data($item,realized)]} {
        ## Eval the global createcommand if we have one, appending the item.
        set cmd [Widget::cget $path -createcommand]
        if {![string equal $cmd ""]} {
            uplevel #0 $cmd [list $item]
        }

        ## Eval this item's createcommand if we have one.
        set cmd [Widget::cget $items($item) -createcommand]
        if {![string equal $cmd ""]} {
            uplevel #0 $cmd
        }

        set data($item,realized) 1
    }

    return
}


proc Wizard::getoption { path item option } {
    Widget::getVariable $path items
    return [Widget::getOption $option "" $path $items($item)]
}


proc Wizard::reorder { path parent nodes } {
    Widget::getVariable $path branches
    set branches($parent) $nodes
}


proc Wizard::_insert_button { path idx node args } {
    Widget::getVariable $path data
    Widget::getVariable $path items
    Widget::getVariable $path buttons
    Widget::getVariable $path widgets

    set buttons($node) 1
    set widgets($node) [eval $path.buttons insert $idx $args]
    set item   [string map [list $path.buttons.b {}] $widgets($node)]
    set items($node) $item
    return $widgets($node)
}


proc Wizard::_insert_step { path idx branch node args } {
    Widget::getVariable $path data
    Widget::getVariable $path steps
    Widget::getVariable $path items
    Widget::getVariable $path widgets
    Widget::getVariable $path branches

    set steps($node) 1
    lappend data(steps) $node
    set data($node,branch) $branch
    if {$idx == "end"} {
        lappend branches($branch) $node
    } else {
	set branches($branch) [linsert $branches($branch) $idx $node]
    }

    set items($node) $path.$node
    Widget::init Wizard::Step $items($node) $args
    set widgets($node) [$path.steps add $node]
    if {[Widget::cget $items($node) -create]} { $path createStep $node }
    return $widgets($node)
}


proc Wizard::_insert_branch { path idx branch node args } {
    Widget::getVariable $path data
    Widget::getVariable $path items
    Widget::getVariable $path branches

    set branches($node)    [list]
    lappend data(branches) $node
    set data($node,branch) $branch
    if {$idx == "end"} {
        lappend branches($branch) $node
    } else {
        set branches($branch) [linsert $branches($branch) $idx $node]
    }

    set items($node) $path.$node
    Widget::init Wizard::Branch $items($node) $args
}


proc Wizard::_is_step { path node } {
    Widget::getVariable $path steps
    return [info exists steps($node)]
}


proc Wizard::_is_branch { path node } {
    Widget::getVariable $path branches
    return [info exists branches($node)]
}


# ------------------------------------------------------------------------------
#  Command Wizard::_destroy
# ------------------------------------------------------------------------------
proc Wizard::_destroy { path } {
    Widget::destroy $path
}


proc SimpleWizard { path args } {
    option add *WizLayoutSimple*Label.padX                5    interactive
    option add *WizLayoutSimple*Label.anchor              nw   interactive
    option add *WizLayoutSimple*Label.justify             left interactive
    option add *WizLayoutSimple*Label.borderWidth         0    interactive
    option add *WizLayoutSimple*Label.highlightThickness  0    interactive

    set cmd [list Wizard::layout::simple $path]
    return [eval [list Wizard $path] $args [list -createcommand $cmd]]
}


proc ClassicWizard { path args } {
    option add *WizLayoutClassic*Label.padX                5    interactive
    option add *WizLayoutClassic*Label.anchor              nw   interactive
    option add *WizLayoutClassic*Label.justify             left interactive
    option add *WizLayoutClassic*Label.borderWidth         0    interactive
    option add *WizLayoutClassic*Label.highlightThickness  0    interactive

    set cmd [list Wizard::layout::classic $path]
    return [eval [list Wizard $path] $args [list -createcommand $cmd]]
}


proc Wizard::layout::simple { wizard step } {
    set frame [$wizard widgets get $step]

    set layout [$wizard widgets set layout -widget $frame.layout -step $step]

    foreach w [list titleframe pretext posttext clientArea] {
	set $w [$wizard widgets set $w -widget $layout.$w -step $step]
    }

    foreach w [list title subtitle icon] {
	set $w [$wizard widgets set $w -widget $titleframe.$w -step $step]
    }

    frame $layout -class WizLayoutSimple

    pack $layout -expand 1 -fill both

    # Client area. This is where the caller places its widgets.
    frame $clientArea -bd 8 -relief flat

    Separator $layout.sep1 -relief groove -orient horizontal

    # title and subtitle and icon
    frame $titleframe -bd 4 -relief flat -background white
    label $title -background white -textvariable [$wizard variable $step -text1]
    label $subtitle -height 2 -background white -padx 15 -width 40 \
    	-textvariable [$wizard variable $step -text2]

    label $icon -borderwidth 0 -background white -anchor c
    set iconImage [$wizard getoption $step -icon]
    if {![string equal $iconImage ""]} { $icon configure -image $iconImage }

    set labelfont [font actual [$title cget -font]]
    $title configure -font [concat $labelfont -weight bold]

    # put the title, subtitle and icon inside the frame we've built for them
    grid $title    -in $titleframe -row 0 -column 0 -sticky nsew
    grid $subtitle -in $titleframe -row 1 -column 0 -sticky nsew
    grid $icon     -in $titleframe -row 0 -column 1 -rowspan 2 -padx 8
    grid columnconfigure $titleframe 0 -weight 1
    grid columnconfigure $titleframe 1 -weight 0

    # pre and post text.
    label $pretext  -textvariable [$wizard variable $step -text3]
    label $posttext -textvariable [$wizard variable $step -text4]

    # when our label widgets change size we want to reset the
    # wraplength to that same size.
    foreach widget {title subtitle pretext posttext} {
	bind [set $widget] <Configure> {
            # yeah, I know this looks weird having two after idle's, but
            # it helps prevent the geometry manager getting into a tight
            # loop under certain circumstances
            #
            # note that subtracting 10 is just a somewhat arbitrary number
            # to provide a little padding...
            after idle {after idle {%W configure -wraplength [expr {%w -10}]}}
        }
    }

    grid $titleframe  -row 0 -column 0 -sticky nsew -padx 0
    grid $layout.sep1 -row 1 -sticky ew 
    grid $pretext     -row 2 -sticky nsew -padx 8 -pady 8
    grid $clientArea  -row 3 -sticky nsew -padx 8 -pady 8
    grid $posttext    -row 4 -sticky nsew -padx 8 -pady 8

    grid columnconfigure $layout 0 -weight 1
    grid rowconfigure    $layout 0 -weight 0
    grid rowconfigure    $layout 1 -weight 0
    grid rowconfigure    $layout 2 -weight 0
    grid rowconfigure    $layout 3 -weight 1
    grid rowconfigure    $layout 4 -weight 0
}

proc Wizard::layout::classic { wizard step } {
    set frame [$wizard widgets get $step]

    set layout [$wizard widgets set layout -widget $frame.layout -step $step]
    foreach w [list title subtitle icon pretext posttext clientArea] {
	set $w [$wizard widgets set $w -widget $layout.$w -step $step]
    }

    frame $layout -class WizLayoutClassic

    pack $layout -expand 1 -fill both

    # Client area. This is where the caller places its widgets.
    frame $clientArea -bd 8 -relief flat
    
    Separator $layout.sep1 -relief groove -orient vertical

    # title and subtitle
    label $title    -textvariable [$wizard variable $step -text1]
    label $subtitle -textvariable [$wizard variable $step -text2] -height 2

    array set labelfont [font actual [$title cget -font]]
    incr labelfont(-size) 6
    set  labelfont(-weight) bold
    $title configure -font [array get labelfont]

    # pre and post text. 
    label $pretext  -textvariable [$wizard variable $step -text3]
    label $posttext -textvariable [$wizard variable $step -text4]

    # when our label widgets change size we want to reset the
    # wraplength to that same size.
    foreach widget {title subtitle pretext posttext} {
        bind [set $widget] <Configure> {
            # yeah, I know this looks weird having two after idle's, but
            # it helps prevent the geometry manager getting into a tight
            # loop under certain circumstances
            #
            # note that subtracting 10 is just a somewhat arbitrary number
            # to provide a little padding...
            after idle {after idle {%W configure -wraplength [expr {%w -10}]}}
        }
    }

    label $icon -borderwidth 1 -relief sunken -background white \
        -anchor c -width 96 -image Wizard::none
    set iconImage [$wizard getoption $step -icon]
    if {![string equal $iconImage ""]} { $icon configure -image $iconImage }

    grid $icon       -row 0 -column 0 -sticky nsew -padx 8 -pady 8 -rowspan 5
    grid $title      -row 0 -column 1 -sticky ew   -padx 8 -pady 8
    grid $subtitle   -row 1 -column 1 -sticky ew   -padx 8 -pady 8
    grid $pretext    -row 2 -column 1 -sticky ew   -padx 8
    grid $clientArea -row 3 -column 1 -sticky nsew -padx 8
    grid $posttext   -row 4 -column 1 -sticky ew   -padx 8 -pady 24

    grid columnconfigure $layout 0 -weight 0
    grid columnconfigure $layout 1 -weight 1

    grid rowconfigure    $layout 0 -weight 0
    grid rowconfigure    $layout 1 -weight 0
    grid rowconfigure    $layout 2 -weight 0
    grid rowconfigure    $layout 3 -weight 1
    grid rowconfigure    $layout 4 -weight 0
}
