############################################
# Active Directory / Office 365 Hard Match #
############################################


# Sets TLS version.  Necessary for some platforms.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

	Write-Progress -Activity "Hard Match" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
	# Write-Progress is not compatible with some remote shell methods.

}

Function PrepareModule {
	param( [string]$ModuleName )

	If (Get-Module -ListAvailable -Name $ModuleName)
		{ Update-Module $ModuleName }
	Else
		{ Install-Module $ModuleName }
	}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

'Preparing Powershell environment...'

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

ShowProgress("Preparing Powershell environment:","Setting up to use page provider NuGet...")
Install-PackageProvider -Name NuGet -Force | Out-Null

# This appears to set PSGallery nicely when need be
Register-PSRepository -Default -InstallationPolicy Trusted 2> $null
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

ShowProgress("Preparing Powershell environment...","Checking/preparing module NuGet...")
PrepareModule("NuGet")
ShowProgress("Preparing Powershell environment...","Checking/preparing module AzureAD...")
PrepareModule("AzureAD")

'Connect to AzureAD...'

Connect-AzureAD

''
'Turn off AZ/AD Sync...'
''

Set-ADSyncScheduler -SyncCycleEnabled $false

# $ADUPN = 'active_directory_user@companynetwork.com'
# $AzureUPN = 'azure_user@companynetwork.com'


# 'Initiating prep for hard match.'
# "Active Directory : $ADUPN"
# "Azure AD :         $AzureUPN"
# ''

Function Do-HardMatch {
	param( [string]$ADUPN, [string]$AzureUPN )
	# Active Directory UPN, $ADUPN.  In ADUC, user properties, Profile tab, 
	# the username plus the domain listed.  The domain has to be Internet-routable,
	# this does *not* have to be the primary email address of the user.
	#
	# Azure AD UPN, $AzureUPN.  This is the Office 365 login, *not* necessarily
	# the primary email address of the user.

	"Get original Azure ImmutableID for $AzureUPN ..."
	$AzureUser = Get-AzureADUser -SearchString $AzureUPN
	$OriginalAzureImmutableID = $AzureUser.ImmutableID
	"Extracted Azure ImmutableID: $OriginalAzureImmutableID"
	""
	""
	"And now extract AD GUID for $ADUPN ..."
	ldifde -f export.txt -r "(Userprincipalname=$ADUPN)" -l *
	$ADGUID = (-split (type export.txt | select-string "ObjectGUID"))[1]

	''
	"Extracted AD GUID: $ADGUID"
	""
	""
	'Set AD GUID into Azure as ImmutableID...'
	Set-AzureADuser -ObjectID $AzureUser.ObjectID -ImmutableID $ADGUID

	''
	'New Azure ImmutableID retrieved as confirmation:'
	$AzureUser = Get-AzureADUser -SearchString $AzureUPN
	$AzureUser.ImmutableID
}

''
'Finally, turn on AZ/AD Sync again...'

Set-ADSyncScheduler -SyncCycleEnabled $true

'Done!'