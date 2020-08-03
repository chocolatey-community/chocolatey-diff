function Get-TempPath {
    <#
.SYNOPSIS
    Returns temporary working directory for this module (dependend on OS).

.DESCRIPTION
    Returns temporary working directory for this module (dependend on OS).

.OUTPUTS
    System.String with a temporary folder for downloading the files

.EXAMPLE
    PS > Get-TempPath
    C:\Users\[username]]\AppData\Local\Temp\chocodiff
#>
    if (Test-IsUnix) {
        "/tmp/chocodiff"
    }
    else {
        Join-Path $env:Temp "chocodiff"
    }
}
