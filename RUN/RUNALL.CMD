@echo off

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile RunDevNodeClean.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'c5c5684da20162dfa9950d54feecdaaf2b6230089ba3d99adc40df8f6040d3bf') { iex .\RunDevNodeClean.ps1 } Else { 'Hash fail on RunDevNodeClean.ps1!' }"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/wt_removeGhosts.ps1') > wt_removeGhosts.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile wt_removeGhosts.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'bf0ba2ce74c3579b460b22997d77192149fa732282daad17a8eba59b9b464fc3') { iex .\wt_removeGhosts.ps1 } Else { 'Hash fail on wt_removeGhosts.ps1!' }"

@del wt_removeGhosts.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'bec13099efe52e9c17e7a2453aca9ec4d773654e17412fcb782e47c39c59f127') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS.ps1!' }"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '8a6a7da84757f46a49950a693d212857a59745fa124d33a67f90df9258cbf080') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS.ps1!' }"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/TOSC.ps1') > TOSC.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TOSC.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'a2e600676b00bcda3961a697f6945dd1f21282a4c7af96d996237b7e9b0f004a') { iex .\TOSC.ps1 } Else { 'Hash fail on TOSC.ps1!' }"

@del TOSC.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '197fb56bb1befacfe01f555b3d39f3b8dc7ed32162d056944d5af10f9832f5bb') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS.ps1!' }"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '50f325eabf26fec6cca8a8afc17589f211379c1be7c64bed203e81533b2bbab9') { iex .\CATE.ps1 } Else { 'Hash fail on CATE.ps1!' }"

@del CATE.ps1

