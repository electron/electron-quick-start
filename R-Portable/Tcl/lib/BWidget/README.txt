BWidget ToolKit 1.9.0				July 2009
Copyright (c) 1998-1999 UNIFIX.
Copyright (c) 2001-2002 ActiveState Corp. 

See the file LICENSE.txt for license info (uses Tcl's BSD-style license).

--------------------------------------------------------------------------

WHAT IS BWIDGET ?

The BWidget Toolkit is a high-level Widget Set for Tcl/Tk built using
native Tcl/Tk 8.x namespaces.

The BWidgets have a professional look&feel as in other well known
Toolkits (Tix or Incr Widgets), but the concept is radically different
because everything is pure Tcl/Tk.  No platform dependencies, and no
compiling required.  The code is 100% Pure Tcl/Tk.

The BWidget library was originally developed by UNIFIX Online, and
released under both the GNU Public License and the Tcl license.
BWidget is now maintained as a community project, hosted by
Sourceforge.  Scores of fixes and enhancements have been added by
community developers.  See the ChangeLog file for details.

--------------------------------------------------------------------------

WIDGET LIST (1.9)

Simple Widgets 
      Label           Extended Label widget
      Entry           Extended Entry widget
      Button          Extended Button widget
      ArrowButton     Button widget with an arrow shape.
      ProgressBar     Progress indicator widget
      ScrollView      Display the visible area of a scrolled window
      Separator       3D separator widget

Manager Widgets 
      MainFrame       Manage toplevel with menu, toolbar and statusbar 
      LabelFrame      Frame with a Label
      TitleFrame      Frame with a title
      ScrolledWindow  Generic scrolled widget
      ScrollableFrame Scrollable frame containing widget
      PanedWindow     Tiled layout manager widget
      ButtonBox       Set of buttons with horizontal or vertical layout
      PagesManager    Pages manager widget
      NoteBook        Notebook manager widget
      Dialog          Dialog abstraction with custom buttons

Composite Widgets 
      LabelEntry      LabelFrame containing an Entry widget. 
      ComboBox        ComboBox widget
      SpinBox         SpinBox widget
      Tree            Tree widget
      ListBox         ListBox widget
      MessageDlg      Message dialog box
      ProgressDlg     Progress indicator dialog box
      PasswdDlg       Login/Password dialog box (contributed by Stephane Lavirotte)
      SelectFont      Font selection widget
      SelectColor     Color selection widget

Commands Classes 
      Widget          The Widget base class
      DynamicHelp     Provide help to Tk widget or BWidget
      DragSite        Commands set for Drag facilities
      DropSite        Commands set for Drop facilities
      BWidget         Utilities

--------------------------------------------------------------------------
INSTALLATION AND USE

- On Unix Platform:
  Uncompress the file BWidget-<version>.tar.Z|gz

  To use the BWidget:
  - If you have uncompressed the archive file under the Tcl Library Path
    directory, you only need to do:
      % package require BWidget
  - If not, you have to specify the BWidget installation path in auto_path
    global variable:
      % lappend auto_path <install_path>
      % package require BWidget

  To launch the demo, you need to cd into the demo subdirectory:
      $ cd <install_path>/demo
      $ wish demo.tcl

- On Windows and others Platforms:
  Uncompress the file BWidget-<version>.zip

  To use the BWidget:
  - If you uncompressed the archive file under the Tcl Library Path
    directory, you only need to do:
      % package require BWidget
  - If not, you have to specify the BWidget installation path in auto_path
    global variable:
      % lappend auto_path your_path
      % package require BWidget

  To launch the demo :
      Double click on demo.tcl in the demo subdirectory


Distribution contains these directories:

BWidget-<version>   Root directory and BWidget Tcl sources
   BWman        HTML manual pages
   images       images used by BWidget
   lang         Resources for language customization
   demo         Demo sources
   tests        BWidgets test suite         


--------------------------------------------------------------------------

DOCUMENTATION

HTML manual pages are available in the BWman subdirectory.  Point to
index.html for frame version with tree navigation, or to contents.html
for no frame version.

--------------------------------------------------------------------------

CONTACTS

The BWidget toolkit is maintained on Sourceforge, at
http://www.sourceforge.net/projects/tcllib/
