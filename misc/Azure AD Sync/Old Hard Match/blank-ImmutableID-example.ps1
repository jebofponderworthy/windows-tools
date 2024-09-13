# Theoretically, this should convert an O365 user from AD-synched to unsynched.

$AzureUPN = "user_email_on_azure@domain.com"

"First connect to AzureAD:"
Connect-AzureAD

"Now set Azure ImmutableID to $null"
$AzureUser = Get-AzureADUser -SearchString $AzureUPN
Set-AzureADuser -ObjectID $AzureUPN -ImmutableID $null

