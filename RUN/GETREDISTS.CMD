@echo off

echo:
echo Processing...
echo ---
echo:
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString('https://raw.githubusercontent.com/jebofponderworthy/windows-tools/d7baf14b98a1e6671139520a16e23d6258b2f710//tools/GetRedists.ps1') > GetRedists.ps1"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"$certrpt = (certutil -hashfile GetRedists.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq '8d1b8a5cb1571e5436188c5374344e6c6ab858c832fca7b0d6b8b5f8e4ed55cd') { iex .\GetRedists.ps1 } Else { 'Hash fail on GetRedists.ps1!' }"

@del GetRedists.ps1

