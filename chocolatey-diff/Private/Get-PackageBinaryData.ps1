function Get-PackageBinaryData {
    <#
    .SYNOPSIS
        The meta information about binaries included in package
    .DESCRIPTION
        The meta information about binaries included in the package, including
        the relative path, the checksum of the file, the embedded file and product
        version as well as the embedded company name.
    .OUTPUTS
        An array of hashtables with the basic information about each binary file.
    .EXAMPLE
        PS > Get-PackageBinaryData -packageDirectory path\to\package\dir
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageDirectory,
        [ValidateSet('sha1', 'sha256', 'sha512')]
        [string]$hashAlgorithm = 'sha256'
    )

    Push-Location $packageDirectory | Out-Null

    try {
        Write-Verbose "Finding binary files in '$packageDirectory..."
        $binaryFiles = Get-ChildItem -Path $packageDirectory -Recurse -File | ? { Test-IsBinary -Path $_.FullName }

        foreach ($file in $binaryFiles) {
            Write-Verbose "Aquiring binary data from $($file.Name)..."

            $item = Get-Item $file.FullName
            $result = @{
                path           = Resolve-Path $file.FullName -Relative
                checksum       = Get-FileHash $file.FullName -Algorithm $hashAlgorithm | % Hash
                fileVersion    = $item.VersionInfo.FileVersion
                productVersion = $item.VersionInfo.ProductVersion
                CompanyName    = $item.VersionInfo.CompanyName
            }
            $result
        }
    } finally {

        Pop-Location | Out-Null
    }
}
