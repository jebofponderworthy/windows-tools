@echo off

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/5392b0fc2ac013802f14aa54430e2e635f9df99a/tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '6d539ef6744774b4366ca9c93a4383526ebf2b2886ce8d8eb74d46b6f79ab2b7') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

