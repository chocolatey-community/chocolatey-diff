<#
.SYNOPSIS
    The the URL to the Chocolatey repository to look at
    (=nugetv2 API Endpoint)

.NOTES
    certain customers may want to use this tooling against
    internal package feeds that are not the community repository
#>
function Get-ChocolateyRepositoryUrl {
    "https://chocolatey.org/api/v2/"
}
