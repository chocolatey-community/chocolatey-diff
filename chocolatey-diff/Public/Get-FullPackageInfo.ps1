function Get-FullPackageInfo {
    <#
.SYNOPSIS
    Get information about a package

.DESCRIPTION
    Fetches all verions of a package and the its current state in the moderation queue

.PARAMETER PackageId
    The Id of the package

.EXAMPLE
    PS C:\> Get-FullPackageInfo -PackageId Chocolatey
    returns an object with information about package 'Chocolatey'
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId
    )

    $pkgInfo = @{
        Id       = $PackageId
        Url      = "$(Get-ChocolateyPackageGalleryUrl)/${$PackageId}"
        Versions = @()
    }

    $url = "$(Get-ChocolateyRepositoryUrl)/package-versions/${PackageId}?includePreRelease=true"
    [array]$jsonVersions = Invoke-RestMethod -Uri $url -UseBasicParsing | Select-Object -Unique
    $apiVersions = $jsonVersions | ForEach-Object { [SemanticVersion]::create($_) } | Sort-Object -Property VersionOnly, Tag -Descending | Select-Object -Unique

    foreach ($v in $apiVersions) {
        $vInfo = Get-VersionData -packageName $PackageId -version $([SemanticVersion]::create($v))
        $pkgInfo.Versions += @{
            Version = $vInfo.version
            Listed  = $vInfo.listed
            Status  = $vInfo.status
        }
    }

    Write-Output $pkgInfo
}
