function Get-TempPath {
    <#
.SYNOPSIS
    Returns temporary working directory for this module (dependend on OS).
#>
    if (Test-IsUnix) {
        "/tmp/chocodiff"
    }
    else {
        Join-Path $env:Temp "chocodiff"
    }
}
