

# This script originally written by Daniel Burrowes
# 2016-09-21
# https://blog.danielburrowes.com/2016/10/powershell-download-and-install-java-8.html

# Downloads the Java installer and installs silently

# -------------------------------------------------------------------------- 

# -Verbose and -Debug

    [CmdletBinding()]
    param(    )

# --------------------------------------------------------------------------

Write-Verbose "Setting Global Variables..."
$InstallDir = "c:\Install\Java"
$Source = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=211996"
$Destination = "$InstallDir\java.exe"
$Options = "$InstallDir\java_options.txt"


#Create install directory
Write-Verbose "Creating Install Directory"
New-Item -Path $InstallDir -ItemType directory -Force

Write-Verbose "Downloading Software..."
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile($Source, $Destination)
Write-Verbose "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)" 

Write-Verbose "Creating Installer Options File..."
$text = 'INSTALL_SILENT=Enable
AUTO_UPDATE=Enable
REBOOT=Disable
SPONSORS=Disable
REMOVEOUTOFDATEJRES=Enable
'

# Create file
$text | Set-Content $Options

#Running the installer
Write-Verbose "Executing Java Install.."
Start-Process -FilePath $Destination -ArgumentList "INSTALLCFG=$Options /s /L $InstallDir\jre-install.log" -Wait -Verbose -PassThru
