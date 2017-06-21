/*
 *
 *  R : A Computer Language for Statistical Data Analysis
 *  file ga.h
 *  Copyright (C) 1998--1999  Guido Masarotto
 *  Copyright (C) 2004--2008   The R Foundation
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 */

/*
   New declarations.
*/

#ifndef __GA__VERSION
#define __GA__VERSION 2.45(1)
#include "graphapp.h"

/* renamed functions */
void	gamainloop(void);
void	gabeep(void);

#define DblClick	0x0010/* added for buttons.c*/


/* windows.c */
#define Border	0x10100000L
void	app_cleanup(void);
int	ismdi(void);
int	isUnicodeWindow(control c);
int	isiconic(window w);
rect	screen_coords(control c);

/* gmenus.c */
typedef struct {
    char *nm;
    menufn fn;
    int key;
    menuitem m;
} MenuItem;

#define STARTMENU {"#STARTMENU", 0, 0}
#define ENDMENU {"#ENDMENU", 0, 0}
#define STARTSUBMENU {"#STARTSUBMENU", 0, 0}
#define ENDSUBMENU {"#ENDSUBMENU", 0, 0}
#define MDIMENU {"#MDIMENU", 0, 0}
#define LASTMENUITEM {0, 0, 0}
menu	newmdimenu(void);
typedef menu popup;
popup	newpopup(actionfn fn);
menubar gmenubar(actionfn fn, MenuItem []);
popup	gpopup(actionfn fn, MenuItem []);
void	gchangepopup(window w, popup p);
/* next is limited to current window... */
void	gchangemenubar(menubar mb);


/* tooltips.c */
int	addtooltip(control c, const char *tp);

/* status.c */
int	addstatusbar(void);
int	delstatusbar(void);
void	setstatus(const char *text);

/* dialogs.c */
void	setuserfilter(const char *);
void    askchangedir(void);
char *	askcdstring(const char *question, const char *default_string);
char *	askfilesavewithdir(const char *title, const char *default_name,
			   const char *dir);
char *  askfilenames(const char *title, const char *default_name, int multi,
		     const char *filters, int filterindex, char *strbuf,
		     int bufsize, const char *dir);
int     countFilenames(const char *strbuf); /* Note that first name is path when there are multiple names */

void	setuserfilterW(const wchar_t *);
wchar_t *askfilenameW(const char *title, const char *default_name);
wchar_t *askfilenamesW(const wchar_t *title, const wchar_t *default_name,
		       int multi,
		       const wchar_t *filters, int filterindex,
		       const wchar_t *dir);
wchar_t *askfilesaveW(const char *title, const char *default_name);



/*  rgb.c */
rgb     nametorgb(const char *colourname);
const char *  rgbtoname(rgb in);
int     rgbtonum(rgb in);
rgb     myGetSysColor(int);
rgb	dialog_bg(void);


/* clipboard.c */
void    copytoclipboard(drawing src);
int     copystringtoclipboard(const char *str);
int     getstringfromclipboard(char * str, int n);
int     clipboardhastext(void);

/* gimage.c */
image  bitmaptoimage(bitmap bm);

/* printer.c  */
typedef objptr printer;
printer newprinter(double w,  double h, const char *name);
void    nextpage(printer p);

/* metafile.c */
typedef objptr metafile;
metafile newmetafile(const char *name, double width, double height);


/* thread safe and extended  drawing functions (gdraw.c) */
#define lSolid 0
#define lDash  (5 | (4<<4))
#define lShortDash  (3 | (4<<4))
#define lLongDash  (8 | (4<<4))
#define lDot   (1 | (4<<4))
#define lDashDot (5 | (4<<4) | (1<<8) | (4<<12))
#define lShortDashDot (3 | (4<<4) | (1<<8) | (4<<12))
#define lLongDashDot (8 | (4<<4) | (1<<8) | (4<<12))
#define lDashDotDot    (5 | (4<<4) | (1<<8) | (3<<12) | (1<<16) | (4<< 20))
#define lShortDashDotDot    (3 | (4<<4) | (1<<8) | (3<<12) | (1<<16) | (4<< 20))
#define lLongDashDotDot    (8 | (4<<4) | (1<<8) | (3<<12) | (1<<16) | (4<< 20))

rect  ggetcliprect(drawing d);
void  gsetcliprect(drawing d, rect r);
void  gbitblt(bitmap db, bitmap sb, point p, rect r);
void  gscroll(drawing d, point dp, rect r);
void  ginvert(drawing d, rect r);
rgb   ggetpixel(drawing d, point p);
void  gsetpixel(drawing d, point p, rgb c);
void  gdrawline(drawing d, int width, int style, rgb c, point p1, point p2,
		int fast, int lend, int ljoin, float lmitre);
void  gdrawrect(drawing d, int width, int style, rgb c, rect r, int fast,
		int lend, int ljoin, float lmitre);
void  gfillrect(drawing d, rgb fill, rect r);
void  gcopy(drawing d, drawing d2, rect r);
void  gcopyalpha(drawing d, drawing d2, rect r, int alpha);
void  gcopyalpha2(drawing d, image src, rect r);
void  gdrawellipse(drawing d, int width, rgb border, rect r, int fast,
		   int lend, int ljoin, float lmitre);
void  gfillellipse(drawing d, rgb fill, rect r);
void  gdrawpolyline(drawing d, int width, int style, rgb c,
		    point *p, int n, int closepath, int fast,
		    int lend, int ljoin, float lmitre);
#define gdrawpolygon(d,w,s,c,p,n,f,e,j,m) gdrawpolyline(d,w,s,c,p,n,1,f,e,j,m)
void  gsetpolyfillmode(drawing d, int oddeven);
void  gfillpolygon(drawing d, rgb fill, point *p, int n);
void  gfillpolypolygon(drawing d, rgb fill, point *p, int npoly, int *nper);
void  gdrawimage(drawing d, image img, rect dr, rect sr);
void  gmaskimage(drawing d, image img, rect dr, rect sr, image mask);
int   gdrawstr(drawing d, font f, rgb c, point p, const char *s);
void  gdrawstr1(drawing d, font f, rgb c, point p, const char *s, double hadj);
rect  gstrrect(drawing d, font f, const char *s);
point gstrsize(drawing d, font f, const char *s);
int   gstrwidth(drawing d ,font f, const char *s);
void  gcharmetric(drawing d, font f, int c, int *ascent, int *descent,
		  int *width);
font  gnewfont(drawing d, const char *face, int style, int size,
	       double rot, int usePoints);
font  gnewfont2(drawing d, const char *face, int style, int size,
		double rot, int usePoints, int quality);
int   ghasfixedwidth(font f);
field newfield_no_border(const char *text, rect r);

int gdrawwcs(drawing d, font f, rgb c, point p, const wchar_t *s);
int gwcswidth(drawing d, font f, const wchar_t *s);

void gwcharmetric(drawing d, font f, int c, int *ascent, int *descent,
		  int *width);
void gwdrawstr1(drawing d, font f, rgb c, point p, const wchar_t *s, int cnt,
		double hadj);
int   gstrwidth1(drawing d ,font f, const char *s, int enc);

/* pixels */
int   devicewidth(drawing dev);
int   deviceheight(drawing dev);
/* mm */
int   devicewidthmm(drawing dev);
int   deviceheightmm(drawing dev);
/* pixels per inch */
int   devicepixelsx(drawing dev);
int   devicepixelsy(drawing dev);

int	isTopmost(window w);
void	BringToTop(window w, int stay); /* stay=0 for regular, 1 for topmost, 2 for toggle */
void *	getHandle(window w);
void 	GA_msgWindow(window c, int type);


/* gbuttons.c */
/* horizontal, vertical and control scrollbar */
#define HWINSB 0
#define VWINSB 1
#define CONTROLSB 2
void	gchangescrollbar(scrollbar sb, int which, int where, int max,
			 int pagesize, int disablenoscroll);
void	gsetcursor(drawing d, cursor c);
control newtoolbar(int height);
button  newtoolbutton(image img, rect r, actionfn fn);
void	scrolltext(textbox c, int lines);
int	ggetkeystate(void);

void	scrollcaret(textbox c, int lines);
void    gsetmodified(textbox c, int modified);
int     ggetmodified(textbox c);
int getlinelength(textbox c);
void getcurrentline(textbox c, char *line, int length);
void getseltext(textbox c, char *text);
void setlimittext(textbox t, long limit);
long getlimittext(textbox t);
void checklimittext(textbox t, long n);
long getpastelength(void);
void textselectionex(control obj, long *start, long *end);
void selecttextex(control obj, long start, long end);

void finddialog(textbox t);
void replacedialog(textbox t);
int modeless_active(void);


/* menus.c */
void	remove_menu_item(menuitem obj);

/* events.c */
void toolbar_show(void);
void toolbar_hide(void);

#endif /* __GA__VERSION */
