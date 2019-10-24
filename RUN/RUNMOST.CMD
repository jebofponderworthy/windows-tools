@echo off

echo:
echo Downloading, verifying, and running Win10Perf.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/Win10Perf.ps1') > Win10Perf.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile Win10Perf.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '200733ada474e147dba78cabd5eecb182b143ece2bbf4720ede968717c7e3861') { iex .\Win10Perf.ps1 } Else { 'Hash fail on Win10Perf.ps1!' }"

@del Win10Perf.ps1

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile RunDevNodeClean.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '3d418c81dbf9a342b42b6f3b429b86a6d07b1a44af43b69be9f24cfc53899ddf') { iex .\RunDevNodeClean.ps1 } Else { 'Hash fail on RunDevNodeClean.ps1!' }"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/wt_removeGhosts.ps1') > wt_removeGhosts.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile wt_removeGhosts.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '4120469ec965266dfe309a0401c5a247b8d1130d029ad7f7e3665f28fe252648') { iex .\wt_removeGhosts.ps1 } Else { 'Hash fail on wt_removeGhosts.ps1!' }"

@del wt_removeGhosts.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '22e9bcac6228de97a04658eb10de06f8b59d929c989ec0ab221d4e9736bb1b03') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS.ps1!' }"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '4b2e8a0c0e73152f8ee9089428fe079299a125410a27d2d68185a922f39a650f') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS.ps1!' }"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '560fec0f94e5a1e9ce53f4971ad0c9b71fe233006d898175ec4d29d7f569a7fb') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS.ps1!' }"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/4c323b8da18ff484efda30b58153e770960bd856/tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'a8e2be322c5fdb1cb5b8358b8ff838b430ec14285623db2a7492c15732df292a') { iex .\CATE.ps1 } Else { 'Hash fail on CATE.ps1!' }"

@del CATE.ps1

