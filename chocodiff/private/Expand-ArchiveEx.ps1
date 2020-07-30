function Expand-ArchiveEx {
    <#
.SYNOPSIS
    Extract archive to target location.

.DESCRIPTION
    Extracts all items of given archive, keeping the directory struture to target location.
    Uses `unzip` on Unix and `Expand-Archive` on other OS.

.PARAMETER Path
    Path to archive file.

.PARAMETER DestinationPath
    Target path for decompressed files.

.PARAMETER Force
    do or do not, there is no try.

.EXAMPLE
    PS C:\> Exapnd-ArchiveEx -path somefile.zip -DestinationPath "/tmp/x"
    extracts contents of "somefile.zip" to "/tmp/x"
#>
    [CmdletBinding()]
    param (
        [string]$Path,
        [string]$DestinationPath,
        [switch]$Force
    )
    if (Test-IsUnix) {
        unzip $Path -d $DestinationPath
    }
    else {
        Expand-Archive @PsBoundParameters
    }
}
