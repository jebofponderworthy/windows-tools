@echo off

echo:
echo Verifying appropriate Powershell is present ...
echo ---
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "[string]$PSVersionTable.PSVersion.Major + '.' + [string]$PSVersionTable.PSVersion.Minor" > psversion.txt
<psversion.txt set /p psversion=
@del psversion.txt
echo Powershell version is: %psversion%
If %psversion% LSS "3.0" (
	Powershell version is less than 3.0, cannot continue.
	pause
	Exit
)
echo Ready to go.

echo:
echo Running mma-appx-etc.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\mma-appx-etc.ps1"
@del mma-appx-etc.ps1

echo:
echo Running TweakMemTCP.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\TweakMemTCP.ps1"
@del TweakMemTCP.ps1

echo:
echo Running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\RunDevNodeClean.ps1"
@del RunDevNodeClean.ps1

echo:
echo Running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\wt_removeGhosts.ps1"
@del wt_removeGhosts.ps1

echo:
echo Running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\TweakNTFS.ps1"
@del TweakNTFS.ps1

echo:
echo Running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\OWTAS.ps1"
@del OWTAS.ps1

If "%1"=="-KEEPSHARECACHING" GOTO KEEPSHARECACHING

echo:
echo Running TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\TOSC.ps1"
@del TOSC.ps1

:KEEPSHARECACHING

echo:
echo Running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\OVSS.ps1"
@del OVSS.ps1

echo:
echo Running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex .\CATE.ps1"
@del CATE.ps1

