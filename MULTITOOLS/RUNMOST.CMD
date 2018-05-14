@echo off

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo --------------------------------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile RunDevNodeClean.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'd9aeff69c52232c5c68ba89c1d7b8baa2aec9f4897f14bb1d1af9642c69d6c0b') { iex .\RunDevNodeClean.ps1 } Else { 'Hash fail on RunDevNodeClean.ps1!' }"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo --------------------------------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'ae61337d69ebc8ed4666962c4d65574efb47df794b667a99c8d76bb7474deaa0') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS.ps1!' }"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo --------------------------------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '0226bd0dbe0631005dc382f8e4fb10abddee6dd8b80bfe870fd0e3fede52f720') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS.ps1!' }"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo --------------------------------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '974d5b8f9a3213fe42b8851087287119fe914f72ea83a2a5499e5a25c5c67823') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS.ps1!' }"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo --------------------------------------------
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b644ee4a0bb136e05ea38a5be6e7e37fbd061d7f//tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '74fbc88a992fe72722aa76ca68cbedad1aa36b72ddea43841e16d4855d911874') { iex .\CATE.ps1 } Else { 'Hash fail on CATE.ps1!' }"

@del CATE.ps1

