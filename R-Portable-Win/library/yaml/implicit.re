#include "yaml.h"

yaml_char_t *
find_implicit_tag(str, len)
  const yaml_char_t *str;
  size_t len;
{
  /* This bit was taken from implicit.re, which is in the Syck library.
   *
   * Copyright (C) 2003 why the lucky stiff */

  const yaml_char_t *cursor, *limit, *marker;
  cursor = str;
  limit = str + len;

/*!re2c

re2c:define:YYCTYPE  = "yaml_char_t";
re2c:define:YYCURSOR = cursor;
re2c:define:YYMARKER = marker;
re2c:define:YYLIMIT  = limit;
re2c:yyfill:enable   = 0;

NULL = [\000] ;
ANY = [\001-\377] ;
DIGIT = [0-9] ;
DIGITSC = [0-9,] ;
DIGITSP = [0-9.] ;
YEAR = DIGIT DIGIT DIGIT DIGIT ;
MON = DIGIT DIGIT ;
SIGN = [-+] ;
HEX = [0-9a-fA-F,] ;
OCT = [0-7,] ;
INTHEX = SIGN? "0x" HEX+ ; 
INTOCT = SIGN? "0" OCT+ ;
INTSIXTY = SIGN? DIGIT DIGITSC* ( ":" [0-5]? DIGIT )+ ;
INTCANON = SIGN? ( "0" | [1-9] DIGITSC* ) ;
FLOATFIX = SIGN? DIGIT DIGITSC* "." DIGITSC* ;
FLOATEXP = SIGN? DIGIT DIGITSC* "." DIGITSP* [eE] SIGN DIGIT+ ;
FLOATSIXTY = SIGN? DIGIT DIGITSC* ( ":" [0-5]? DIGIT )+ "." DIGITSC* ;
INF = ( "inf" | "Inf" | "INF" ) ;
FLOATINF = [+]? "." INF ;
FLOATNEGINF = [-] "." INF ;
FLOATNAN = "." ( "nan" | "NaN" | "NAN" ) ;
NULLTYPE = ( "~" | "null" | "Null" | "NULL" )? ;
BOOLYES = ( "y" | "Y" | "yes" | "Yes" | "YES" | "true" | "True" | "TRUE" | "on" | "On" | "ON" ) ;
BOOLNO = ( "n" | "N" | "no" | "No" | "NO" | "false" | "False" | "FALSE" | "off" | "Off" | "OFF" ) ;
INTNA = ".na.integer" ;
FLOATNA = ".na.real" ;
STRNA = ".na.character" ;
BOOLNA = ".na" ;
TIMEZ = ( "Z" | [-+] DIGIT DIGIT ( ":" DIGIT DIGIT )? ) ;
TIMEYMD = YEAR "-" MON "-" MON ;
TIMEISO = YEAR "-" MON "-" MON [Tt] MON ":" MON ":" MON ( "." DIGIT* )? TIMEZ ;
TIMESPACED = YEAR "-" MON "-" MON [ \t]+ MON ":" MON ":" MON ( "." DIGIT* )? [ \t]+ TIMEZ ;
TIMECANON = YEAR "-" MON "-" MON "T" MON ":" MON ":" MON ( "." DIGIT* [1-9]+ )? "Z" ;
MERGE = "<<" ;
DEFAULTKEY = "=" ;

NULLTYPE NULL       {   return (yaml_char_t *)"null"; }

BOOLYES NULL        {   return (yaml_char_t *)"bool#yes"; }

BOOLNO NULL         {   return (yaml_char_t *)"bool#no"; }

BOOLNA NULL         {   return (yaml_char_t *)"bool#na"; }

INTHEX NULL         {   return (yaml_char_t *)"int#hex"; }

INTOCT NULL         {   return (yaml_char_t *)"int#oct"; }

INTSIXTY NULL       {   return (yaml_char_t *)"int#base60"; }

INTNA NULL          {   return (yaml_char_t *)"int#na"; }

INTCANON NULL       {   return (yaml_char_t *)"int"; }

FLOATFIX NULL       {   return (yaml_char_t *)"float#fix"; }

FLOATEXP NULL       {   return (yaml_char_t *)"float#exp"; }

FLOATSIXTY NULL     {   return (yaml_char_t *)"float#base60"; }

FLOATINF NULL       {   return (yaml_char_t *)"float#inf"; }

FLOATNEGINF NULL    {   return (yaml_char_t *)"float#neginf"; }

FLOATNAN NULL       {   return (yaml_char_t *)"float#nan"; }

FLOATNA NULL        {   return (yaml_char_t *)"float#na"; }

TIMEYMD NULL        {   return (yaml_char_t *)"timestamp#ymd"; }

TIMEISO NULL        {   return (yaml_char_t *)"timestamp#iso8601"; }

TIMESPACED NULL     {   return (yaml_char_t *)"timestamp#spaced"; }

TIMECANON NULL      {   return (yaml_char_t *)"timestamp"; }

STRNA NULL          {   return (yaml_char_t *)"str#na"; }

DEFAULTKEY NULL     {   return (yaml_char_t *)"default"; }

MERGE NULL          {   return (yaml_char_t *)"merge"; }

ANY                 {   return (yaml_char_t *)"str"; }

*/

}
