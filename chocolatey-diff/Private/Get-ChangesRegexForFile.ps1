#Requires -version 6.0
function Get-ChangesRegexForFile {
    <#
.SYNOPSIS
    Returns a set of regular expressions for a known Chocolatey file.

.DESCRIPTION
    Returns a set of regular expressions for a known Chocolatey file.

.OUTPUTS
    System.String[] with regexes for a know Chocolatey file.

.PARAMETER FileName
    The name of the file. Only the filename with extension is expected.

.EXAMPLE
    PS > Get-ChangesRegexForFile -FileName chocolateyInstall.ps1
    <TODO>
#>
    [OutputType([System.String[]],[System.String])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FileName
    )

    $knownExtensions = @{
        '.nuspec' = @(
            "<version>.*<\/version>",
            "<releaseNotes>.*<\/releaseNotes>"
        )
    }

    $knownFiles = @{
        'chocolateyInstall.ps1'      = @(
            "^[$]?\s*url(32|64)?\s*=\s*[\`"'].*[\`"']",
            "^[$]?\s*file(32|64)?\s*=\s*[\`"'].*[\`"']",
            "^[$]?\s*checksum(32|64)?\s*=\s*[\`"'].*[\`"']",
            "^[$]?\s*checksumType(32|64)?\s*=\s*[\`"'].*[\`"']",
            "^[$]version\s*=\s*[\`"'].*[\`"']"
        )
        # 'chocolateyUninstall.ps1' = @()
        'chocolateyBeforeModify.ps1' = @(
            "[$]?version.*"
        )
        'VERIFICATION.txt' = @(
            "\s*url.*",
            "\s*32-Bit.*",
            "\s*64-Bit.*",
            "\s*checksum.*",
            "\s*checksumType.*"
        )
    }

    $extension = Split-Path -Path $FileName -Extension

    $exactFileName = Split-Path -Path $FileName -Leaf

    if ($knownExtensions.ContainsKey($extension)) {
        return $knownExtensions[$extension]
    } elseif ($knownFiles.ContainsKey($exactFileName)) {
        return $knownFiles[$exactFileName]
    }

    # Can't find a regex for this file, returning null
    return ''
}
