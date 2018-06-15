

namespace eval DemoManager {
    variable _progress 0
    variable _afterid  ""
    variable _status "Compute in progress..."
    variable _homogeneous 0
}


proc DemoManager::create { nb } {
    set frame [$nb insert end demoManager -text "Manager"]

    set topf  [frame $frame.topf]
    set titf1 [TitleFrame $topf.titf1 -text "MainFrame"]
    set titf2 [TitleFrame $topf.titf2 -text "NoteBook"]
    set titf3 [TitleFrame $frame.titf3 -text "Paned & ScrolledWindow"]

    _mainframe [$titf1 getframe]
    _notebook  [$titf2 getframe]
    _paned     [$titf3 getframe]

    pack $titf1 $titf2 -padx 4 -side left -fill both -expand yes
    pack $topf -fill x -pady 2
    pack $titf3 -pady 2 -padx 4 -fill both -expand yes

    return $frame
}


proc DemoManager::_mainframe { parent } {
    set labf1 [LabelFrame $parent.labf1 -text "Toolbar" -side top -anchor w \
                   -relief sunken -borderwidth 2]
    set subf  [$labf1 getframe]
    checkbutton $subf.chk1 -text "View toolbar 1" -variable Demo::toolbar1 \
        -command {$Demo::mainframe showtoolbar 0 $Demo::toolbar1}
    checkbutton $subf.chk2 -text "View toolbar 2" -variable Demo::toolbar2 \
        -command {$Demo::mainframe showtoolbar 1 $Demo::toolbar2}
    pack $subf.chk1 $subf.chk2 -anchor w -fill x
    pack $labf1 -fill both

    set labf2 [LabelFrame $parent.labf2 -text "Status bar" -side top -anchor w \
                   -relief sunken -borderwidth 2]
    set subf  [$labf2 getframe]
    checkbutton $subf.chk1 -text "Show Progress\nindicator" -justify left \
        -variable DemoManager::_progress \
        -command  {DemoManager::_show_progress}
    pack $subf.chk1 -anchor w -fill x

    pack $labf1 $labf2 -side left -padx 4 -fill both
}


proc DemoManager::_notebook { parent } {
    checkbutton $parent.chk1 -text "Homogeneous label" \
        -variable DemoManager::_homogeneous \
        -command  {$Demo::notebook configure -homogeneous $DemoManager::_homogeneous}
    pack $parent.chk1 -side left -anchor n -fill x
}



proc DemoManager::_paned { parent } {
    set pw1   [PanedWindow $parent.pw -side top]
    set pane  [$pw1 add -minsize 100]

    set pw2    [PanedWindow $pane.pw -side left]
    set pane1  [$pw2 add -minsize 100]
    set pane2  [$pw2 add -minsize 100]
    set pane3  [$pw1 add -minsize 100]

    foreach pane [list $pane1 $pane2] {
        set sw    [ScrolledWindow $pane.sw]
        set lb    [listbox $sw.lb -height 8 -width 20 -highlightthickness 0]
        for {set i 1} {$i <= 8} {incr i} {
            $lb insert end "Value $i"
        }
        $sw setwidget $lb
        pack $sw -fill both -expand yes
    }

    set sw [ScrolledWindow $pane3.sw -relief sunken -borderwidth 2]
    set sf [ScrollableFrame $sw.f]
    $sw setwidget $sf
    set subf [$sf getframe]
    set lab [label $subf.lab -text "This is a ScrollableFrame"]
    set chk [checkbutton $subf.chk -text "Constrained width" \
                 -variable DemoManager::_constw \
                 -command  "$sf configure -constrainedwidth \$DemoManager::_constw"]
    pack $lab
    pack $chk -anchor w
    bind $chk <FocusIn> "$sf see $chk"
    for {set i 0} {$i <= 20} {incr i} {
        pack [entry $subf.ent$i -width 50]  -fill x -pady 4
	bind $subf.ent$i <FocusIn> "$sf see $subf.ent$i"
        $subf.ent$i insert end "Text field $i"
    }

    pack $sw $pw2 $pw1 -fill both -expand yes
}


proc DemoManager::_show_progress { } {
    variable _progress
    variable _afterid
    variable _status

    if { $_progress } {
        set Demo::status   "Compute in progress..."
        set Demo::prgindic 0
        $Demo::mainframe showstatusbar progression
        if { $_afterid == "" } {
            set _afterid [after 30 DemoManager::_update_progress]
        }
    } else {
        set Demo::status ""
        $Demo::mainframe showstatusbar status
        set _afterid ""
    }
}


proc DemoManager::_update_progress { } {
    variable _progress
    variable _afterid

    if { $_progress } {
        if { $Demo::prgindic < 100 } {
            incr Demo::prgindic 5
            set _afterid [after 30 DemoManager::_update_progress]
        } else {
            set _progress 0
            $Demo::mainframe showstatusbar status
            set Demo::status "Done"
            set _afterid ""
            after 500 {set Demo::status ""}
        }
    } else {
        set _afterid ""
    }
}
