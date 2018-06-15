'' convert commas to dots
'' based on code by Ekkehard Horner

Option Explicit

WScript.Quit miniTr()

Function miniTr()
   Dim sSearch  : sSearch  = ","
   Dim sReplace : sReplace = "."
   Do Until WScript.StdIn.AtEndOfStream
      Dim sInpChr : sInpChr = WScript.StdIn.Read( 1 )
      Dim sOutChr : sOutChr = sInpChr
      Dim nPos    : nPos    = InStr( sSearch, sInpChr )
      If 0 < nPos Then
         sOutChr = Mid( sReplace, nPos, 1 )
      End If
      WScript.StdOut.Write sOutChr
   Loop
   miniTr = 0
End Function
