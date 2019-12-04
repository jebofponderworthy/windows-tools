@echo off

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/095e7315fd85ab787e7f4c69bdf6d469e53ee6ce/tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'a3999b4d40f9dd468f20d4e37ba605819f68339d7b16695cc10a82cce2b7c058') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

