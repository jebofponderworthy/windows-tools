$ReleaseNotes = @(
	"OVSS",
	"Removes all orphan shadows, and then preallocates 20%",
	"of each drive volume for VSS as many different tools'",
	"docs advise."
	)

Update-ScriptFileInfo -Path .\OVSS.ps1 -Version 1.01 `
	-Author "Jonathan E. Brickman" `
	-Description "OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows" `
	-ReleaseNotes $ReleaseNotes `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path .\OVSS.ps1 -NuGetApiKey ff4b1024-6264-4e77-b672-88c5ebe0c10d
