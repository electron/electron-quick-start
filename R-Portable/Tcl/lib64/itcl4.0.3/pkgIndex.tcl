# Tcl package index file, version 1.0

if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded itcl 4.0.3 [list load [file join $dir "itcl403.dll"] itcl]
package ifneeded Itcl 4.0.3 [list load [file join $dir "itcl403.dll"] itcl]
