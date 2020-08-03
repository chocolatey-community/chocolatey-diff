function Get-ChocolateyRepositoryUrl {
    <#
.SYNOPSIS
    The the URL to the Chocolatey repository to look at

.DESCRIPTION
    The the URL to the Chocolatey repository to look at
    (=nugetv2 API Endpoint)

.NOTES
    certain customers may want to use this tooling against
    internal package feeds that are not the community repository

.OUTPUTS
    System.String with the URL of the Chocolatey NuGet v2 API

.EXAMPLE
    PS > Get-ChocolateyRepositoryUrl
    https://chocolatey.org/api/v2/
#>
    "https://chocolatey.org/api/v2/"
}
