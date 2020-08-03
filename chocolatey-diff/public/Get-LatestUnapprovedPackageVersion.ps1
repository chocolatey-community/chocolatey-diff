function Get-LatestUnapprovedPackageVersion {
    <#
.SYNOPSIS
    Get the latest UNapproved version of a package

.DESCRIPTION
    Uses Get-FullPackageInfo to retrieve all versions of given pacakge
    and return first version that has one of the following status 
    * responded
    * updated
    * submitted
    * ready

.PARAMETER PackageId
    The Id of the package

.EXAMPLE
    PS C:\> Get-LatestUnapprovedPackageVersion -PackageId Chocolatey
    returns the version of the latets responded, updated, submitted or "ready" 
    package with Id "Chocolatey".
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId
    )
    $pkgInfo = Get-FullPackageInfo -PackageId $PackageId
    $unapprovedStatus = @("responded", "updated", "submitted", "ready")
    foreach ($v in $pkgInfo.Versions) {
        if ($unapprovedStatus -contains $v.Status) {
            Write-Output $v
            break;
        }
    }
}