################################
#    Turn Off Share Caching    #
#                              #
# v2.0 by Jonathan E. Brickman #
################################

"
"TOSC: Turn Off Share Caching"
""

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

# Get it done.

Get-SMBShare | ForEach { 
    $ShareName = $_.Name
    If ($ShareName -eq "print$") 
        { 
        "Setting caching to 'Programs' for: " + $ShareName
        Try {
            Set-SMBShare -Name $ShareName -CachingMode Programs -Confirm:$False -ErrorAction Stop
            }
        Catch {
            "    Error for " + $ShareName
            }
        }
    Else 
        {
        "Setting no caching for: " + $ShareName
            Try {
                Set-SMBShare -Name $ShareName -CachingMode None -Confirm:$False -ErrorAction Stop
                }
            Catch 
                {
                "    Not possible for " + $ShareName
                }
        }
    }
