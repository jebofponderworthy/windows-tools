@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/OWTAS.ps1') > OWTAS.ps1"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "If ((Get-FileHash 'OWTAS.ps1').Hash = '741BB611869715AD3793FAFDF3C27A323A7A89F2BB4C86717161EB10A64230AD') { iex .\OWTAS.ps1 } Else { 'Hash fail on OWTAS!' }"
del OWTAS.ps1
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.ps1') > CATE.ps1"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "If ((Get-FileHash 'CATE.ps1').Hash = 'F959C11ABA8524A307243604AB08D23CC63EED630A29AE52A3019F745BC4E3D5') { iex .\CATE.ps1 } Else { 'Hash fail on CATE!' }"
del CATE.ps1
