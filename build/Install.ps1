Write-Host 'Running install script' -ForegroundColor Yellow

Write-Host 'Installing NuGet PackageProvider'
$pkg = Install-PackageProvider -Name NuGet -Force -ErrorAction Stop
Write-Host "Installed NuGet version '$($pkg.version)'"

Install-Module -Name 'PSScriptAnalyzer' -Repository PSGallery -Force -ErrorAction Stop
Install-Module -Name 'Pester' -SkipPublisherCheck -Repository PSGallery -Force -ErrorAction Stop

Write-Host 'Updating PSModulePath for testing'
$env:PSModulePath = $env:PSModulePath + ";" + "C:\projects"

$RequiredModules  = 'PSScriptAnalyzer','Pester'
$InstalledModules = Get-Module -Name $RequiredModules -ListAvailable
if ( ($InstalledModules.count -lt $RequiredModules.Count) -or ($Null -eq $InstalledModules)) {
  throw "Required modules are missing."
} else {
  Write-Host 'All modules required found' -ForegroundColor Green
}
