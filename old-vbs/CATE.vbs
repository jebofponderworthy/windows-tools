'
' Clean All Temp Etc.
'
' version 5.26
'
' by Jonathan Brickman, a substantial rewrite and 
' enhancement of a core originally written by David Barrett
' with contributions by Frank Voss
'
' last mod 2017-11-17
' Fixed AppData\Local\Temp\1 folder preservation.
'
' Current code (c) 2017 Jonathan E. Brickman
' licensed under the 3-Clause BSD License
' please see the bottom of this file for the full text
'
' Core originally written by David Barrett
' Copyright 2009
' http://www.cedit.biz/ 
' The original code was licensed under the Creative Commons
' Attribution 2.5 Licence
' http://creativecommons.org/licenses/by/2.5/ 
'
' You are free to use it for both personal and
' commercial purposes, so long as full attribution
' is given to the author (David Barrett).
'
' This notice must not be removed
'
' 

' ForceCScript makes sure that this runs with CScript, not WScript.

Function ForceCScript()
On Error Resume Next
WScript.StdErr.Write(Chr(7))
If Err.Number <> 0 Then
    Err.Clear
    On Error GoTo 0
    set WshSh=WScript.CreateObject("WScript.Shell")
    sh=WshSh.ExpandEnvironmentStrings("%COMSPEC%")
    If InStr(sh,"%") = 1 Then sh="cmd.exe"
    WshSh.Run(sh & " /C cscript /nologo """&WScript.ScriptFullName&"""")
    WScript.Quit()
End If
End Function

call ForceCScript()

' Self-elevation to administrator.  Code derived from Ken posting at kellestine.com.
' No further contact info known for Ken!

'Checks if the script is running elevated (UAC)
function isElevated

  Set shell = CreateObject("WScript.Shell")
  Set whoami = shell.Exec("whoami /groups")
  Set whoamiOutput = whoami.StdOut
  strWhoamiOutput = whoamiOutput.ReadAll
 
  If InStr(1, strWhoamiOutput, "S-1-16-12288", vbTextCompare) Then 
    isElevated = True
  Else
      isElevated = False
  End If

  ' Clean up, just in case
  Set shell = Nothing
  Set whoami = Nothing
  Set whoamiOutput = Nothing

end function

'Re-runs the process prompting for priv elevation on re-run
sub uacPrompt
  
  interpreter = "cscript.exe"
 
  'Start a new instance with an elevation prompt first
  Set shellApp = CreateObject("Shell.Application")
  shellApp.ShellExecute interpreter, Chr(34) & WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
 
  'End the non-elevated instance
  WScript.Quit

end sub

'Make sure we are running elevated, prompt if not
if not isElevated Then uacPrompt

dim objWSH, objFSO, sysDrv
dim initialFreeSpace
dim strComputer
dim objRegistry
dim strKeyPath, objSubKey, arrSubkeys, strValueName
dim sProfile
dim sTemp, sTmp, sWindows, sLocalAppData, sProgramData, sWER, sDotNetItem
dim profileQty, profileCount

wscript.echo "CleanAllTemp"
wscript.echo ""
wscript.echo "originally by David Barrett"
wscript.echo "updated and modded substantially by Jonathan E. Brickman"
wscript.echo ""
wscript.echo "Cleans all profiles' temp and IE cache folders"
wscript.echo "A whole subfolder deletion is indicated by \"
wscript.echo "A file deletion is indicated by ,"
wscript.echo "A whole subfolder deletion failure is indicated by X"
wscript.echo "A file deletion failure is indicated by x"
wscript.echo ""

set objFSO = CreateObject("Scripting.FileSystemObject")
set objWSH = CreateObject("WScript.Shell")
set sysDrv = objFSO.GetDrive(objFSO.GetDriveName(objWSH.ExpandEnvironmentStrings("%SystemDrive%")))

sTemp = objWSH.ExpandEnvironmentStrings("%TEMP%")
sTmp = objWSH.ExpandEnvironmentStrings("%TMP%")
sWindows = objWSH.ExpandEnvironmentStrings("%SystemRoot%")
sLocalAppData = objWSH.ExpandEnvironmentStrings("%LOCALAPPDATA%")
sProgramData = objWSH.ExpandEnvironmentStrings("%ProgramData%") 
If sProgramData <> "" Then
	sWER = objWSH.ExpandEnvironmentStrings("%ProgramData%") & "\Microsoft\Windows\WER\ReportQueue"
Else
	sWER = ""
End If

' Get current free space on system drive
initialFreeSpace = CDbl(sysDrv.FreeSpace)

Const HKEY_LOCAL_MACHINE = &H80000002

strComputer = "."
 
Set objRegistry=GetObject("winmgmts:\\" & _ 
    strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
objRegistry.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubkeys
profileQty = uBound(arrSubkeys) + 1
profileCount = 1
 
For Each objSubkey In arrSubkeys

	strValueName = "ProfileImagePath"
	strSubPath = strKeyPath & "\" & objSubkey
	objRegistry.GetExpandedStringValue HKEY_LOCAL_MACHINE,strSubPath,strValueName,sProfile

	wscript.echo "Cleaning profile folder " & profileCount & " of " & profileQty & " : " & sProfile

	DeleteFolderContents sProfile & "\Local Settings\Temp"

	DeleteFolderContents sProfile & "\Local Settings\Temporary Internet Files"

	DeleteFolderContents sProfile & "\AppData\Local\Microsoft\Windows\Temporary Internet Files"

	DeleteFolderContents sProfile & "\AppData\Local\Google\Chrome\User Data\Default\Cache"

	' Windows 8 and 8.1
	DeleteFolderContents sProfile & "\AppData\Local\Microsoft\Windows\INetCache\IE"

	' Windows 10
	DeleteFolderContents sProfile & "\AppData\Local\Microsoft\Windows\INetCache\Low\Content.IE5"
	DeleteFolderContents sProfile & "\AppData\Local\Microsoft\Windows\INetCache\Low\Flash"
	DeleteFolderContents sProfile & "\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook"

	If objFSO.FolderExists(sProfile & "\AppData\Local\Temp") Then
		DeleteFolderContents sProfile & "\AppData\Local\Temp"
		If Not objFSO.FolderExists(sProfile & "\AppData\Local\Temp\Low") Then
			objFSO.CreateFolder(sProfile & "\AppData\Local\Temp\Low")
		End If
		If Not objFSO.FolderExists(sProfile & "\AppData\Local\Temp\1") Then
			objFSO.CreateFolder(sProfile & "\AppData\Local\Temp\1")
		End If
		objWSH.Run "icacls " & sProfile & "\Appdata\Local\Temp\Low /setintegritylevel low", 0
		objWSH.Run "icacls " & sProfile & "\Appdata\Local\Temp\1 /setintegritylevel low", 0
	End If

	DeleteFolderContents sProfile & "\Application Data\Local\Microsoft\Windows\WER"

	DeleteFolderContents sProfile & "\Application Data\Adobe\Flash Player\AssetCache"

	DeleteFolderContents sProfile & "\Application Data\Sun\Java\Deployment\cache"

	DeleteFolderContents sProfile & "\Application Data\Microsoft\CryptnetUrlCache"

	profileCount = profileCount + 1

Next

' Now empty certain folders in %SystemRoot%

wscript.echo "Processing folder: " & sWindows & "\Temp"
DeleteFolderContents sWindows & "\Temp"

wscript.echo "Processing folder: " & sWindows & "\system32\wbem\Logs"
DeleteFolderContents sWindows & "\system32\wbem\Logs"

wscript.echo "Processing folder: " & sWindows & "\Debug"
DeleteFolderContents sWindows & "\Debug"

wscript.echo "Processing folder: " & sWindows & "\PCHEALTH\ERRORREP\UserDumps"
DeleteFolderContents sWindows & "\PCHEALTH\ERRORREP\UserDumps"

' And ditto the system-wide Windows Error Reporting queue, if it exists.
If sWER <> "" Then
	wscript.echo "Processing folder: " & sWER
	DeleteFolderContents sWER
End If

' Delete select log files.  These become extremely fragmented over time.
wscript.echo "Processing folder: " & sWindows & "\system32\Logfiles"
DeleteSubfolderFiles sWindows & "\system32\Logfiles"
wscript.echo "Processing files: " & sWindows & "\Logs\CBS\*.log"
DeleteFileGlob sWindows & "\Logs\CBS\*.log"
wscript.echo "Processing files: " & sWindows & "\Logs\DISM\*.log"
DeleteFileGlob sWindows & "\Logs\DISM\*.log"
wscript.echo "Processing files: " & sWindows & "\inf\*.log"
DeleteFileGlob sWindows & "\inf\*.log"

' Delete all *.pf in Prefetch
wscript.echo "Processing files: " & sWindows & "\Prefetch\*.pf"
DeleteFileGlob sWindows & "\Prefetch\*.pf"

wscript.Echo ""
WScript.echo "Freed " & CLng( CDbl(CDbl(sysDrv.FreeSpace) - CDbl(initialFreeSpace))/CDbl(1024*1024)) & " megabytes."

Set sysDrv = Nothing
Set objWsH = Nothing
Set objFSO = Nothing
Set objRegistry = Nothing

' ---------------------- Subroutines -------------------

sub DeleteFolderContents(strFolder)
    ' Deletes all files and folders within the given folder
    dim objFolder, objFile, objSubFolder, doCRLF
    on error resume next
    
    ' Just exit if the named folder doesn't exist on this system
    If Not objFSO.FolderExists(strFolder) Then
	Exit Sub
    End If

    doCRLF = 0
    set objFolder=objFSO.GetFolder(strFolder)

    if Err.Number<>0 then
        Err.Clear
	set objFolder = Nothing
        Exit Sub ' Couldn't get a handle to the folder, so can't do anything
    end if
    for each objSubFolder in objFolder.SubFolders
        objSubFolder.Delete true
        if Err.Number<>0 then
	    'Could not delete whole folder
	    wscript.stdout.write "X"
            'Try recursive, delete everything inside, 
	    'ensuring as complete an overall result as possible
	    'do NOT do CRLF after this sub iteration ends
    	    doCRLF = 0
            Err.Clear
            DeleteFolderContents(strFolder & "\" & objSubFolder.Name)
	else
	    wscript.stdout.write "\"
	    doCRLF = 1
        end if
    next
    for each objFile in ObjFolder.Files
        objFile.Delete true
        if Err.Number<>0 then
		wscript.stdout.write "x"
	        doCRLF = 1
		Err.Clear ' In case we couldn't delete a file
	else
		wscript.stdout.write ","
	        doCRLF = 1
	end if
    next

    Set objFolder = Nothing

    if doCRLF > 0 then
	wscript.stdout.write vbCRLF
    end if
end sub

sub DeleteSubfolderFiles(strFolder)
    ' Deletes all files only, within subfolders of the current folder
    dim objFolder, objFile, objSubFolder, doCRLF
    on error resume next

    doCRLF = 0

    set objFolder=objFSO.GetFolder(strFolder)

    if Err.Number<>0 then
        Err.Clear
	set objFolder = Nothing
        Exit Sub ' Couldn't get a handle to the folder, so can't do anything
    end if

    for each objSubFolder in objFolder.SubFolders
	for each objFile in objSubFolder.Files
		objFile.Delete true
                if Err.Number<>0 then 
			wscript.stdout.write "x"
			doCRLF = 1
			Err.Clear ' In case we couldn't delete a file
		else
			wscript.stdout.write ","
	        	doCRLF = 1
		end if
	next
    next

    Set objFolder = Nothing

    if doCRLF > 0 then
	wscript.stdout.write vbCRLF
    end if
end sub

sub DeleteFileGlob(strGlob)
	' Deletes all files only as described by strGlob
	' Globbing is possible but extremely cody and slow
	' in vbscript, so we will use CMD.  This does mean
	' no progress characters when we use this function.
	dim objWSH2
	set objWSH2 = CreateObject("WScript.Shell")

	objWSH2.run "CMD.EXE /C DEL /Q """ & strGlob & """ > NUL", 0, true

	set objWSH2 = Nothing
end sub

' This code licensed under The 3-Clause BSD License:
' 
' SPDX short identifier: BSD-3-Clause
' 
' Note: This license has also been called the “New BSD License” 
' or “Modified BSD License”. See also the 2-clause BSD License.
' 
' Copyright
' 
' Redistribution and use in source and binary forms, with or 
' without modification, are permitted provided that the 
' following conditions are met:
' 
' 1. Redistributions of source code must retain the above 
' copyright notice, this list of conditions and the following disclaimer.
' 
' 2. Redistributions in binary form must reproduce the above 
' copyright notice, this list of conditions and the following disclaimer 
' in the documentation and/or other materials provided with the distribution.
' 
' 3. Neither the name of the copyright holder nor the names of its 
' contributors may be used to endorse or promote products derived 
' from this software without specific prior written permission.
' 
' THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
' “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
' LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
' FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
' COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
' INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
' BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
' CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
' LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
' ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
' POSSIBILITY OF SUCH DAMAGE.
