/*
 * Conceptually based on Tk3 table widget by Roland King (rols@lehman.com)
 *
 * see ChangeLog file for details
 *
 * current maintainer: jeff at hobbs org
 *
 * Copyright 1997-2002, Jeffrey Hobbs (jeff@hobbs.org)
 */

		*************************************
		  The Tk Table Widget Version 2.0+
		*************************************

INTRODUCTION

TkTable is a table/matrix widget extension to tk/tcl.
The basic features of the widget are:

 * multi-line cells
 * support for embedded windows (one per cell)
 * row & column spanning
 * variable width columns / height rows (interactively resizable)
 * row and column titles
 * multiple data sources ((Tcl array || Tcl command) &| internal caching)
 * supports standard Tk reliefs, fonts, colors, etc.
 * x/y scrollbar support
 * 'tag' styles per row, column or cell to change visual appearance
 * in-cell editing - returns value back to data source
 * support for disabled (read-only) tables or cells (via tags)
 * multiple selection modes, with "active" cell
 * multiple drawing modes to get optimal performance for larger tables
 * optional 'flashes' when things update
 * cell validation support
 * Works everywhere Tk does (including Windows and Mac!)
 * Unicode support (Tk8.1+)

FINDING THE WIDGET

0. The newest version is most likely found at:
	http://tktable.sourceforge.net/
	http://www.purl.org/net/hobbs/tcl/capp/

BUILDING AND INSTALLING THE WIDGET

1. Uncompress and unpack the distribution

   ON UNIX and OS X:
	gzip -cd Tktable<version>.tar.gz | tar xf -

   ON WINDOWS:
	use something like WinZip to unpack the archive.

   ON MACINTOSH:
	use StuffIt Expander to unstuff the archive.
    
   This will create a subdirectory tkTable<version> with all the files in it.

2. Configure

   ON UNIX and OS X:
        cd Tktable<version>
	./configure

   tkTable uses information left in tkConfig.sh when you built tk.  This
   file will be found in $exec_prefix/lib/.  You might set the --prefix and
   --exec-prefix options of configure if you don't want the default
   (/usr/local).  If building on multiple unix platforms, the following is
   recommended to isolate build conflicts:
	mkdir <builddir>/<platform>
	cd !$
	/path/to/Tktable<version>/configure

   ON WINDOWS:

   Version 2.8 added support for building in the cygwin environment on
   Windows based on TEA (http://www.tcl.tk/doc/tea/).  You can retrieve
   cygwin from:
	http://sources.redhat.com/cygwin/

   Inside the cygwin environment, you build the same as on Unix.

   Otherwise, hack makefile.vc until it works and compile.  It has problems
   executing wish from a path with a space in it, but the DLL builds just
   fine.  A DLL should be available where you found this archive.

3. Make and Install

   ON UNIX< OS X or WINDOWS (with cygwin):
	make
	make test (OPTIONAL)
	make demo (OPTIONAL)
	make install

   ON WINDOWS (makefile.vc):
	nmake -f makefile.vc
	nmake -f makefile.vc test (OPTIONAL)
	nmake -f makefile.vc install

   tkTable is built to comply to the latest tcl package conventions.
   There is also a specific "make static" for those who need it.

4. Use it

   Start a regular wish interpreter, 'load' the library, and use the table.
   There are a few test scripts in the demos directory which you can source.

5. Read the documentation

   There is a Unix manpage and HTML translation provided in the doc/
   subdirectory.  These describe the table widget's features and commands
   in depth.  If something is confusing, just to try it out.

6. Python users

   There is a library/tktable.py wrapper for use with Python/Tkinter.

THINGS TO WATCH OUT FOR

Packing
  The table tries not to allocate huge chunks of screen real estate if
  you ask it for a lot of rows and columns.  You can always stretch out
  the frame or explicitly tell it how big it can be.  If you want to
  stretch the table, remember to pack it with fill both and expand on,
  or with grid, give it -sticky news and configure the grid row and column
  for some weighting.

Array   
  The array elements for the table are of the form array(2,3) etc.  Make
  sure there are no spaces around the ','.  Negative indices are allowed.

Editing
  If you can't edit, remember that the focus model in tk is explicit, so
  you need to click on the table or give it the focus command.  Just
  having a selected cell is not the same thing as being able to edit.
  You also need the editing cursor.  If you can't get the cursor, make
  sure that you actually have a variable assigned to the table, and that
  the "state" of the cell is not disabled.

COMMENTS, BUGS, etc.

* Please can you send comments and bug reports to the current maintainer
  and their best will be done to address them.  A mailing list for
  tktable discussion is tktable-users@lists.sourceforge.net.

* If you find a bug, a short piece of Tcl that exercises it would be very
  useful, or even better, compile with debugging and specify where it
  crashed in that short piece of Tcl.  Use the SourceForge site to check
  for known bugs or submit new ones.
