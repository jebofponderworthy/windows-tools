@echo off

echo:
echo Downloading RunDevNodeClean.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

echo:
echo Downloading TweakNTFS.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

echo:
echo Downloading OWTAS.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/OWTAS.ps1') > OWTAS.ps1"

echo:
echo Downloading TOSC.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/TOSC.ps1') > TOSC.ps1"

echo:
echo Downloading OVSS.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/OVSS.ps1') > OVSS.ps1"

echo:
echo Downloading CATE.ps1 ...
echo --------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/CATE.ps1') > CATE.ps1"

