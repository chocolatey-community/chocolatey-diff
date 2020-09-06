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
    Join-Path ([System.IO.Path]::GetTempPath()) "chocodiff"
}
