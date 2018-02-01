#####################################
# TweakNTFS: Tweak All NTFS Volumes #
#   for Performance And Reliability #
#####################################
#         presumes ample RAM!       #


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


"Tweaks for all drives..."
$output = iex ('fsutil 8dot3name set 1') -ErrorAction SilentlyContinue
$output = iex ('fsutil behavior set disablelastaccess 1') -ErrorAction SilentlyContinue

Get-Volume | ForEach {
    If ($_.FileSystem -eq "NTFS")
        {
        $DriveLetter = $_.DriveLetter

        If ($DriveLetter -match "[A-Z]")
            {
            "Tweaking " + $DriveLetter + ":" + " ..."
            $output = iex ('fsutil repair set ' + ($DriveLetter + ':') + ' 0x01') -ErrorAction SilentlyContinue
            $output = iex ('fsutil resource setautoreset true ' + ($DriveLetter + ':\')) -ErrorAction SilentlyContinue
            $output = iex ('fsutil resource setconsistent ' + ($DriveLetter + ':\')) -ErrorAction SilentlyContinue
            $output = iex ('fsutil resource setlog shrink 10 ' + ($DriveLetter + ':\')) -ErrorAction SilentlyContinue
            }
        }
    }

"Done!"

# Get-Volume -fl
# has lots and lots of helpful detail.
