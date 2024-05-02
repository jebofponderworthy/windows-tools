#Begin Script

$RemovalItems =  @(
"Microsoft.Advertising.Xaml",
"Microsoft.BingWeather",
"Microsoft.BingFinance",
"Microsoft.BingNews",
"Microsoft.BingSports",
"Microsoft.SkypeApp",
"Microsoft.WindowsCommunicationsApps",
"Microsoft.XboxGameOverlay",
"Microsoft.XboxGamingOverlay",
"Microsoft.XboxGameCallableUI",
"Microsoft.Xbox.TCUI",
"Microsoft.XboxApp",
"Microsoft.XboxSpeechToTextOverlay",
"Microsoft.XboxIdentityProvider",
"Microsoft.YourPhone",
"Microsoft.ZuneVideo",
"Microsoft.ZuneMusic",
".DiscoverHPTouchpointManager",
".HPDesktopSupportUtilities",
".HPJumpStart",
".HPPCHardwareDiagnosticsWindows",
".HPPowerManage",
".HPPrivacySettings",
".HPProgrammableKey",
".HPQuickDrop",
".myHP",
".HPSupportAssistant",
".HPSystemInformation",
".HPWorkWell",
".HPAccessoryCenter"
)

$ProvisionedItems = Get-AppxProvisionedPackage -Online
foreach ($ProvItem in $ProvisionedItems) {
	foreach ($RemItem in $RemovalItems) {
		If ($ProvItem.DisplayName -like "*$RemItem*") {
			Write-Host "Deprovisioning:" $ProvItem.DisplayName
			$error.clear()
			try {
				Remove-AppXProvisionedPackage -Online -PackageName $ProvItem.PackageName -ErrorAction SilentlyContinue | Out-Null
			}
			catch { "Failed: Microsoft does not allow, or other error." }
			if (!$error) { "Succeeded!" }
		}
	}
}

$InstalledItems = Get-AppxPackage -AllUsers
foreach ($InstItem in $InstalledItems) {
	foreach ($RemItem in $RemovalItems) {
		if ($InstItem.Name -like "*$RemItem*") {
			Write-Host "User-level removal operation:" $InstItem.Name
			$error.clear()
			try {
				Get-AppxPackage $InstItem.Name -AllUsers | Remove-AppxPackage -Allusers -ErrorAction SilentlyContinue | Out-Null
			}
			catch { "Failed: Microsoft does not allow, or other error." }
			if (!$error) { "Succeeded!" }
		}
	}
}

# End Script