<#
.SYNOPSIS
    Check if on Unix OS or not

.DESCRIPTION
    This function takes a look at `$PSVersionTable.Platform`
    and returns $true if the current PowerShell session runs on Unix
    and $false if on any other OS.

.EXAMPLE
    PS C:\maurice> Test-IsUnix
    $false

    PS ~MACgary> Test-IsUnix
    $true
#>
function Test-IsUnix {
    $PSVersionTable.Platform -eq "Unix"
}
