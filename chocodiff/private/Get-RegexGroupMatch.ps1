
function Get-RegexGroupMatch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $SearchText,

        [Parameter(Mandatory)]
        [regex] $Regex,

        [Parameter(Mandatory)]
        [string] $GroupName
    )

    $m = [regex]::Match($SearchText, $Regex, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($m.Success) {
        $m.Groups[$GroupName].Value
    }
}
