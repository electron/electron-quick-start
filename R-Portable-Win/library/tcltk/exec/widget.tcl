## Barebones requirements for creating and querying megawidgets
##
## Copyright 1997-8 Jeffrey Hobbs, jeff.hobbs@acm.org
##
## Initiated: 5 June 1997
## Last Update: 1998

package require Tk 8
package require ::Utility
package provide Widget 2.0

##------------------------------------------------------------------------
## PROCEDURE
##	widget
##
## DESCRIPTION
##	Implements and modifies megawidgets
##
## ARGUMENTS
##	widget <subcommand> ?<args>?
##
## <classname> specifies a global array which is the name of a class and
## contains options database information.
##
## add classname option ?args?
##	adds ...
##
## create classname
##	creates the widget class $classname based on the specifications
##	in the global array of the same name
##
## classes ?pattern?
##	returns the classes created with this command.
##
## delete classname option ?args?
##	deletes ...
##
## value classname key
##	returns the value of a key from the special class variable.
##
## OPTIONS
##	none
##
## RETURNS
##	the namespace for the widget class (::Widget::$CLASS)
##
## NAMESPACE & STATE
##	The namespace Widget is used, with public procedure "widget".
##
##------------------------------------------------------------------------
##
## For a well-commented example for creating a megawidget using this method,
## see the ScrolledText example at the end of the file.
##
## SHORT LIST OF IMPORTANT THINGS TO KNOW:
##
## Specify the "type", "base", & "components" keys of the $CLASS global array
##
## In the $w global array that is created for each instance of a megawidget,
## the following keys are set by the "widget create $CLASS" procedure:
##   "base", "basecmd", "container", "class", any option specified in the
##   $CLASS array, each component will have a named key
##
## The following public methods are created for you in the namespace:
##   cget	::Widget::$CLASS::_cget
##   configure	::Widget::$CLASS::_configure
##   destruct	::Widget::$CLASS::_destruct
##   subwidget	::Widget::$CLASS::_subwidget
## The following additional submethods are required (you write them):
##   construct	::Widget::$CLASS::construct
##   configure	::Widget::$CLASS::configure
## You may want the following that will be called when appropriate:
##   init	::Widget::$CLASS::init
##	(after initial configuration)
##   destruct	::Widget::$CLASS::destruct
##	(called first thing when widget is being destroyed)
##
## All ::Widget::$CLASS::_* commands are considered public methods.  The
## megawidget routine will match your options and methods on a unique
## substring basis.
##
## END OF SHORT LIST


## Dummy call for indexers
proc widget args {}

namespace eval ::Widget {;

namespace export -clear widget
variable CLASSES
variable CONTAINERS {frame toplevel}
namespace import -force ::Utility::get_opts*

;proc widget {cmd args} {
    ## Establish the prefix of public commands
    set prefix [namespace current]::_
    if {[string match {} [set arg [info commands $prefix$cmd]]]} {
	set arg [info commands $prefix$cmd*]
    }
    switch [llength $arg] {
	1 { return [uplevel $arg $args] }
	0 {
	    set arg [info commands $prefix*]
	    regsub -all $prefix $arg {} arg
	    return -code error "unknown [lindex [info level 0] 0] method\
		    \"$cmd\", must be one of: [join [lsort $arg] {, }]"
	}
	default {
	    regsub -all $prefix $arg {} arg
	    return -code error "ambiguous method \"$cmd\",\
		    could be one of: [join [lsort $arg] {, }]"
	}
    }
}

;proc verify_class {CLASS} {
    variable CLASSES
    if {![info exists CLASSES($CLASS)]} {
	return -code error "no known class \"$CLASS\""
    }
    return
}

;proc _add {CLASS what args} {
    variable CLASSES
    verify_class $CLASS
    if {[string match ${what}* options]} {
	add_options $CLASSES($CLASS) $CLASS $args
    } else {
	return -code error "unknown type for add, must be one of:\
		options, components"
    }
}

;proc _find_class {CLASS {root .}} {
    if {[string match $CLASS [winfo class $root]]} {
	return $root
    } else {
	foreach w [winfo children $root] {
	    set w [_find_class $CLASS $w]
	    if {[string compare {} $w]} {
		return $w
	    }
	}
    }
}

;proc _delete {CLASS what args} {
    variable CLASSES
    verify_class $CLASS
}

;proc _classes {{pattern "*"}} {
    variable CLASSES
    return [array names CLASSES $pattern]
}

;proc _value {CLASS key} {
    variable CLASSES
    verify_class $CLASS
    upvar \#0 $CLASSES($CLASS)::class class
    if {[info exists class($key)]} {
	return $class($key)
    } else {
	return -code error "unknown key \"$key\" in class \"$CLASS\""
    }
}

## handle
## Handles the method calls for a widget.  This is the command to which
## all megawidget dummy commands are redirected for interpretation.
##
;proc handle {namesp w subcmd args} {
    upvar \#0 ${namesp}::$w data
    if {[string match {} [set arg [info commands ${namesp}::_$subcmd]]]} {
	set arg [info commands ${namesp}::_$subcmd*]
    }
    set num [llength $arg]
    if {$num==1} {
	return [uplevel $arg [list $w] $args]
    } elseif {$num} {
	regsub -all "${namesp}::_" $arg {} arg
	return -code error "ambiguous method \"$subcmd\",\
		could be one of: [join $arg {, }]"
    } elseif {[catch {uplevel [list $data(basecmd) $subcmd] $args} err]} {
	return -code error $err
    } else {
	return $err
    }
}

## construct
## Constructs the megawidget instance instantiation proc based on the
## current knowledge of the megawidget. 
##
;proc construct {namesp CLASS} {
    upvar \#0 ${namesp}::class class \
	    ${namesp}::components components

    lappend dataArrayVals [list class $CLASS]
    if {[string compare $class(type) $class(base)]} {
	## If -type and -base don't match, we need a special setup
	lappend dataArrayVals "base \$w.[list [lindex $components(base) 1]]" \
		"basecmd ${namesp}::\$w.[list [lindex $components(base) 1]]" \
		"container ${namesp}::.\$w"
	## If the base widget is not the container, then we want to rename
	## its widget commands and add the CLASS and container bind tables
	## to its bindtags in case certain bindings are made
	## Interp alias is the optimal solution, but exposes
	## a bug in Tcl7/8 when renaming aliases
	#interp alias {} \$base {} ::Widget::handle $namesp \$w
	set renamingCmd "rename \$base \$data(basecmd)
	;proc ::\$base args \"uplevel ::Widget::handle $namesp \[list \$w\] \\\$args\"
	bindtags \$base \[linsert \[bindtags \$base\] 1\
		[expr {[string match toplevel $class(type)]?{}:{$w}}] $CLASS\]"
    } else {
	## -type and -base are the same, we only create for one
	lappend dataArrayVals "base \$w" \
		"basecmd ${namesp}::\$w" \
		"container ${namesp}::\$w"
	if {[string compare {} [lindex $components(base) 3]]} {
	    lappend dataArrayVals "[lindex $components(base) 3] \$w"
	}
	## When the base widget and container are the same, we have a
	## straightforward renaming of commands
	set renamingCmd {}
    }
    set baseConstruction {}
    foreach name [array names components] {	
	if {[string match base $name]} {
	    continue
	}
	foreach {type wid opts} $components($name) break
	lappend dataArrayVals "[list $name] \$w.[list $wid]"
	lappend baseConstruction "$type \$w.[list $wid] $opts"
	if {[string match toplevel $type]} {
	    lappend baseConstruction "wm withdraw \$data($name)"
	}
    }
    set dataArrayVals [join $dataArrayVals " \\\n\t"]
    ## the lsort ensure that parents are created before children
    set baseConstruction [join [lsort -index 1 $baseConstruction] "\n    "]

    ## More of this proc could be configured ahead of time for increased
    ## construction speed.  It's delicate, so handle with extreme care.
    ;proc ${namesp}::$CLASS {w args} [subst {
	variable options
	upvar \#0 ${namesp}::\$w data
	$class(type) \$w -class $CLASS
	[expr [string match toplevel $class(type)]?{wm withdraw \$w\n}:{}]
	## Populate data array with user definable options
	foreach o \[array names options\] {
	    if {\[string match -* \$options(\$o)\]} continue
	    set data(\$o) \[option get \$w \[lindex \$options(\$o) 0\] $CLASS\]
	}

	## Populate the data array
	array set data \[list $dataArrayVals\]
	## Create all the base and component widgets
	$baseConstruction

	## Allow for an initialization proc to be eval'ed
	## The user must create one
	if {\[catch {construct \$w} err\]} {
	    catch {_destruct \$w}
	    return -code error \"megawidget construction error: \$err\"
	}

	set base \$data(base)
	rename \$w \$data(container)
	$renamingCmd
	;proc ::\$w args \"uplevel ::Widget::handle $namesp \[list \$w\] \\\$args\"
	#interp alias {} \$w {} ::Widget::handle $namesp \$w

	## Do the configuring here and eval the post initialization procedure
	if {(\[string compare {} \$args\] && \
		\[catch {uplevel 1 ${namesp}::_configure \$w \$args} err\]) || \
		\[catch {${namesp}::init \$w} err\]} {
	    catch { ${namesp}::_destruct \$w }
	    return -code error \"megawidget initialization error: \$err\"
	}

	return \$w
    }
    ]
}

;proc add_options {namesp CLASS optlist} {
    upvar \#0 ${namesp}::class class \
	    ${namesp}::options options \
	    ${namesp}::widgets widgets
    ## Go through the option definition, substituting for ALIAS where
    ## necessary and setting up the options database for this $CLASS
    ## There are several possible formats:
    ## 1. -optname -optnamealias
    ## 2. -optname dbname dbcname value
    ## 3. -optname ALIAS componenttype option
    ## 4. -optname ALIAS componenttype option dbname dbcname
    foreach optdef $optlist {
	foreach {optname alias type opt dbname dbcname} $optdef break
	set len [llength $optdef]
	switch -glob -- $alias {
	    -*	{
		if {$len != 2} {
		    return -code error "wrong \# args for option alias,\
			    must be: {-aliasoptioname -realoptionname}"
		}
		set options($optname) $alias
		continue
	    }
	    ALIAS - alias {
		if {$len != 4 && $len != 6} {
		    return -code error "wrong \# args for ALIAS, must be:\
			    {-optionname ALIAS componenttype option\
			    ?databasename databaseclass?}"
		}
		if {![info exists widgets($type)]} {
		    return -code error "cannot create alias \"$optname\" to\
			    $CLASS component type \"$type\" option \"$opt\":\
			    component type does not exist"
		} elseif {![info exists config($type)]} {
		    if {[string compare toplevel $type]} {
			set w .__widget__$type
			catch {destroy $w}
			## Make sure the component widget type exists,
			## returns the widget name,
			## and accepts configure as a subcommand
			if {[catch {$type $w} result] || \
				[string compare $result $w] || \
				[catch {$w configure} config($type)]} {
			    ## Make sure we destroy it if it was a bad widget
			    catch {destroy $w}
			    ## Or rename it if it was a non-widget command
			    catch {rename $w {}}
			    return -code error "invalid widget type \"$type\""
			}
			catch {destroy $w}
		    } else {
			set config($type) [. configure]
		    }
		}
		set i [lsearch -glob $config($type) "$opt\[ \t\]*"]
		if {$i == -1} {
		    return -code error "cannot create alias \"$o\" to $CLASS\
			    component type \"$type\" option \"$opt\":\
			    option does not exist"
		}
		if {$len==4} {
		    foreach {opt dbname dbcname def} \
			    [lindex $config($type) $i] break
		} elseif {$len==6} {
		    set def [lindex [lindex $config($type) $i] 3]
		}
	    }
	    default {
		if {$len != 4} {
		    return -code error "wrong \# args for option \"$optdef\",\
			    must be:\
			    {-optioname databasename databaseclass defaultval}"
		}
		foreach {optname dbname dbcname def} $optdef break
	    }
	}
	set options($optname) [list $dbname $dbcname $def]
	option add *$CLASS.$dbname $def widgetDefault
    }
}

;proc _create {CLASS args} {
    if {![string match {[A-Z]*} $CLASS] || [string match { } $CLASS]} {
	return -code error "invalid class name \"$CLASS\": it must begin\
		with a capital letter and contain no spaces"
    }

    variable CONTAINERS
    variable CLASSES
    set namesp [namespace current]::$CLASS
    namespace eval $namesp {
	variable class
	variable options
	variable components
	variable widgets
	catch {unset class}
	catch {unset options}
	catch {unset components}
	catch {unset widgets}
    }
    upvar \#0 ${namesp}::class class \
	    ${namesp}::options options \
	    ${namesp}::components components \
	    ${namesp}::widgets widgets

    get_opts2 classopts $args {
	-type		frame
	-base		frame
	-components	{}
	-options	{}
    } {
	-type		list
	-base		list
	-components	list
	-options	list
    }

    ## First check to see that their container type is valid
    ## I'd like to include canvas and text, but they don't accept the
    ## -class option yet, which would thus require some voodoo on the
    ## part of the constructor to make it think it was the proper class
    if {![regexp ^([join $CONTAINERS |])\$ $classopts(-type)]} {
	return -code error "invalid class container type\
		\"$classopts(-type)\", must be one of:\
		[join $CONTAINERS {, }]"
    }

    ## Then check to see that their base widget type is valid
    ## We will create a default widget of the appropriate type just in
    ## case they use the DEFAULT keyword as a default value in their
    ## megawidget class definition
    if {[info exists classopts(-base)]} {
	## We check to see that we can create the base, that it returns
	## the same widget value we put in, and that it accepts cget.
	if {[string match toplevel $classopts(-base)] && \
		[string compare toplevel $classopts(-type)]} {
	    return -code error "\"toplevel\" is not allowed as the base\
		    widget of a megawidget (perhaps you intended it to\
		    be the class type)"
	}
    } else {
	## The container is the default base widget
	set classopts(-base) $classopts(-type)
    }

    ## Ensure that the class is set correctly
    array set class [list class $CLASS \
	    base $classopts(-base) \
	    type $classopts(-type)]

    set widgets($class(type)) 0

    if {![info exists classopts(-components)]} {
	set classopts(-components) {}
    }
    foreach compdef $classopts(-components) {
	set opts {}
	switch [llength $compdef] {
	    0 continue
	    1 { set name [set type [set wid $compdef]] }
	    2 {
		set type [lindex $compdef 0]
		set name [set wid [lindex $compdef 1]]
	    }
	    default {
		foreach {type name wid opts} $compdef break
		set opts [string trim $opts]
	    }
	}
	if {[info exists components($name)]} {
	    return -code error "component name \"$name\" occurs twice\
		    in $CLASS class"
	}
	if {[info exists widnames($wid)]} {
	    return -code error "widget name \"$wid\" occurs twice\
		    in $CLASS class"
	}
	if {[regexp {(^[\.A-Z]| |\.$)} $wid]} {
	    return -code error "invalid $CLASS class component widget\
		    name \"$wid\": it cannot begin with a capital letter,\
		    contain spaces or start or end with a \".\""
	}
	if {[string match *.* $wid] && \
		![info exists widnames([file root $wid])]} {
	    ## If the widget name contains a '.', then make sure we will
	    ## have created all the parents first.  [file root $wid] is
	    ## a cheap trick to remove the last .child string from $wid
	    return -code error "no specified parent for $CLASS class\
		    component widget name \"$wid\""
	}
	if {[string match base $type]} {
	    set type $class(base)
	    set components(base) [list $type $wid $opts $name]
	    if {[string match $type $class(type)]} continue
	}
	set components($name) [list $type $wid $opts]
	set widnames($wid) 0
	set widgets($type) 0
    }
    if {![info exists components(base)]} {
	set components(base) [list $class(base) $class(base) {}]
	# What should we really do here?
	#set components($class(base)) $components(base)
	set widgets($class(base)) 0
	if {![regexp ^([join $CONTAINERS |])\$ $class(base)] && \
		![info exists components($class(base))]} {
	    set components($class(base)) $components(base)
	}
    }

    ## Process options
    add_options $namesp $CLASS $classopts(-options)

    namespace eval $namesp {
	set CLASS [namespace tail [namespace current]]
	## The _destruct must occur to remove excess state elements.
	## The [winfo class %W] will work in this Destroy, which is necessary
	## to determine if we are destroying the actual megawidget container.
	bind $CLASS <Destroy> [namespace code {
	    if {[string compare {} [::widget classes [::winfo class %W]]]} {
		if [catch {_destruct %W} err] { puts $err }
	    }
	}]
    }
    ## This creates the basic constructor procedure for the class
    ## as ${namesp}::$CLASS
    construct $namesp $CLASS

    ## Both $CLASS and [string tolower $CLASS] commands will be created
    ## in the global namespace
    namespace eval $namesp [list namespace export -clear $CLASS]
    namespace eval :: [list namespace import -force ${namesp}::$CLASS]
    interp alias {} ::[string tolower $CLASS] {} ::$CLASS

    ## These are provided so that errors due to lack of the command
    ## existing don't arise.  Since they are stubbed out here, the
    ## user can't depend on 'unknown' or 'auto_load' to get this proc.
    if {[string match {} [info commands ${namesp}::construct]]} {
	;proc ${namesp}::construct {w} {
	    # the user should rewrite this
	    # without the following error, a simple megawidget that was just
	    # a frame would be created by default
	    return -code error "user must write their own\
		    [lindex [info level 0] 0] function"
	}
    }
    if {[string match {} [info commands ${namesp}::init]]} {
	;proc ${namesp}::init {w} {
	    # the user should rewrite this
	}
    }

    ## The user is not supposed to change this proc
    set comps [lsort [array names components]]
    ;proc ${namesp}::_subwidget {w {widget return} args} [subst {
	variable \$w
	upvar 0 \$w data
	switch -- \$widget {
	    return	{
		return [list $comps]
	    }
	    all {
		if {\[string compare {} \$args\]} {
		    foreach sub [list $comps] {
			catch {uplevel 1 \[list \$data(\$sub)\] \$args}
		    }
		} else {
		    return [list $comps]
		}
	    }
	    [join $comps { - }] {
		if {\[string compare {} \$args\]} {
		    return \[uplevel 1 \[list \$data(\$widget)\] \$args\]
		} else {
		    return \$data(\$widget)
		}
	    }
	    default {
		return -code error \"No \$data(class) subwidget \\\"\$widget\\\",\
			must be one of: [join $comps {, }]\"
	    }
	}
    }]

    ## The user is not supposed to change this proc
    ## Instead they create a ::Widget::$CLASS::destruct proc
    ## Some of this may be redundant, but at least it does the job
    ;proc ${namesp}::_destruct {w} "
    upvar \#0 ${namesp}::\$w data
    catch {${namesp}::destruct \$w}
    catch {::destroy \$data(base)}
    catch {::destroy \$w}
    catch {rename \$data(basecmd) {}}
    catch {rename ::\$data(base) {}}
    catch {rename ::\$w {}}
    catch {unset data}
    return\n"
    
    if {[string match {} [info commands ${namesp}::destruct]]} {
	## The user can optionally provide a special destroy handler
	;proc ${namesp}::destruct {w args} {
	    # empty
	}
    }

    ## The user is not supposed to change this proc
    ;proc ${namesp}::_cget {w args} {
	if {[llength $args] != 1} {
	    return -code error "wrong \# args: should be \"$w cget option\""
	}
	set namesp [namespace current]
	upvar \#0 ${namesp}::$w data ${namesp}::options options
	if {[info exists options($args)]&&[string match -* $options($args)]} {
	    set args $options($args)
	}
	if {[string match {} [set arg [array names data $args]]]} {
	    set arg [array names data ${args}*]
	}
	set num [llength $arg]
	if {$num==1} {
	    return $data($arg)
	} elseif {$num} {
	    return -code error "ambiguous option \"$args\",\
		    must be one of: [join $arg {, }]"
	} elseif {[catch {$data(basecmd) cget $args} err]} {
	    return -code error $err
	} else {
	    return $err
	}
    }

    ## The user is not supposed to change this proc
    ## Instead they create a $CLASS:configure proc
    ;proc ${namesp}::_configure {w args} {
	set namesp [namespace current]
	upvar \#0 ${namesp}::$w data ${namesp}::options options

	set num [llength $args]
	if {$num==1} {
	    if {[info exists options($args)] && \
		    [string match -* $options($args)]} {
		set args $options($args)
	    }
	    if {[string match {} [set arg [array names data $args]]]} {
		set arg [array names data ${args}*]
	    }
	    set num [llength $arg]
	    if {$num==1} {
		## FIX one-elem config
		return "[list $arg] $options($arg) [list $data($arg)]"
	    } elseif {$num} {
		return -code error "ambiguous option \"$args\",\
			must be one of: [join $arg {, }]"
	    } elseif {[catch {$data(basecmd) configure $args} err]} {
		return -code error $err
	    } else {
		return $err
	    }
	} elseif {$num} {
	    ## Group the {key val} pairs to be distributed
	    if {$num&1} {
		set last [lindex $args end]
		set args [lrange $args 0 [incr num -2]]
	    }
	    set widargs {}
	    set cmdargs {}
	    foreach {key val} $args {
		if {[info exists options($key)] && \
			[string match -* $options($key)]} {
		    set key $options($key)
		}
		if {[string match {} [set arg [array names data $key]]]} {
		    set arg [array names data $key*]
		}
		set len [llength $arg]
		if {$len==1} {
		    lappend widargs $arg $val
		} elseif {$len} {
		    set ambarg [list $key $arg]
		    break
		} else {
		    lappend cmdargs $key $val
		}
	    }
	    if {[string compare {} $widargs]} {
		uplevel ${namesp}::configure [list $w] $widargs
	    }
	    if {[string compare {} $cmdargs] && [catch \
		    {uplevel [list $data(basecmd)] configure $cmdargs} err]} {
		return -code error $err
	    }
	    if {[info exists ambarg]} {
		return -code error "ambiguous option \"[lindex $ambarg 0]\",\
			must be one of: [join [lindex $ambarg 1] {, }]"
	    }
	    if {[info exists last]} {
		return -code error "value for \"$last\" missing"
	    }
	} else {
	    foreach opt [$data(basecmd) configure] {
		set opts([lindex $opt 0]) [lrange $opt 1 end]
	    }
	    foreach opt [array names options] {
		if {[string match -* $options($opt)]} {
		    set opts($opt) [string range $options($opt) 1 end]
		} else {
		    set opts($opt) "$options($opt) [list $data($opt)]"
		}
	    }
	    foreach opt [lsort [array names opts]] {
		lappend config "$opt $opts($opt)"
	    }
	    return $config
	}
    }

    if {[string match {} [info commands ${namesp}::configure]]} {
	## The user is intended to rewrite this one
	;proc ${namesp}::configure {w args}  {
	    foreach {key val} $args {
		puts "$w: configure $key to [list $value]"
	    }
	}
    }

    set CLASSES($CLASS) $namesp
    return $namesp
}

}; #end namespace ::Widget

namespace eval :: { namespace import -force ::Widget::widget }

########################################################################
########################## EXAMPLES ####################################
########################################################################

########################################################################
########################## ScrolledText ################################
########################################################################

##------------------------------------------------------------------------
## PROCEDURE
##	scrolledtext
##
## DESCRIPTION
##	Implements a ScrolledText mega-widget
##
## ARGUMENTS
##	scrolledtext <window pathname> <options>
##
## OPTIONS
##	(Any text widget option may be used in addition to these)
##
## -autoscrollbar TCL_BOOLEAN			DEFAULT: 1
##	Whether to have dynamic or static scrollbars.
##
## RETURNS: the window pathname
##
## METHODS/SUBCOMMANDS
##	These are the subcmds that an instance of this megawidget recognizes.
##	Aside from those listed here, it accepts subcmds that are valid for
##	text widgets.
##
## subwidget widget
##	Returns the true widget path of the specified widget.  Valid
##	widgets are text, xscrollbar, yscrollbar.
##
## BINDINGS (in addition to default widget bindings)
##
## NAMESPACE & STATE
##	The megawidget creates a global array with the classname, and a
## global array which is the name of each megawidget is created.  The latter
## array is deleted when the megawidget is destroyed.
##	Public procs of $CLASSNAME and [string tolower $CLASSNAME] are used.
## Other procs that begin with $CLASSNAME are private.  For each widget,
## commands named .$widgetname and $CLASSNAME$widgetname are created.
##
## EXAMPLE USAGE:
##
## pack [scrolledtext .st -width 40 -height 10] -fill both -exp 1
##
##------------------------------------------------------------------------

## Each widget created will also have a global array created by the
## instantiation procedure that is the name of the widget (represented
## as $w below).  There three special key names in the $CLASS array:
##
## -type
##    the type of base container we want to use (frame or toplevel).
##    This would default to frame.  This widget will be created for us
##    by the constructor function.  The $w array will have a "container"
##    key that will point to the exact widget name.
##
## -base
##   the base widget type for this class.  This key is optional and
##   represents what kind of widget will be the base for the class. This
##   way we know what default methods/options you'll have.  If not
##   specified, it defaults to the container type.  
##   To the global $w array, the key "basecmd" will be added by the widget
##   instantiation function to point to a new proc that will be the direct
##   accessor command for the base widget ("text" in the case of the
##   ScrolledText megawidget).  The $w "base" key will be the valid widget
##   name (for passing to [winfo] and such), but "basecmd" will be the
##   valid direct accessor function
##
## -components
##   the component widgets of the megawidget.  This is a list of tuples
##   (ie: {{listbox listbox} {scrollbar yscrollbar} {scrollbar xscrollbar}})
##   where each item is in the form {widgettype name}.  These components
##   will be created before the $CLASS::construct proc is called and the $w
##   array will have keys with each name pointing to the appropriate
##   widget in it.  Use these keys to access your subwidgets.  It is from
##   this component list and the base and type about that the subwidget
##   method is created.
##  
## -options
##   A list of lists, this specifies the
##   options that this megawidget handles.  The value can either be a
##   3-tuple list of the form {databaseName databaseClass defaultValue}, or
##   it can be one element matching -*, which means this key (say -bd) is
##   an alias for the option specified in the value (say -borderwidth)
##   which must be specified fully somewhere else in the class array.
##
## If the value is a list beginning with "ALIAS", then the option is derived
## from a component of the megawidget.  The form of the value must be a list
## with the elements:
##	{ALIAS componenttype option ?databasename databaseclass?}
## An example of this would be inheriting a label components anchor:
##	{ALIAS label -anchor labelAnchor Anchor}
## If the databasename is not specified, it determines the final options
## database info from the component and uses the components default value.
## Otherwise, just the components default value is used.
##
## The $w array will be populated by the instantiation procedure with the
## default values for all the specified $CLASS options.
##

# Create this to make sure there are registered in auto_mkindex
# these must come before the [widget create ...]
proc ScrolledText args {}
proc scrolledtext args {}
widget create ScrolledText -type frame -base text -components {
    {base text text {-xscrollcommand [list $data(xscrollbar) set] \
	    -yscrollcommand [list $data(yscrollbar) set]}}
    {scrollbar xscrollbar sx {-orient h -bd 1 -highlightthickness 1 \
	    -command [list $w xview]}}
    {scrollbar yscrollbar sy {-orient v -bd 1 -highlightthickness 1 \
	    -command [list $w yview]}}
} -options {
    {-autoscrollbar autoScrollbar AutoScrollbar 1}
}

## Then we "create" the widget.  This makes all the necessary default widget
## routines.  It creates the public accessor functions ($CLASSNAME and
## [string tolower $CLASSNAME]) as well as the public cget, configure, destroy
## and subwidget methods.  The cget and configure commands work like the
## regular Tk ones.  The destroy method is superfluous, as megawidgets will
## respond properly to [destroy $widget] (the Tk destroy command).
## The subwidget method has the following form:
##
##   $widget subwidget name
##	name	- the component widget name
##   Returns the widget patch to the component widget name.
##   Allows the user direct access to your subwidgets.
##
## THE USER SHOULD PROVIDE AT LEAST THE FOLLOWING:
##
## $NAMESPACE::construct {w}		=> return value ignored
##	w	- the widget name, also the name of the global data array
## This procedure is called by the public accessor (instantiation) proc
## right after creating all component widgets and populating the global $w
## array with all the default option values, the "base" key and the key
## names for any other components.  The user should then grid/pack all
## subwidgets into $w.  At this point, the initial configure has not
## occured, so the widget options are all the default.  If this proc
## errors, so does the main creation routine, returning your error.
##
## $NAMESPACE::configure {w args}	=> return ignored (should be empty)
##	w	- the widget name, also the name of the global data array
##	args	- a list of key/vals (already verified to exist)
## The user should process the key/vals however they require  If this
## proc errors, so does the main creation routine, returning your error.
##
## THE FOLLOWING IS OPTIONAL:
##
## $NAMESPACE::init {w}			=> return value ignored
##	w	- the widget name, also the name of the global data array
## This procedure is called after the public configure routine and after
## the "basecmd" key has been added to the $w array.  Ideally, this proc
## would be used to do any widget specific one-time initialization.
##
## $NAMESPACE::destruct {w}		=> return ignored (should be empty)
##	w	- the widget name, also the name of the global data array
## A default destroy handler is provided that cleans up after the megawidget
## (all state info), but if special cleanup stuff is needed, you would provide
## it in this procedure.  This is the first proc called in the default destroy
## handler.
##

namespace eval ::Widget::ScrolledText {;

;proc construct {w} {
    upvar \#0 [namespace current]::$w data

    grid $data(text) $data(yscrollbar) -sticky news
    grid $data(xscrollbar) -sticky ew
    grid columnconfig $w 0 -weight 1
    grid rowconfig $w 0 -weight 1
    grid remove $data(yscrollbar) $data(xscrollbar)
    bind $data(text) <Configure> [namespace code [list resize $w 1]]
}

;proc configure {w args} {
    upvar \#0 [namespace current]::$w data
    set truth {^(1|yes|true|on)$}
    foreach {key val} $args {
	switch -- $key {
	    -autoscrollbar	{
		set data($key) [regexp -nocase $truth $val]
		if {$data($key)} {
		    resize $w 0
		} else {
		    grid $data(xscrollbar)
		    grid $data(yscrollbar)
		}
	    }
	}
    }
}

# captures xview commands to the text widget
;proc _xview {w args} {
    upvar \#0 [namespace current]::$w data
    if {[catch {uplevel $data(basecmd) xview $args} err]} {
	return -code error $err
    }
}

# captures yview commands to the text widget
;proc _yview {w args} {
    upvar \#0 [namespace current]::$w data
    if {[catch {uplevel $data(basecmd) yview $args} err]} {
	return -code error $err
    } elseif {![winfo ismapped $data(xscrollbar)] && \
	    [string compare {0 1} [$data(basecmd) xview]]} {
	## If the xscrollbar was unmapped, but is now needed, show it
	grid $data(xscrollbar)
    }
}

# captures insert commands to the text widget
;proc _insert {w args} {
    upvar \#0 [namespace current]::$w data
    set code [catch {uplevel $data(basecmd) insert $args} err]
    if {[winfo ismapped $w]} { resize $w 0 }
    return -code $code $err
}

# captures delete commands to the text widget
;proc _delete {w args} {
    upvar \#0 [namespace current]::$w data
    set code [catch {uplevel $data(basecmd) delete $args} err]
    if {[winfo ismapped $w]} { resize $w 1 }
    return -code $code $err
}

# called when the ScrolledText widget is resized by the user or possibly
# needs the scrollbars (de|at)tached due to insert/delete.
;proc resize {w d} {
    upvar \#0 [namespace current]::$w data
    ## Only when deleting should we consider removing the scrollbars
    if {!$data(-autoscrollbar)} return
    if {[string compare {0 1} [$data(basecmd) xview]]} {
	grid $data(xscrollbar)
    } elseif {$d} {
	grid remove $data(xscrollbar)
    }
    if {[string compare {0 1} [$data(basecmd) yview]]} {
	grid $data(yscrollbar)
    } elseif {$d} {
	grid remove $data(yscrollbar)
    }
}


}; #end namespace ::Widget::ScrolledText
