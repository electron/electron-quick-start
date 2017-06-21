# ----------------------------------------------------------------------------
#  widget.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: widget.tcl,v 1.35.2.1 2011/11/14 14:33:29 oehhar Exp $
# ----------------------------------------------------------------------------
#  Index of commands:
#     - Widget::tkinclude
#     - Widget::bwinclude
#     - Widget::declare
#     - Widget::addmap
#     - Widget::init
#     - Widget::destroy
#     - Widget::setoption
#     - Widget::configure
#     - Widget::cget
#     - Widget::subcget
#     - Widget::hasChanged
#     - Widget::options
#     - Widget::_get_tkwidget_options
#     - Widget::_test_tkresource
#     - Widget::_test_bwresource
#     - Widget::_test_synonym
#     - Widget::_test_string
#     - Widget::_test_flag
#     - Widget::_test_enum
#     - Widget::_test_int
#     - Widget::_test_boolean
# ----------------------------------------------------------------------------
# Each megawidget gets a namespace of the same name inside the Widget namespace
# Each of these has an array opt, which contains information about the 
# megawidget options.  It maps megawidget options to a list with this format:
#     {optionType defaultValue isReadonly {additionalOptionalInfo}}
# Option types and their additional optional info are:
#	TkResource	{genericTkWidget genericTkWidgetOptionName}
#	BwResource	{nothing}
#	Enum		{list of enumeration values}
#	Int		{Boundary information}
#	Boolean		{nothing}
#	String		{nothing}
#	Flag		{string of valid flag characters}
#	Synonym		{nothing}
#	Color		{nothing}
#
# Next, each namespace has an array map, which maps class options to their
# component widget options:
#	map(-foreground) => {.e -foreground .f -foreground}
#
# Each has an array ${path}:opt, which contains the value of each megawidget
# option for a particular instance $path of the megawidget, and an array
# ${path}:mod, which stores the "changed" status of configuration options.

# Steps for creating a bwidget megawidget:
# 1. parse args to extract subwidget spec
# 2. Create frame with appropriate class and command line options
# 3. Get initialization options from optionDB, using frame
# 4. create subwidgets

# Uses newer string operations
package require Tcl 8.1.1

namespace eval Widget {
    variable _optiontype
    variable _class
    variable _tk_widget

    # This controls whether we try to use themed widgets from Tile
    variable _theme 0

    variable _aqua [expr {($::tcl_version >= 8.4) &&
			  [string equal [tk windowingsystem] "aqua"]}]

    array set _optiontype {
        TkResource Widget::_test_tkresource
        BwResource Widget::_test_bwresource
        Enum       Widget::_test_enum
        Int        Widget::_test_int
        Boolean    Widget::_test_boolean
        String     Widget::_test_string
        Flag       Widget::_test_flag
        Synonym    Widget::_test_synonym
        Color      Widget::_test_color
        Padding    Widget::_test_padding
    }

    proc use {} {}
}


# ----------------------------------------------------------------------------
#  Command Widget::tkinclude
#     Includes tk widget resources to BWidget widget.
#  class      class name of the BWidget
#  tkwidget   tk widget to include
#  subpath    subpath to configure
#  args       additionnal args for included options
# ----------------------------------------------------------------------------
proc Widget::tkinclude { class tkwidget subpath args } {
    foreach {cmd lopt} $args {
        # cmd can be
        #   include      options to include            lopt = {opt ...}
        #   remove       options to remove             lopt = {opt ...}
        #   rename       options to rename             lopt = {opt newopt ...}
        #   prefix       options to prefix             lopt = {pref opt opt ..}
        #   initialize   set default value for options lopt = {opt value ...}
        #   readonly     set readonly flag for options lopt = {opt flag ...}
        switch -- $cmd {
            remove {
                foreach option $lopt {
                    set remove($option) 1
                }
            }
            include {
                foreach option $lopt {
                    set include($option) 1
                }
            }
            prefix {
                set prefix [lindex $lopt 0]
                foreach option [lrange $lopt 1 end] {
                    set rename($option) "-$prefix[string range $option 1 end]"
                }
            }
            rename     -
            readonly   -
            initialize {
                array set $cmd $lopt
            }
            default {
                return -code error "invalid argument \"$cmd\""
            }
        }
    }

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap
    upvar 0 ${class}::optionExports exports

    # create resources informations from tk widget resources
    foreach optdesc [_get_tkwidget_options $tkwidget] {
        set option [lindex $optdesc 0]
        if { (![info exists include] || [info exists include($option)]) &&
             ![info exists remove($option)] } {
            if { [llength $optdesc] == 3 } {
                # option is a synonym
                set syn [lindex $optdesc 1]
                if { ![info exists remove($syn)] } {
                    # original option is not removed
                    if { [info exists rename($syn)] } {
                        set classopt($option) [list Synonym $rename($syn)]
                    } else {
                        set classopt($option) [list Synonym $syn]
                    }
                }
            } else {
                if { [info exists rename($option)] } {
                    set realopt $option
                    set option  $rename($option)
                } else {
                    set realopt $option
                }
                if { [info exists initialize($option)] } {
                    set value $initialize($option)
                } else {
                    set value [lindex $optdesc 1]
                }
                if { [info exists readonly($option)] } {
                    set ro $readonly($option)
                } else {
                    set ro 0
                }
                set classopt($option) \
			[list TkResource $value $ro [list $tkwidget $realopt]]

		# Add an option database entry for this option
		set optionDbName ".[lindex [_configure_option $realopt ""] 0]"
		if { ![string equal $subpath ":cmd"] } {
		    set optionDbName "$subpath$optionDbName"
		}
		option add *${class}$optionDbName $value widgetDefault
		lappend exports($option) "$optionDbName"

		# Store the forward and backward mappings for this
		# option <-> realoption pair
                lappend classmap($option) $subpath "" $realopt
		set submap($realopt) $option
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::bwinclude
#     Includes BWidget resources to BWidget widget.
#  class    class name of the BWidget
#  subclass BWidget class to include
#  subpath  subpath to configure
#  args     additionnal args for included options
# ----------------------------------------------------------------------------
proc Widget::bwinclude { class subclass subpath args } {
    foreach {cmd lopt} $args {
        # cmd can be
        #   include      options to include            lopt = {opt ...}
        #   remove       options to remove             lopt = {opt ...}
        #   rename       options to rename             lopt = {opt newopt ...}
        #   prefix       options to prefix             lopt = {prefix opt opt ...}
        #   initialize   set default value for options lopt = {opt value ...}
        #   readonly     set readonly flag for options lopt = {opt flag ...}
        switch -- $cmd {
            remove {
                foreach option $lopt {
                    set remove($option) 1
                }
            }
            include {
                foreach option $lopt {
                    set include($option) 1
                }
            }
            prefix {
                set prefix [lindex $lopt 0]
                foreach option [lrange $lopt 1 end] {
                    set rename($option) "-$prefix[string range $option 1 end]"
                }
            }
            rename     -
            readonly   -
            initialize {
                array set $cmd $lopt
            }
            default {
                return -code error "invalid argument \"$cmd\""
            }
        }
    }

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap
    upvar 0 ${class}::optionExports exports
    upvar 0 ${subclass}::opt subclassopt
    upvar 0 ${subclass}::optionExports subexports

    # create resources informations from BWidget resources
    foreach {option optdesc} [array get subclassopt] {
	set subOption $option
        if { (![info exists include] || [info exists include($option)]) &&
             ![info exists remove($option)] } {
            set type [lindex $optdesc 0]
            if { [string equal $type "Synonym"] } {
                # option is a synonym
                set syn [lindex $optdesc 1]
                if { ![info exists remove($syn)] } {
                    if { [info exists rename($syn)] } {
                        set classopt($option) [list Synonym $rename($syn)]
                    } else {
                        set classopt($option) [list Synonym $syn]
                    }
                }
            } else {
                if { [info exists rename($option)] } {
                    set realopt $option
                    set option  $rename($option)
                } else {
                    set realopt $option
                }
                if { [info exists initialize($option)] } {
                    set value $initialize($option)
                } else {
                    set value [lindex $optdesc 1]
                }
                if { [info exists readonly($option)] } {
                    set ro $readonly($option)
                } else {
                    set ro [lindex $optdesc 2]
                }
                set classopt($option) \
			[list $type $value $ro [lindex $optdesc 3]]

		# Add an option database entry for this option
		foreach optionDbName $subexports($subOption) {
		    if { ![string equal $subpath ":cmd"] } {
			set optionDbName "$subpath$optionDbName"
		    }
		    # Only add the option db entry if we are overriding the
		    # normal widget default
		    if { [info exists initialize($option)] } {
			option add *${class}$optionDbName $value \
				widgetDefault
		    }
		    lappend exports($option) "$optionDbName"
		}

		# Store the forward and backward mappings for this
		# option <-> realoption pair
                lappend classmap($option) $subpath $subclass $realopt
		set submap($realopt) $option
            }
        }
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::declare
#    Declares new options to BWidget class.
# ----------------------------------------------------------------------------
proc Widget::declare { class optlist } {
    variable _optiontype

    namespace eval $class {}
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::optionExports exports
    upvar 0 ${class}::optionClass optionClass

    foreach optdesc $optlist {
        set option  [lindex $optdesc 0]
        set optdesc [lrange $optdesc 1 end]
        set type    [lindex $optdesc 0]

        if { ![info exists _optiontype($type)] } {
            # invalid resource type
            return -code error "invalid option type \"$type\""
        }

        if { [string equal $type "Synonym"] } {
            # test existence of synonym option
            set syn [lindex $optdesc 1]
            if { ![info exists classopt($syn)] } {
                return -code error "unknow option \"$syn\" for Synonym \"$option\""
            }
            set classopt($option) [list Synonym $syn]
            continue
        }

        # all other resource may have default value, readonly flag and
        # optional arg depending on type
        set value [lindex $optdesc 1]
        set ro    [lindex $optdesc 2]
        set arg   [lindex $optdesc 3]

        if { [string equal $type "BwResource"] } {
            # We don't keep BwResource. We simplify to type of sub BWidget
            set subclass    [lindex $arg 0]
            set realopt     [lindex $arg 1]
            if { ![string length $realopt] } {
                set realopt $option
            }

            upvar 0 ${subclass}::opt subclassopt
            if { ![info exists subclassopt($realopt)] } {
                return -code error "unknow option \"$realopt\""
            }
            set suboptdesc $subclassopt($realopt)
            if { $value == "" } {
                # We initialize default value
                set value [lindex $suboptdesc 1]
            }
            set type [lindex $suboptdesc 0]
            set ro   [lindex $suboptdesc 2]
            set arg  [lindex $suboptdesc 3]
	    set optionDbName ".[lindex [_configure_option $option ""] 0]"
	    option add *${class}${optionDbName} $value widgetDefault
	    set exports($option) $optionDbName
            set classopt($option) [list $type $value $ro $arg]
            continue
        }

        # retreive default value for TkResource
        if { [string equal $type "TkResource"] } {
            set tkwidget [lindex $arg 0]
            set realopt  [lindex $arg 1]
            if { ![string length $realopt] } {
                set realopt $option
            }
            set tkoptions [_get_tkwidget_options $tkwidget]
            set ind [lsearch $tkoptions [list $realopt *]]
            set optdesc [lindex $tkoptions $ind];
            set tkoptions [_get_tkwidget_options $tkwidget]
            if { ![string length $value] } {
                # We initialize default value
                set value [lindex $optdesc end]
            }
	    set optionDbName ".[lindex [_configure_option $option ""] 0]"
	    option add *${class}${optionDbName} $value widgetDefault
	    set exports($option) $optionDbName
            set classopt($option) [list TkResource $value $ro \
		    [list $tkwidget $realopt]]
	    set optionClass($option) [lindex $optdesc 1]
            continue
        }

	set optionDbName ".[lindex [_configure_option $option ""] 0]"
	option add *${class}${optionDbName} $value widgetDefault
	set exports($option) $optionDbName
        # for any other resource type, we keep original optdesc
        set classopt($option) [list $type $value $ro $arg]
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::define
#  	Declares a new class and loads its dependencies.
#
# Arguments:
#	class		megawidget class
#	filename	file where the class resides
#	options    	The following options are supported:
#			-classonly	Prevents megawidget setup: creation of
#					megawidget alias, binding of the
#					<Destroy> event and stubbing of the
#					'use' procedure.
#			-namespace ns	Indicate the namespace where the
#					megawidget's procedures reside. Defaults
#					to ::${class}.
#	dependencies   	classes the class being defined depends on.
#
# ----------------------------------------------------------------------------
proc Widget::define { class filename args } {
    variable ::BWidget::use
    set classonly 0;
    set ns ::${class};
    for {set i 0; set n [llength $args]} {$i < $n} {incr i} {
	set option [lindex $args $i];
	switch -- $option {
	    -classonly {
		set classonly 1;
	    }
	    -namespace {
		incr i;
		set ns [lindex $args $i];
	    }
	    default {
		# stop processing options
		break;
	    }
	}
    }
    set args [lrange $args $i end]

    set use($class)      $args
    set use($class,file) $filename
    set use($class,namespace) $ns;
    lappend use(classes) $class

    # Make sure the class description namespace exists.
    namespace eval $class {}
    # Make sure the megawidget namespace exists.
    namespace eval $ns {}

    if {!$classonly} {
	interp alias {} ${ns} {} ${ns}::create
	proc ${ns}::use {} {}
	bind $class <Destroy> [list Widget::destroy %W]
    }

    foreach dep $args {
	if {![info exists use(${dep},namespace)]} {
	    # Lazy-loaded modules are not yet loaded (actually that seems to be
	    # the whole point of this 'use' mechanism.) so they have not configured
	    # a namespace. Use namespace=class convention. Note that the class MUST
	    # not be prefixed by ::.
	    ${dep}::use;
	} else {
	    $use(${dep},namespace)::use;
	}
    }
}


proc Widget::create { class path {rename 1} } {
    if {$rename} { rename $path ::$path:cmd }

    variable ::BWidget::use;
    set ns [expr {[info exists use(${class},namespace)]
		  ? $use(${class},namespace)
		  : $class}];

    proc ::$path { cmd args } \
	[subst {return \[eval \[linsert \$args 0 ${ns}::\$cmd [list $path]\]\]}]
    return $path
}


# ----------------------------------------------------------------------------
#  Command Widget::addmap
# ----------------------------------------------------------------------------
proc Widget::addmap { class subclass subpath options } {
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::optionExports exports
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::map$subpath submap

    foreach {option realopt} $options {
        if { ![string length $realopt] } {
            set realopt $option
        }
	set val [lindex $classopt($option) 1]
	set optDb ".[lindex [_configure_option $realopt ""] 0]"
	if { ![string equal $subpath ":cmd"] } {
	    set optDb "$subpath$optDb"
	}
	option add *${class}${optDb} $val widgetDefault
	lappend exports($option) $optDb
	# Store the forward and backward mappings for this
	# option <-> realoption pair
        lappend classmap($option) $subpath $subclass $realopt
	set submap($realopt) $option
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::init
# ----------------------------------------------------------------------------
proc Widget::init { class path options } {
    variable _inuse
    variable _class
    variable _optiontype

    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::$path:opt  pathopt
    upvar 0 ${class}::$path:mod  pathmod
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::$path:init pathinit

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }
    # We prefer to use the actual widget for option db queries, but if it
    # doesn't exist yet, do the next best thing:  create a widget of the
    # same class and use that.
    set fpath $path
    set rdbclass [string map [list :: ""] $class]
    if { ![winfo exists $path] } {
	set fpath ".#BWidget.#Class#$class"
	# encapsulation frame to not pollute '.' childspace
	if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
	if { ![winfo exists $fpath] } {
	    frame $fpath -class $rdbclass
	}
    }
    foreach {option optdesc} [array get classopt] {
        set pathmod($option) 0
	if { [info exists classmap($option)] } {
	    continue
	}
        set type [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
	    continue
        }
        if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set optdb [lindex [_configure_option $option $alt] 0]
        set def   [option get $fpath $optdb $rdbclass]
        if { [string length $def] } {
            set pathopt($option) $def
        } else {
            set pathopt($option) [lindex $optdesc 1]
        }
    }

    if {![info exists _inuse($class)]} { set _inuse($class) 0 }
    incr _inuse($class)

    set _class($path) $class
    foreach {option value} $options {
        if { ![info exists classopt($option)] } {
            unset pathopt
            unset pathmod
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        # this may fail if a wrong enum element was used
        if {[catch {
             $_optiontype($type) $option $value [lindex $optdesc 3]
        } msg]} {
            if {[info exists pathopt]} {
                unset pathopt
            }
            unset pathmod
            return -code error $msg
        }
        set pathopt($option) $msg
	set pathinit($option) $pathopt($option)
    }
}

# Bastien Chevreux (bach@mwgdna.com)
#
# copyinit performs basically the same job as init, but it uses a
#  existing template to initialize its values. So, first a perferct copy
#  from the template is made just to be altered by any existing options
#  afterwards.
# But this still saves time as the first initialization parsing block is
#  skipped.
# As additional bonus, items that differ in just a few options can be
#  initialized faster by leaving out the options that are equal.

# This function is currently used only by ListBox::multipleinsert, but other
#  calls should follow :)

# ----------------------------------------------------------------------------
#  Command Widget::copyinit
# ----------------------------------------------------------------------------
proc Widget::copyinit { class templatepath path options } {
    variable _class
    variable _optiontype
    upvar 0 ${class}::opt classopt \
	    ${class}::$path:opt	 pathopt \
	    ${class}::$path:mod	 pathmod \
	    ${class}::$path:init pathinit \
	    ${class}::$templatepath:opt	  templatepathopt \
	    ${class}::$templatepath:mod	  templatepathmod \
	    ${class}::$templatepath:init  templatepathinit

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }

    # We use the template widget for option db copying, but it has to exist!
    array set pathmod  [array get templatepathmod]
    array set pathopt  [array get templatepathopt]
    array set pathinit [array get templatepathinit]

    set _class($path) $class
    foreach {option value} $options {
	if { ![info exists classopt($option)] } {
	    unset pathopt
	    unset pathmod
	    return -code error "unknown option \"$option\""
	}
	set optdesc $classopt($option)
	set type    [lindex $optdesc 0]
	if { [string equal $type "Synonym"] } {
	    set option	[lindex $optdesc 1]
	    set optdesc $classopt($option)
	    set type	[lindex $optdesc 0]
	}
	set pathopt($option) [$_optiontype($type) $option $value [lindex $optdesc 3]]
	set pathinit($option) $pathopt($option)
    }
}

# Widget::parseArgs --
#
#	Given a widget class and a command-line spec, cannonize and validate
#	the given options, and return a keyed list consisting of the 
#	component widget and its masked portion of the command-line spec, and
#	one extra entry consisting of the portion corresponding to the 
#	megawidget itself.
#
# Arguments:
#	class	widget class to parse for.
#	options	command-line spec
#
# Results:
#	result	keyed list of portions of the megawidget and that segment of
#		the command line in which that portion is interested.

proc Widget::parseArgs {class options} {
    variable _optiontype
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    
    foreach {option val} $options {
	if { ![info exists classopt($option)] } {
	    error "unknown option \"$option\""
	}
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
	if { [string equal $type "TkResource"] } {
	    # Make sure that the widget used for this TkResource exists
	    Widget::_get_tkwidget_options [lindex [lindex $optdesc 3] 0]
	}
	set val [$_optiontype($type) $option $val [lindex $optdesc 3]]
		
	if { [info exists classmap($option)] } {
	    foreach {subpath subclass realopt} $classmap($option) {
		lappend maps($subpath) $realopt $val
	    }
	} else {
	    lappend maps($class) $option $val
	}
    }
    return [array get maps]
}

# Widget::initFromODB --
#
#	Initialize a megawidgets options with information from the option
#	database and from the command-line arguments given.
#
# Arguments:
#	class	class of the widget.
#	path	path of the widget -- should already exist.
#	options	command-line arguments.
#
# Results:
#	None.

proc Widget::initFromODB {class path options} {
    variable _inuse
    variable _class

    upvar 0 ${class}::$path:opt  pathopt
    upvar 0 ${class}::$path:mod  pathmod
    upvar 0 ${class}::map classmap

    if { [info exists pathopt] } {
	unset pathopt
    }
    if { [info exists pathmod] } {
	unset pathmod
    }
    # We prefer to use the actual widget for option db queries, but if it
    # doesn't exist yet, do the next best thing:  create a widget of the
    # same class and use that.
    set fpath [_get_window $class $path]
    set rdbclass [string map [list :: ""] $class]
    if { ![winfo exists $path] } {
	set fpath ".#BWidget.#Class#$class"
	# encapsulation frame to not pollute '.' childspace
	if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
	if { ![winfo exists $fpath] } {
	    frame $fpath -class $rdbclass
	}
    }

    foreach {option optdesc} [array get ${class}::opt] {
        set pathmod($option) 0
	if { [info exists classmap($option)] } {
	    continue
	}
        set type [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
	    continue
        }
	if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set optdb [lindex [_configure_option $option $alt] 0]
        set def   [option get $fpath $optdb $rdbclass]
        if { [string length $def] } {
            set pathopt($option) $def
        } else {
            set pathopt($option) [lindex $optdesc 1]
        }
    }

    if {![info exists _inuse($class)]} { set _inuse($class) 0 }
    incr _inuse($class)

    set _class($path) $class
    array set pathopt $options
}



# ----------------------------------------------------------------------------
#  Command Widget::destroy
# ----------------------------------------------------------------------------
proc Widget::destroy { path } {
    variable _class
    variable _inuse

    if {![info exists _class($path)]} { return }

    set class $_class($path)
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod
    upvar 0 ${class}::$path:init pathinit

    if {[info exists _inuse($class)]} { incr _inuse($class) -1 }

    if {[info exists pathopt]} {
        unset pathopt
    }
    if {[info exists pathmod]} {
        unset pathmod
    }
    if {[info exists pathinit]} {
        unset pathinit
    }

    if {![string equal [info commands $path] ""]} { rename $path "" }

    # Unset any variables used in this widget.
    # Guard, as some internal classes (Bitmap, LabelEntry, ListBox::Item,
    # NoteBook::Page, PanedWindow::Pane, ScrollableFrame, ScrollableFrame,
    # ScrollableFrame, Tree::Node, Wizard::Branch, Wizard::Step, Wizard::Widget)
    # are declared but not defined.
    if {[info exists ::BWidget::use(${class},namespace)]} {
	set ns $::BWidget::use(${class},namespace);
	foreach var [info vars ${ns}::${path}:*] { unset $var }
    }

    unset _class($path)
}


# ----------------------------------------------------------------------------
#  Command Widget::configure
# ----------------------------------------------------------------------------
proc Widget::configure { path options } {
    set len [llength $options]
    if { $len <= 1 } {
        return [_get_configure $path $options]
    } elseif { $len % 2 == 1 } {
        return -code error "incorrect number of arguments"
    }

    variable _class
    variable _optiontype

    set class $_class($path)
    upvar 0 ${class}::opt  classopt
    upvar 0 ${class}::map  classmap
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod

    set window [_get_window $class $path]
    foreach {option value} $options {
        if { ![info exists classopt($option)] } {
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        if { ![lindex $optdesc 2] } {
            set newval [$_optiontype($type) $option $value [lindex $optdesc 3]]
            if { [info exists classmap($option)] } {
		set window [_get_window $class $window]
                foreach {subpath subclass realopt} $classmap($option) {
                    # Interpretation of special pointers:
                    # | subclass | subpath | widget           | path           | class   |
                    # +----------+---------+------------------+----------------+-context-+
                    # | :cmd     | :cmd    | herited widget   | window:cmd     |window   |
                    # | :cmd     | *       | subwidget        | window.subpath | window  |
                    # | ""       | :cmd    | herited widget   | window:cmd     | window  |
                    # | ""       | *       | own              | window         | window  |
                    # | *        | :cmd    | own              | window         | current |
                    # | *        | *       | subwidget        | window.subpath | current |
                    if { [string length $subclass] && ! [string equal $subclass ":cmd"] } {
                        if { [string equal $subpath ":cmd"] } {
                            set subpath ""
                        }
                        set ns $::BWidget::use(${subclass},namespace);
                        set curval [${ns}::cget $window$subpath $realopt]
                        ${ns}::configure $window$subpath $realopt $newval
                    } else {
                        set curval [$window$subpath cget $realopt]
                        $window$subpath configure $realopt $newval
                    }
                }
            } else {
		set curval $pathopt($option)
		set pathopt($option) $newval
	    }
	    set pathmod($option) [expr {![string equal $newval $curval]}]
        }
    }

    return {}
}


# ----------------------------------------------------------------------------
#  Command Widget::cget
# ----------------------------------------------------------------------------
proc Widget::cget { path option } {
    variable _class
    if { ![info exists _class($path)] } {
        return -code error "unknown widget $path"
    }

    set class $_class($path)
    if { ![info exists ${class}::opt($option)] } {
        return -code error "unknown option \"$option\""
    }

    set optdesc [set ${class}::opt($option)]
    set type    [lindex $optdesc 0]
    if {[string equal $type "Synonym"]} {
        set option [lindex $optdesc 1]
    }

    if { [info exists ${class}::map($option)] } {
	foreach {subpath subclass realopt} [set ${class}::map($option)] {break}
	set path "[_get_window $class $path]$subpath"
	return [$path cget $realopt]
    }
    upvar 0 ${class}::$path:opt pathopt
    set pathopt($option)
}


# ----------------------------------------------------------------------------
#  Command Widget::subcget
# ----------------------------------------------------------------------------
proc Widget::subcget { path subwidget } {
    variable _class
    set class $_class($path)
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::map$subwidget submap
    upvar 0 ${class}::$path:init pathinit

    set result {}
    foreach realopt [array names submap] {
	if { [info exists pathinit($submap($realopt))] } {
	    lappend result $realopt $pathopt($submap($realopt))
	}
    }
    return $result
}


# ----------------------------------------------------------------------------
#  Command Widget::hasChanged
# ----------------------------------------------------------------------------
proc Widget::hasChanged { path option pvalue } {
    variable _class
    upvar $pvalue value
    set class $_class($path)
    upvar 0 ${class}::$path:mod pathmod

    set value   [Widget::cget $path $option]
    set result  $pathmod($option)
    set pathmod($option) 0

    return $result
}

proc Widget::hasChangedX { path option args } {
    variable _class
    set class $_class($path)
    upvar 0 ${class}::$path:mod pathmod

    set result  $pathmod($option)
    set pathmod($option) 0
    foreach option $args {
	lappend result $pathmod($option)
	set pathmod($option) 0
    }

    set result
}


# ----------------------------------------------------------------------------
#  Command Widget::setoption
# ----------------------------------------------------------------------------
proc Widget::setoption { path option value } {
#    variable _class

#    set class $_class($path)
#    upvar 0 ${class}::$path:opt pathopt

#    set pathopt($option) $value
    Widget::configure $path [list $option $value]
}


# ----------------------------------------------------------------------------
#  Command Widget::getoption
# ----------------------------------------------------------------------------
proc Widget::getoption { path option } {
#    set class $::Widget::_class($path)
#    upvar 0 ${class}::$path:opt pathopt

#    return $pathopt($option)
    return [Widget::cget $path $option]
}

# Widget::getMegawidgetOption --
#
#	Bypass the superfluous checks in cget and just directly peer at the
#	widget's data space.  This is much more fragile than cget, so it 
#	should only be used with great care, in places where speed is critical.
#
# Arguments:
#	path	widget to lookup options for.
#	option	option to retrieve.
#
# Results:
#	value	option value.

proc Widget::getMegawidgetOption {path option} {
    variable _class
    set class $_class($path)
    upvar 0 ${class}::${path}:opt pathopt
    set pathopt($option)
}

# Widget::setMegawidgetOption --
#
#	Bypass the superfluous checks in cget and just directly poke at the
#	widget's data space.  This is much more fragile than configure, so it 
#	should only be used with great care, in places where speed is critical.
#
# Arguments:
#	path	widget to lookup options for.
#	option	option to retrieve.
#	value	option value.
#
# Results:
#	value	option value.

proc Widget::setMegawidgetOption {path option value} {
    variable _class
    set class $_class($path)
    upvar 0 ${class}::${path}:opt pathopt
    set pathopt($option) $value
}

# ----------------------------------------------------------------------------
#  Command Widget::_get_window
#  returns the window corresponding to widget path
# ----------------------------------------------------------------------------
proc Widget::_get_window { class path } {
    set idx [string last "#" $path]
    if { $idx != -1 && [string equal [string range $path [expr {$idx+1}] end] $class] } {
        return [string range $path 0 [expr {$idx-1}]]
    } else {
        return $path
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::_get_configure
#  returns the configuration list of options
#  (as tk widget do - [$w configure ?option?])
# ----------------------------------------------------------------------------
proc Widget::_get_configure { path options } {
    variable _class

    set class $_class($path)
    upvar 0 ${class}::opt classopt
    upvar 0 ${class}::map classmap
    upvar 0 ${class}::$path:opt pathopt
    upvar 0 ${class}::$path:mod pathmod

    set len [llength $options]
    if { !$len } {
        set result {}
        foreach option [lsort [array names classopt]] {
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
            if { [string equal $type "Synonym"] } {
                set syn     $option
                set option  [lindex $optdesc 1]
                set optdesc $classopt($option)
                set type    [lindex $optdesc 0]
            } else {
                set syn ""
            }
            if { [string equal $type "TkResource"] } {
                set alt [lindex [lindex $optdesc 3] 1]
            } else {
                set alt ""
            }
            set res [_configure_option $option $alt]
            if { $syn == "" } {
                lappend result [concat $option $res [list [lindex $optdesc 1]] [list [cget $path $option]]]
            } else {
                lappend result [list $syn [lindex $res 0]]
            }
        }
        return $result
    } elseif { $len == 1 } {
        set option  [lindex $options 0]
        if { ![info exists classopt($option)] } {
            return -code error "unknown option \"$option\""
        }
        set optdesc $classopt($option)
        set type    [lindex $optdesc 0]
        if { [string equal $type "Synonym"] } {
            set option  [lindex $optdesc 1]
            set optdesc $classopt($option)
            set type    [lindex $optdesc 0]
        }
        if { [string equal $type "TkResource"] } {
            set alt [lindex [lindex $optdesc 3] 1]
        } else {
            set alt ""
        }
        set res [_configure_option $option $alt]
        return [concat $option $res [list [lindex $optdesc 1]] [list [cget $path $option]]]
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::_configure_option
# ----------------------------------------------------------------------------
proc Widget::_configure_option { option altopt } {
    variable _optiondb
    variable _optionclass

    if { [info exists _optiondb($option)] } {
        set optdb $_optiondb($option)
    } else {
        set optdb [string range $option 1 end]
    }
    if { [info exists _optionclass($option)] } {
        set optclass $_optionclass($option)
    } elseif { [string length $altopt] } {
        if { [info exists _optionclass($altopt)] } {
            set optclass $_optionclass($altopt)
        } else {
            set optclass [string range $altopt 1 end]
        }
    } else {
        set optclass [string range $option 1 end]
    }
    return [list $optdb $optclass]
}

# ----------------------------------------------------------------------------
#  Command Widget::_make_tk_widget_name
# ----------------------------------------------------------------------------
# Before, the widget meta name was build as: ".#BWidget.#$tkwidget"
# This does not work for ttk widgets, as they have an "::" in their name.
# Thus replace any "::" by "__" will do the job.
proc Widget::_make_tk_widget_name { tkwidget } {
    set pos 0
    for {set pos 0} {0 <= [set pos [string first "::" $tkwidget $pos]]} {incr pos} {
	set tkwidget [string range $tkwidget 0 [expr {$pos-1}]]__[string range $tkwidget [expr {$pos+2}] end]
    }
    return ".#BWidget.#$tkwidget"
}

# ----------------------------------------------------------------------------
#  Command Widget::_get_tkwidget_options
# ----------------------------------------------------------------------------
proc Widget::_get_tkwidget_options { tkwidget } {
    variable _tk_widget
    variable _optiondb
    variable _optionclass

    set widget [_make_tk_widget_name $tkwidget]
    # encapsulation frame to not pollute '.' childspace
    if {![winfo exists ".#BWidget"]} { frame ".#BWidget" }
    if { ![winfo exists $widget] || ![info exists _tk_widget($tkwidget)] } {
	set widget [$tkwidget $widget]
	# JDC: Withdraw toplevels, otherwise visible
	if {[string equal $tkwidget "toplevel"]} {
	    wm withdraw $widget
	}
	set config [$widget configure]
	foreach optlist $config {
	    set opt [lindex $optlist 0]
	    if { [llength $optlist] == 2 } {
		set refsyn [lindex $optlist 1]
		# search for class
		set idx [lsearch $config [list * $refsyn *]]
		if { $idx == -1 } {
		    if { [string index $refsyn 0] == "-" } {
			# search for option (tk8.1b1 bug)
			set idx [lsearch $config [list $refsyn * *]]
		    } else {
			# last resort
			set idx [lsearch $config [list -[string tolower $refsyn] * *]]
		    }
		    if { $idx == -1 } {
			# fed up with "can't read classopt()"
			return -code error "can't find option of synonym $opt"
		    }
		}
		set syn [lindex [lindex $config $idx] 0]
		# JDC: used 4 (was 3) to get def from optiondb
		set def [lindex [lindex $config $idx] 4]
		lappend _tk_widget($tkwidget) [list $opt $syn $def]
	    } else {
		# JDC: used 4 (was 3) to get def from optiondb
		set def [lindex $optlist 4]
		lappend _tk_widget($tkwidget) [list $opt $def]
		set _optiondb($opt)    [lindex $optlist 1]
		set _optionclass($opt) [lindex $optlist 2]
	    }
	}
    }
    return $_tk_widget($tkwidget)
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_tkresource
# ----------------------------------------------------------------------------
proc Widget::_test_tkresource { option value arg } {
#    set tkwidget [lindex $arg 0]
#    set realopt  [lindex $arg 1]
    foreach {tkwidget realopt} $arg break
    set path     [_make_tk_widget_name $tkwidget]
    set old      [$path cget $realopt]
    $path configure $realopt $value
    set res      [$path cget $realopt]
    $path configure $realopt $old

    return $res
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_bwresource
# ----------------------------------------------------------------------------
proc Widget::_test_bwresource { option value arg } {
    return -code error "bad option type BwResource in widget"
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_synonym
# ----------------------------------------------------------------------------
proc Widget::_test_synonym { option value arg } {
    return -code error "bad option type Synonym in widget"
}

# ----------------------------------------------------------------------------
#  Command Widget::_test_color
# ----------------------------------------------------------------------------
proc Widget::_test_color { option value arg } {
    if {[catch {winfo rgb . $value} color]} {
        return -code error "bad $option value \"$value\": must be a colorname \
		or #RRGGBB triplet"
    }

    return $value
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_string
# ----------------------------------------------------------------------------
proc Widget::_test_string { option value arg } {
    set value
}


# ----------------------------------------------------------------------------
#  Command Widget::_test_flag
# ----------------------------------------------------------------------------
proc Widget::_test_flag { option value arg } {
    set len [string length $value]
    set res ""
    for {set i 0} {$i < $len} {incr i} {
        set c [string index $value $i]
        if { [string first $c $arg] == -1 } {
            return -code error "bad [string range $option 1 end] value \"$value\": characters must be in \"$arg\""
        }
        if { [string first $c $res] == -1 } {
            append res $c
        }
    }
    return $res
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_enum
# -----------------------------------------------------------------------------
proc Widget::_test_enum { option value arg } {
    if { [lsearch $arg $value] == -1 } {
        set last [lindex   $arg end]
        set sub  [lreplace $arg end end]
        if { [llength $sub] } {
            set str "[join $sub ", "] or $last"
        } else {
            set str $last
        }
        return -code error "bad [string range $option 1 end] value \"$value\": must be $str"
    }
    return $value
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_int
# -----------------------------------------------------------------------------
proc Widget::_test_int { option value arg } {
    if { ![string is int -strict $value] || \
	    ([string length $arg] && \
	    ![expr [string map [list %d $value] $arg]]) } {
		    return -code error "bad $option value\
			    \"$value\": must be integer ($arg)"
    }
    return $value
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_boolean
# -----------------------------------------------------------------------------
proc Widget::_test_boolean { option value arg } {
    if { ![string is boolean -strict $value] } {
        return -code error "bad $option value \"$value\": must be boolean"
    }

    # Get the canonical form of the boolean value (1 for true, 0 for false)
    return [string is true $value]
}


# -----------------------------------------------------------------------------
#  Command Widget::_test_padding
# -----------------------------------------------------------------------------
proc Widget::_test_padding { option values arg } {
    set len [llength $values]
    if {$len < 1 || $len > 2} {
        return -code error "bad pad value \"$values\":\
                        must be positive screen distance"
    }

    foreach value $values {
        if { ![string is int -strict $value] || \
            ([string length $arg] && \
            ![expr [string map [list %d $value] $arg]]) } {
                return -code error "bad pad value \"$value\":\
                                must be positive screen distance ($arg)"
        }
    }
    return $values
}


# Widget::_get_padding --
#
#       Return the requesting padding value for a padding option.
#
# Arguments:
#	path		Widget to get the options for.
#       option          The name of the padding option.
#	index		The index of the padding.  If the index is empty,
#                       the first padding value is returned.
#
# Results:
#	Return a numeric value that can be used for padding.
proc Widget::_get_padding { path option {index 0} } {
    set pad [Widget::cget $path $option]
    set val [lindex $pad $index]
    if {$val == ""} { set val [lindex $pad 0] }
    return $val
}


# -----------------------------------------------------------------------------
#  Command Widget::focusNext
#  Same as tk_focusNext, but call Widget::focusOK
# -----------------------------------------------------------------------------
proc Widget::focusNext { w } {
    set cur $w
    while 1 {

	# Descend to just before the first child of the current widget.

	set parent $cur
	set children [winfo children $cur]
	set i -1

	# Look for the next sibling that isn't a top-level.

	while 1 {
	    incr i
	    if {$i < [llength $children]} {
		set cur [lindex $children $i]
		if {[string equal [winfo toplevel $cur] $cur]} {
		    continue
		} else {
		    break
		}
	    }

	    # No more siblings, so go to the current widget's parent.
	    # If it's a top-level, break out of the loop, otherwise
	    # look for its next sibling.

	    set cur $parent
	    if {[string equal [winfo toplevel $cur] $cur]} {
		break
	    }
	    set parent [winfo parent $parent]
	    set children [winfo children $parent]
	    set i [lsearch -exact $children $cur]
	}
	if {[string equal $cur $w] || [focusOK $cur]} {
	    return $cur
	}
    }
}


# -----------------------------------------------------------------------------
#  Command Widget::focusPrev
#  Same as tk_focusPrev, except:
#	+ Don't traverse from a child to a direct ancestor
#	+ Call Widget::focusOK instead of tk::focusOK
# -----------------------------------------------------------------------------
proc Widget::focusPrev { w } {
    set cur $w
    set origParent [winfo parent $w]
    while 1 {

	# Collect information about the current window's position
	# among its siblings.  Also, if the window is a top-level,
	# then reposition to just after the last child of the window.

	if {[string equal [winfo toplevel $cur] $cur]}  {
	    set parent $cur
	    set children [winfo children $cur]
	    set i [llength $children]
	} else {
	    set parent [winfo parent $cur]
	    set children [winfo children $parent]
	    set i [lsearch -exact $children $cur]
	}

	# Go to the previous sibling, then descend to its last descendant
	# (highest in stacking order.  While doing this, ignore top-levels
	# and their descendants.  When we run out of descendants, go up
	# one level to the parent.

	while {$i > 0} {
	    incr i -1
	    set cur [lindex $children $i]
	    if {[string equal [winfo toplevel $cur] $cur]} {
		continue
	    }
	    set parent $cur
	    set children [winfo children $parent]
	    set i [llength $children]
	}
	set cur $parent
	if {[string equal $cur $w]} {
	    return $cur
	}
	# If we are just at the original parent of $w, skip it as a
	# potential focus accepter.  Extra safety in this is to see if
	# that parent is also a proc (not a C command), which is what
	# BWidgets makes for any megawidget.  Could possibly also check
	# for '[info commands ::${origParent}:cmd] != ""'.  [Bug 765667]
	if {[string equal $cur $origParent]
	    && [info procs ::$origParent] != ""} {
	    continue
	}
	if {[focusOK $cur]} {
	    return $cur
	}
    }
}


# ----------------------------------------------------------------------------
#  Command Widget::focusOK
#  Same as tk_focusOK, but handles -editable option and whole tags list.
# ----------------------------------------------------------------------------
proc Widget::focusOK { w } {
    set code [catch {$w cget -takefocus} value]
    if { $code == 1 } {
        return 0
    }
    if {($code == 0) && ($value != "")} {
	if {$value == 0} {
	    return 0
	} elseif {$value == 1} {
	    return [winfo viewable $w]
	} else {
	    set value [uplevel \#0 [list $value $w]]
            if {$value != ""} {
		return $value
	    }
        }
    }
    if {![winfo viewable $w]} {
	return 0
    }
    set code [catch {$w cget -state} value]
    if {($code == 0) && ($value == "disabled")} {
	return 0
    }
    set code [catch {$w cget -editable} value]
    if {($code == 0) && ($value == 0)} {
        return 0
    }

    set top [winfo toplevel $w]
    foreach tags [bindtags $w] {
        if { ![string equal $tags $top]  &&
             ![string equal $tags "all"] &&
             [regexp Key [bind $tags]] } {
            return 1
        }
    }
    return 0
}


proc Widget::traverseTo { w } {
    set focus [focus]
    if {![string equal $focus ""]} {
	event generate $focus <<TraverseOut>>
    }
    focus $w

    event generate $w <<TraverseIn>>
}

# Widget::which --
#
#	Retrieve a fully qualified variable name for the specified option or
#	widget variable.
#
#	If the option is not one for which a variable exists, throw an error
#	(ie, those options that map directly to widget options).
#
#	For widget variables, return the fully qualified name even if the
#	variable had not been previously set, in order to allow adding variable
#	traces prior to their creation.
#
# Arguments:
#	path	megawidget to get an option var for.
#	type	either -option or -variable.
#	name    name of the option or widget variable.
#
# Results:
#	Fully qualified name of the variable for the option or the widget
#	variable.
#
proc Widget::which {path args} {
    switch -- [llength $args] {
	1 {
	    set type -option;
	    set name [lindex $args 0];
	}
	2 {
	    set type [lindex $args 0];
	    set name [lindex $args 1];
	}
	default {
	    return -code error "incorrect number of arguments";
	}
    }

    variable _class;
    set class $_class($path);

    switch -- $type {
	-option {
	    upvar 0 ${class}::$path:opt pathopt;

	    if { ![info exists pathopt($name)] } {
		error "unable to find variable for option \"$name\"";
	    }

	    return ::Widget::${class}::${path}:opt(${name});
	}
	-variable {
	    set ns $::BWidget::use(${class},namespace);
	    return ${ns}::${path}:${name};
	}
    }
}


# Widget::varForOption --
#
#	Retrieve a fully qualified variable name for the option specified.
#	If the option is not one for which a variable exists, throw an error 
#	(ie, those options that map directly to widget options) Superseded by
#       widget::which.
#
# Arguments:
#	path	megawidget to get an option var for.
#	option	option to get a var for.
#
# Results:
#	varname	name of the variable, fully qualified, suitable for tracing.

proc Widget::varForOption {path option} {
    return [::Widget::which $path -option $option];
}

# Widget::getVariable --
#
#       Get a variable from within the namespace of the widget.
#
# Arguments:
#	path		Megawidget to get the variable for.
#	varName		The variable name to retrieve.
#       newVarName	The variable name to refer to in the calling proc.
#
# Results:
#	Creates a reference to newVarName in the calling proc.
proc Widget::getVariable { path varName {newVarName ""} } {
    variable _class
    set class $_class($path)
    set ns $::BWidget::use(${class},namespace);
    if {![string length $newVarName]} { set newVarName $varName }
    uplevel 1 [list ::upvar \#0 ${ns}::${path}:${varName} $newVarName]
}

# Widget::options --
#
#       Return a key-value list of options for a widget.  This can
#       be used to serialize the options of a widget and pass them
#       on to a new widget with the same options.
#
# Arguments:
#	path		Widget to get the options for.
#	args		A list of options.  If empty, all options are returned.
#
# Results:
#	Returns list of options as: -option value -option value ...
proc Widget::options { path args } {
    if {[llength $args]} {
        foreach option $args {
            lappend options [_get_configure $path $option]
        }
    } else {
        set options [_get_configure $path {}]
    }

    set result [list]
    foreach list $options {
        if {[llength $list] < 5} { continue }
        lappend result [lindex $list 0] [lindex $list end]
    }
    return $result
}


# Widget::getOption --
#
#	Given a list of widgets, determine which option value to use.
#	The widgets are given to the command in order of highest to
#	lowest.  Starting with the lowest widget, whichever one does
#	not match the default option value is returned as the value.
#	If all the widgets are default, we return the highest widget's
#	value.
#
# Arguments:
#	option		The option to check.
#	default		The default value.  If any widget in the list
#			does not match this default, its value is used.
#	args		A list of widgets.
#
# Results:
#	Returns the value of the given option to use.
#
proc Widget::getOption { option default args } {
    for {set i [expr [llength $args] -1]} {$i >= 0} {incr i -1} {
	set widget [lindex $args $i]
	set value  [Widget::cget $widget $option]
	if {[string equal $value $default]} { continue }
	return $value
    }
    return $value
}


proc Widget::nextIndex { path node } {
    Widget::getVariable $path autoIndex
    if {![info exists autoIndex]} { set autoIndex -1 }
    return [string map [list #auto [incr autoIndex]] $node]
}


proc Widget::exists { path } {
    variable _class
    return [info exists _class($path)]
}

proc Widget::theme {{bool {}}} {
    # Private, *experimental* API that may change at any time - JH
    variable _theme
    if {[llength [info level 0]] == 2} {
	# set theme-ability
	if {[catch {package require Tk 8.5a6}]
	    && [catch {package require tile 0.6}]
	    && [catch {package require tile 1}]} {
	    return -code error "BWidget's theming requires tile 0.6+"
	} else {
	    catch {style default BWSlim.Toolbutton -padding 0}
	}
	set _theme [string is true -strict $bool]
    }
    return $_theme
}
