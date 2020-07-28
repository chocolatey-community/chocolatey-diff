
function Expand-ArchiveEx {
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
