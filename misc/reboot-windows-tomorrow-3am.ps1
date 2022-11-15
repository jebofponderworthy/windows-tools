# Delete old scheduled task of this name, if present

Unregister-ScheduledTask -TaskName "schtasks_REBOOT" -Confirm:$false 2> $null

# Create new scheduled task of this name

$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\shutdown.exe' -Argument '-f -r -t 0'
$tomorrow3AM = (Get-Date).AddHours(24)
$tomorrow3AM = $tomorrow3AM.AddHours( ($tomorrow3AM.Hour * -1) + 3 )
$tomorrow3AM = $tomorrow3AM.AddMinutes( $tomorrow3AM.Minute * -1 )
$tomorrow3AM = $tomorrow3AM.AddSeconds( $tomorrow3AM.Second * -1 )
$tomorrow3AM = $tomorrow3AM.AddMilliseconds( $tomorrow3AM.Millisecond * -1 )
$trigger = New-ScheduledTaskTrigger -Once -At $tomorrow3AM
$taskprincipal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -RunLevel Highest
Register-ScheduledTask -TaskName 'schtasks_REBOOT' -Action $action -Trigger $trigger -Description 'Scheduled Reboot' -Principal $taskprincipal