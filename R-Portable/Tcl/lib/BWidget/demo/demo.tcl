#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec wish "$0" ${1+"$@"}

namespace eval Demo {
    variable _wfont

    variable notebook
    variable mainframe
    variable status
    variable prgtext
    variable prgindic
    variable font
    variable font_name
    variable toolbar1  1
    variable toolbar2  1

    set pwd [pwd]
    cd [file dirname [info script]]
    variable DEMODIR [pwd]
    cd $pwd

    foreach script {
	manager.tcl basic.tcl select.tcl dnd.tcl tree.tcl tmpldlg.tcl
    } {
	namespace inscope :: source $DEMODIR/$script
    }
}


proc Demo::create { } {
    global   tk_patchLevel
    variable _wfont
    variable notebook
    variable mainframe
    variable font
    variable prgtext
    variable prgindic

    set prgtext "Please wait while loading font..."
    set prgindic -1
    _create_intro
    update
    SelectFont::loadfont

    bind all <F12> { catch {console show} }

    # Menu description
    set descmenu {
        "&File" all file 0 {
            {command "E&xit" {} "Exit BWidget demo" {} -command exit}
        }
        "&Options" all options 0 {
            {checkbutton "Toolbar &1" {all option} "Show/hide toolbar 1" {}
                -variable Demo::toolbar1
                -command  {$Demo::mainframe showtoolbar 0 $Demo::toolbar1}
            }
            {checkbutton "Toolbar &2" {all option} "Show/hide toolbar 2" {}
                -variable Demo::toolbar2
                -command  {$Demo::mainframe showtoolbar 1 $Demo::toolbar2}
            }
        }
    }

    set prgtext   "Creating MainFrame..."
    set prgindic  0
    set mainframe [MainFrame .mainframe \
                       -menu         $descmenu \
                       -textvariable Demo::status \
                       -progressvar  Demo::prgindic]

    # toolbar 1 creation
    incr prgindic
    set tb1  [$mainframe addtoolbar]
    set bbox [ButtonBox $tb1.bbox1 -spacing 0 -padx 1 -pady 1]
    $bbox add -image [Bitmap::get new] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Create a new file"
    $bbox add -image [Bitmap::get open] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Open an existing file"
    $bbox add -image [Bitmap::get save] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Save file"
    pack $bbox -side left -anchor w

    set sep [Separator $tb1.sep -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w

    incr prgindic
    set bbox [ButtonBox $tb1.bbox2 -spacing 0 -padx 1 -pady 1]
    $bbox add -image [Bitmap::get cut] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Cut selection"
    $bbox add -image [Bitmap::get copy] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Copy selection"
    $bbox add -image [Bitmap::get paste] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Paste selection"
    pack $bbox -side left -anchor w

   # toolbar 2 creation
    incr prgindic
    set tb2    [$mainframe addtoolbar]
    set _wfont [SelectFont $tb2.font -type toolbar \
                    -command "Demo::update_font \[$tb2.font cget -font\]"]
    set font   [$_wfont cget -font]
    pack $_wfont -side left -anchor w

    $mainframe addindicator -text "BWidget [package version BWidget]"
    $mainframe addindicator -textvariable tk_patchLevel

    # NoteBook creation
    set frame    [$mainframe getframe]
    set notebook [NoteBook $frame.nb]

    set prgtext   "Creating Manager..."
    incr prgindic
    set f0  [DemoManager::create $notebook]
    set prgtext   "Creating Basic..."
    incr prgindic
    set f1  [DemoBasic::create $notebook]
    set prgtext   "Creating Select..."
    incr prgindic
    set f2 [DemoSelect::create $notebook]
    set prgtext   "Creating Dialog..."
    incr prgindic
    set f3b [DemoDlg::create $notebook]
    set prgtext   "Creating Drag and Drop..."
    incr prgindic
    set f4 [DemoDnd::create $notebook]
    set prgtext   "Creating Tree..."
    incr prgindic
    set f5 [DemoTree::create $notebook]

    set prgtext   "Done"
    incr prgindic
    $notebook compute_size
    pack $notebook -fill both -expand yes -padx 4 -pady 4
    $notebook raise [$notebook page 0]

    pack $mainframe -fill both -expand yes
    update idletasks
    destroy .intro
}


proc Demo::update_font { newfont } {
    variable _wfont
    variable notebook
    variable font
    variable font_name

    . configure -cursor watch
    if { $font != $newfont } {
        $_wfont configure -font $newfont
        $notebook configure -font $newfont
        set font $newfont
    }
    . configure -cursor ""
}


proc Demo::_create_intro { } {
    variable DEMODIR

    set top [toplevel .intro -relief raised -borderwidth 2]

    wm withdraw $top
    wm overrideredirect $top 1

    set ximg  [label $top.x -bitmap @$DEMODIR/x1.xbm \
	    -foreground grey90 -background white]
    set bwimg [label $ximg.bw -bitmap @$DEMODIR/bwidget.xbm \
	    -foreground grey90 -background white]
    set frame [frame $ximg.f -background white]
    set lab1  [label $frame.lab1 -text "Loading demo" \
	    -background white -font {times 8}]
    set lab2  [label $frame.lab2 -textvariable Demo::prgtext \
	    -background white -font {times 8} -width 35]
    set prg   [ProgressBar $frame.prg -width 50 -height 10 -background white \
	    -variable Demo::prgindic -maximum 10]
    pack $lab1 $lab2 $prg
    place $frame -x 0 -y 0 -anchor nw
    place $bwimg -relx 1 -rely 1 -anchor se
    pack $ximg
    BWidget::place $top 0 0 center
    wm deiconify $top
}


proc Demo::main {} {
    variable DEMODIR

    lappend ::auto_path [file dirname $DEMODIR]
    package require BWidget

    option add *TitleFrame.l.font {helvetica 11 bold italic}

    wm withdraw .
    wm title . "BWidget demo"

    Demo::create
    BWidget::place . 0 0 center
    wm deiconify .
    raise .
    focus -force .
}

Demo::main
wm geom . [wm geom .]
