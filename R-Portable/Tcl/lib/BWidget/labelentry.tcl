# ------------------------------------------------------------------------------
#  labelentry.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: labelentry.tcl,v 1.6.2.1 2011/02/14 16:56:09 oehhar Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelEntry::create
#     - LabelEntry::configure
#     - LabelEntry::cget
#     - LabelEntry::bind
# ------------------------------------------------------------------------------

namespace eval LabelEntry {
    Widget::define LabelEntry labelentry Entry LabelFrame

    Widget::bwinclude LabelEntry LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude LabelEntry Entry .e \
        remove {-fg -bg} \
        rename {-foreground -entryfg -background -entrybg}

    Widget::addmap LabelEntry "" :cmd {-background {}}

    ::bind BwLabelEntry <FocusIn> [list focus %W.labf]
    ::bind BwLabelEntry <Destroy> [list LabelEntry::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command LabelEntry::create
# ------------------------------------------------------------------------------
proc LabelEntry::create { path args } {
    array set maps [list LabelEntry {} :cmd {} .labf {} .e {}]
    array set maps [Widget::parseArgs LabelEntry $args]

    if {[Widget::theme]} {
        eval [list ttk::frame $path] $maps(:cmd) -class LabelEntry \
            -takefocus 0
    }  else  {
        eval [list frame $path] $maps(:cmd) -class LabelEntry \
            -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    }
    Widget::initFromODB LabelEntry $path $maps(LabelEntry)
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.e]]
    set subf  [LabelFrame::getframe $labf]
    set entry [eval [list Entry::create $path.e] $maps(.e)]

    pack $entry -in $subf -fill both -expand yes
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwLabelEntry [winfo toplevel $path] all]

    Widget::create LabelEntry $path
    proc ::$path { cmd args } \
    	"return \[LabelEntry::_path_command [list $path] \$cmd \$args\]"
    return $path
}


# ------------------------------------------------------------------------------
#  Command LabelEntry::configure
# ------------------------------------------------------------------------------
proc LabelEntry::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelEntry::cget
# ------------------------------------------------------------------------------
proc LabelEntry::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command LabelEntry::bind
# ------------------------------------------------------------------------------
proc LabelEntry::bind { path args } {
    return [eval [list ::bind $path.e] $args]
}


#------------------------------------------------------------------------------
#  Command LabelEntry::_path_command
#------------------------------------------------------------------------------
proc LabelEntry::_path_command { path cmd larg } {
    if { [string equal $cmd "configure"] ||
         [string equal $cmd "cget"] ||
         [string equal $cmd "bind"] } {
        return [eval [list LabelEntry::$cmd $path] $larg]
    } else {
        return [eval [list $path.e:cmd $cmd] $larg]
    }
}


proc LabelEntry::_destroy { path } {
    Widget::destroy $path
}
