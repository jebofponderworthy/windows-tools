$firefoxToClean = @(
	"cache",
	"cache2\entries",
	"thumbnails",
	"cookies.sqlite",
	"webappstore.sqlite",
	"chromeappstore.sqlite"
	)

# This loop handles Firefox -- IN DEVELOPMENT JEB
Get-ChildItem -Path 'C:\users\jonathanb\AppData\Local\Mozilla\Firefox\Profiles\' | ForEach-Object {
	$ffProfilePath = Get-ItemProperty $_.pspath
		
	ForEach ($subPath in $firefoxToClean) {
		$ToClean = "$ffProfilePath\$subPath"
		$ToClean
		}
	}