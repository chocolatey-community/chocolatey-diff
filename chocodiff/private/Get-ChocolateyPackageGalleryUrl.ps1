<#
.SYNOPSIS
    The the URL to the Chocolatey package gallery/server to look at
    (=pretty http site with package information and bling bling)

.NOTES
    certain customers may want to use this tooling against
    internal package galleries that are not the community package gallery
#>
function Get-ChocolateyPackageGalleryUrl {
    # note: this may contain additional logic 
    # / may be configured by user in future releases
    "https://chocolatey.org/packages"
}
