@echo off

echo:
echo Downloading, verifying, and running RunDevNodeClean.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/RunDevNodeClean.ps1') > RunDevNodeClean.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile RunDevNodeClean.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'aa455f0cccb371cc2edc2cb62591bc83a75eac038a224b6a19bc16a441b56d11') { iex .\RunDevNodeClean.ps1 } Else { 'Hash fail on RunDevNodeClean.ps1!' }"

@del RunDevNodeClean.ps1

echo:
echo Downloading, verifying, and running wt_removeGhosts.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/wt_removeGhosts.ps1') > wt_removeGhosts.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile wt_removeGhosts.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '2a327c2a2734b18d848558dbeadf62b3e267f280a29e9c40a3ae6c7fa73e7681') { iex .\wt_removeGhosts.ps1 } Else { 'Hash fail on wt_removeGhosts.ps1!' }"

@del wt_removeGhosts.ps1

echo:
echo Downloading, verifying, and running TweakNTFS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '5b650116d1ae92254e9c78a2f5e46d5dcc289386bf70b4abedd09fed0f84e98e') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS.ps1!' }"

@del TweakNTFS.ps1

echo:
echo Downloading, verifying, and running OWTAS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '961fc020eaca123324b2da81a77ed4d0d82f377eb998adc7f6ee9bc24fd8ffcb') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS.ps1!' }"

@del OWTAS.ps1

echo:
echo Downloading, verifying, and running TOSC.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/TOSC.ps1') > TOSC.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TOSC.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '901630fa56907849065f574d0dab34d8656d2a6c25a58b93fd67b50c0e6d396d') { iex .\TOSC.ps1 } Else { 'Hash fail on TOSC.ps1!' }"

@del TOSC.ps1

echo:
echo Downloading, verifying, and running OVSS.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '1a3e63e6b6e2c0ed545d3799e5e49520380b669a066565a2fbbd399dda1129be') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS.ps1!' }"

@del OVSS.ps1

echo:
echo Downloading, verifying, and running CATE.ps1 ...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '7cf31909bc5daa88e31dbc375b879ff6fb7100af1c6c2de88d2acd7a253ab876') { iex .\CATE.ps1 } Else { 'Hash fail on CATE.ps1!' }"

@del CATE.ps1

