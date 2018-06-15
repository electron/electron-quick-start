if {[catch {package present Tcl 8.6.0}]} return
if {($::tcl_platform(platform) eq "unix") && ([info exists ::env(DISPLAY)]
	|| ([info exists ::argv] && ("-display" in $::argv)))} {
    package ifneeded Tk 8.6.4 [list load [file normalize [file join $dir .. .. bin libtk8.6.dll]] Tk]
} else {
    package ifneeded Tk 8.6.4 [list load [file normalize [file join $dir .. .. bin tk86.dll]] Tk]
}
