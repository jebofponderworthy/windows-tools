@echo off

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/e2f8388143cece2117aade126c23e178b07b5980/tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '8a2a79662719dc35b8b1a338d32cba761d85b3881a12c678dd66f8e5fc32018b') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

