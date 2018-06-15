$ReleaseNotes = @(
	"TweakNTFS",
	"Tweaks all NTFS volumes on a system for",
	"performance and reliability, using FSUTIL"
	)

Update-ScriptFileInfo -Path .\TweakNTFS.ps1 -Version 2.12 `
	-Author "Jonathan E. Brickman" `
	-Description "TweakNTFS - optimizes NTFS volumes for performance and reliability" `
	-ReleaseNotes $ReleaseNotes `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path .\TweakNTFS.ps1 -NuGetApiKey ff4b1024-6264-4e77-b672-88c5ebe0c10d
