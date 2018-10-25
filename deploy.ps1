#Add a new line to the markdown file.
$date = Get-Date -Uformat "%D"

#Update the manifest file
$manifest = Import-PowerShellDataFile .\VSTS-TestModule.psd1
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# Update the manifest file
Update-ModuleManifest -Path .\VSTS-TestModule.psd1 -ModuleVersion $NewVersion
#Sleep Incase of update
Start-Sleep -Seconds 5
#Find the Nuspec File
$MonolithFile = ".\VSTS-TestModule.nuspec"
#Import the New PSD file
$newString = Import-PowerShellDataFile .\VSTS-TestModule.psd1 
$xmlFile = New-Object xml
# Load the Nuspec file and modify it
$xmlFile.Load($MonolithFile)
$xmlFile.package.metadata.version = $newString.ModuleVersion
$xmlFile.package.metadata.releaseNotes = "Version $($newString.ModuleVersion) was modified by $($env:USERNAME) on $($date)"
$xmlFile.Save($MonolithFile) 

# Update the Markdown file to have the version update
Add-Content -Path .\README.md -Value "  **Version: $($newString.ModuleVersion)**"
Add-Content -Path .\README.md -Value "  by: $($env:USERNAME) on $($date)"
