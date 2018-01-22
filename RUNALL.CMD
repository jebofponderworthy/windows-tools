@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256) ; If ($certrpt[1] -eq 'a7b2b98ea74075f8b10c32e0783c2a71ec9937a73398b329b747f3acfbf30cb0') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS!' }"

@del OWTAS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/TOSC.ps1') > TOSC.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile TOSC.ps1 SHA256) ; If ($certrpt[1] -eq '81f05fb4e0c34817510fd717aaa3d676cb4409a80365fba6f8fd8da6b1abf01c') { iex .\TOSC.ps1 } Else { 'Hash fail on TOSC!' }"

@del TOSC.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256) ; If ($certrpt[1] -eq '974d5b8f9a3213fe42b8851087287119fe914f72ea83a2a5499e5a25c5c67823') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS!' }"

@del OVSS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256) ; If ($certrpt[1] -eq '351f860345c45d88014517f4e0d1eec33d9ff71dec1307ef5d462d825626877c') { iex .\CATE.ps1 } Else { 'Hash fail on CATE!' }"

@del CATE.ps1

