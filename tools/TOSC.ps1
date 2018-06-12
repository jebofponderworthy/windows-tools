################################
#    Turn Off Share Caching    #
#                              #
# v3.2 by Jonathan E. Brickman #
################################

''
'TOSC: Turn Off Share Caching'
''

# Self-elevate if not already elevated.

if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {    
    "Running elevated; good."
    ""
    }
else {
    "Not running as elevated.  Starting elevated shell." 
    Start-Process powershell -WorkingDirectory $PSScriptRoot -Verb runAs -ArgumentList "-noprofile -noexit -file $PSCommandPath" 
    return "Done. This one will now exit."
    ""
    }

# Get list of shares with 'net view', parse, and set appropriately.
get-WmiObject -class Win32_Share | foreach {
	if ( $_.Name -ne 'IPC$' ) {
		""
		"Turning off share caching for " + $_.Name
		$result = iex ('net share "' + $_.Name + '" /CACHE:None') -ErrorAction SilentlyContinue
		if ($result -eq $null)
			{ "Not possible." }
		else
			{ "Done." }
		}
	}






