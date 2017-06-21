# -----------------------------------------------------------------------------
#  passwddlg.tcl
#  This file is part of Unifix BWidget Toolkit
#   by Stephane Lavirotte (Stephane.Lavirotte@sophia.inria.fr)
#  $Id: passwddlg.tcl,v 1.12 2009/06/11 15:42:51 oehhar Exp $
# -----------------------------------------------------------------------------
#  Index of commands:
#     - PasswdDlg::create
#     - PasswdDlg::configure
#     - PasswdDlg::cget
#     - PasswdDlg::_verifonlogin
#     - PasswdDlg::_verifonpasswd
#     - PasswdDlg::_max
#------------------------------------------------------------------------------

namespace eval PasswdDlg {
    Widget::define PasswdDlg passwddlg Dialog LabelEntry

    Widget::bwinclude PasswdDlg Dialog :cmd \
	    remove     {-image -bitmap -side -default -cancel -separator} \
	    initialize {-modal local -anchor e}
    
    Widget::bwinclude PasswdDlg LabelEntry .frame.lablog \
	    remove [list -command -justify -name -show -side	        \
		-state -takefocus -width -xscrollcommand -padx -pady	\
		-dragenabled -dragendcmd -dragevent -draginitcmd	\
		-dragtype -dropenabled -dropcmd -dropovercmd -droptypes	\
		] \
	    prefix [list login -editable -helptext -helpvar -label      \
		-text -textvariable -underline				\
		] \
	    initialize [list -relief sunken -borderwidth 2		\
		-labelanchor w -width 15 -loginlabel "Login"		\
		]
    
    Widget::bwinclude PasswdDlg LabelEntry .frame.labpass		\
	    remove [list -command -width -show -side -takefocus		\
		-xscrollcommand -dragenabled -dragendcmd -dragevent	\
		-draginitcmd -dragtype -dropenabled -dropcmd		\
		-dropovercmd -droptypes -justify -padx -pady -name	\
		] \
	    prefix [list passwd -editable -helptext -helpvar -label	\
		-state -text -textvariable -underline			\
		] \
	    initialize [list -relief sunken -borderwidth 2		\
		-labelanchor w -width 15 -passwdlabel "Password"	\
		]
    
    Widget::declare PasswdDlg {
        {-type        Enum       ok           0 {ok okcancel}}
        {-labelwidth  TkResource -1           0 {label -width}}
        {-command     String     ""           0}
    }
}


# -----------------------------------------------------------------------------
#  Command PasswdDlg::create
# -----------------------------------------------------------------------------
proc PasswdDlg::create { path args } {

    array set maps [list PasswdDlg {} :cmd {} .frame.lablog {} \
	    .frame.labpass {}]
    array set maps [Widget::parseArgs PasswdDlg $args]

    Widget::initFromODB PasswdDlg "$path#PasswdDlg" $maps(PasswdDlg)

    # Extract the PasswdDlg megawidget options (those that don't map to a
    # subwidget)
    set type      [Widget::cget "$path#PasswdDlg" -type]
    set cmd       [Widget::cget "$path#PasswdDlg" -command]

    set defb -1
    set canb -1
    switch -- $type {
        ok        { set lbut {ok}; set defb 0 }
        okcancel  { set lbut {ok cancel} ; set defb 0; set canb 1 }
    }

    eval [list Dialog::create $path] $maps(:cmd) \
        [list -class PasswdDlg -image [Bitmap::get passwd] \
	     -side bottom -default $defb -cancel $canb]
    foreach but $lbut {
        if { $but == "ok" && $cmd != "" } {
            Dialog::add $path -text $but -name $but -command $cmd
        } else {
            Dialog::add $path -text $but -name $but
        }
    }

    set frame [Dialog::getframe $path]
    bind $path  <Return>  ""
    bind $frame <Destroy> [list Widget::destroy $path\#PasswdDlg]

    set lablog [eval [list LabelEntry::create $frame.lablog] \
		    $maps(.frame.lablog) \
		    [list -name login -dragenabled 0 -dropenabled 0 \
			 -command [list PasswdDlg::_verifonpasswd \
				       $path $frame.labpass]]]

    set labpass [eval [list LabelEntry::create $frame.labpass] \
		     $maps(.frame.labpass) \
		     [list -name password -show "*" \
			  -dragenabled 0 -dropenabled 0 \
			  -command [list PasswdDlg::_verifonlogin \
					$path $frame.lablog]]]

    # compute label width
    if {[$lablog cget -labelwidth] == 0} {
        set loglabel  [$lablog cget -label]
        set passlabel [$labpass cget -label]
        set labwidth  [_max [string length $loglabel] [string length $passlabel]]
        incr labwidth 1
        $lablog  configure -labelwidth $labwidth
        $labpass configure -labelwidth $labwidth
    }

    Widget::create PasswdDlg $path 0

    pack  $frame.lablog $frame.labpass -fill x -expand 1

    # added by bach@mwgdna.com
    #  give focus to loginlabel unless the state is disabled
    if {[$lablog cget -editable]} {
	focus $frame.lablog.e
    } else {
	focus $frame.labpass.e
    }
    set res [Dialog::draw $path]

    if { $res == 0 } {
        set res [list [$lablog.e cget -text] [$labpass.e cget -text]]
    } else {
        set res [list]
    }
    Widget::destroy "$path#PasswdDlg"
    destroy $path

    return $res
}

# -----------------------------------------------------------------------------
#  Command PasswdDlg::configure
# -----------------------------------------------------------------------------

proc PasswdDlg::configure { path args } {
    set res [Widget::configure "$path#PasswdDlg" $args]
}

# -----------------------------------------------------------------------------
#  Command PasswdDlg::cget
# -----------------------------------------------------------------------------

proc PasswdDlg::cget { path option } {
    return [Widget::cget "$path#PasswdDlg" $option]
}


# -----------------------------------------------------------------------------
#  Command PasswdDlg::_verifonlogin
# -----------------------------------------------------------------------------
proc PasswdDlg::_verifonlogin { path labpass } {
    Dialog::enddialog $path 0
}

# -----------------------------------------------------------------------------
#  Command PasswdDlg::_verifonpasswd
# -----------------------------------------------------------------------------
proc PasswdDlg::_verifonpasswd { path labpass } {
    if {[string equal [$labpass cget -state] "disabled"]} {
        Dialog::enddialog $path 0
    } else {
        focus $labpass
    }
}

# -----------------------------------------------------------------------------
#  Command PasswdDlg::_max
# -----------------------------------------------------------------------------
proc PasswdDlg::_max { val1 val2 } { 
    return [expr {($val1 > $val2) ? ($val1) : ($val2)}] 
}
