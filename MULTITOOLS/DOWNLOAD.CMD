@echo off

echo:
echo Downloading RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

echo:
echo Downloading TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

echo:
echo Downloading OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/OWTAS.ps1') > OWTAS.ps1"

echo:
echo Downloading TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/TOSC.ps1') > TOSC.ps1"

echo:
echo Downloading OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/OVSS.ps1') > OVSS.ps1"

echo:
echo Downloading CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/2d0c66f40ee9d6c16e8e1ca7a72833074db85a61//tools/CATE.ps1') > CATE.ps1"

