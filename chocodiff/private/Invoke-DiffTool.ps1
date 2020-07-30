function Invoke-DiffTool {
    <#
.SYNOPSIS
    Create a diff of two files in a new process and wait for the result.

.DESCRIPTION
    This function uses `$env:difftool` to create the diff of two files,
    if the difftool environment variable is not set, it will default 
    to `diff` on Unix OS and "diff.exe" from KDiff3 in its default
    install location on Windows OS.

.PARAMETER Path1
    Path to the first file to compare against the second. 
    (=base file)

.PARAMETER Path2
    Path to the second file to comapre against the first.
    (=target file)

.EXAMPLE
    PS C:\> Invoke-DiffTool -Path1 somefile.txt -Path2 anotherfile.txt
    creates a diff of somefile.txt and anotherfile.txt
#>
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
