@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'a7b2b98ea74075f8b10c32e0783c2a71ec9937a73398b329b747f3acfbf30cb0') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS!' }"

@del OWTAS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/TOSC.ps1') > TOSC.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TOSC.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'b844d23fda260656b9a2541bd3cda2672e5d0e57eae8f56ea1a9d21a8359b49c') { iex .\TOSC.ps1 } Else { 'Hash fail on TOSC!' }"

REM @del TOSC.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '974d5b8f9a3213fe42b8851087287119fe914f72ea83a2a5499e5a25c5c67823') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS!' }"

@del OVSS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '351f860345c45d88014517f4e0d1eec33d9ff71dec1307ef5d462d825626877c') { iex .\CATE.ps1 } Else { 'Hash fail on CATE!' }"

@del CATE.ps1

