/*
 *  GraphApp
 *  --------
 *  Common cross-platform graphics application routines.
 *  Version 2.4 (c) Lachlan Patrick 1996-1998.
 *  This header file is designed to be platform-independent.
 *
 *  Copyright 2006-8	The R Foundation
 *  Copyrigth 2013	The R Core Team
 *
 */

/*
 *  Common cross-platform graphics routines library.
 */

#ifndef _GRAPHAPP_H
#define _GRAPHAPP_H	240

/*
 *  Assume C declarations for C++
 */

#ifdef __cplusplus
extern "C" {
#endif /* begin normal C declarations */

/*
 *  Definition of some constants.
 */

#include <stdio.h>
#include <stdlib.h>

#ifndef Pi
#define Pi 3.14159265359
#endif

/*
 *  Types.
 */

typedef unsigned char GAbyte;

#define byte GAbyte

#ifndef objptr
  typedef struct { int kind; } gui_obj;
  typedef gui_obj * objptr;
#endif

typedef unsigned long rgb;    /* red-green-blue colour value */

typedef objptr font;          /* font of certain size and style */
typedef objptr cursor;        /* mouse cursor shape */

typedef objptr drawing;       /* bitmap, window or control */

typedef drawing bitmap;       /* platform-specific bitmap */
typedef drawing window;       /* on-screen window */
typedef drawing control;      /* buttons, text-fields, scrollbars */

typedef control label;        /* text label */
typedef control button;       /* push button */
typedef control checkbox;     /* check-box */
typedef control radiobutton;  /* radio button */
typedef control radiogroup;   /* group of radio buttons */
typedef control field;        /* one-line text field */
typedef control textbox;      /* multi-line text box */
typedef control scrollbar;    /* scroll-bar */
typedef control listbox;      /* list of text */
typedef control progressbar;  /* progress bar */

typedef control menubar;      /* contains menus */
typedef control menu;         /* pull-down menu contains menuitems */
typedef control menuitem;     /* a single item in a pull-down menu */

/*
 *  Structures.
 */

typedef struct point point;
typedef struct rect rect;
typedef struct drawstruct drawstruct;
typedef struct drawstruct *drawstate;
typedef struct imagedata imagedata;
typedef struct imagedata *image;

struct point
{
    int x, y;
};

struct rect
{
    int x, y;		/* top-left point inside rect */
    int width, height;	/* width and height of rect */
};

struct drawstruct
{
    drawing	dest;
    rgb	hue;
    int	mode;
    point	p;
    int	linewidth;
    font	fnt;
    cursor	crsr;
};

struct imagedata {
    int     depth;
    int     width;
    int     height;
    int     cmapsize;
    rgb *   cmap;
    byte *  pixels;
};

/*
 *  Call-backs.
 */

typedef void (*voidfn)(void);
typedef void (*timerfn)(void *data);
typedef void (*actionfn)(control c);
typedef void (*drawfn)(control c, rect r);
typedef void (*mousefn)(control c, int buttons, point xy);
typedef void (*intfn)(control c, int argument);
typedef void (*keyfn)(control c, int key);
typedef void (*menufn)(menuitem m);
typedef void (*scrollfn)(scrollbar s, int position);
typedef void (*dropfn)(control c, char *data);
typedef void (*imfn)(control c, font *f, point *xy);

/*
 *  Mouse buttons state (bit-fields).
 */

#define NoButton	0x0000
#define LeftButton	0x0001
#define MiddleButton	0x0002
#define RightButton	0x0004

/*
 *  ANSI character codes.
 */

#define BELL	0x07
#define BKSP	0x08
#define VTAB	0x0B
#define FF	0x0C
#define ESC	0x1B

/*
 *  Edit-key codes.
 */

#define INS	0x2041
#define DEL	0x2326
#define HOME	0x21B8
#define END	0x2198
#define PGUP	0x21DE
#define PGDN	0x21DF
#define ENTER	0x2324

/*
 *  Cursor-key codes.
 */

#define LEFT	0x2190
#define UP	0x2191
#define RIGHT	0x2192
#define DOWN	0x2193

/*
 *  Function-key codes.
 */

#define F1	0x276C
#define F2	0x276D
#define F3	0x276E
#define F4	0x276F
#define F5	0x2770
#define F6	0x2771
#define F7	0x2772
#define F8	0x2773
#define F9	0x2774
#define F10	0x2775

/*
 *  Redefined functions.
 */
#define REDEFINE_FUNC_NAMES
#define addpt      GA_addpt
#define subpt      GA_subpt
#define equalpt    GA_equalpt
#define newmenu    GA_newmenu
#define newcontrol GA_newcontrol
#define newwindow  GA_newwindow
/* #define gettext    GA_gettext */
#define settext    GA_settext

#define R_REMAP
#ifdef R_REMAP
#define BringToTop		GA_BringToTop
#define GetCurrentWinPos	GA_GetCurrentWinPos
#define activatecontrol		GA_activatecontrol
#define add_context		GAI_add_context
#define add_strings		GA_add_strings
#define addstatusbar		GA_addstatusbar
#define addto		GA_addto
#define addtooltip		GA_addtooltip
#define adjust_menu		GAI_adjust_menu
#define app_cleanup		GA_appcleanup
#define apperror		GA_apperror
#define apply_to_list		GAI_apply_to_list
#define askUserPass		GA_askUserPass
#define askcdstring		GA_askcdstring
#define askchangedir		GA_askchangedir
#define askfilename		GA_askfilename
#define askfilenames		GA_askfilenames
#define askfilenamewithdir	GA_askfilenamewithdir
#define askfilesave		GA_askfilesave
#define askfilesavewithdir	GA_askfilesavewithdir
#define askok		GA_askok
#define askokcancel		GA_askokcancel
#define askpassword		GA_askpassword
#define askstring		GA_askstring
#define askyesno		GA_askyesno
#define askyesnocancel		GA_askyesnocancel
#define bitblt		GA_bitblt
#define bitmaptoimage		GA_bitmaptoimage
#define bottomleft		GA_bottomleft
#define bottomright		GA_bottomright
#define brighter		GA_brighter
#define changelistbox		GA_changelistbox
#define changescrollbar		GA_changescrollbar
#define char_to_string		GAI_char_to_string
#define check		GA_check
#define checklimittext		GA_checklimittext
#define clear		GA_clear
#define cleartext		GA_cleartext
#define clipboardhastext		GA_clipboardhastext
#define clipr		GA_clipr
#define compare_strings		GAI_compare_strings
#define convert32to8		GA_convert32to8
#define convert8to32		GA_convert8to32
#define copy_string		GAI_copy_string
#define copydrawstate		GA_copydrawstate
#define copyimage		GA_copyimage
#define copyrect		GA_copyrect
#define copystringtoclipboard		GA_copystringtoclipboard
#define copytext		GA_copytext
#define copytoclipboard		GA_copytoclipboard
#define countFilenames		GA_countFilenames
#define createbitmap		GA_createbitmap
#define createcursor		GA_createcursor
#define currentcursor		GA_currentcursor
#define currentdrawing		GA_currentdrawing
#define currentfont		GA_currentfont
#define currentlinewidth		GA_currentlinewidth
#define currentmode		GA_currentmode
#define currentpoint		GA_currentpoint
#define currentrgb		GA_currentrgb
#define currenttime		GA_currenttime
#define cuttext		GA_cuttext
#define darker		GA_darker
#define decrease_refcount	GAI_decrease_refcount
#define del_all_contexts	GAI_del_all_contexts
#define del_context		GAI_del_context
#define del_string		GAI_del_string
#define delay		GA_delay
#define deletion_traversal	GAI_deletion_traversal
#define delimage		GA_delimage
#define delobj		GA_delobj
#define delstatusbar		GA_delstatusbar
#define deviceheight		GA_deviceheight
#define deviceheightmm		GA_deviceheightmm
#define devicepixelsx		GA_devicepixelsx
#define devicepixelsy		GA_devicepixelsy
#define devicewidth		GA_devicewidth
#define devicewidthmm		GA_devicewidthmm
#define dialog_bg		GA_dialog_bg
#define disable		GA_disable
#define divpt		GA_divpt
#define doevent		GA_doevent
#define draw		GA_draw
#define drawall		GA_drawall
#define drawarc		GA_drawarc
#define drawbrighter		GA_drawbrighter
#define drawdarker		GA_drawdarker
#define drawellipse		GA_drawellipse
#define drawgreyscale		GA_drawgreyscale
#define drawimage		GA_drawimage
#define drawline		GA_drawline
#define drawmonochrome		GA_drawmonochrome
#define drawpoint		GA_drawpoint
#define drawpolygon		GA_drawpolygon
#define drawrect		GA_drawrect
#define drawroundrect		GA_drawroundrect
#define drawstr		GA_drawstr
#define drawtext		GA_drawtext
#define drawto		GA_drawto
#define enable		GA_enable
#define equalr		GA_equalr
#define execapp		GA_execapp
#define exitapp		GA_exitapp
#define fillarc		GA_fillarc
#define fillellipse		GA_fillellipse
#define fillpolygon		GA_fillpolygon
#define fillrect		GA_fillrect
#define fillroundrect		GA_fillroundrect
#define find_object		GAI_find_object
#define find_valid_sibling	GAI_find_valid_sibling
#define finddialog		GA_finddialog
#define finish_contexts		GAI_finish_contexts
#define finish_events		GAI_finish_events
#define finish_objects		GAI_finish_objects
#define fix_brush		GAI_fix_brush
#define flashcontrol		GA_flashcontrol
#define float_to_string		GAI_float_to_string
#define fontascent		GA_fontascent
#define fontdescent		GA_fontdescent
#define fontheight		GA_fontheight
#define fontwidth		GA_fontwidth
#define gabeep		GA_gabeep
#define gamainloop		GA_gamainloop
#define gbitblt		GA_gbitblt
#define gchangemenubar		GA_gchangemenubar
#define gchangepopup		GA_gchangepopup
#define gchangescrollbar		GA_gchangescrollbar
#define gcharmetric		GA_gcharmetric
#define gcopy		GA_gcopy
#define gcopyalpha		GA_gcopyalpha
#define gdrawellipse		GA_gdrawellipse
#define gdrawline		GA_gdrawline
#define gdrawpolyline		GA_gdrawpolyline
#define gdrawrect		GA_gdrawrect
#define gdrawstr		GA_gdrawstr
#define gdrawstr1		GA_gdrawstr1
#define gdrawwcs		GA_gdrawwcs
#define getHandle		GA_getHandle
#define getSysFontSize		GA_getSysFontSize
#define get_context		GAI_get_context
#define get_grey_pixel		GAI_get_grey_pixel
#define get_image_pixel		GAI_get_image_pixel
#define get_modeless		GAI_get_modeless
#define get_monochrome_pixel	GAI_get_monochrome_pixel
#define getbackground		GA_getbackground
#define getbitmapdata		GA_getbitmapdata
#define getbitmapdata2		GA_getbitmapdata2
#define getcliprect		GA_getcliprect
#define getcurrentline		GA_getcurrentline
#define getdata		GA_getdata
#define getforeground		GA_getforeground
#define getkeystate		GA_getkeystate
#define getlimittext		GA_getlimittext
#define getlinelength		GA_getlinelength
#define getlistitem		GA_getlistitem
#define getpalette		GA_getpalette
#define getpalettesize		GA_getpalettesize
#define getpastelength		GA_getpastelength
#define getpixel		GA_getpixel
#define getpixels		GA_getpixels
#define getseltext		GA_getseltext
#define getstringfromclipboard		GA_getstringfromclipboard
#define gettextfont		GA_gettextfont
#define getvalue		GA_getvalue
#define gfillellipse		GA_gfillellipse
#define gfillpolygon		GA_gfillpolygon
#define gfillrect		GA_gfillrect
#define ggetcliprect		GA_ggetcliprect
#define ggetkeystate		GA_ggetkeystate
#define ggetmodified		GA_ggetmodified
#define ggetpixel		GA_ggetpixel
#define ghasfixedwidth		GA_ghasfixedwidth
#define ginvert		GA_ginvert
#define gmenubar		GA_gmenubar
#define gnewfont		GA_gnewfont
#define gnewfont2		GA_gnewfont2
#define goldfillellipse		GA_goldfillellipse
#define gpopup		GA_gpopup
#define gprintf		GA_gprintf
#define growr		GA_growr
#define gscroll		GA_gscroll
#define gsetcliprect		GA_gsetcliprect
#define gsetcursor		GA_gsetcursor
#define gsetpolyfillmode	GA_gsetpolyfillmode
#define gsetmodified		GA_gsetmodified
#define gsetpixel		GA_gsetpixel
#define gstrrect		GA_gstrrect
#define gstrsize		GA_gstrsize
#define gstrwidth		GA_gstrwidth
#define gwcharmetric		GA_gwcharmetric
#define gwcswidth		GA_gwcswidth
#define gwdrawstr1		GA_gwdrawstr1
#define handle_control		GAI_handle_control
#define handle_findreplace	GAI_handle_findreplace
#define handle_menu_id		GAI_handle_menu_id
#define handle_menu_key		GAI_handle_menu_key
#define has_transparent_pixels	GAI_has_transparent_pixels
#define hide			GA_hide
#define hide_window		GAI_hide_window
#define highlight		GA_highlight
#define imagedepth		GA_imagedepth
#define imageheight		GA_imageheight
#define imagetobitmap		GA_imagetobitmap
#define imagewidth		GA_imagewidth
#define increase_refcount	GAI_increase_refcount
#define init_contexts		GAI_init_contexts
#define init_cursors		GAI_init_cursors
#define init_events		GAI_init_events
#define init_fonts		GAI_init_fonts
#define init_menus		GAI_init_menus
#define init_objects		GAI_init_objects
#define initapp			GA_initapp
#define inserttext		GA_inserttext
#define insetr			GA_insetr
#define int_to_string		GAI_int_to_string
#define invertrect		GA_invertrect
#define isTopmost		GA_isTopmost
#define ischecked		GA_ischecked
#define isenabled		GA_isenabled
#define ishighlighted		GA_ishighlighted
#define isiconic		GA_isiconic
#define ismdi			GA_ismdi
#define isselected		GA_isselected
#define isUnicodeWindow		GA_isUnicodeWindow
#define isvisible		GA_isvisible
#define lineto			GA_lineto
#define load_gif		GAI_load_gif
#define loadbitmap		GA_loadbitmap
#define loadcursor		GA_loadcursor
#define loadimage		GA_loadimage
#define memalloc		GAI_memalloc
#define memexpand		GAI_memexpand
#define memfree		GAI_memfree
#define memjoin		GAI_memjoin
#define memlength		GAI_memlength
#define memrealloc		GAI_memrealloc
#define midpt		GA_midpt
#define modeless_active		GA_modeless_active
#define move_to_front		GAI_move_to_front
#define moveto		GA_moveto
#define mulpt		GA_mulpt
#define myAppendMenu		GA_myAppendMenu
#define myGetSysColor		GA_myGetSysColor
#define myMessageBox		GA_myMessageBox
#define nametorgb		GA_nametorgb
#define new_font_object		GA_new_font_object
#define new_object		GAI_new_object
#define new_string		GAI_new_string
#define newbitmap		GA_newbitmap
#define newbutton		GA_newbutton
#define newcheckbox		GA_newcheckbox
#define newcursor		GA_newcursor
#define newdrawing		GA_newdrawing
#define newdropfield		GA_newdropfield
#define newdroplist		GA_newdroplist
#define newfield		GA_newfield
#define newfield_no_border		GA_newfield_no_border
#define newfont		GA_newfont
#define newimage		GA_newimage
#define newimagebutton		GA_newimagebutton
#define newimagecheckbox		GA_newimagecheckbox
#define newlabel		GA_newlabel
#define newlistbox		GA_newlistbox
#define newmdimenu		GA_newmdimenu
#define newmenubar		GA_newmenubar
#define newmenuitem		GA_newmenuitem
#define newmetafile		GA_newmetafile
#define newmultilist		GA_newmultilist
#define newpassword		GA_newpassword
#define newpicture		GA_newpicture
#define newpoint		GA_newpoint
#define newpopup		GA_newpopup
#define newprinter		GA_newprinter
#define newprogressbar		GA_newprogressbar
#define newradiobutton		GA_newradiobutton
#define newradiogroup		GA_newradiogroup
#define newrect		GA_newrect
#define newrichtextarea		GA_newrichtextarea
#define newscrollbar		GA_newscrollbar
#define newsubmenu		GA_newsubmenu
#define newtextarea		GA_newtextarea
#define newtextbox		GA_newtextbox
#define newtoolbar		GA_newtoolbar
#define newtoolbutton		GA_newtoolbutton
#define nextpage		GA_nextpage
#define objdepth		GA_objdepth
#define objheight		GA_objheight
#define objrect		GA_objrect
#define objwidth		GA_objwidth
#define oldfillellipse		GA_oldfillellipse
#define parentwindow		GA_parentwindow
#define pastetext		GA_pastetext
#define peekevent		GA_peekevent
#define protect_object		GAI_protect_object
#define ptinr		GA_ptinr
#define raddpt		GA_raddpt
#define rcanon		GA_rcanon
#define rcenter		GA_rcenter
#define rdiv		GA_rdiv
#define redraw		GA_redraw
#define remove_context		GAI_remove_context
#define remove_menu_item	GA_remove_menu_item
#define replacedialog		GA_replacedialog
#define resetdrawstate		GA_resetdrawstate
#define resize			GA_resize
#define restoredrawstate	GA_restoredrawstate
#define rgbtoname		GA_rgbtoname
#define rgbtonum		GA_rgbtonum
#define rinr		GA_rinr
#define rmove		GA_rmove
#define rmul		GA_rmul
#define rpt		GA_rpt
#define rsubpt		GA_rsubpt
#define rxr		GA_rxr
#define save_gif		GAI_save_gif
#define saveimage		GA_saveimage
#define scaleimage		GA_scaleimage
#define screen_coords		GA_screen_coords
#define scrollcaret		GA_scrollcaret
#define scrollrect		GA_scrollrect
#define scrolltext		GA_scrolltext
#define selecttext		GA_selecttext
#define selecttextex		GA_selecttextex
#define setaction		GA_setaction
#define setbackground		GA_setbackground
#define setbitmapdata		GA_setbitmapdata
#define setcaret		GA_setcaret
#define setcliprect		GA_setcliprect
#define setclose		GA_setclose
#define setcursor		GA_setcursor
#define setdata		GA_setdata
#define setdel		GA_setdel
#define setdrawmode		GA_setdrawmode
#define setdrawstate		GA_setdrawstate
#define setdrop		GA_setdrop
#define setfont		GA_setfont
#define setforeground		GA_setforeground
#define sethit		GA_sethit
#define setimage		GA_setimage
#define setim		GA_setim
#define setkeyaction		GA_setkeyaction
#define setkeydown		GA_setkeydown
#define setlimittext		GA_setlimittext
#define setlinewidth		GA_setlinewidth
#define setlistitem		GA_setlistitem
#define setmousedown		GA_setmousedown
#define setmousedrag		GA_setmousedrag
#define setmousemove		GA_setmousemove
#define setmouserepeat		GA_setmouserepeat
#define setmousetimer		GA_setmousetimer
#define setmouseup		GA_setmouseup
#define setonfocus		GA_setonfocus
#define setpalette		GA_setpalette
#define setpixel		GA_setpixel
#define setpixels		GA_setpixels
#define setprogressbar		GA_setprogressbar
#define setprogressbarrange		GA_setprogressbarrange
#define setredraw		GA_setredraw
#define setresize		GA_setresize
#define setrgb		GA_setrgb
#define setstatus		GA_setstatus
#define settextfont		GA_settextfont
#define settimer		GA_settimer
#define settimerfn		GA_settimerfn
#define setuserfilter		GA_setuserfilter
#define setvalue		GA_setvalue
#define show		GA_show
#define showcaret	GA_showcaret
#define show_window		GAI_show_window
#define simple_window		GAI_simple_window
#define sortpalette		GA_sortpalette
#define startgraphapp		GA_startgraphapp
#define stepprogressbar		GA_stepprogressbar
#define string_diff		GAI_string_diff
#define string_length		GAI_string_length
#define strrect		GA_strrect
#define strsize		GA_strsize
#define strwidth		GA_strwidth
#define textheight		GA_textheight
#define textselection		GA_textselection
#define textselectionex		GA_textselectionex
#define texturerect		GA_texturerect
#define to_c_string		GAI_to_c_string
#define to_dos_string		GAI_to_dos_string
#define toolbar_hide		GA_toolbar_hide
#define toolbar_show		GA_toolbar_show
#define topleft		GA_topleft
#define topright		GA_topright
#define tree_search		GA_tree_search
#define uncheck		GA_uncheck
#define undotext		GA_undotext
#define unhighlight		GA_unhighlight
#define updatestatus		GA_updatestatus
#define waitevent		GA_waitevent

#define ColorName		GA_ColorName
#define Courier			GA_Courier
#define FixedFont		GA_FixedFont
#define Helvetica		GA_Helvetica
#define MDIFrame		GA_MDIFrame
#define MDIStatus		GA_MDIStatus
#define MDIToolbar		GA_MDIToolbar
#define SystemFont		GA_SystemFont
#define Times			GA_Times
#define TopmostDialogs		GA_TopmostDialogs
#define active_windows		GAI_active_windows
#define app_control_proc	GAI_app_control_proc
#define app_control_procedure	GAI_app_control_procedure
#define app_doc_proc		GAI_app_doc_proc
#define app_drawstate		GAI_app_drawstate
#define app_initialised		GAI_app_initialised
#define app_name		GAI_app_name
#define app_timer_proc		GAI_app_timer_proc
#define app_timer_procedure	GAI_app_timer_procedure
#define app_win_proc		GAI_app_win_proc
#define app_work_proc		GAI_app_work_proc
#define child_id		GAI_child_id
#define current			GAI_current
#define current_menu		GAI_current_menu
#define current_menubar		GAI_current_menubar
#define current_window		GAI_current_window
#define dc			GAI_dc
#define hAccel			GAI_hAccel
#define hwndClient		GAI_hwndClient
#define hwndFrame		GAI_hwndFrame
#define hwndMain		GAI_hwndMain
#define is_NT			GA_isNT
#define keystate		GAI_keystate
#define menus_active		GAI_menus_active
#define prev_instance		GAI_prev_instance
#define the_brush		GAI_the_brush
#define the_pen			GAI_the_pen
#define this_instance		GAI_this_instance
#define win_rgb			GAI_win_rgb

#define ArrowCursor		GA_ArrowCursor
#define BlankCursor		GA_BlankCursor
#define CaretCursor		GA_CaretCursor
#define CrossCursor		GA_CrossCursor
#define HandCursor		GA_HandCursor
#define TextCursor		GA_TextCursor
#define WatchCursor		GA_WatchCursor

#define cam_image		GA_cam_image
#define color_image		GA_color_image
#define console1_image		GA_console1_image
#define console_image		GA_console_image
#define copy1_image		GA_copy1_image
#define copy_image		GA_copy_image
#define copypaste_image		GA_copypaste_image
#define cut_image		GA_cut_image
#define erase_image		GA_erase_image
#define help_image		GA_help_image
#define open1_image		GA_open1_image
#define open_image		GA_open_image
#define paste1_image		GA_paste1_image
#define paste_image		GA_paste_image
#define print_image		GA_print_image
#define save_image		GA_save_image
#define stop_image		GA_stop_image
#endif

/*
 *  General functions.
 */

int	initapp(int argc, char *argv[]);
void	exitapp(void);

void	drawall(void);
int	peekevent(void);
void	waitevent(void);
int	doevent(void);
void	mainloop(void);

int	execapp(char *cmd);

/*void	beep(void);*/

/*
 *  Point and rectangle arithmetic.
 */

point	newpoint(int x, int y);
rect	newrect(int left, int top, int width, int height);
rect	rpt(point min, point max);

#define pt(x,y)         newpoint((x),(y))
#define rect(x,y,w,h)   newrect((x),(y),(w),(h))

point	topleft(rect r);
point	bottomright(rect r);
point	topright(rect r);
point	bottomleft(rect r);

point	addpt(point p1, point p2);
point	subpt(point p1, point p2);
point	midpt(point p1, point p2);
point	mulpt(point p1, int i);
point	divpt(point p1, int i);
rect	rmove(rect r, point p);
rect	raddpt(rect r, point p);
rect	rsubpt(rect r, point p);
rect	rmul(rect r, int i);
rect	rdiv(rect r, int i);
rect	growr(rect r, int w, int h);
rect	insetr(rect r, int i);
rect	rcenter(rect r1, rect r2);
int	ptinr(point p, rect r);
int	rinr(rect r1, rect r2);
int	rxr(rect r1, rect r2);
int	equalpt(point p1, point p2);
int	equalr(rect r1, rect r2);
rect	clipr(rect r1, rect r2);
rect	rcanon(rect r);

/*
 *  Colour functions and constants.
 */

#define	rgb(r,g,b)    ((((rgb)r)<<16)|(((rgb)g)<<8)|((rgb)b))
#define getalpha(col) (((col)>>24)&0x00FFUL)
#define getred(col)   (((col)>>16)&0x00FFUL)
#define getgreen(col) (((col)>>8)&0x00FFUL)
#define getblue(col)  ((col)&0x00FFUL)

void	setrgb(rgb c);
#define	setcolor(c)  setrgb(c)
#define	setcolour(c) setrgb(c)

/* changed to avoid clashes with w32api 2.0 */
#define gaRed		0x00FF0000UL
#define gaGreen		0x0000FF00UL
#define gaBlue		0x000000FFUL


#define Transparent     0xFFFFFFFFUL

#define Black		0x00000000UL
#define White		0x00FFFFFFUL
#define Yellow		0x00FFFF00UL
#define Magenta		0x00FF00FFUL
#define Cyan		0x0000FFFFUL

#define Grey		0x00808080UL
#define Gray		0x00808080UL
#define LightGrey	0x00C0C0C0UL
#define LightGray	0x00C0C0C0UL
#define DarkGrey	0x00404040UL
#define DarkGray	0x00404040UL

#define DarkBlue	0x00000080UL
#define DarkGreen	0x00008000UL
#define DarkRed		0x008B0000UL/* changed to match rgb */
#define LightBlue	0x0080C0FFUL
#define LightGreen	0x0080FF80UL
#define LightRed	0x00FFC0FFUL
#define Pink		0x00FFAFAFUL
#define Brown		0x00603000UL
#define Orange		0x00FF8000UL
#define Purple		0x00C000FFUL
#define Lime		0x0080FF00UL

/*
 *  Context functions for bitmaps, windows, controls.
 */

void	addto(control dest);
void	drawto(drawing dest);
void	setlinewidth(int width);

/*
 *  Transfer modes for drawing operations, S=source, D=destination.
 *  The modes are arranged so that, for example, (~D)|S == notDorS.
 */

void	setdrawmode(int mode);

#define Zeros	 0x00
#define DnorS	 0x01
#define DandnotS 0x02
#define notS	 0x03
#define notDandS 0x04
#define notD	 0x05
#define DxorS	 0x06
#define DnandS	 0x07
#define DandS	 0x08
#define DxnorS	 0x09
#define D	 0x0A
#define DornotS	 0x0B
#define S	 0x0C
#define notDorS	 0x0D
#define DorS	 0x0E
#define Ones	 0x0F

/*
 *  Drawing functions.
 */

void	bitblt(drawing dest, drawing src, point dp, rect sr, int mode);

void	scrollrect(point dp, rect sr);
void	copyrect(drawing src, point dp, rect sr);
void	texturerect(drawing src, rect r);
void	invertrect(rect r);

rgb	getpixel(point p);
void	setpixel(point p, rgb c);

/*
 *  Drawing using the current colour.
 */

void	moveto(point p);
void	lineto(point p);

void	drawpoint(point p);
void	drawline(point p1, point p2);
void	drawrect(rect r);
void	fillrect(rect r);
void	drawarc(rect r, int start_angle, int end_angle);
void	fillarc(rect r, int start_angle, int end_angle);
void	drawellipse(rect r);
void	fillellipse(rect r);
void	drawroundrect(rect r);
void	fillroundrect(rect r);
void	drawpolygon(point *p, int n);
void	fillpolygon(point *p, int n);

/*
 *  Drawing text, selecting fonts.
 */

font	newfont(const char *name, int style, int size);
void	setfont(font f);

int	fontwidth(font f);
int	fontheight(font f);
int	fontascent(font f);
int	fontdescent(font f);

#define	getascent(f)	fontascent(f)
#define	getdescent(f)	fontdescent(f)

int	strwidth(font f, const char *s);
point	strsize(font f, const char *s);
rect	strrect(font f, const char *s);

int	drawstr(point p, const char *str);
int	textheight(int width, const char *text);
const char *drawtext(rect r, int alignment, const char *text);
int	gprintf(const char *fmt, ...);

/*
 *  Text styles and alignments.
 */

#define Plain		0x0000
#define Bold		0x0001
#define Italic		0x0002
#define BoldItalic	0x0003
#define SansSerif	0x0004
#define FixedWidth	0x0008
#define Wide		0x0010
#define Narrow		0x0020

#define AlignTop        0x0000
#define AlignBottom     0x0100
#define VJustify        0x0200
#define VCenter         0x0400
#define VCentre         0x0400
#define AlignLeft       0x0000
#define AlignRight      0x1000
#define Justify	        0x2000
#define Center	        0x4000
#define Centre          0x4000
#define AlignCenter     0x4000
#define AlignCentre     0x4000
#define Underline       0x0800

/*
 *  Find the current state of drawing.
 */

drawing	currentdrawing(void);
rgb	currentrgb(void);
#define	currentcolor() currentrgb()
#define	currentcolour() currentrgb()
int	currentmode(void);
point	currentpoint(void);
int	currentlinewidth(void);
font	currentfont(void);
cursor	currentcursor(void);

/*
 *  Find current keyboard state.
 */

int	getkeystate(void);

#define AltKey	0x0001
#define CmdKey	0x0001
#define CtrlKey		0x0002
#define OptionKey	0x0002
#define ShiftKey	0x0004

/*
 *  Bitmaps.
 */

bitmap	newbitmap(int width, int height, int depth);
bitmap	loadbitmap(const char *name);
bitmap	imagetobitmap(image img);
bitmap	createbitmap(int width, int height, int depth, byte *data);
void	setbitmapdata(bitmap b, byte data[]);
void	getbitmapdata(bitmap b, byte data[]);
void	getbitmapdata2(bitmap b, byte **data);

/*
 *  Images.
 */

image	newimage(int width, int height, int depth);
image	copyimage(image img);
void	delimage(image img);

int     imagedepth(image img);
int     imagewidth(image img);
int     imageheight(image img);

void	setpixels(image img, byte pixels[]);
byte *	getpixels(image img);

void	setpalette(image img, int length, rgb cmap[]);
rgb *	getpalette(image img);
int	getpalettesize(image img);

image	scaleimage(image src, rect dr, rect sr);
image	convert32to8(image img);
image	convert8to32(image img);
void	sortpalette(image img);

image	loadimage(const char *filename);
void	saveimage(image img, const char *filename);

void	drawimage(image img, rect dr, rect sr);
void	drawmonochrome(image img, rect dr, rect sr);
void	drawgreyscale(image img, rect dr, rect sr);
#define drawgrayscale drawgreyscale
void	drawdarker(image img, rect dr, rect sr);
void	drawbrighter(image img, rect dr, rect sr);

/*
 *  Windows.
 */

window	newwindow(const char *name, rect r, long flags);
void	show(window w);
void	hide(window w);
rect    GetCurrentWinPos(window obj);

/*
 *  Window creation flags.
 */

#define SimpleWindow	0x00000000L

#define Menubar		0x00000010L
#define Titlebar	0x00000020L
#define Closebox	0x00000040L
#define Resize		0x00000080L
#define Maximize	0x00000100L
#define Minimize	0x00000200L
#define HScrollbar	0x00000400L
#define VScrollbar	0x00000800L
#define CanvasSize	0x00200000L

#define Modal		0x00001000L
#define Floating	0x00002000L
#define Centered	0x00004000L
#define Centred		0x00004000L

#define Workspace	0x00010000L
#define Document	0x00020000L
#define ChildWindow	0x00040000L

#define TrackMouse	0x00080000L

#define UsePalette	0x00100000L
#define UseUnicode	0x00200000L

#define StandardWindow	(Titlebar|Closebox|Resize|Maximize|Minimize)

/*
 *  Functions which work for bitmaps, windows and controls.
 */

int	objdepth(objptr obj);
rect	objrect(objptr obj);
int	objwidth(objptr obj);
int	objheight(objptr obj);
void	delobj(objptr obj);

#define	getdepth(obj)	objdepth((objptr)(obj))
#define	getrect(obj)	objrect((objptr)(obj))
#define	getwidth(obj)	objwidth((objptr)(obj))
#define	getheight(obj)	objheight((objptr)(obj))
#define	del(obj)	delobj((objptr)(obj))

/*
 *  Setting window and control callback functions.
 */

void	setaction(control c, actionfn fn);
void	sethit(control c, intfn fn);
void	setdel(control c, actionfn fn);
void	setclose(control c, actionfn fn);

void	setredraw(control c, drawfn fn);
void	setresize(control c, drawfn fn);

void	setkeydown(control c, keyfn fn);
void	setkeyaction(control c, keyfn fn);

void	setmousedown(control c, mousefn fn);
void	setmousedrag(control c, mousefn fn);
void	setmouseup(control c, mousefn fn);
void	setmousemove(control c, mousefn fn);
void	setmouserepeat(control c, mousefn fn);

void	setdrop(control c, dropfn fn);

void	setonfocus(control c, actionfn fn);

void    setim(control c, imfn fn);

/*
 *  Using windows and controls.
 */

void	clear(control c);
void	draw(control c);
void	redraw(control c);
void	resize(control c, rect r);

void	show(control c);
void	hide(control c);
int	isvisible(control c);

void	enable(control c);
void	disable(control c);
int	isenabled(control c);

void	check(control c);
void	uncheck(control c);
int	ischecked(control c);

void	highlight(control c);
void	unhighlight(control c);
int	ishighlighted(control c);

void	flashcontrol(control c);
void	activatecontrol(control c);

/*
 *  Changing the state of a control.
 */

void	settext(control c, const char *newtext);
char *	GA_gettext(control c);
#define setname(c,newname) settext(c,newname)
#define getname(c) GA_gettext(c)

void	settextfont(control c, font f);
font	gettextfont(control c);

void	setforeground(control c, rgb fg);
rgb	getforeground(control c);
void	setbackground(control c, rgb bg);
rgb	getbackground(control c);

void	setvalue(control c, int value);
int	getvalue(control c);
void	setdata(control c, void *data);
void *	getdata(control c);

window	parentwindow(control c);

/*
 *  Control states.
 */

#define Visible		0x0001L
#define Enabled	0x0002L
#define Checked	0x0004L
#define Highlighted	0x0008L
#define Armed           0x0010L
#define Focus           0x0020L

/*
 *  Create buttons, scrollbars, controls etc on the current window.
 */

control	  newcontrol(const char *text, rect r);

drawing	  newdrawing(rect r, drawfn fn);
drawing	  newpicture(image img, rect r);

button	  newbutton(const char *text, rect r, actionfn fn);
button	  newimagebutton(image img, rect r, actionfn fn);
void	  setimage(control c, image img);

checkbox  newcheckbox(const char *text, rect r, actionfn fn);
checkbox  newimagecheckbox(image img, rect r, actionfn fn);

radiobutton newradiobutton(const char *text, rect r, actionfn fn);
radiogroup  newradiogroup(void);

scrollbar newscrollbar(rect r, int max, int pagesize, scrollfn fn);
void	  changescrollbar(scrollbar s, int where, int max, int size);

label	  newlabel(const char *text, rect r, int alignment);
field	  newfield(const char *text, rect r);
field	  newpassword(const char *text, rect r);
textbox	  newtextbox(const char *text, rect r);
textbox	  newtextarea(const char *text, rect r);
textbox	  newrichtextarea(const char *text, rect r);

listbox	  newlistbox(const char *list[], rect r, scrollfn fn, actionfn dble);
listbox	  newdroplist(const char *list[], rect r, scrollfn fn);
listbox	  newdropfield(const char *list[], rect r, scrollfn fn);
listbox	  newmultilist(const char *list[], rect r, scrollfn fn, actionfn dble);
int	  isselected(listbox b, int index);
void	  setlistitem(listbox b, int index);
int	  getlistitem(listbox b);
void	  changelistbox(listbox b, const char *new_list[]);

progressbar newprogressbar(rect r, int pmin, int pmax, int incr, int smooth);
void setprogressbar(progressbar obj, int n);
void stepprogressbar(progressbar obj, int n);
void setprogressbarrange(progressbar obj, int pbmin, int pbmax);


menubar	  newmenubar(actionfn adjust_menus);
menu	  newsubmenu(menu parent, const char *name);
menu	  newmenu(const char *name);
menuitem  newmenuitem(const char *name, int key, menufn fn);

/*
 *  Text editing functions.
 */

void  undotext(textbox t);
void  cuttext(textbox t);
void  copytext(textbox t);
void  cleartext(textbox t);
void  pastetext(textbox t);
void  inserttext(textbox t, const char *text);
void  selecttext(textbox t, long start, long end);
void  textselection(textbox t, long *start, long *end);

/*
 *  Dialogs.
 */

#define YES    1
#define NO    -1
#define CANCEL 0

void	apperror(const char *errstr);
void	askok(const char *info);
int	askokcancel(const char *question);
int	askyesno(const char *question);
int	askyesnocancel(const char *question);
char *	askstring(const char *question, const char *default_string);
char *	askpassword(const char *question, const char *default_string);
char *	askfilename(const char *title, const char *default_name);
char *  askfilenamewithdir(const char *title, const char *default_name, const char *dir);
char *	askfilesave(const char *title, const char *default_name);
char *	askUserPass(const char *title);

/*
 *  Time functions.
 */

int	settimer(unsigned millisec);
void	settimerfn(timerfn timeout, void *data);
int	setmousetimer(unsigned millisec);
void	delay(unsigned millisec);
long	currenttime(void);

/*
 *  Cursors.
 */

cursor	newcursor(point hotspot, image img);
cursor	createcursor(point offset, byte *white_mask, byte *black_shape);
cursor	loadcursor(const char *name);
void	setcursor(cursor c);

/*
 *  Change the drawing state.
 */

drawstate copydrawstate(void);
void	setdrawstate(drawstate saved_state);
void	restoredrawstate(drawstate saved_state);
void	resetdrawstate(void);

/*
 *  Caret-related functions.
 */
 
void 	setcaret(control c, int x, int y, int width, int height);
void	showcaret(control c, int showing);

/*
 *  Library supplied variables.
 */

#include <R_ext/libextern.h>
#undef LibExtern
#ifdef GA_DLL_BUILD
# define LibExtern LibExport
#else
# define LibExtern extern LibImport
#endif

LibExtern font		FixedFont;	/* fixed-width font */
LibExtern cursor	ArrowCursor;	/* normal arrow cursor */
LibExtern cursor	BlankCursor;	/* invisible cursor */
LibExtern cursor	WatchCursor;	/* wait for the computer */
LibExtern cursor	CaretCursor;	/* insert text */
LibExtern cursor	TextCursor;	/* insert text */
LibExtern cursor	HandCursor;	/* hand pointer */
LibExtern cursor	CrossCursor;	/* cross pointer */
LibExtern font		SystemFont;	/* system font */
LibExtern font		Times;	/* times roman font (serif) */
LibExtern font		Helvetica;	/* helvetica font (sans serif) */
LibExtern font		Courier;	/* courier font (fixed width) */

#undef LibExtern
#undef extern

#ifdef __cplusplus
}
#endif /* end normal C declarations */


#ifdef __cplusplus

/* begin C++ declarations */

/*
 *  Point and rectangle arithmetic.
 */

inline point operator +  (point p, point p2)  {p.x+=p2.x; p.y+=p2.y; return p;}
inline point operator -  (point p, point p2)  {p.x-=p2.x; p.y-=p2.y; return p;}
inline point operator += (point& p, point p2) {p.x+=p2.x; p.y+=p2.y; return p;}
inline point operator -= (point& p, point p2) {p.x-=p2.x; p.y-=p2.y; return p;}

inline rect operator +  (rect r, point p)  {r.x+=p.x; r.y+=p.y; return r;}
inline rect operator -  (rect r, point p)  {r.x-=p.x; r.y-=p.y; return r;}
inline rect operator += (rect& r, point p) {r.x+=p.x; r.y+=p.y; return r;}
inline rect operator -= (rect& r, point p) {r.x-=p.x; r.y-=p.y; return r;}

inline rect operator +  (rect r, int i)    {return insetr(r,-i);}
inline rect operator -  (rect r, int i)    {return insetr(r,i);}
inline rect operator ++ (rect& r)          {return r=insetr(r,-1);}
inline rect operator -- (rect& r)          {return r=insetr(r,1);}
inline rect operator += (rect& r, int i)   {return r=insetr(r,-i);}
inline rect operator -= (rect& r, int i)   {return r=insetr(r,i);}

inline int operator == (point p1, point p2) {return equalpt(p1,p2);}
inline int operator == (rect r1, rect r2)   {return equalr(r1,r2);}
inline int operator != (point p1, point p2) {return !equalpt(p1,p2);}
inline int operator != (rect r1, rect r2)   {return !equalr(r1,r2);}

#endif /* end C++ declarations */

#endif /* Common cross-platform graphics library. */
