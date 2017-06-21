# ------------------------------------------------------------------------------
#  bitmap.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: bitmap.tcl,v 1.4 2003/10/20 21:23:52 damonc Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - Bitmap::get
#     - Bitmap::_init
# ----------------------------------------------------------------------------
namespace eval Bitmap {
    Widget::define Bitmap bitmap -classonly

    variable path
    variable _bmp
    variable _types {
        photo  .gif
        photo  .ppm
        bitmap .xbm
        photo  .xpm
    }

    proc use {} {}
}


# ----------------------------------------------------------------------------
#  Command Bitmap::get
# ----------------------------------------------------------------------------
proc Bitmap::get { name } {
    variable path
    variable _bmp
    variable _types

    if {[info exists _bmp($name)]} {
        return $_bmp($name)
    }

    # --- Nom de fichier avec extension ---------------------------------
    set ext [file extension $name]
    if { $ext != "" } {
        if { ![info exists _bmp($ext)] } {
            error "$ext not supported"
        }

        if { [file exists $name] } {
            if {[string equal $ext ".xpm"]} {
                set _bmp($name) [xpm-to-image $name]
                return $_bmp($name)
            }
            if {![catch {set _bmp($name) [image create $_bmp($ext) -file $name]}]} {
                return $_bmp($name)
            }
        }
    }

    foreach dir $path {
        foreach {type ext} $_types {
            if { [file exists [file join $dir $name$ext]] } {
                if {[string equal $ext ".xpm"]} {
                    set _bmp($name) [xpm-to-image [file join $dir $name$ext]]
                    return $_bmp($name)
                } else {
                    if {![catch {set _bmp($name) [image create $type -file [file join $dir $name$ext]]}]} {
                        return $_bmp($name)
                    }
                }
            }
        }
    }

    return -code error "$name not found"
}


# ----------------------------------------------------------------------------
#  Command Bitmap::_init
# ----------------------------------------------------------------------------
proc Bitmap::_init { } {
    global   env
    variable path
    variable _bmp
    variable _types

    set path [list "." [file join $::BWIDGET::LIBRARY images]]
    set supp [image types]
    foreach {type ext} $_types {
        if { [lsearch $supp $type] != -1} {
            set _bmp($ext) $type
        }
    }
}


Bitmap::_init
