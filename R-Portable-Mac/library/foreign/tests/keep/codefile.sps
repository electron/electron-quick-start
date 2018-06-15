SET DECIMAL=DOT.

DATA LIST FILE= "datafile.dat"  free (",")
ENCODING="Locale"
/ X1 X2 * X3 (A8) 
  .

VARIABLE LABELS
X1 "X1" 
 X2 "X2" 
 X3 "X3" 
 .
VARIABLE LEVEL X1, X2 
 (scale).

EXECUTE.
