
function Invoke-DiffTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Path1,
        
        [Parameter(Mandatory)]
        [string] $Path2
    )
    $diffTool = if ($env:difftool) {
        $env:difftool
    }
    elseif (Test-IsUnix) {
        "diff"
    }
    else {
        "C:\Program Files\KDiff3\bin\diff.exe"
    }
    Write-Verbose "using difftool: $diffTool"
    Start-Process -NoNewWindow -Wait -FilePath $diffTool -ArgumentList "${oldItem}", "${newItem}"  
}
