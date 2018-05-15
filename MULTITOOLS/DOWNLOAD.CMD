@echo off

echo:
echo Downloading RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

echo:
echo Downloading TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

echo:
echo Downloading OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/OWTAS.ps1') > OWTAS.ps1"

echo:
echo Downloading TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/TOSC.ps1') > TOSC.ps1"

echo:
echo Downloading OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/OVSS.ps1') > OVSS.ps1"

echo:
echo Downloading CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc//tools/CATE.ps1') > CATE.ps1"

