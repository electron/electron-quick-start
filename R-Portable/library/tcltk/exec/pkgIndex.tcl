# Tcl package index file, version 1.0


package ifneeded Hierarchy 2.0 [list tclPkgSetup $dir Hierarchy 2.0 {
    {hierarchy.tcl source {
	Hierarchy hierarchy hierarchy_dir hierarchy_widget
}   }   }]

package ifneeded Widget 2.0 [list tclPkgSetup $dir Widget 2.0 {
    {widget.tcl source {
	widget scrolledtext ScrolledText
}   }   }]

package ifneeded ::Utility 1.0 [subst {
    source [file join $dir util.tcl]
}]
#	get_opts get_opts2 randrng best_match grep
#	lremove lrandomize lunique luniqueo
#	line_append echo alias which ls dir validate fit_format

package ifneeded ::Utility::dump 1.0 [subst {
    source [file join $dir util-dump.tcl]
}]
#	dump

package ifneeded ::Utility::string 1.0 [subst {
    source [file join $dir util-string.tcl]
}]
#	string_reverse obfuscate untabify tabify wrap_lines

package ifneeded ::Utility::number 1.0 [subst {
    source [file join $dir util-number.tcl]
}]
#	get_square_size roman2dec bin2hex hex2bin

package ifneeded ::Utility::tk 1.0 [subst {
    source [file join $dir util-tk.tcl]
}]
#	warn place_window canvas_center canvas_see

package ifneeded ::Utility::expand 1.0 [subst {
    source [file join $dir util-expand.tcl]
}]
#	expand


package ifneeded PBar 1.0 [list tclPkgSetup $dir PBar 1.0 {
    {progressbar.tcl source {
	PBar ProgressBar ProgressBar::create ProgressBar::use
}   }   }]
