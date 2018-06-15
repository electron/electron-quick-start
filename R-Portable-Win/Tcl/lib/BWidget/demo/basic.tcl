
namespace eval DemoBasic {
    variable var
    variable count 0
    variable id    ""
}


proc DemoBasic::create { nb } {
    set frame [$nb insert end demoBasic -text "Basic"]

    set topf  [frame $frame.topf]
    set titf1 [TitleFrame $topf.titf1 -text "Label"]
    set titf2 [TitleFrame $topf.titf2 -text "Entry"]
    set titf3 [TitleFrame $frame.titf3 -text "Button and ArrowButton"]

    _label  [$titf1 getframe]
    _entry  [$titf2 getframe]
    _button [$titf3 getframe]

    pack $titf1 $titf2 -side left -fill both -padx 4 -expand yes
    pack $topf -pady 2 -fill x
    pack $titf3 -pady 2 -padx 4 -fill x

    return $frame
}


proc DemoBasic::_label { parent } {
    variable var

    set lab [Label $parent.label -text "This is a Label widget" \
                 -helptext "Label widget"]
    set chk [checkbutton $parent.chk -text "Disabled" \
                 -variable DemoBasic::var($lab,-state) \
                 -onvalue  disabled -offvalue normal \
                 -command  "$lab configure -state \$DemoBasic::var($lab,-state)"]
    pack $lab -anchor w -pady 4
    pack $chk -anchor w
}


proc DemoBasic::_entry { parent } {
    set ent  [Entry $parent.entry -text "Press enter" \
                  -command  {set DemoBasic::var(entcmd) "-command called" ; after 500 {set DemoBasic::var(entcmd) ""}} \
                   -helptext "Entry widget"]
    set chk1 [checkbutton $parent.chk1 -text "Disabled" \
                  -variable DemoBasic::var($ent,state) \
                  -onvalue  disabled -offvalue normal \
                  -command  "$ent configure -state \$DemoBasic::var($ent,state)"]
    set chk2 [checkbutton $parent.chk2 -text "Non editable" \
                  -variable DemoBasic::var($ent,editable) \
                  -onvalue  false -offvalue true \
                  -command  "$ent configure -editable \$DemoBasic::var($ent,editable)"]
    set lab  [label $parent.cmd -textvariable DemoBasic::var(entcmd) -foreground red]
    pack $ent -pady 4 -anchor w
    pack $chk1 $chk2 -anchor w
    pack $lab -pady 4
}


proc DemoBasic::_button { parent } {
    variable var

    set frame [frame $parent.butfr]
    set but   [Button $frame.but -text "Press me!" \
                   -repeatdelay 300 \
                   -command  "DemoBasic::_butcmd command" \
                   -helptext "This is a Button widget"]
    set sep1  [Separator $frame.sep1 -orient vertical]
    set arr1  [ArrowButton $frame.arr1 -type button \
                   -width 25 -height 25 \
                   -repeatdelay 300 \
                   -command  "DemoBasic::_butcmd command" \
                   -helptext "This is an ArrowButton widget\nof type button"]
    set sep2  [Separator $frame.sep2 -orient vertical]
    set arr2  [ArrowButton $frame.arr2 -type arrow \
                   -width 25 -height 25 -relief sunken -ipadx 0 -ipady 0 \
                   -repeatdelay 300 \
                   -command  "DemoBasic::_butcmd command" \
                   -helptext "This is an ArrowButton widget\nof type arrow"]

    pack $but  -side left -padx 4
    pack $sep1 -side left -padx 4 -fill y
    pack $arr1 -side left -padx 4
    pack $sep2 -side left -padx 4 -fill y
    pack $arr2 -side left -padx 4
    pack $frame

    set sep3  [Separator $parent.sep3 -orient horizontal]
    pack $sep3 -fill x -pady 10

    set labf1 [LabelFrame $parent.labf1 -text "Command" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf1 getframe]
    set chk1  [checkbutton $subf.chk1 -text "Disabled" \
                   -variable DemoBasic::var(bstate) -onvalue disabled -offvalue normal \
                   -command  "DemoBasic::_bstate \$DemoBasic::var(bstate) $but $arr1 $arr2"]
    set chk2  [checkbutton $subf.chk2 -text "Use -armcommand/\n-disarmcommand" \
                   -justify left \
                   -variable DemoBasic::var(barmcmd) \
                   -command  "DemoBasic::_barmcmd \$DemoBasic::var(barmcmd) $but $arr1 $arr2"]
    pack $chk1 $chk2 -anchor w

    set label [label $parent.label -textvariable DemoBasic::var(butcmd) -foreground red]
    pack $label -side bottom -pady 4

    set labf2 [LabelFrame $parent.labf2 -text "Direction" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf2 getframe]
    set var(bside) top
    foreach dir {top left bottom right} {
        set rad [radiobutton $subf.$dir -text "$dir arrow" \
                     -variable DemoBasic::var(bside) -value $dir \
                     -command  "DemoBasic::_bside \$DemoBasic::var(bside) $arr1 $arr2"]
        pack $rad -anchor w
    }

    set labf3 [LabelFrame $parent.labf3 -text "Relief" -side top \
                   -anchor w -relief sunken -borderwidth 1]
    set subf  [$labf3 getframe]
    set var(brelief) raised
    foreach {f lrelief} {f1 {raised sunken ridge groove} f2 {flat solid link}} {
        set f [frame $subf.$f]
        foreach relief $lrelief {
            set rad [radiobutton $f.$relief -text $relief \
                         -variable DemoBasic::var(brelief) -value $relief \
                         -command  "DemoBasic::_brelief \$DemoBasic::var(brelief) $but $arr1 $arr2"]
            pack $rad -anchor w
        }
        pack $f -side left -padx 2 -anchor n
    }
    pack $labf1 $labf2 $labf3 -side left -fill y -padx 4
}


proc DemoBasic::_bstate { state but arr1 arr2 } {
    foreach but [list $but $arr1 $arr2] {
        $but configure -state $state
    }
}


proc DemoBasic::_brelief { relief but arr1 arr2 } {
    $but configure -relief $relief
    if { $relief != "link" } {
        foreach arr [list $arr1 $arr2] {
            $arr configure -relief $relief
        }
    }
}


proc DemoBasic::_bside { side args } {
    foreach arr $args {
        $arr configure -dir $side
    }
}


proc DemoBasic::_barmcmd { value but arr1 arr2 } {
    if { $value } {
        $but configure \
            -armcommand    "DemoBasic::_butcmd arm" \
            -disarmcommand "DemoBasic::_butcmd disarm" \
            -command {}
        foreach arr [list $arr1 $arr2] {
            $arr configure \
                -armcommand    "DemoBasic::_butcmd arm" \
                -disarmcommand "DemoBasic::_butcmd disarm" \
                -command {}
        }
    } else {
        $but configure -armcommand {} -disarmcommand {} \
            -command  "DemoBasic::_butcmd command"
        foreach arr [list $arr1 $arr2] {
            $arr configure -armcommand {} -disarmcommand {} \
                -command "DemoBasic::_butcmd command"
        }
    }
}


proc DemoBasic::_butcmd { reason } {
    variable count
    variable id

    catch {after cancel $id}
    if { $reason == "arm" } {
        incr count
        set DemoBasic::var(butcmd) "$reason command called ($count)"
    } else {
        set count 0
        set DemoBasic::var(butcmd) "$reason command called"
    }
    set id [after 500 {set DemoBasic::var(butcmd) ""}]
}


