
namespace eval DemoDnd {
}


proc DemoDnd::create { nb } {

    set frame [$nb insert end demoDnd -text "Drag and Drop"]

    set titf1 [TitleFrame $frame.titf1 -text "Drag sources"]
    set subf  [$titf1 getframe]

    set ent1  [LabelEntry $subf.e1 -label "Entry" -labelwidth 14 -dragenabled 1 -dragevent 3]
    set labf1 [LabelFrame $subf.f1 -text "Label (text)" -width 14]
    set f     [$labf1 getframe]
    set lab   [Label $f.l -text "Drag this text" -dragenabled 1 -dragevent 3]
    pack $lab

    set labf2 [LabelFrame $subf.f2 -text "Label (bitmap)" -width 14]
    set f     [$labf2 getframe]
    set lab   [Label $f.l -bitmap info -dragenabled 1 -dragevent 3]
    pack $lab

    pack $ent1 $labf1 $labf2 -side top -fill x -pady 4

    set titf2 [TitleFrame $frame.titf2 -text "Drop targets"]
    set subf  [$titf2 getframe]

    set ent1  [LabelEntry $subf.e1 -label "Entry" -labelwidth 14 -dropenabled 1]
    set labf1 [LabelFrame $subf.f1 -text "Label" -width 14]
    set f     [$labf1 getframe]
    set lab   [Label $f.l -dropenabled 1 -highlightthickness 1]
    pack $lab -fill x

    pack $ent1 $labf1 -side top -fill x -pady 4

    pack $titf1 $titf2 -pady 4

    return $frame
}


