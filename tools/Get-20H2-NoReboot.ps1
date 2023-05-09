[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Executionpolicy RemoteSigned -Scope Process -Force
Install-PackageProvider -Name NuGet -Force -ErrorAction 'SilentlyContinue' > $null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
If (Get-InstalledModule -Name PsWindowsUpdate -ErrorAction 'SilentlyContinue') {
	Update-Module -Name PSWindowsUpdate -Force
} Else {
	Install-Module -Name PSWindowsUpdate -Force
}
Import-Module PSWindowsUpdate

powershell Get-WindowsUpdate

powershell Install-WindowsUpdate -AcceptAll -AutoReboot
