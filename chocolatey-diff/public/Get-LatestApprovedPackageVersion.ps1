function Get-LatestApprovedPackageVersion {
    <#
.SYNOPSIS
    Get the latest approved version of a package

.DESCRIPTION
    Uses Get-FullPackageInfo to retrieve all versions of given pacakge
    and return first version that has an "approved" status.

.PARAMETER PackageId
    The Id of the package

.EXAMPLE
    PS C:\> Get-LatestApprovedPackageVersion -PackageId Chocolatey
    returns the version of the latets approved package with Id "Chocolatey".
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId
    )
    $pkgInfo = Get-FullPackageInfo -PackageId $PackageId
    foreach ($v in $pkgInfo.Versions) {
        if ($v.Status -eq "approved") {
            Write-Output $v
            break;
        }
    }
}