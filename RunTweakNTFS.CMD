@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/TweakNTFS.ps1') > TweakNTFS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '1d39c04d609ea7ff67ed67c653322b85a51432bbf327a7c67a6269209e522896') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS!' }"

REM @del TweakNTFS.ps1
