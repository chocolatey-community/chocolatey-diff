function Test-IsBinary {
    <#
.SYNOPSIS
    Test if a given filename is a binary file or not

.DESCRIPTION
    This function tests if a file is binary or not

.PARAMETER Path
    Path to the file to verify if it's binary

.INPUTS
    None. You cannot pipe objects to Test-IsBinary.

.OUTPUTS
    System.Boolean. Test-isBinary returns $true when a file is binary

.EXAMPLE
    PS C:\> Test-IsBinary -Path c:\path\to\sometextfile.txt
    False

.EXAMPLE
    PS C:\> Test-IsBinary -Path c:\path\to\somebinaryfile.exe
    True
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $Path
)
    $nonPrintable = [char[]] (0..8 + 10..31 + 127 + 129 + 141 + 143 + 144 + 157)
    $lines = Get-Content -Path $Path -ErrorAction Ignore -TotalCount 5
    $result = @($lines | Where-Object { $_.IndexOfAny($nonPrintable) -ge 0 })

    $result.Count -gt 0
}