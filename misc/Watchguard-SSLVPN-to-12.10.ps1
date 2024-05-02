"Checking for presence of Watchguard SSL VPN client..."
$test = (Get-Package | Where-Object { $_."Name" -like "WatchGuard Mobile VPN with SSL client*" })

if ($test.Length -gt 0) {
    "Found.  Downloading:"
    $URL = "https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_10/WG-MVPN-SSL_12_10.exe"
    mkdir C:\0CBT -Force -ErrorAction SilentlyContinue
    del "C:\0CBT\WG-MVPN*"
    Start-BitsTransfer -Source $URL -Destination "C:\0CBT"
    If (-not (Test-Path C:\0CBT\WG-MVPN-SSL_12_10.exe)) {
        "Download failed entirely."
        exit
        }
    "Verifying file integrity..."
    $CorrectFileHash = "B399888F952C327A35E2216BD3549E173496D1A6D781697713D508312F0A8131"
    $FileHash = (Get-FileHash "C:\0CBT\WG-MVPN-SSL_12_10.exe").Hash
    If ($FileHash -Like $CorrectFileHash) {
		taskkill /f /im wgsslvpnc.exe *> $null
        "Installing..."
        C:\0CBT\WG-MVPN-SSL_12_10.exe /silent /verysilent /NORESTART *> $null
        }
    else {
        "Download failed partially."
        exit
        }
    }
else {
    "Watchguard SSL VPN client not found."
    }
	