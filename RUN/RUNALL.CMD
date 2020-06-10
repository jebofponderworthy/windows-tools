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
echo Downloading and running mma-appx-etc.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/mma-appx-etc.ps1') > mma-appx-etc.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\mma-appx-etc.ps1"

@del mma-appx-etc.ps1

echo:
echo Downloading and running TweakMemTCP.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/TweakMemTCP.ps1') > TweakMemTCP.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\TweakMemTCP.ps1"

@del TweakMemTCP.ps1

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\RunDevNodeClean.ps1"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/fork-of-istvans-scripts/master/removeGhosts.ps1') > wt_removeGhosts.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\wt_removeGhosts.ps1 -Force"

@del wt_removeGhosts.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\TweakNTFS.ps1"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\OWTAS.ps1"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/TOSC.ps1') > TOSC.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\TOSC.ps1"

@del TOSC.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\OVSS.ps1"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\CATE.ps1"

@del CATE.ps1

