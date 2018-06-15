$ReleaseNotes = @(
	"GetRedists",
	"Retrieve and install all of the VC++ redistributable libraries",
	"currently being supported by Microsoft, using the excellent",
	"VcRedist package."
	)

Update-ScriptFileInfo -Path ..\tools\GetRedists.ps1 -Version 1.32 `
	-Author "Jonathan E. Brickman" `
	-Description "GetRedists - Get all current Microsoft VC++ redistributables" `
	-ReleaseNotes $ReleaseNotes `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path ..\tools\GetRedists.ps1 -NuGetApiKey 6f05b805-b551-403f-9b05-b45fb420c69b
