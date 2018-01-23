################################
#    Turn Off Share Caching    #
#                              #
# v3.0 by Jonathan E. Brickman #
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
$netview = iex ("net view " + $env:computername + " /all")
for ($i=7; $i -lt ($netview.Count - 2); $i++)
	{
	$ShareName = $netview[$i].split(" ")[0]
	""
	"Turning off share caching for " + $ShareName
	$result = iex ("net share " + $ShareName + " /CACHE:None") -ErrorAction SilentlyContinue
	if ($result -eq $null)
		{ "Not possible." }
	else
		{ "Done." }
	}
