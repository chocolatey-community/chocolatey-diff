<#
.SYNOPSIS
    Returns temporary working directory for this module (dependend on OS).
#>
function Get-TempPath {
    if (Test-IsUnix) {
        "/tmp/chocodiff"
    }
    else {
        Join-Path $env:Temp "chocodiff"
    }
}
