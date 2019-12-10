@echo off

echo ----------------------------------------------------------
echo Install and update all Microsoft redistributable libraries
echo ----------------------------------------------------------

echo:
echo Verifying appropriate Powershell is present ...
echo ---
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "[string]$PSVersionTable.PSVersion.Major + '.' + [string]$PSVersionTable.PSVersion.Minor" > psversion.txt
<psversion.txt set /p psversion=
@del psversion.txt
echo Powershell version is: %psversion%
If %psversion% LSS "5.1" (
	Powershell version is less than 5.1, cannot continue.
	pause
	Exit
)
echo Ready to go.

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/12645a911ab70f855b0b919910c86bfe67b80b42/tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '2bb3078b3d68b42351fc7a2823e788c1b8de5e8607c9c5add8e3e700df13f461') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

