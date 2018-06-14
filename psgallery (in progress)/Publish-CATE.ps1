Update-ScriptFileInfo -Path .\CATE.ps1 -Version 3.53 `
	-Author "Jonathan E. Brickman" `
	-Description "Clean All Temp Etc - cleans temporary files and folders from all user profiles, clears logs, and more" `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path .\CATE.ps1 -NuGetApiKey ff4b1024-6264-4e77-b672-88c5ebe0c10d
