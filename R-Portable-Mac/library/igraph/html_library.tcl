# Simple HTML display library by Stephen Uhler (stephen.uhler@sun.com)
# Copyright (c) 1995 by Sun Microsystems
# Version 0.3 Fri Sep  1 10:47:17 PDT 1995
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# To use this package,  create a text widget (say, .text)
# and set a variable full of html, (say $html), and issue:
#	HMinit_win .text
#	HMparse_html $html "HMrender .text"
# You also need to supply the routine:
#   proc HMlink_callback {win href} { ...}
#      win:  The name of the text widget
#      href  The name of the link
# which will be called anytime the user "clicks" on a link.
# The supplied version just prints the link to stdout.
# In addition, if you wish to use embedded images, you will need to write
#   proc HMset_image {handle src}
#      handle  an arbitrary handle (not really)
#      src     The name of the image
# Which calls
#	HMgot_image $handle $image
# with the TK image.
#
# To return a "used" text widget to its initialized state, call:
#   HMreset_win .text
# See "sample.tcl" for sample usage
##################################################################
############################################
# mapping of html tags to text tag properties
# properties beginning with "T" map directly to text tags

# These are Defined in HTML 2.0

array set HMtag_map {
	b      {weight bold}
	blockquote	{style i indent 1 Trindent rindent}
	bq		{style i indent 1 Trindent rindent}
	cite   {style i}
	code   {family courier}
	dfn    {style i}	
	dir    {indent 1}
	dl     {indent 1}
	em     {style i}
	h1     {size 24 weight bold}
	h2     {size 22}		
	h3     {size 20}	
	h4     {size 18}
	h5     {size 16}
	h6     {style i}
	i      {style i}
	kbd    {family courier weight bold}
	menu     {indent 1}
	ol     {indent 1}
	pre    {fill 0 family courier Tnowrap nowrap}
	samp   {family courier}		
	strong {weight bold}		
	tt     {family courier}
	u	 {Tunderline underline}
	ul     {indent 1}
	var    {style i}	
}

# These are in common(?) use, but not defined in html2.0

array set HMtag_map {
	center {Tcenter center}
	strike {Tstrike strike}
	u	   {Tunderline underline}
}

# initial values

set HMtag_map(hmstart) {
	family times   weight medium   style r   size 14
	Tcenter ""   Tlink ""   Tnowrap ""   Tunderline ""   list list
	fill 1   indent "" counter 0 adjust 0
}

# html tags that insert white space

array set HMinsert_map {
	blockquote "\n\n" /blockquote "\n"
	br	"\n"
	dd	"\n" /dd	"\n"
	dl	"\n" /dl	"\n"
	dt	"\n"
	form "\n"	/form "\n"
	h1	"\n\n"	/h1	"\n"
	h2	"\n\n"	/h2	"\n"
	h3	"\n\n"	/h3	"\n"
	h4	"\n"	/h4	"\n"
	h5	"\n"	/h5	"\n"
	h6	"\n"	/h6	"\n"
	li   "\n"
	/dir "\n"
	/ul "\n"
	/ol "\n"
	/menu "\n"
	p	"\n\n"
	pre "\n"	/pre "\n"
}

# tags that are list elements, that support "compact" rendering

array set HMlist_elements {
	ol 1   ul 1   menu 1   dl 1   dir 1
}
############################################
# initialize the window and stack state

proc HMinit_win {win} {
	upvar #0 HM$win var
	
	HMinit_state $win
	$win tag configure underline -underline 1
	$win tag configure center -justify center
	$win tag configure nowrap -wrap none
	$win tag configure rindent -rmargin $var(S_tab)c
	$win tag configure strike -overstrike 1
	$win tag configure mark -foreground red		;# list markers
	$win tag configure list -spacing1 3p -spacing3 3p		;# regular lists
	$win tag configure compact -spacing1 0p		;# compact lists
	$win tag configure link -borderwidth 2 -foreground blue	;# hypertext links
	HMset_indent $win $var(S_tab)
	$win configure -wrap word

	# configure the text insertion point
	$win mark set $var(S_insert) 1.0

	# for horizontal rules
	$win tag configure thin -font [HMx_font times 2 medium r]
	$win tag configure hr -relief sunken -borderwidth 2 -wrap none \
		-tabs [winfo width $win]
	bind $win <Configure> {
		%W tag configure hr -tabs %w
		%W tag configure last -spacing3 %h
	}

	# generic link enter callback

	$win tag bind link <1> "HMlink_hit $win %x %y"
}

# set the indent spacing (in cm) for lists
# TK uses a "weird" tabbing model that causes \t to insert a single
# space if the current line position is past the tab setting

proc HMset_indent {win cm} {
	set tabs [expr $cm / 2.0]
	$win configure -tabs ${tabs}c
	foreach i {1 2 3 4 5 6 7 8 9} {
		set tab [expr $i * $cm]
		$win tag configure indent$i -lmargin1 ${tab}c -lmargin2 ${tab}c \
			-tabs "[expr $tab + $tabs]c [expr $tab + 2*$tabs]c"
	}
}

# reset the state of window - get ready for the next page
# remove all but the font tags, and remove all form state

proc HMreset_win {win} {
	upvar #0 HM$win var
	regsub -all { +[^L ][^ ]*} " [$win tag names] " {} tags
	catch "$win tag delete $tags"
	eval $win mark unset [$win mark names]
	$win delete 0.0 end
	$win tag configure hr -tabs [winfo width $win]

	# configure the text insertion point
	$win mark set $var(S_insert) 1.0

	# remove form state.  If any check/radio buttons still exists, 
	# their variables will be magically re-created, and never get
	# cleaned up.
	catch unset [info globals HM$win.form*]

	HMinit_state $win
	return HM$win
}

# initialize the window's state array
# Parameters beginning with S_ are NOT reset
#  adjust_size:		global font size adjuster
#  unknown:		character to use for unknown entities
#  tab:			tab stop (in cm)
#  stop:		enabled to stop processing
#  update:		how many tags between update calls
#  tags:		number of tags processed so far
#  symbols:		Symbols to use on un-ordered lists

proc HMinit_state {win} {
	upvar #0 HM$win var
	array set tmp [array get var S_*]
	catch {unset var}
	array set var {
		stop 0
		tags 0
		fill 0
		list list
		S_adjust_size 0
		S_tab 1.0
		S_unknown \xb7
		S_update 10
		S_symbols O*=+-o\xd7\xb0>:\xb7
		S_insert Insert
	}
	array set var [array get tmp]
}

# alter the parameters of the text state
# this allows an application to over-ride the default settings
# it is called as: HMset_state -param value -param value ...

array set HMparam_map {
	-update S_update
	-tab S_tab
	-unknown S_unknown
	-stop S_stop
	-size S_adjust_size
	-symbols S_symbols
    -insert S_insert
}

proc HMset_state {win args} {
	upvar #0 HM$win var
	global HMparam_map
	set bad 0
	if {[catch {array set params $args}]} {return 0}
	foreach i [array names params] {
		incr bad [catch {set var($HMparam_map($i)) $params($i)}]
	}
	return [expr $bad == 0]
}

############################################
# manage the display of html

# HMrender gets called for every html tag
#   win:   The name of the text widget to render into
#   tag:   The html tag (in arbitrary case)
#   not:   a "/" or the empty string
#   param: The un-interpreted parameter list
#   text:  The plain text until the next html tag

proc HMrender {win tag not param text} {
	upvar #0 HM$win var
	if {$var(stop)} return
	global HMtag_map HMinsert_map HMlist_elements
	set tag [string tolower $tag]
	set text [HMmap_esc $text]

	# manage compact rendering of lists
	if {[info exists HMlist_elements($tag)]} {
		set list "list [expr {[HMextract_param $param compact] ? "compact" : "list"}]"
	} else {
		set list ""
	}

	# Allow text to be diverted to a different window (for tables)
	# this is not currently used
	if {[info exists var(divert)]} {
		set win $var(divert)
		upvar #0 HM$win var
	}

	# adjust (push or pop) tag state
	catch {HMstack $win $not "$HMtag_map($tag) $list"}

	# insert white space (with current font)
	# adding white space can get a bit tricky.  This isn't quite right
	set bad [catch {$win insert $var(S_insert) $HMinsert_map($not$tag) "space $var(font)"}]
	if {!$bad && [lindex $var(fill) end]} {
		set text [string trimleft $text]
	}

	# to fill or not to fill
	if {[lindex $var(fill) end]} {
		set text [HMzap_white $text]
	}

	# generic mark hook
	catch {HMmark $not$tag $win $param text} err

	# do any special tag processing
	catch {HMtag_$not$tag $win $param text} msg


	# add the text with proper tags

	set tags [HMcurrent_tags $win]
	$win insert $var(S_insert) $text $tags

	# We need to do an update every so often to insure interactive response.
	# This can cause us to re-enter the event loop, and cause recursive
	# invocations of HMrender, so we need to be careful.
	if {!([incr var(tags)] % $var(S_update))} {
		update
	}
}

# html tags requiring special processing
# Procs of the form HMtag_<tag> or HMtag_</tag> get called just before
# the text for this tag is displayed.  These procs are called inside a 
# "catch" so it is OK to fail.
#   win:   The name of the text widget to render into
#   param: The un-interpreted parameter list
#   text:  A pass-by-reference name of the plain text until the next html tag
#          Tag commands may change this to affect what text will be inserted
#          next.

# A pair of pseudo tags are added automatically as the 1st and last html
# tags in the document.  The default is <HMstart> and </HMstart>.
# Append enough blank space at the end of the text widget while
# rendering so HMgoto can place the target near the top of the page,
# then remove the extra space when done rendering.

proc HMtag_hmstart {win param text} {
	upvar #0 HM$win var
	$win mark gravity $var(S_insert) left
	$win insert end "\n " last
	$win mark gravity $var(S_insert) right
}

proc HMtag_/hmstart {win param text} {
	$win delete last.first end
}

# put the document title in the window banner, and remove the title text
# from the document

proc HMtag_title {win param text} {
	upvar $text data
	wm title [winfo toplevel $win] $data
	set data ""
}

proc HMtag_hr {win param text} {
	upvar #0 HM$win var
	$win insert $var(S_insert) "\n" space "\n" thin "\t" "thin hr" "\n" thin
}

# list element tags

proc HMtag_ol {win param text} {
	upvar #0 HM$win var
	set var(count$var(level)) 0
}

proc HMtag_ul {win param text} {
	upvar #0 HM$win var
	catch {unset var(count$var(level))}
}

proc HMtag_menu {win param text} {
	upvar #0 HM$win var
	set var(menu) ->
	set var(compact) 1
}

proc HMtag_/menu {win param text} {
	upvar #0 HM$win var
	catch {unset var(menu)}
	catch {unset var(compact)}
}
	
proc HMtag_dt {win param text} {
	upvar #0 HM$win var
	upvar $text data
	set level $var(level)
	incr level -1
	$win insert $var(S_insert) "$data" \
		"hi [lindex $var(list) end] indent$level $var(font)"
	set data {}
}

proc HMtag_li {win param text} {
	upvar #0 HM$win var
	set level $var(level)
	incr level -1
	set x [string index $var(S_symbols)+-+-+-+-" $level]
	catch {set x [incr var(count$level)]}
	catch {set x $var(menu)}
	$win insert $var(S_insert) \t$x\t "mark [lindex $var(list) end] indent$level $var(font)"
}

# Manage hypertext "anchor" links.  A link can be either a source (href)
# a destination (name) or both.  If its a source, register it via a callback,
# and set its default behavior.  If its a destination, check to see if we need
# to go there now, as a result of a previous HMgoto request.  If so, schedule
# it to happen with the closing </a> tag, so we can highlight the text up to
# the </a>.

proc HMtag_a {win param text} {
	upvar #0 HM$win var

	# a source

	if {[HMextract_param $param href]} {
		set var(Tref) [list L:$href]
		HMstack $win "" "Tlink link"
		HMlink_setup $win $href
	}

	# a destination

	if {[HMextract_param $param name]} {
		set var(Tname) [list N:$name]
		HMstack $win "" "Tanchor anchor"
		$win mark set N:$name "$var(S_insert) - 1 chars"
		$win mark gravity N:$name left
		if {[info exists var(goto)] && $var(goto) == $name} {
			unset var(goto)
			set var(going) $name
		}
	}
}

# The application should call here with the fragment name
# to cause the display to go to this spot.
# If the target exists, go there (and do the callback),
# otherwise schedule the goto to happen when we see the reference.

proc HMgoto {win where {callback HMwent_to}} {
	upvar #0 HM$win var
	if {[regexp N:$where [$win mark names]]} {
		$win see N:$where
		update
		eval $callback $win [list $where]
		return 1
	} else {
		set var(goto) $where
		return 0
	}
}

# We actually got to the spot, so highlight it!
# This should/could be replaced by the application
# We'll flash it orange a couple of times.

proc HMwent_to {win where {count 0} {color orange}} {
	upvar #0 HM$win var
	if {$count > 5} return
	catch {$win tag configure N:$where -foreground $color}
	update
	after 200 [list HMwent_to $win $where [incr count] \
				[expr {$color=="orange" ? "" : "orange"}]]
}

proc HMtag_/a {win param text} {
	upvar #0 HM$win var
	if {[info exists var(Tref)]} {
		unset var(Tref)
		HMstack $win / "Tlink link"
	}

	# goto this link, then invoke the call-back.

	if {[info exists var(going)]} {
		$win yview N:$var(going)
		update
		HMwent_to $win $var(going)
		unset var(going)
	}

	if {[info exists var(Tname)]} {
		unset var(Tname)
		HMstack $win / "Tanchor anchor"
	}
}

#           Inline Images
# This interface is subject to change
# Most of the work is getting around a limitation of TK that prevents
# setting the size of a label to a widthxheight in pixels
#
# Images have the following parameters:
#    align:  top,middle,bottom
#    alt:    alternate text
#    ismap:  A clickable image map
#    src:    The URL link
# Netscape supports (and so do we)
#    width:  A width hint (in pixels)
#    height:  A height hint (in pixels)
#    border: The size of the window border

proc HMtag_img {win param text} {
	upvar #0 HM$win var

	# get alignment
	array set align_map {top top    middle center    bottom bottom}
	set align bottom		;# The spec isn't clear what the default should be
	HMextract_param $param align
	catch {set align $align_map([string tolower $align])}

	# get alternate text
	set alt "<image>"
	HMextract_param $param alt
	set alt [HMmap_esc $alt]

	# get the border width
	set border 1
	HMextract_param $param border

	# see if we have an image size hint
	# If so, make a frame the "hint" size to put the label in
	# otherwise just make the label
	set item $win.$var(tags)
	# catch {destroy $item}
	if {[HMextract_param $param width] && [HMextract_param $param height]} {
		frame $item -width $width -height $height
		pack propagate $item 0
		set label $item.label
		label $label
		pack $label -expand 1 -fill both
	} else {
		set label $item
		label $label 
	}

	$label configure -relief ridge -fg orange -text $alt
	catch {$label configure -bd $border}
	$win window create $var(S_insert) -align $align -window $item -pady 2 -padx 2

	# add in all the current tags (this is overkill)
	set tags [HMcurrent_tags $win]
	foreach tag $tags {
		$win tag add $tag $item
	}

	# set imagemap callbacks
	if {[HMextract_param $param ismap]} {
		# regsub -all {[^L]*L:([^ ]*).*}  $tags {\1} link
		set link [lindex $tags [lsearch -glob $tags L:*]]
		regsub L: $link {} link
		global HMevents
		regsub -all {%} $link {%%} link2
		foreach i [array names HMevents] {
			bind $label <$i> "catch \{%W configure $HMevents($i)\}"
		}
		bind $label <1> "+HMlink_callback $win $link2?%x,%y"
	} 

	# now callback to the application
	set src ""
	HMextract_param $param src
	HMset_image $win $label $src
	return $label	;# used by the forms package for input_image types
}

# The app needs to supply one of these
proc HMset_image {win handle src} {
	HMgot_image $handle "can't get\n$src"
}

# When the image is available, the application should call back here.
# If we have the image, put it in the label, otherwise display the error
# message.  If we don't get a callback, the "alt" text remains.
# if we have a clickable image, arrange for a callback

proc HMgot_image {win image_error} {
	# if we're in a frame turn on geometry propogation
	if {[winfo name $win] == "label"} {
		pack propagate [winfo parent $win] 1
	}
	if {[catch {$win configure -image $image_error}]} {
		$win configure -image {}
		$win configure -text $image_error
	}
}

# Sample hypertext link callback routine - should be replaced by app
# This proc is called once for each <A> tag.
# Applications can overwrite this procedure, as required, or
# replace the HMevents array
#   win:   The name of the text widget to render into
#   href:  The HREF link for this <a> tag.

array set HMevents {
	Enter	{-borderwidth 2 -relief raised }
	Leave	{-borderwidth 2 -relief flat }
	1		{-borderwidth 2 -relief sunken}
	ButtonRelease-1	{-borderwidth 2 -relief raised}
}

# We need to escape any %'s in the href tag name so the bind command
# doesn't try to substitute them.

proc HMlink_setup {win href} {
	global HMevents
	regsub -all {%} $href {%%} href2
	foreach i [array names HMevents] {
		eval {$win tag bind  L:$href <$i>} \
			\{$win tag configure \{L:$href2\} $HMevents($i)\}
	}
}

# generic link-hit callback
# This gets called upon button hits on hypertext links
# Applications are expected to supply ther own HMlink_callback routine
#   win:   The name of the text widget to render into
#   x,y:   The cursor position at the "click"

proc HMlink_hit {win x y} {
	set tags [$win tag names @$x,$y]
	set link [lindex $tags [lsearch -glob $tags L:*]]
	# regsub -all {[^L]*L:([^ ]*).*}  $tags {\1} link
	regsub L: $link {} link
	HMlink_callback $win $link
}

# replace this!
#   win:   The name of the text widget to render into
#   href:  The HREF link for this <a> tag.

proc HMlink_callback {win href} {
	puts "Got hit on $win, link $href"
}

# extract a value from parameter list (this needs a re-do)
# returns "1" if the keyword is found, "0" otherwise
#   param:  A parameter list.  It should alredy have been processed to
#           remove any entity references
#   key:    The parameter name
#   val:    The variable to put the value into (use key as default)

proc HMextract_param {param key {val ""}} {

	if {$val == ""} {
		upvar $key result
	} else {
		upvar $val result
	}
    set ws "    \n\r"
 
    # look for name=value combinations.  Either (') or (") are valid delimeters
    if {
      [regsub -nocase [format {.*%s[%s]*=[%s]*"([^"]*).*} $key $ws $ws] $param {\1} value] ||
      [regsub -nocase [format {.*%s[%s]*=[%s]*'([^']*).*} $key $ws $ws] $param {\1} value] ||
      [regsub -nocase [format {.*%s[%s]*=[%s]*([^%s]+).*} $key $ws $ws $ws] $param {\1} value] } {
        set result $value
        return 1
    }

	# now look for valueless names
	# I should strip out name=value pairs, so we don't end up with "name"
	# inside the "value" part of some other key word - some day
	
	set bad \[^a-zA-Z\]+
	if {[regexp -nocase  "$bad$key$bad" -$param-]} {
		return 1
	} else {
		return 0
	}
}

# These next two routines manage the display state of the page.

# Push or pop tags to/from stack.
# Each orthogonal text property has its own stack, stored as a list.
# The current (most recent) tag is the last item on the list.
# Push is {} for pushing and {/} for popping

proc HMstack {win push list} {
	upvar #0 HM$win var
	array set tags $list
	if {$push == ""} {
		foreach tag [array names tags] {
			lappend var($tag) $tags($tag)
		}
	} else {
		foreach tag [array names tags] {
			# set cnt [regsub { *[^ ]+$} $var($tag) {} var($tag)]
			set var($tag) [lreplace $var($tag) end end]
		}
	}
}

# extract set of current text tags
# tags starting with T map directly to text tags, all others are
# handled specially.  There is an application callback, HMset_font
# to allow the application to do font error handling

proc HMcurrent_tags {win} {
	upvar #0 HM$win var
	set font font
	foreach i {family size weight style} {
		set $i [lindex $var($i) end]
		append font :[set $i]
	}
	set xfont [HMx_font $family $size $weight $style $var(S_adjust_size)]
	HMset_font $win $font $xfont
	set indent [llength $var(indent)]
	incr indent -1
	lappend tags $font indent$indent
	foreach tag [array names var T*] {
		lappend tags [lindex $var($tag) end]	;# test
	}
	set var(font) $font
	set var(xfont) [$win tag cget $font -font]
	set var(level) $indent
	return $tags
}

# allow the application to do do better font management
# by overriding this procedure

proc HMset_font {win tag font} {
	catch {$win tag configure $tag -font $font} msg
}

# generate an X font name
proc HMx_font {family size weight style {adjust_size 0}} {
	catch {incr size $adjust_size}
	return "-*-$family-$weight-$style-normal-*-*-${size}0-*-*-*-*-*-*"
}

# Optimize HMrender (hee hee)
# This is experimental

proc HMoptimize {} {
	regsub -all "\n\[ 	\]*#\[^\n\]*" [info body HMrender] {} body
	regsub -all ";\[ 	\]*#\[^\n]*" $body {} body
	regsub -all "\n\n+" $body \n body
	proc HMrender {win tag not param text} $body
}
############################################
# Turn HTML into TCL commands
#   html    A string containing an html document
#   cmd		A command to run for each html tag found
#   start	The name of the dummy html start/stop tags

proc HMparse_html {html {cmd HMtest_parse} {start hmstart}} {
	regsub -all \{ $html {\&ob;} html
	regsub -all \} $html {\&cb;} html
	set w " \t\r\n"	;# white space
	proc HMcl x {return "\[$x\]"}
	set exp <(/?)([HMcl ^$w>]+)[HMcl $w]*([HMcl ^>]*)>
	set sub "\}\n$cmd {\\2} {\\1} {\\3} \{"
	regsub -all $exp $html $sub html
	eval "$cmd {$start} {} {} \{ $html \}"
	eval "$cmd {$start} / {} {}"
}

proc HMtest_parse {command tag slash text_after_tag} {
	puts "==> $command $tag $slash $text_after_tag"
}

# Convert multiple white space into a single space

proc HMzap_white {data} {
	regsub -all "\[ \t\r\n\]+" $data " " data
	return $data
}

# find HTML escape characters of the form &xxx;

proc HMmap_esc {text} {
	if {![regexp & $text]} {return $text}
	regsub -all {([][$\\])} $text {\\\1} new
	regsub -all {&#([0-9][0-9]?[0-9]?);?} \
		$new {[format %c [scan \1 %d tmp;set tmp]]} new
	regsub -all {&([a-zA-Z]+);?} $new {[HMdo_map \1]} new
	return [subst $new]
}

# convert an HTML escape sequence into character

proc HMdo_map {text {unknown ?}} {
	global HMesc_map
	set result $unknown
	catch {set result $HMesc_map($text)}
	return $result
}

# table of escape characters (ISO latin-1 esc's are in a different table)

array set HMesc_map {
   lt <   gt >   amp &   quot \"   copy \xa9
   reg \xae   ob \x7b   cb \x7d   nbsp \xa0
}
#############################################################
# ISO Latin-1 escape codes

array set HMesc_map {
	nbsp \xa0 iexcl \xa1 cent \xa2 pound \xa3 curren \xa4
	yen \xa5 brvbar \xa6 sect \xa7 uml \xa8 copy \xa9
	ordf \xaa laquo \xab not \xac shy \xad reg \xae
	hibar \xaf deg \xb0 plusmn \xb1 sup2 \xb2 sup3 \xb3
	acute \xb4 micro \xb5 para \xb6 middot \xb7 cedil \xb8
	sup1 \xb9 ordm \xba raquo \xbb frac14 \xbc frac12 \xbd
	frac34 \xbe iquest \xbf Agrave \xc0 Aacute \xc1 Acirc \xc2
	Atilde \xc3 Auml \xc4 Aring \xc5 AElig \xc6 Ccedil \xc7
	Egrave \xc8 Eacute \xc9 Ecirc \xca Euml \xcb Igrave \xcc
	Iacute \xcd Icirc \xce Iuml \xcf ETH \xd0 Ntilde \xd1
	Ograve \xd2 Oacute \xd3 Ocirc \xd4 Otilde \xd5 Ouml \xd6
	times \xd7 Oslash \xd8 Ugrave \xd9 Uacute \xda Ucirc \xdb
	Uuml \xdc Yacute \xdd THORN \xde szlig \xdf agrave \xe0
	aacute \xe1 acirc \xe2 atilde \xe3 auml \xe4 aring \xe5
	aelig \xe6 ccedil \xe7 egrave \xe8 eacute \xe9 ecirc \xea
	euml \xeb igrave \xec iacute \xed icirc \xee iuml \xef
	eth \xf0 ntilde \xf1 ograve \xf2 oacute \xf3 ocirc \xf4
	otilde \xf5 ouml \xf6 divide \xf7 oslash \xf8 ugrave \xf9
	uacute \xfa ucirc \xfb uuml \xfc yacute \xfd thorn \xfe
	yuml \xff
}

##########################################################
# html forms management commands

# As each form element is located, it is created and rendered.  Additional
# state is stored in a form specific global variable to be processed at
# the end of the form, including the "reset" and "submit" options.
# Remember, there can be multiple forms existing on multiple pages.  When
# HTML tables are added, a single form could be spread out over multiple
# text widgets, which makes it impractical to hang the form state off the
# HM$win structure.  We don't need to check for the existance of required
# parameters, we just "fail" and get caught in HMrender

# This causes line breaks to be preserved in the inital values
# of text areas
array set HMtag_map {
	textarea    {fill 0}
}

##########################################################
# html isindex tag.  Although not strictly forms, they're close enough
# to be in this file

# is-index forms
# make a frame with a label, entry, and submit button

proc HMtag_isindex {win param text} {
	upvar #0 HM$win var

	set item $win.$var(tags)
	if {[winfo exists $item]} {
		destroy $item
	}
	frame $item -relief ridge -bd 3
	set prompt "Enter search keywords here"
	HMextract_param $param prompt
	label $item.label -text [HMmap_esc $prompt] -font $var(xfont)
	entry $item.entry
	bind $item.entry <Return> "$item.submit invoke"
	button $item.submit -text search -font $var(xfont) -command \
		[format {HMsubmit_index %s {%s} [HMmap_reply [%s get]]} \
		$win $param $item.entry]
	pack $item.label -side top
	pack $item.entry $item.submit -side left

	# insert window into text widget

	$win insert $var(S_insert) \n isindex
	HMwin_install $win $item
	$win insert $var(S_insert) \n isindex
	bind $item <Visibility> {focus %W.entry}
}

# This is called when the isindex form is submitted.
# The default version calls HMlink_callback.  Isindex tags should either
# be deprecated, or fully supported (e.g. they need an href parameter)

proc HMsubmit_index {win param text} {
	HMlink_callback $win ?$text
}

# initialize form state.  All of the state for this form is kept
# in a global array whose name is stored in the form_id field of
# the main window array.
# Parameters: ACTION, METHOD, ENCTYPE

proc HMtag_form {win param text} {
	upvar #0 HM$win var

	# create a global array for the form
	set id HM$win.form$var(tags)
	upvar #0 $id form

	# missing /form tag, simulate it
	if {[info exists var(form_id)]} {
		puts "Missing end-form tag !!!! $var(form_id)"
		HMtag_/form $win {} {}
	}
	catch {unset form}
	set var(form_id) $id

	set form(param) $param		;# form initial parameter list
	set form(reset) ""			;# command to reset the form
	set form(reset_button) ""	;# list of all reset buttons
	set form(submit) ""			;# command to submit the form
	set form(submit_button) ""	;# list of all submit buttons
}

# Where we're done try to get all of the state into the widgets so
# we can free up the form structure here.  Unfortunately, we can't!

proc HMtag_/form {win param text} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	# make submit button entries for all radio buttons
	foreach name [array names form radio_*] {
		regsub radio_ $name {} name
		lappend form(submit) [list $name \$form(radio_$name)]
	}

	# process the reset button(s)

	foreach item $form(reset_button) {
		$item configure -command $form(reset)
	}

	# no submit button - add one
	if {$form(submit_button) == ""} {
		HMinput_submit $win {}
	}

	# process the "submit" command(s)
	# each submit button could have its own name,value pair

	foreach item $form(submit_button) {
		set submit $form(submit)
		catch {lappend submit $form(submit_$item)}
		$item configure -command  \
				[list HMsubmit_button $win $var(form_id) $form(param) \
				$submit]
	}

	# unset all unused fields here
	unset form(reset) form(submit) form(reset_button) form(submit_button)
	unset var(form_id)
}

###################################################################
# handle form input items
# each item type is handled in a separate procedure
# Each "type" procedure needs to:
# - create the window
# - initialize it
# - add the "submit" and "reset" commands onto the proper Q's
#   "submit" is subst'd
#   "reset" is eval'd

proc HMtag_input {win param text} {
	upvar #0 HM$win var

	set type text	;# the default
	HMextract_param $param type
	set type [string tolower $type]
	if {[catch {HMinput_$type $win $param} err]} {
		puts stderr $err
	}
}

# input type=text
# parameters NAME (reqd), MAXLENGTH, SIZE, VALUE

proc HMinput_text {win param {show {}}} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	# make the entry
	HMextract_param $param name		;# required
	set item $win.input_text,$var(tags)
	set size 20; HMextract_param $param size
	set maxlength 0; HMextract_param $param maxlength
	entry $item -width $size -show $show

	# set the initial value
	set value ""; HMextract_param $param value
	$item insert 0 $value
		
	# insert the entry
	HMwin_install $win $item

	# set the "reset" and "submit" commands
	append form(reset) ";$item delete 0 end;$item insert 0 [list $value]"
	lappend form(submit) [list $name "\[$item get]"]

	# handle the maximum length (broken - no way to cleanup bindtags state)
	if {$maxlength} {
		bindtags $item "[bindtags $item] max$maxlength"
		bind max$maxlength <KeyPress> "%W delete $maxlength end"
	}
}

# password fields - same as text, only don't show data
# parameters NAME (reqd), MAXLENGTH, SIZE, VALUE

proc HMinput_password {win param} {
	HMinput_text $win $param *
}

# checkbuttons are missing a "get" option, so we must use a global
# variable to store the value.
# Parameters NAME, VALUE, (reqd), CHECKED

proc HMinput_checkbox {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	HMextract_param $param name
	HMextract_param $param value

	# Set the global variable, don't use the "form" alias as it is not
	# defined in the global scope of the button
	set variable $var(form_id)(check_$var(tags))	
	set item $win.input_checkbutton,$var(tags)
	checkbutton $item -variable $variable -off {} -on $value -text "  "
	if {[HMextract_param $param checked]} {
		$item select
		append form(reset) ";$item select"
	} else {
		append form(reset) ";$item deselect"
	}

	HMwin_install $win $item
	lappend form(submit) [list $name \$form(check_$var(tags))]
}

# radio buttons.  These are like check buttons, but only one can be selected

proc HMinput_radio {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	HMextract_param $param name
	HMextract_param $param value

	set first [expr ![info exists form(radio_$name)]]
	set variable $var(form_id)(radio_$name)
	set variable $var(form_id)(radio_$name)
	set item $win.input_radiobutton,$var(tags)
	radiobutton $item -variable $variable -value $value -text " "

	HMwin_install $win $item

	if {$first || [HMextract_param $param checked]} {
		$item select
		append form(reset) ";$item select"
	} else {
		append form(reset) ";$item deselect"
	}

	# do the "submit" actions in /form so we only end up with 1 per button grouping
	# contributing to the submission
}

# hidden fields, just append to the "submit" data
# params: NAME, VALUE (reqd)

proc HMinput_hidden {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form
	HMextract_param $param name
	HMextract_param $param value
	lappend form(submit) [list $name $value]
}

# handle input images.  The spec isn't very clear on these, so I'm not
# sure its quite right
# Use std image tag, only set up our own callbacks
#  (e.g. make sure ismap isn't set)
# params: NAME, SRC (reqd) ALIGN

proc HMinput_image {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form
	HMextract_param $param name
	set name		;# barf if no name is specified
	set item [HMtag_img $win $param {}]
	$item configure -relief raised -bd 2 -bg blue

	# make a dummy "submit" button, and invoke it to send the form.
	# We have to get the %x,%y in the value somehow, so calculate it during
	# binding, and save it in the form array for later processing

	set submit $win.dummy_submit,$var(tags)
	if {[winfo exists $submit]} {
		destroy $submit
	}
	button $submit	-takefocus 0;# this never gets mapped!
	lappend form(submit_button) $submit
	set form(submit_$submit) [list $name $name.\$form(X).\$form(Y)]
	
	$item configure -takefocus 1
	bind $item <FocusIn> "catch \{$win see $item\}"
	bind $item <1> "$item configure -relief sunken"
	bind $item <Return> "
		set $var(form_id)(X) 0
		set $var(form_id)(Y) 0
		$submit invoke	
	"
	bind $item <ButtonRelease-1> "
		set $var(form_id)(X) %x
		set $var(form_id)(Y) %y
		$item configure -relief raised
		$submit invoke	
	"
}

# Set up the reset button.  Wait for the /form to attach
# the -command option.  There could be more that 1 reset button
# params VALUE

proc HMinput_reset {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	set value reset
	HMextract_param $param value

	set item $win.input_reset,$var(tags)
	button $item -text [HMmap_esc $value]
	HMwin_install $win $item
	lappend form(reset_button) $item
}

# Set up the submit button.  Wait for the /form to attach
# the -command option.  There could be more that 1 submit button
# params: NAME, VALUE

proc HMinput_submit {win param} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	HMextract_param $param name
	set value submit
	HMextract_param $param value
	set item $win.input_submit,$var(tags)
	button $item -text [HMmap_esc $value] -fg blue
	HMwin_install $win $item
	lappend form(submit_button) $item
	# need to tie the "name=value" to this button
	# save the pair and do it when we finish the submit button
	catch {set form(submit_$item) [list $name $value]}
}

#########################################################################
# selection items
# They all go into a list box.  We don't what to do with the listbox until
# we know how many items end up in it.  Gather up the data for the "options"
# and finish up in the /select tag
# params: NAME (reqd), MULTIPLE, SIZE 

proc HMtag_select {win param text} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form

	HMextract_param $param name
	set size 5;  HMextract_param $param size
	set form(select_size) $size
	set form(select_name) $name
	set form(select_values) ""		;# list of values to submit
	if {[HMextract_param $param multiple]} {
		set mode multiple
	} else {
		set mode single
	}
	set item $win.select,$var(tags)
    frame $item
    set form(select_frame) $item
	listbox $item.list -selectmode $mode -width 0 -exportselection 0
	HMwin_install $win $item
}

# select options
# The values returned in the query may be different from those
# displayed in the listbox, so we need to keep a separate list of
# query values.
#  form(select_default) - contains the default query value
#  form(select_frame) - name of the listbox's containing frame
#  form(select_values)  - list of query values
# params: VALUE, SELECTED

proc HMtag_option {win param text} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form
	upvar $text data
	set frame $form(select_frame)

	# set default option (or options)
	if {[HMextract_param $param selected]} {
        lappend form(select_default) [$form(select_frame).list size]
    }
    set value [string trimright $data " \n"]
    $frame.list insert end $value
	HMextract_param $param value
	lappend form(select_values) $value
	set data ""
}
 
# do most of the work here!
# if SIZE>1, make the listbox.  Otherwise make a "drop-down"
# listbox with a label in it
# If the # of items > size, add a scroll bar
# This should probably be broken up into callbacks to make it
# easier to override the "look".

proc HMtag_/select {win param text} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form
	set frame $form(select_frame)
	set size $form(select_size)
	set items [$frame.list size]

	# set the defaults and reset button
	append form(reset) ";$frame.list selection clear 0  $items"
	if {[info exists form(select_default)]} {
		foreach i $form(select_default) {
			$frame.list selection set $i
			append form(reset) ";$frame.list selection set $i"
		}
	} else {
		$frame.list selection set 0
		append form(reset) ";$frame.list selection set 0"
	}

	# set up the submit button. This is the general case.  For single
	# selections we could be smarter

	for {set i 0} {$i < $size} {incr i} {
		set value [format {[expr {[%s selection includes %s] ? {%s} : {}}]} \
				$frame.list $i [lindex $form(select_values) $i]]
		lappend form(submit) [list $form(select_name) $value]
	}
	
	# show the listbox - no scroll bar

	if {$size > 1 && $items <= $size} {
		$frame.list configure -height $items
		pack $frame.list

	# Listbox with scrollbar

	} elseif {$size > 1} {
		scrollbar $frame.scroll -command "$frame.list yview"  \
				-orient v -takefocus 0
		$frame.list configure -height $size \
			-yscrollcommand "$frame.scroll set"
		pack $frame.list $frame.scroll -side right -fill y

	# This is a joke!

	} else {
		scrollbar $frame.scroll -command "$frame.list yview"  \
			-orient h -takefocus 0
		$frame.list configure -height 1 \
			-yscrollcommand "$frame.scroll set"
		pack $frame.list $frame.scroll -side top -fill x
	}

	# cleanup

	foreach i [array names form select_*] {
		unset form($i)
	}
}

# do a text area (multi-line text)
# params: COLS, NAME, ROWS (all reqd, but default rows and cols anyway)

proc HMtag_textarea {win param text} {
	upvar #0 HM$win var
	upvar #0 $var(form_id) form
	upvar $text data

	set rows 5; HMextract_param $param rows
	set cols 30; HMextract_param $param cols
	HMextract_param $param name
	set item $win.textarea,$var(tags)
	frame $item
	text $item.text -width $cols -height $rows -wrap none \
			-yscrollcommand "$item.scroll set" -padx 3 -pady 3
	scrollbar $item.scroll -command "$item.text yview"  -orient v
	$item.text insert 1.0 $data
	HMwin_install $win $item
	pack $item.text $item.scroll -side right -fill y
	lappend form(submit) [list $name "\[$item.text get 0.0 end]"]
	append form(reset) ";$item.text delete 1.0 end; \
			$item.text insert 1.0 [list $data]"
	set data ""
}

# procedure to install windows into the text widget
# - win:  name of the text widget
# - item: name of widget to install

proc HMwin_install {win item} {
	upvar #0 HM$win var
	$win window create $var(S_insert) -window $item -align bottom
	$win tag add indent$var(level) $item
	set focus [expr {[winfo class $item] != "Frame"}]
	$item configure -takefocus $focus
	bind $item <FocusIn> "$win see $item"
}

#####################################################################
# Assemble and submit the query
# each list element in "stuff" is a name/value pair
# - The names are the NAME parameters of the various fields
# - The values get run through "subst" to extract the values
# - We do the user callback with the list of name value pairs

proc HMsubmit_button {win form_id param stuff} {
	upvar #0 HM$win var
	upvar #0 $form_id form
	set query ""
	foreach pair $stuff {
		set value [subst [lindex $pair 1]]
		if {$value != ""} {
			set item [lindex $pair 0]
			lappend query $item $value
		}
	}
	# this is the user callback.
	HMsubmit_form $win $param $query
}

# sample user callback for form submission
# should be replaced by the application
# Sample version generates a string suitable for http

proc HMsubmit_form {win param query} {
	set result ""
	set sep ""
	foreach i $query {
		append result  $sep [HMmap_reply $i]
		if {$sep != "="} {set sep =} {set sep &}
	}
	puts $result
}

# do x-www-urlencoded character mapping
# The spec says: "non-alphanumeric characters are replaced by '%HH'"
 
set HMalphanumeric	a-zA-Z0-9	;# definition of alphanumeric character class
for {set i 1} {$i <= 256} {incr i} {
    set c [format %c $i]
    if {![string match \[$HMalphanumeric\] $c]} {
        set HMform_map($c) %[format %.2x $i]
    }
}

# These are handled specially
array set HMform_map {
    " " +   \n %0d%0a
}

# 1 leave alphanumerics characters alone
# 2 Convert every other character to an array lookup
# 3 Escape constructs that are "special" to the tcl parser
# 4 "subst" the result, doing all the array substitutions
 
proc HMmap_reply {string} {
    global HMform_map HMalphanumeric
    regsub -all \[^$HMalphanumeric\] $string {$HMform_map(&)} string
    regsub -all \n $string {\\n} string
    regsub -all \t $string {\\t} string
    regsub -all {[][{})\\]\)} $string {\\&} string
    return [subst $string]
}

# convert a x-www-urlencoded string int a a list of name/value pairs

# 1  convert a=b&c=d... to {a} {b} {c} {d}...
# 2, convert + to  " "
# 3, convert %xx to char equiv

proc HMcgiDecode {data} {
	set data [split $data "&="]
	foreach i $data {
		lappend result [cgiMap $i]
	}
	return $result
}

proc HMcgiMap {data} {
	regsub -all {\+} $data " " data
	
	if {[regexp % $data]} {
		regsub -all {([][$\\])} $data {\\\1} data
		regsub -all {%([0-9a-fA-F][0-9a-fA-F])} $data  {[format %c 0x\1]} data
		return [subst $data]
	} else {
		return $data
	}
}

# There is a bug in the tcl library focus routines that prevents focus
# from every reaching an un-viewable window.  Use our *own*
# version of the library routine, until the bug is fixed, make sure we
# over-ride the library version, and not the otherway around

auto_load tkFocusOK
proc tkFocusOK w {
    set code [catch {$w cget -takefocus} value]
    if {($code == 0) && ($value != "")} {
    if {$value == 0} {
        return 0
    } elseif {$value == 1} {
        return 1
    } else {
        set value [uplevel #0 $value $w]
        if {$value != ""} {
        return $value
        }
    }
    }
    set code [catch {$w cget -state} value]
    if {($code == 0) && ($value == "disabled")} {
    return 0
    }
    regexp Key|Focus "[bind $w] [bind [winfo class $w]]"
}
