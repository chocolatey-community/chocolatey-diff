
function Get-LatestApprovedPackageVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId
    )
    $pkgInfo = Get-FullPackageInfo -PackageId $PackageId
    foreach ($v in $pkgInfo.Versions) {
        if ($v.Status -contains "Approved") {
            Write-Output $v
            break;
        }
    }
}
