# This function helps when we have a user who is an indirect, effective,
# member of a group, but we don't know how the relationship obtains.

function Find-NestedGroupMember
	{
	param( [string]$Group, [string]$Username )

	"Searching for membership in $Group , by username $Username ..."

	## Find all members  in the group specified 
	$members = Get-ADGroupMember -Identity $Group
	
	foreach ($member in $members) 
		{
		if ($member.Name -eq $Username)
			{
			"Found $Username in $Group!"
			exit
			}
			
		## If any member in  that group is another group, recurse the function
		if ($member.objectClass -eq 'group')
			{
			Find-NestedGroupMember $member.Name $UserName
			}
		}
	}

Find-NestedGroupMember Group Username