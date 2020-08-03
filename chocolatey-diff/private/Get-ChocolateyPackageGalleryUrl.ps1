function Get-ChocolateyPackageGalleryUrl {
    <#
.SYNOPSIS
    The the URL to the Chocolatey package gallery/server to look at

.DESCRIPTION
    The the URL to the Chocolatey package gallery/server to look at
    (=pretty http site with package information and bling bling)

.NOTES
    certain customers may want to use this tooling against
    internal package galleries that are not the community package gallery

.OUTPUTS
    System.String with the URL of the Chocolatey Gallery

.EXAMPLE
    PS > Get-ChocolateyPackageGalleryUrl
    https://chocolatey.org/packages
#>
    "https://chocolatey.org/packages"
}
