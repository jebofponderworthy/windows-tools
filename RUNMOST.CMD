@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OWTAS.ps1') > OWTAS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OWTAS.ps1 SHA256) ; If ($certrpt[1] -eq 'e88a40327e2f2f4aea1d6257bf97af52cc2efe608e0c50b3a395f42706bffada') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS!' }"

@del OWTAS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OVSS.ps1') > OVSS.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile OVSS.ps1 SHA256) ; If ($certrpt[1] -eq 'c81c95cd0d7eb72c7773dbebf66c232dc46e0902396598ca0643c0f6195a72c9') { iex .\OVSS.ps1 } Else { 'Hash fail on OVSS!' }"

@del OVSS.ps1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.ps1') > CATE.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile CATE.ps1 SHA256) ; If ($certrpt[1] -eq '1d6e7e509d2b672771e954b4d03ede47bd913aa15dbcb470123f13f84172d98b') { iex .\CATE.ps1 } Else { 'Hash fail on CATE!' }"

@del CATE.ps1

