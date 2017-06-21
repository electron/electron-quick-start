
namespace eval DemoDlg {
    variable tmpl
    variable msg
    variable progmsg
    variable progval
    variable resources "en"
}


proc DemoDlg::create { nb } {
    set frame [$nb insert end demoDlg -text "Dialog"]

    set titf1 [TitleFrame $frame.titf1 -text "Resources"]
    set titf2 [TitleFrame $frame.titf2 -text "Template Dialog"]
    set titf3 [TitleFrame $frame.titf3 -text "Message Dialog"]
    set titf4 [TitleFrame $frame.titf4 -text "Other dialog"]

    set subf [$titf1 getframe]
    set cmd  {option read [file join $::BWIDGET::LIBRARY "lang" $DemoDlg::resources.rc]}
    set rad1 [radiobutton $subf.rad1 -text "English" \
                  -variable DemoDlg::resources -value en \
                  -command  $cmd]
    set rad2 [radiobutton $subf.rad2 -text "French" \
                  -variable DemoDlg::resources -value fr \
                  -command  $cmd]
    set rad3 [radiobutton $subf.rad3 -text "German" \
                  -variable DemoDlg::resources -value de \
                  -command  $cmd]
    pack $rad1 $rad2 $rad3 -side left

    _tmpldlg [$titf2 getframe]
    _msgdlg  [$titf3 getframe]
    _stddlg  [$titf4 getframe]

    pack $titf1 -fill x -pady 2 -padx 2
    pack $titf4 -side bottom -fill x -pady 2 -padx 2
    pack $titf2 $titf3 -side left -padx 2 -fill both -expand yes
}


proc DemoDlg::_tmpldlg { parent } {
    variable tmpl

    set tmpl(side)   bottom
    set tmpl(anchor) c

    set labf1 [LabelFrame $parent.labf1 -text "Button side" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf1 getframe]
    radiobutton $subf.rad1 -text "Bottom" \
        -variable DemoDlg::tmpl(side) -value bottom -anchor w
    radiobutton $subf.rad2 -text "Left" \
        -variable DemoDlg::tmpl(side) -value left   -anchor w
    radiobutton $subf.rad3 -text "Right" \
        -variable DemoDlg::tmpl(side) -value right  -anchor w
    radiobutton $subf.rad4 -text "Top" \
        -variable DemoDlg::tmpl(side) -value top    -anchor w

    pack $subf.rad1 $subf.rad2 $subf.rad3 $subf.rad4 -fill x -anchor w

    set labf2 [LabelFrame $parent.labf2 -text "Button anchor" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf2 getframe]
    radiobutton $subf.rad1 -text "North" \
        -variable DemoDlg::tmpl(anchor) -value n -anchor w
    radiobutton $subf.rad2 -text "West" \
        -variable DemoDlg::tmpl(anchor) -value w -anchor w
    radiobutton $subf.rad3 -text "East" \
        -variable DemoDlg::tmpl(anchor) -value e -anchor w
    radiobutton $subf.rad4 -text "South" \
        -variable DemoDlg::tmpl(anchor) -value s -anchor w
    radiobutton $subf.rad5 -text "Center" \
        -variable DemoDlg::tmpl(anchor) -value c -anchor w

    pack $subf.rad1 $subf.rad2 $subf.rad3 $subf.rad4 $subf.rad5 -fill x -anchor w

    set sep    [Separator  $parent.sep -orient horizontal]
    set button [button $parent.but -text "Show" -command DemoDlg::_show_tmpldlg]

    pack $button -side bottom
    pack $sep -side bottom -fill x -pady 10
    pack $labf1 $labf2 -side left -padx 4 -anchor n
}


proc DemoDlg::_msgdlg { parent } {
    variable msg

    set msg(type) ok
    set msg(icon) info

    set labf1 [LabelFrame $parent.labf1 -text "Type" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf1 getframe]
    radiobutton $subf.rad1 -text "Ok" -variable DemoDlg::msg(type) -value ok -anchor w
    radiobutton $subf.rad2 -text "Ok, Cancel" -variable DemoDlg::msg(type) -value okcancel -anchor w
    radiobutton $subf.rad3 -text "Retry, Cancel" -variable DemoDlg::msg(type) -value retrycancel -anchor w
    radiobutton $subf.rad4 -text "Yes, No" -variable DemoDlg::msg(type) -value yesno -anchor w
    radiobutton $subf.rad5 -text "Yes, No, Cancel" -variable DemoDlg::msg(type) -value yesnocancel -anchor w
    radiobutton $subf.rad6 -text "Abort, Retry, Ignore" -variable DemoDlg::msg(type) -value abortretryignore -anchor w
    radiobutton $subf.rad7 -text "User" -variable DemoDlg::msg(type) -value user -anchor w
    Entry $subf.user -textvariable DemoDlg::msg(buttons)

    pack $subf.rad1 $subf.rad2 $subf.rad3 $subf.rad4 $subf.rad5 $subf.rad6 -fill x -anchor w
    pack $subf.rad7 $subf.user -side left

    set labf2 [LabelFrame $parent.labf2 -text "Icon" -side top -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf2 getframe]
    radiobutton $subf.rad1 -text "Information" -variable DemoDlg::msg(icon) -value info     -anchor w
    radiobutton $subf.rad2 -text "Question"    -variable DemoDlg::msg(icon) -value question -anchor w
    radiobutton $subf.rad3 -text "Warning"     -variable DemoDlg::msg(icon) -value warning  -anchor w
    radiobutton $subf.rad4 -text "Error"       -variable DemoDlg::msg(icon) -value error    -anchor w
    pack $subf.rad1 $subf.rad2 $subf.rad3 $subf.rad4 -fill x -anchor w


    set sep    [Separator  $parent.sep -orient horizontal]
    set button [button $parent.but -text "Show" -command DemoDlg::_show_msgdlg]

    pack $button -side bottom
    pack $sep -side bottom -fill x -pady 10
    pack $labf1 $labf2 -side left -padx 4 -anchor n
}


proc DemoDlg::_stddlg { parent } {
    set but0  [button $parent.but0 \
                   -text "Select a color " \
                   -command "DemoDlg::_show_color $parent.but0"]
    set but1  [button $parent.but1 \
                   -text    "Font selector dialog" \
                   -command DemoDlg::_show_fontdlg]
    set but2  [button $parent.but2 \
                   -text    "Progression dialog" \
                   -command DemoDlg::_show_progdlg]
    set but3  [button $parent.but3 \
                   -text    "Password dialog" \
                   -command DemoDlg::_show_passdlg]

    pack $but0 $but1 $but2 $but3 -side left -padx 5 -anchor w
}

proc DemoDlg::_show_color {w} {
    set color [SelectColor::menu $w.color [list below $w] \
                       -color [$w cget -background]]
    if {[string length $color]} {
        $w configure -background $color
    }
}

proc DemoDlg::_show_tmpldlg { } {
    variable tmpl

    set dlg [Dialog .tmpldlg -parent . -modal local \
                 -separator 1 \
                 -title   "Template dialog" \
                 -side    $tmpl(side)    \
                 -anchor  $tmpl(anchor)  \
                 -default 0 -cancel 1]
    $dlg add -name ok
    $dlg add -name cancel
    set msg [message [$dlg getframe].msg -text "Template\nDialog" -justify center -anchor c]
    pack $msg -fill both -expand yes -padx 100 -pady 100
    $dlg draw
    destroy $dlg
}


proc DemoDlg::_show_msgdlg { } {
    variable msg

    destroy .msgdlg
    MessageDlg .msgdlg -parent . \
        -message "Message for MessageBox" \
        -type    $msg(type) \
        -icon    $msg(icon) \
        -buttons $msg(buttons)
}


proc DemoDlg::_show_fontdlg { } {
    set font [SelectFont .fontdlg -parent . -font $Demo::font]
    if { $font != "" } {
        Demo::update_font $font
    }
}


proc DemoDlg::_show_progdlg { } {
    set DemoDlg::progmsg "Compute in progress..."
    set DemoDlg::progval 0

    ProgressDlg .progress -parent . -title "Wait..." \
        -type         infinite \
        -width        20 \
        -textvariable DemoDlg::progmsg \
        -variable     DemoDlg::progval \
        -stop         "Stop" \
        -command      {destroy .progress}
    _update_progdlg
}


proc DemoDlg::_update_progdlg { } {
    if { [winfo exists .progress] } {
        set DemoDlg::progval 2
        after 20 DemoDlg::_update_progdlg
    }
}

proc DemoDlg::_show_passdlg { } {
    PasswdDlg .passwd -parent .
}

