@echo off

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/06bbd155322db73d9257a0ed07a14cdb7bff8770//tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '637be685eea83fbba9347173b2fd73f098c85e4012140042983a5f8c519c7c67') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

