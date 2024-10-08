############################################
# Active Directory / Office 365 Hard Match #
############################################

# Now using MSOnline module due to Microsoft changes

$ADUPN = 'ad_username@domain.com'
$AzureUPN = 'azure_username@domain.com'

'############################################'
'# Active Directory / Office 365 Hard Match #'
'############################################'
''

'Initiating prep for hard match.'
"Active Directory : $ADUPN"
"Azure AD :         $AzureUPN"
''

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

''
'Setting up hard match...'
''

'Update MSOnline module and connect to Azure:'
PrepareModule MSOnline
Connect-MsolService

''
'Turn off AZ/AD Sync...'
''

Set-ADSyncScheduler -SyncCycleEnabled $false

"Now get original Azure ImmutableID for $AzureUPN ..."
$AzureUser = Get-Msoluser -UserPrincipalName $AzureUPN
$OriginalAzureImmutableID = $AzureUser.ImmutableID
"Extracted Azure ImmutableID: $OriginalAzureImmutableID"
""
""
"And now extract AD GUID for $ADUPN ..."
$OriginalADGUID = (Get-ADUser username | fl objectGuid)
$ADGUID = [Convert]::ToBase64String([guid]::New($OriginalADGUID).ToByteArray())

''
"Extracted and converted AD GUID: $ADGUID"
""
""
'Set AD GUID as Azure ImmutableID...'
Set-MsolUser -UserPrincipalName $AzureUser.ObjectID -ImmutableID $ADGUID

''
'New Azure ImmutableID retrieved as confirmation:'
$AzureUser = Get-MsolUser -UserPrincipalName $AzureUPN
$AzureUser.ImmutableID

''
'Finally, turn on AZ/AD Sync again...'

Set-ADSyncScheduler -SyncCycleEnabled $true

'Done!'