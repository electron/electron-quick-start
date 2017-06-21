# ------------------------------------------------------------------------------
#  messagedlg.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#     - MessageDlg::create
# ------------------------------------------------------------------------------

namespace eval MessageDlg {
    Widget::define MessageDlg messagedlg Dialog

    Widget::tkinclude MessageDlg message .frame.msg \
	    remove [list -cursor -highlightthickness		\
		-highlightbackground -highlightcolor		\
		-relief -borderwidth -takefocus -textvariable	\
		] \
	    rename [list -text -message]			\
	    initialize [list -aspect 800 -anchor c -justify center]

    Widget::bwinclude MessageDlg Dialog :cmd \
	    remove [list -modal -image -bitmap -side -anchor -separator \
		-homogeneous -padx -pady -spacing]

    Widget::declare MessageDlg {
        {-icon       Enum   info 0 {none error info question warning}}
        {-type       Enum   user 0 {abortretryignore ok okcancel \
		retrycancel yesno yesnocancel user}}
        {-buttons     String "" 0}
        {-buttonwidth String 0  0}
    }

    Widget::addmap MessageDlg "" tkMBox {
	-parent {} -message {} -default {} -title {}
    }
}


# ------------------------------------------------------------------------------
#  Command MessageDlg::create
# ------------------------------------------------------------------------------
proc MessageDlg::create { path args } {
    global tcl_platform

    array set maps [list MessageDlg {} :cmd {} .frame.msg {} tkMBox {}]
    array set maps [Widget::parseArgs MessageDlg $args]
    Widget::initFromODB MessageDlg "$path#Message" $maps(MessageDlg)

    array set dialogArgs $maps(:cmd)

    set type  [Widget::cget "$path#Message" -type]
    set icon  [Widget::cget "$path#Message" -icon]
    set width [Widget::cget "$path#Message" -buttonwidth]

    set defb  -1
    set canb  -1
    switch -- $type {
        abortretryignore {set lbut {abort retry ignore}; set defb 0}
        ok               {set lbut {ok}; set defb 0 }
        okcancel         {set lbut {ok cancel}; set defb 0; set canb 1}
        retrycancel      {set lbut {retry cancel}; set defb 0; set canb 1}
        yesno            {set lbut {yes no}; set defb 0; set canb 1}
        yesnocancel      {set lbut {yes no cancel}; set defb 0; set canb 2}
        user             {set lbut [Widget::cget "$path#Message" -buttons]}
    }

    # If the user didn't specify a default button, use our type-specific
    # default, adding its flag/value to the "user" settings and to the tkMBox
    # settings
    if { ![info exists dialogArgs(-default)] } {
	lappend maps(:cmd) -default $defb
	lappend maps(tkMBox) -default $defb
    }
    if { ![info exists dialogArgs(-cancel)] } {
        lappend maps(:cmd) -cancel $canb
    }

    # Same with title as with default
    if { ![info exists dialogArgs(-title)] } {
        set frame [frame $path -class MessageDlg]
        set title [option get $frame "${icon}Title" MessageDlg]
        destroy $frame
        if { $title == "" } {
            set title "Message"
        }
	lappend maps(:cmd) -title $title
	lappend maps(tkMBox) -title $title
    }

    # Create the "user" type dialog
    if { $type == "user" } {
        if { $icon != "none" } {
            set image [Bitmap::get $icon]
        } else {
            set image ""
        }
        eval [list Dialog::create $path] $maps(:cmd) \
	    [list -image $image -modal local -side bottom -anchor e]
        foreach but $lbut {
            Dialog::add $path -text $but -name $but -width $width
        }
        set frame [Dialog::getframe $path]

        eval [list message $frame.msg] $maps(.frame.msg) \
	    [list -relief flat -borderwidth 0 -highlightthickness 0 \
		 -textvariable ""]
        pack  $frame.msg -side left -padx 3m -pady 1m -fill x -expand yes

        set res [Dialog::draw $path]
	destroy $path
    } else {
	# Do some translation of args into tk_messageBox syntax, then create
	# the tk_messageBox
	array set tkMBoxArgs $maps(tkMBox)
	set tkMBoxArgs(-default) [lindex $lbut $tkMBoxArgs(-default)]
	if { ![string equal $icon "none"] } {
	    set tkMBoxArgs(-icon) $icon
	}
	if {[info exists tkMBoxArgs(-parent)]
	    && ![winfo exists $tkMBoxArgs(-parent)]} {
	    unset tkMBoxArgs(-parent)
	}
	set tkMBoxArgs(-type) $type
	set res [eval [list tk_messageBox] [array get tkMBoxArgs]]
	set res [lsearch $lbut $res]
    }
    Widget::destroy "$path#Message"
    return $res
}
