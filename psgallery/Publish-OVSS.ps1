Update-ScriptFileInfo -Path .\OVSS.ps1 -Version 1.31 `
	-Author "Jonathan E. Brickman" `
	-Description "OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows" `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path .\OVSS.ps1 -NuGetApiKey ff4b1024-6264-4e77-b672-88c5ebe0c10d
