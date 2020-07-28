
function Get-LatestUnapprovedPackageVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId
    )
    $pkgInfo = Get-FullPackageInfo -PackageId $PackageId
    $unapprovedStatus = @("Responded", "Updated", "Submitted", "Ready")
    foreach ($v in $pkgInfo.Versions) {
        if ($unapprovedStatus -contains $v.Status) {
            Write-Output $v
            break;
        }
    }
}
