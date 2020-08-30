Write-Host 'Running install script' -ForegroundColor Yellow

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-Module -Name 'PSScriptAnalyzer' -Force
Install-Module -Name 'Pester' -Force

$RequiredModules  = 'PSScriptAnalyzer','Pester'
$InstalledModules = Get-Module -Name $RequiredModules -ListAvailable
if ( ($InstalledModules.count -lt $RequiredModules.Count) -or ($Null -eq $InstalledModules)) {
  throw "Required modules are missing."
} else {
  Write-Host 'All modules required found' -ForegroundColor Green
}
