namespace eval DemoSelect {
    variable var
}


proc DemoSelect::create { nb } {
    set frame [$nb insert end demoSelect -text "Spin & Combo"]

    set titf1 [TitleFrame $frame.titf1 -text SpinBox]
    set subf  [$titf1 getframe]
    set spin  [SpinBox $subf.spin \
                   -range {1 100 1} -textvariable DemoSelect::var(spin,var) \
                   -helptext "This is the SpinBox"]
    set ent   [LabelEntry $subf.ent -label "Linked var" -labelwidth 10 -labelanchor w \
                   -textvariable DemoSelect::var(spin,var) -editable 0 \
                   -helptext "This is an Entry reflecting\nthe linked var of SpinBox"]
    set labf  [LabelFrame $subf.options -text "Options" -side top -anchor w \
                   -relief sunken -borderwidth 1 \
                   -helptext "Modify some options of SpinBox"]
    set subf  [$labf getframe]
    set chk1  [checkbutton $subf.chk1 -text "Non editable" \
                   -variable DemoSelect::var(spin,editable) -onvalue false -offvalue true \
                   -command "$spin configure -editable \$DemoSelect::var(spin,editable)"]
    set chk2  [checkbutton $subf.chk2 -text "Disabled" \
                   -variable DemoSelect::var(spin,state) -onvalue disabled -offvalue normal \
                   -command "$spin configure -state \$DemoSelect::var(spin,state)"]

    pack $chk1 $chk2 -side left -anchor w
    pack $spin $ent $labf -pady 4 -fill x
    pack $titf1

    set titf2 [TitleFrame $frame.titf2 -text ComboBox]
    set subf  [$titf2 getframe]
    set combo [ComboBox $subf.combo \
                   -textvariable DemoSelect::var(combo,var) \
                   -values {"first value" "second value" "third value" "fourth value" "fifth value"} \
                   -helptext "This is the ComboBox"]
    set ent   [LabelEntry $subf.ent -label "Linked var" -labelwidth 10 -labelanchor w \
                   -textvariable DemoSelect::var(combo,var) -editable 0 \
                   -helptext "This is an Entry reflecting\nthe linked var of ComboBox"]
    set labf  [LabelFrame $subf.options -text "Options" -side top -anchor w \
                   -relief sunken -borderwidth 1 \
                   -helptext "Modify some options of SpinBox"]
    set subf  [$labf getframe]
    set chk1  [checkbutton $subf.chk1 -text "Non editable" \
                   -variable DemoSelect::var(combo,editable) -onvalue false -offvalue true \
                   -command  "$combo configure -editable \$DemoSelect::var(combo,editable)"]
    set chk2  [checkbutton $subf.chk2 -text "Disabled" \
                   -variable DemoSelect::var(combo,state) -onvalue disabled -offvalue normal \
                   -command  "$combo configure -state \$DemoSelect::var(combo,state)"]

    pack $chk1 $chk2 -side left -anchor w
    pack $combo $ent $labf -pady 4 -fill x

    pack $titf1 $titf2 -pady 4

    return $frame
}

