' ***************************************
' ******* Optimize Worker Threads *******
' ******** and Service Requests *********
' **************** 2.21 *****************
' ***************************************
' ********* Jonathan E. Brickman ********
' ********* jeb@ponderworthy.com ********
' ***************************************
' ***************************************


' ********** Set up environment *********

Option Explicit

force_cscript

Dim HKEY_LOCAL_MACHINE, strComputer, CPUarch
Dim Return
Dim AddCriticalWorkerThreads, AddDelayedWorkerThreads, DefaultWorkerThreads

HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."

' ********** Find out how much RAM is in machine *******

Dim AvailableRAM, AvailableRAMFormatted

AvailableRAM = CDbl( get_available_memory() )

AvailableRAMFormatted = FormatNumber(AvailableRAM, 2)
WScript.echo "Available RAM: " & AvailableRAMFormatted & "G"

' ******** Get ready for registry operations **********

Dim ObjRegistry, strPath, strValue

Set ObjRegistry = _
    GetObject("winmgmts:{impersonationLevel = impersonate}!\\" _
    & strComputer & "\root\default:StdRegProv")

' ********** Find out whether OS is 32-bit or 64-bit **********

' HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE
' contains either 'AMD64' or 'x86' or other, if not AMD64 presume 32-bit

' ObjRegistry.GetStringValue?...
' http://msdn.microsoft.com/en-us/library/windows/desktop/aa390788%28v=vs.85%29.aspx

strPath = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

ObjRegistry.GetSTRINGValue HKEY_LOCAL_MACHINE, strPath, "PROCESSOR_ARCHITECTURE", CPUarch

' CPUarch will be AMD64 or IA64 if 64-bit, otherwise 32-bit

' ********** Calculate values to be used **********

If CPUarch = "AMD64" or CPUarch = "IA64" Then
	AddCriticalWorkerThreads = CInt(AvailableRAM * 3)
	AddDelayedWorkerThreads = CInt(AvailableRAM * 3)
	DefaultWorkerThreads = 64
	WScript.echo "OS Bit width: " & 64
Else
	AddCriticalWorkerThreads = CInt(AvailableRAM * 6)
	AddDelayedWorkerThreads = CInt(AvailableRAM * 6)
	DefaultWorkerThreads = 64
	WScript.echo "OS Bit width: " & 32
end if


' ********** Set Additional Critical and Delayed Worker Threads ***********

strPath = "SYSTEM\CurrentControlSet\Control\Session Manager\Executive"

' Create key in case it doesn't exist yet
Return = objRegistry.CreateKey(HKEY_LOCAL_MACHINE, strPath)

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "AdditionalCriticalWorkerThreads", AddCriticalWorkerThreads
If Err <> 0 Then
	WScript.Echo "Could not set AdditionalCriticalWorkerThreads."
End If

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "AdditionalDelayedWorkerThreads", AddDelayedWorkerThreads
If Err <> 0 Then
	WScript.Echo "Could not set AdditionalDelayedWorkerThreads."
End If

WScript.echo "Additional Critical Worker Threads: " & AddCriticalWorkerThreads
WScript.echo "Additional Delayed Worker Threads: " & AddDelayedWorkerThreads

WScript.Echo ""


' ********** Set Default Number of Worker Threads ***********

strPath = "SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters"

' Create second key in case it doesn't exist yet
Return = objRegistry.CreateKey(HKEY_LOCAL_MACHINE, strPath)

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "DefaultNumberOfWorkerThreads", DefaultWorkerThreads
If Err <> 0 Then
	WScript.Echo "Could not set DefaultNumberOfWorkerThreads."
End If

WScript.echo "Default Worker Threads: " & DefaultWorkerThreads

' ********** Optimize Service Work Items and Requests *************

strPath = "SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters"

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "MaxWorkItems", 8192
If Err <> 0 Then
	WScript.Echo "Could not set MaxWorkItems."
End If

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "MaxMpxCt", 2048
If Err <> 0 Then
	WScript.Echo "Could not set MaxMpxCt."
End If

ObjRegistry.SetDWORDValue HKEY_LOCAL_MACHINE, strPath, "MaxCmds", 2048
If Err <> 0 Then
	WScript.Echo "Could not set MaxCmds."
End If

WScript.echo "RpcXdr MaxWorkItems: " & 8192
WScript.echo "RpcXdr MaxMpxCt: " & 2048
WScript.echo "RpcXdr MaxCmds: " & 2048

' ********* End! **********

Set ObjRegistry = Nothing



' ********* Subroutines **********

Function get_available_memory
	Dim objWMIService, strComputer, colSettings, objComputer

	strComputer = "."

	Set objWMIService = GetObject("winmgmts:" _
	    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

	Set colSettings = objWMIService.ExecQuery _
	    ("Select * from Win32_ComputerSystem")

	For Each objComputer in colSettings 
	    get_available_memory = CDbl(objComputer.TotalPhysicalMemory) / CDbl(1024.0) / CDbl(1024.0) / CDbl(1024.0)
	Next
	Set colSettings = Nothing
	Set objWMIService = Nothing
end Function

' the below is part of another script written by David Barrett
' Copyright 2009
' licensed under the Creative Commons
' Attribution 2.5 Licence
' http://creativecommons.org/licenses/by/2.5/ 

sub force_cscript
    dim args : args=""
    dim i, wshshell
    If right(lCase(wscript.fullname),11)= "wscript.exe" then
        for i=0 to wscript.arguments.count-1
            args = args & wscript.arguments(i) & " "
        next

        Set WshShell = CreateObject("wscript.shell")

        wshshell.run wshshell.ExpandEnvironmentStrings("%comspec%") & _
            " /c cscript.exe //nologo """ & wscript.scriptfullname & """" & args

        set wshshell=nothing

        wscript.quit
    end if
end sub


