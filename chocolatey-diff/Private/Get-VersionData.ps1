function Get-VersionData {
    <#
.SYNOPSIS
    Get information about a specific package version

.DESCRIPTION
    Get package
    * `version` as [SemanticVersion]
    * `status` in moderation queue
    * `listed` - the visibility on the repository site

.PARAMETER PackageName
    The Id of the package

.OUTPUTS
    VersionData object with all known data for a specific version

.EXAMPLE
    PS > Get-VersionData -packageName chocolatey -version 0.10.15
#>
    param(
        [Parameter(Mandatory = $true)]
        [string]$packageName,
        [Parameter(Mandatory = $true)]
        [SemanticVersion]$version
    )

    $versionData = [VersionData]::new()
    $versionData.version = $version
    $versionData.status = "unknown"
    $versionData.listed = $false

    $url = "$(Get-ChocolateyRepositoryUrl)/Packages(Id='$packageName',Version='$($version.Raw)')"

    try {
        $packagePage = Invoke-RestMethod -Uri $url -UseBasicParsing
    }
    catch {
        $versionData.url = "$(Get-ChocolateyPackageGalleryUrl)/${packageName}/$($version.Raw)"
        $versionData.status = "rejected" # This is an assumption when it can not be found using the api
    }

    $properties = $packagePage.entry.properties
    $versionData.url = ($properties.GalleryDetailsUrl) ? $properties.GalleryDetailsUrl : "$(Get-ChocolateyPackageGalleryUrl)/${packageName}/$($version.Raw)"
    $isApproved = $properties.IsApproved.InnerText
    if (-Not $isApproved) {
        $isApproved = "false"
    }
    $dt = $properties.Published.InnerText
    if (-Not $dt) {
        $dt = "01.01.1970"
    }
    $published = [datetime]::Parse($dt)

    if ($published -gt [datetime]::UnixEpoch) {
        # Unix epoch is returning 01.01.1970, there should be no packages before this date
        $versionData.listed = $true
    }

    if ([bool]::Parse($isApproved)) {
        $versionData.status = "approved"
    }
    elseif ($properties.PackageStatus -eq "Exempted") {
        $versionData.status = "exempted"
    }
    elseif ($properties.PackageStatus -eq "Submitted") {
        if ($properties.PackageSubmittedStatus -eq "Waiting") {
            $versionData.status = "waiting"
        }
        else {
            $versionData.status = "submitted"
        }
    }
    else {
        # Anything else would most likely be an unknown status
    }

    return $versionData
}
