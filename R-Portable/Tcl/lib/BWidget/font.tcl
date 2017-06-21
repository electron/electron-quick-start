# ----------------------------------------------------------------------------
#  font.tcl
#  This file is part of Unifix BWidget Toolkit
# ----------------------------------------------------------------------------
#  Index of commands:
#     - SelectFont::create
#     - SelectFont::configure
#     - SelectFont::cget
#     - SelectFont::_draw
#     - SelectFont::_destroy
#     - SelectFont::_modstyle
#     - SelectFont::_update
#     - SelectFont::_getfont
#     - SelectFont::_init
# ----------------------------------------------------------------------------

namespace eval SelectFont {
    Widget::define SelectFont font Dialog LabelFrame ScrolledWindow

    Widget::declare SelectFont {
        {-title		String		"Font selection" 0}
        {-parent	String		"" 0}
        {-background	TkResource	"" 0 frame}

        {-type		Enum		dialog        0 {dialog toolbar}}
        {-font		TkResource	""            0 label}
	{-initialcolor	String		""            0}
	{-families	String		"all"         1}
	{-querysystem	Boolean		1             0}
	{-nosizes	Boolean		0             1}
	{-styles	String		"bold italic underline overstrike" 1}
        {-command	String		""            0}
        {-sampletext	String		"Sample Text" 0}
        {-bg		Synonym		-background}
    }

    variable _families
    variable _styleOff
    array set _styleOff [list bold normal italic roman]
    variable _sizes     {4 5 6 7 8 9 10 11 12 13 14 15 16 \
	    17 18 19 20 21 22 23 24}
    
    # Set up preset lists of fonts, so the user can avoid the painfully slow
    # loadfont process if desired.
    if { [string equal $::tcl_platform(platform) "windows"] } {
	set presetVariable [list	\
		7x14			\
		Arial			\
		{Arial Narrow}		\
		{Lucida Sans}		\
		{MS Sans Serif}		\
		{MS Serif}		\
		{Times New Roman}	\
		]
	set presetFixed    [list	\
		6x13			\
		{Courier New}		\
		FixedSys		\
		Terminal		\
		]
	set presetAll      [list	\
		6x13			\
		7x14			\
		Arial			\
		{Arial Narrow}		\
		{Courier New}		\
		FixedSys		\
		{Lucida Sans}		\
		{MS Sans Serif}		\
		{MS Serif}		\
		Terminal		\
		{Times New Roman}	\
		]
    } else {
	set presetVariable [list	\
		helvetica		\
		lucida			\
		lucidabright		\
		{times new roman}	\
		]
	set presetFixed    [list	\
		courier			\
		fixed			\
		{lucida typewriter}	\
		screen			\
		serif			\
		terminal		\
		]
	set presetAll      [list	\
		courier			\
		fixed			\
		helvetica		\
		lucida			\
		lucidabright		\
		{lucida typewriter}	\
		screen			\
		serif			\
		terminal		\
		{times new roman}	\
		]
    }
    array set _families [list \
	    presetvariable	$presetVariable	\
	    presetfixed		$presetFixed	\
	    presetall		$presetAll	\
	    ]

    variable _widget
}


# ----------------------------------------------------------------------------
#  Command SelectFont::create
# ----------------------------------------------------------------------------
proc SelectFont::create { path args } {
    variable _families
    variable _sizes
    variable $path
    upvar 0  $path data

    # Initialize the internal rep of the widget options
    Widget::init SelectFont "$path#SelectFont" $args

    if { [Widget::getoption "$path#SelectFont" -querysystem] } {
        loadfont [Widget::getoption "$path#SelectFont" -families]
    }

    set bg [Widget::getoption "$path#SelectFont" -background]
    set _styles [Widget::getoption "$path#SelectFont" -styles]
    if { [Widget::getoption "$path#SelectFont" -type] == "dialog" } {
        Dialog::create $path -modal local -anchor e -default 0 -cancel 1 \
	    -background $bg \
            -title  [Widget::getoption "$path#SelectFont" -title] \
            -parent [Widget::getoption "$path#SelectFont" -parent]

        set frame [Dialog::getframe $path]
        set topf  [frame $frame.topf -relief flat -borderwidth 0 -background $bg]

        set labf1 [LabelFrame::create $topf.labf1 -text "Font" -name font \
                       -side top -anchor w -relief flat -background $bg]
        set sw    [ScrolledWindow::create [LabelFrame::getframe $labf1].sw \
                       -background $bg]
        set lbf   [listbox $sw.lb \
                       -height 5 -width 25 -exportselection false -selectmode browse]
        ScrolledWindow::setwidget $sw $lbf
        LabelFrame::configure $labf1 -focus $lbf
	if { [Widget::getoption "$path#SelectFont" -querysystem] } {
	    set fam [Widget::getoption "$path#SelectFont" -families]
	} else {
	    set fam "preset"
	    append fam [Widget::getoption "$path#SelectFont" -families]
	}
        eval [list $lbf insert end] $_families($fam)
        set script "set [list SelectFont::${path}(family)] \[%W curselection\];\
		        SelectFont::_update [list $path]"
        bind $lbf <ButtonRelease-1> $script
        bind $lbf <space>           $script
	bind $lbf <1>               [list focus %W]
	bind $lbf <Up> $script
	bind $lbf <Down> $script
        pack $sw -fill both -expand yes

        set labf2 [LabelFrame::create $topf.labf2 -text "Size" -name size \
                       -side top -anchor w -relief flat -background $bg]
        set sw    [ScrolledWindow::create [LabelFrame::getframe $labf2].sw \
                       -scrollbar vertical -background $bg]
        set lbs   [listbox $sw.lb \
                       -height 5 -width 6 -exportselection false -selectmode browse]
        ScrolledWindow::setwidget $sw $lbs
        LabelFrame::configure $labf2 -focus $lbs
        eval [list $lbs insert end] $_sizes
        set script "set [list SelectFont::${path}(size)] \[%W curselection\];\
			SelectFont::_update [list $path]"
        bind $lbs <ButtonRelease-1> $script
        bind $lbs <space>           $script
	bind $lbs <1>               [list focus %W]
	bind $lbs <Up> $script
	bind $lbs <Down> $script
        pack $sw -fill both -expand yes

        set labf3 [LabelFrame::create $topf.labf3 -text "Style" -name style \
                       -side top -anchor w -relief sunken -bd 1 -background $bg]
        set subf  [LabelFrame::getframe $labf3]
        foreach st $_styles {
            set name [lindex [BWidget::getname $st] 0]
            if { $name == "" } {
                set name [string toupper $name 0]
            }
            checkbutton $subf.$st -text $name \
                -variable   SelectFont::$path\($st\) \
                -background $bg \
                -command    [list SelectFont::_update $path]
            bind $subf.$st <Return> break
            pack $subf.$st -anchor w
        }
        LabelFrame::configure $labf3 -focus $subf.[lindex $_styles 0]

        pack $labf1 -side left -anchor n -fill both -expand yes
	if { ![Widget::getoption "$path#SelectFont" -nosizes] } {
	        pack $labf2 -side left -anchor n -fill both -expand yes -padx 8
	}
        pack $labf3 -side left -anchor n -fill both -expand yes

        set botf [frame $frame.botf -width 100 -height 50 \
                      -bg white -bd 0 -relief flat \
                      -highlightthickness 1 -takefocus 0 \
                      -highlightbackground black \
                      -highlightcolor black]

        set lab  [label $botf.label \
                      -background white -foreground black \
                      -borderwidth 0 -takefocus 0 -highlightthickness 0 \
                      -text [Widget::getoption "$path#SelectFont" -sampletext]]
        place $lab -relx 0.5 -rely 0.5 -anchor c

	pack $topf -pady 4 -fill both -expand yes

	if { [Widget::getoption "$path#SelectFont" -initialcolor] != ""} {
		set thecolor [Widget::getoption "$path#SelectFont" -initialcolor]
		set colf [frame $frame.colf]
			
		set frc [frame $colf.frame -width 50 -height 20 -bg $thecolor -bd 0 -relief flat\
			-highlightthickness 1 -takefocus 0 \
			-highlightbackground black \
			-highlightcolor black]
			
		set script "set [list SelectFont::${path}(fontcolor)] \[tk_chooseColor -parent $colf.button -initialcolor \[set [list SelectFont::${path}(fontcolor)]\]\];\
			SelectFont::_update [list $path]"
		
		set name [lindex [BWidget::getname colorPicker] 0]
		if { $name == "" } {
			set name "Color..."
		}
		set but  [button $colf.button -command $script \
			-text $name]
		
		$lab configure -foreground $thecolor
		$frc configure -bg $thecolor
		
		pack $but -side left
		pack $frc -side left -padx 5
		
		set data(frc) $frc
		set data(fontcolor) $thecolor

		pack $colf -pady 4 -fill x -expand true        
	
	} else {
		set data(fontcolor) -1
	}
	pack $botf -pady 4 -fill x

        Dialog::add $path -name ok
        Dialog::add $path -name cancel

        set data(label) $lab
        set data(lbf)   $lbf
        set data(lbs)   $lbs

        _getfont $path

	Widget::create SelectFont $path 0

        return [_draw $path]
    } else {
	if { [Widget::getoption "$path#SelectFont" -querysystem] } {
	    set fams [Widget::getoption "$path#SelectFont" -families]
	} else {
	    set fams "preset"
	    append fams [Widget::getoption "$path#SelectFont" -families]
	}
	if {[Widget::theme]} {
	    ttk::frame $path
	    set lbf [ttk::combobox $path.font \
			 -takefocus 0 -exportselection 0 \
			 -values   $_families($fams) \
			 -textvariable SelectFont::${path}(family) \
			 -state readonly]
	    set lbs [ttk::combobox $path.size \
			 -takefocus 0 -exportselection 0 \
			 -width    4 \
			 -values   $_sizes \
			 -textvariable SelectFont::${path}(size) \
			 -state readonly]
	    bind $lbf <<ComboboxSelected>> [list SelectFont::_update $path]
	    bind $lbs <<ComboboxSelected>> [list SelectFont::_update $path]
	} else {
	    frame $path -background $bg
	    set lbf [ComboBox::create $path.font \
			 -highlightthickness 0 -takefocus 0 -background $bg \
			 -values   $_families($fams) \
			 -textvariable SelectFont::$path\(family\) \
			 -editable 0 \
			 -modifycmd [list SelectFont::_update $path]]
	    set lbs [ComboBox::create $path.size \
			 -highlightthickness 0 -takefocus 0 -background $bg \
			 -width    4 \
			 -values   $_sizes \
			 -textvariable SelectFont::$path\(size\) \
			 -editable 0 \
			 -modifycmd [list SelectFont::_update $path]]
	}
	bind $path <Destroy> [list SelectFont::_destroy $path]
        pack $lbf -side left -anchor w
        pack $lbs -side left -anchor w -padx 4
        foreach st $_styles {
	    if {$::Widget::_theme} {
		ttk::checkbutton $path.$st -takefocus 0 \
		    -style BWSlim.Toolbutton \
		    -image [Bitmap::get $st] \
		    -variable SelectFont::${path}($st) \
		    -command [list SelectFont::_update $path]
	    } else {
		button $path.$st \
		    -highlightthickness 0 -takefocus 0 -padx 0 -pady 0 \
		    -background $bg \
		    -image [Bitmap::get $st] \
		    -command [list SelectFont::_modstyle $path $st]
	    }
            pack $path.$st -side left -anchor w
        }
        set data(label) ""
        set data(lbf)   $lbf
        set data(lbs)   $lbs
        _getfont $path

	return [Widget::create SelectFont $path]
    }

    return $path
}


# ----------------------------------------------------------------------------
#  Command SelectFont::configure
# ----------------------------------------------------------------------------
proc SelectFont::configure { path args } {
    set _styles [Widget::getoption "$path#SelectFont" -styles]

    set res [Widget::configure "$path#SelectFont" $args]

    if { [Widget::hasChanged "$path#SelectFont" -font font] } {
        _getfont $path
    }
    if { [Widget::hasChanged "$path#SelectFont" -background bg] } {
        switch -- [Widget::getoption "$path#SelectFont" -type] {
            dialog {
                Dialog::configure $path -background $bg
                set topf [Dialog::getframe $path].topf
                $topf configure -background $bg
                foreach labf {labf1 labf2} {
                    LabelFrame::configure $topf.$labf -background $bg
                    set subf [LabelFrame::getframe $topf.$labf]
                    ScrolledWindow::configure $subf.sw -background $bg
                    $subf.sw.lb configure -background $bg
                }
                LabelFrame::configure $topf.labf3 -background $bg
                set subf [LabelFrame::getframe $topf.labf3]
                foreach w [winfo children $subf] {
                    $w configure -background $bg
                }
            }
            toolbar {
                $path configure -background $bg
                ComboBox::configure $path.font -background $bg
                ComboBox::configure $path.size -background $bg
                foreach st $_styles {
                    $path.$st configure -background $bg
                }
            }
        }
    }
    return $res
}


# ----------------------------------------------------------------------------
#  Command SelectFont::cget
# ----------------------------------------------------------------------------
proc SelectFont::cget { path option } {
    return [Widget::cget "$path#SelectFont" $option]
}


# ----------------------------------------------------------------------------
#  Command SelectFont::loadfont
# ----------------------------------------------------------------------------
proc SelectFont::loadfont {{which all}} {
    variable _families

    # initialize families
    if {![info exists _families(all)]} {
	set _families(all) [lsort -dictionary [font families]]
    }
    if {[regexp {fixed|variable} $which] \
	    && ![info exists _families($which)]} {
	# initialize families
	set _families(fixed) {}
	set _families(variable) {}
	foreach family $_families(all) {
	    if { [font metrics [list $family] -fixed] } {
		lappend _families(fixed) $family
	    } else {
		lappend _families(variable) $family
	    }
	}
    }
    return
}


# ----------------------------------------------------------------------------
#  Command SelectFont::_draw
# ----------------------------------------------------------------------------
proc SelectFont::_draw { path } {
    variable $path
    upvar 0  $path data

    $data(lbf) selection clear 0 end
    $data(lbf) selection set $data(family)
    $data(lbf) activate $data(family)
    $data(lbf) see $data(family)
    $data(lbs) selection clear 0 end
    $data(lbs) selection set $data(size)
    $data(lbs) activate $data(size)
    $data(lbs) see $data(size)
    _update $path

    if { [Dialog::draw $path] == 0 } {
        set result [Widget::getoption "$path#SelectFont" -font]
    	set color $data(fontcolor)
	
	if { $color == "" } {
		set color #000000
	}

    } else {
        set result ""
        if {$data(fontcolor) == -1} {
            set color -1
        } else {
            set color ""
        }
    }
    unset data
    Widget::destroy "$path#SelectFont"
    destroy $path
    if { $color != -1 } {
    	return [list $result $color]
    } else {
    	return $result
    }
}


# ----------------------------------------------------------------------------
#  Command SelectFont::_modstyle
# ----------------------------------------------------------------------------
proc SelectFont::_modstyle { path style } {
    variable $path
    upvar 0  $path data

    $path.$style configure -relief [expr {$data($style) ? "raised" : "sunken"}]
    set data($style) [expr {!$data($style)}]
    _update $path
}


# ----------------------------------------------------------------------------
#  Command SelectFont::_update
# ----------------------------------------------------------------------------
proc SelectFont::_update { path } {
    variable _families
    variable _sizes
    variable _styleOff
    variable $path
    upvar 0  $path data

    set type [Widget::getoption "$path#SelectFont" -type]
    set _styles [Widget::getoption "$path#SelectFont" -styles]
    if { [Widget::getoption "$path#SelectFont" -querysystem] } {
	set fams [Widget::getoption "$path#SelectFont" -families]
    } else {
	set fams "preset"
	append fams [Widget::getoption "$path#SelectFont" -families]
    }
    if { $type == "dialog" } {
        set curs [$path:cmd cget -cursor]
        $path:cmd configure -cursor watch
    }
    if { [Widget::getoption "$path#SelectFont" -type] == "dialog" } {
        set font [list [lindex $_families($fams) $data(family)] \
		[lindex $_sizes $data(size)]]
    } else {
        set font [list $data(family) $data(size)]
    }
    foreach st $_styles {
        if { $data($st) } {
            lappend font $st
        } elseif {[info exists _styleOff($st)]} {
	    # This adds the default bold/italic value to a font
	    #lappend font $_styleOff($st)
	}
    }
    Widget::setoption "$path#SelectFont" -font $font
    if { $type == "dialog" } {
        $data(label) configure -font $font
        $path:cmd configure -cursor $curs
	if { ($data(fontcolor) != "") && ($data(fontcolor) != -1) } {
		$data(label) configure -foreground $data(fontcolor)
		$data(frc) configure -bg $data(fontcolor)
	} elseif { $data(fontcolor) == "" }  {
		#If no color is selected, restore previous one
		set data(fontcolor) [$data(label) cget -foreground]

	}
    } elseif { [set cmd [Widget::getoption "$path#SelectFont" -command]] != "" } {
        uplevel \#0 $cmd
    }
}


# ----------------------------------------------------------------------------
#  Command SelectFont::_getfont
# ----------------------------------------------------------------------------
proc SelectFont::_getfont { path } {
    variable _families
    variable _sizes
    variable $path
    upvar 0  $path data

    array set font [font actual [Widget::getoption "$path#SelectFont" -font]]
    set data(bold)       [expr {![string equal $font(-weight) "normal"]}]
    set data(italic)     [expr {![string equal $font(-slant)  "roman"]}]
    set data(underline)  $font(-underline)
    set data(overstrike) $font(-overstrike)
    set _styles [Widget::getoption "$path#SelectFont" -styles]
    if { [Widget::getoption "$path#SelectFont" -querysystem] } {
	set fams [Widget::getoption "$path#SelectFont" -families]
    } else {
	set fams "preset"
	append fams [Widget::getoption "$path#SelectFont" -families]
    }
    if { [Widget::getoption "$path#SelectFont" -type] == "dialog" } {
        set idxf [lsearch $_families($fams) $font(-family)]
        set idxs [lsearch $_sizes    $font(-size)]
        set data(family) [expr {$idxf >= 0 ? $idxf : 0}]
        set data(size)   [expr {$idxs >= 0 ? $idxs : 0}]
    } else {
	set data(family) $font(-family)
	set data(size)   $font(-size)
	if {![Widget::theme]} {
	    foreach st $_styles {
		$path.$st configure \
		    -relief [expr {$data($st) ? "sunken":"raised"}]
	    }
	}
    }
}


# ----------------------------------------------------------------------------
#  Command SelectFont::_destroy
# ----------------------------------------------------------------------------
proc SelectFont::_destroy { path } {
    variable $path
    upvar 0  $path data
    unset data
    Widget::destroy "$path#SelectFont"
}
