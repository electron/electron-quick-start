namespace eval Widget {}
proc Widget::_opt_defaults {{prio widgetDefault}} {
    if {$::tcl_version >= 8.4} {
	set plat [tk windowingsystem]
    } else {
	set plat $::tcl_platform(platform)
    }
    switch -exact $plat {
	"aqua" {
	}
	"win32" -
	"windows" {
	    #option add *Listbox.background	SystemWindow $prio
	    option add *ListBox.background	SystemWindow $prio
	    #option add *Button.padY		0 $prio
	    option add *ButtonBox.padY		0 $prio
	    option add *Dialog.padY		0 $prio
	    option add *Dialog.anchor		e $prio
	}
	"x11" -
	default {
	    option add *Scrollbar.width		12 $prio
	    option add *Scrollbar.borderWidth	1  $prio
	    option add *Dialog.separator	1  $prio
	    option add *MainFrame.relief	raised $prio
	    option add *MainFrame.separator	none   $prio
	}
    }
}
Widget::_opt_defaults

# Try to load lang file corresponding to current msgcat locale
proc Widget::_opt_lang {} {
    if {0 != [llength [info commands ::msgcat::mcpreferences]]} {
        set langs [::msgcat::mcpreferences]
    }
    lappend langs en

    foreach lang $langs {
        set l [file join $::BWIDGET::LIBRARY "lang" "$lang.rc"]
        if {(![catch {file readable $l} result]) && ($result)} {
            option read $l
            break
        }
    }
}
Widget::_opt_lang

## Add a TraverseIn binding to standard Tk widgets to handle some of
## the BWidget-specific things we do.
bind Entry   <<TraverseIn>> { %W selection range 0 end; %W icursor end }
bind Spinbox <<TraverseIn>> { %W selection range 0 end; %W icursor end }

bind all <Key-Tab>       { Widget::traverseTo [Widget::focusNext %W] }
bind all <<PrevWindow>>  { Widget::traverseTo [Widget::focusPrev %W] }
