REM ********************************
REM *    Turn Off Share Caching    *
REM *                              *
REM * v1.0 by Jonathan E. Brickman *
REM ********************************

Wscript.echo "TOSC: Turn Off Share Caching"
Wscript.echo "v1.0"
Wscript.echo "Remember to run this as administrator!"
Wscript.echo ""

Dim strComputer, objWMIService, colShares, WshShell, retval

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colShares = objWMIService.ExecQuery("Select * from Win32_Share")

Set WshShell = WScript.CreateObject("WScript.Shell")

For each objShare in colShares
	' Skip the dollar shares
	If Right(objShare.Name, 1) <> "$" Then
		retval = WshShell.Run("net share " & objShare.Name & " /CACHE:None", 7, True)
		If retval <> 0 Then
			Wscript.Echo "Error for share: " & objShare.Name
		Else
			Wscript.Echo "Turned caching off for share: " & objShare.Name 
		End If
	End If
Next

Set WshShell = Nothing
Set colShares = Nothing
Set objWMIService = Nothing
