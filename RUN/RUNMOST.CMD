@echo off

echo:
echo Downloading, verifying, and running Win10perf.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/Win10perf.ps1') > Win10perf.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile Win10perf.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'CertUtil:Thevolumeforafilehasbeenexternallyalteredsothattheopenedfileisnolongervalid.') { iex .\Win10perf.ps1 } Else { 'Hash fail on Win10perf.ps1!' }"

@del Win10perf.ps1

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile RunDevNodeClean.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'd6501e77f5545ebefef12f0252d8c549c9783788fd804026bb5d119d0b184b6d') { iex .\RunDevNodeClean.ps1 } Else { 'Hash fail on RunDevNodeClean.ps1!' }"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/wt_removeGhosts.ps1') > wt_removeGhosts.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile wt_removeGhosts.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '08ffd1fa100da3ddedafee07509b5a91f93faa121172766fdad06d654a69abfc') { iex .\wt_removeGhosts.ps1 } Else { 'Hash fail on wt_removeGhosts.ps1!' }"

@del wt_removeGhosts.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '34ccc49e51db6df3b9bc2548bf34efe0486760d101e8aea4573153fcc0a63d97') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS.ps1!' }"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '1293a81430c7e06a1d6ffce8278c5deddb5ea9d8aee005d73de4e4ac39cc2a7f') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS.ps1!' }"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '65b3a25cceb9bc85b54cbdee021ee8cd271d2c7ab740cb0d23300f9d8db3346b') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS.ps1!' }"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/21370ad0e7d367aac1e619620d188a073978a542/tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'cb14b9a3989a9aeb6dc872f0d9b1f432758412511624807f187444f378e42712') { iex .\CATE.ps1 } Else { 'Hash fail on CATE.ps1!' }"

@del CATE.ps1

