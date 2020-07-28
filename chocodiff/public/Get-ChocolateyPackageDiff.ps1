function Get-ChocolateyPackageDiff {
    <#
.SYNOPSIS
    Shows the diff of two packages

.DESCRIPTION
    This will try and download two versions of a Chocolatey package, and compare the package contents.

.NOTES
    Chocolatey is copyrighted by its rightful owners. See: https://chocolatey.org

.INPUTS
    None

.OUTPUTS
    None

.PARAMETER PackageName
    The name of the package to Compare

.PARAMETER OldPackageVersion
    The old version of the package to Compare

.PARAMETER NewPackageVersion
    The new version of the package to Compare

.PARAMETER DownloadLocation
    OPTIONAL - The folder to download the file to.
    The folder will be created when it does not exists
    Defaults to $env:Temp

.PARAMETER KeepFiles
    OPTIONAL - Keep the downloaded files

.PARAMETER UseBeyondCompare
    OPTIONAL - Requires Beyond Compare 4 to be installed in the default location.

.EXAMPLE
    >
    Get-ChocolateyPackageDiff -packageName chocolatey -oldPackageVersion 0.10.14 -newPackageVersion 0.10.15

#>
    param(
        [parameter(Mandatory = $true, Position = 0)][string] $packageName,
        [parameter(Mandatory = $true, Position = 1)][string] $oldPackageVersion,
        [parameter(Mandatory = $true, Position = 2)][string] $newPackageVersion,
        [parameter(Mandatory = $false)][string] $downloadLocation = $(Get-TempPath),
        [parameter(Mandatory = $false)][switch] $keepFiles = $false,
        [parameter(Mandatory = $false)][switch] $useBeyondCompare = $false
    )
    $currentProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    
    $oldFileName = Join-Path $downloadLocation "${packageName}.${oldPackageVersion}.zip"
    $newFileName = Join-Path $downloadLocation "${packageName}.${newPackageVersion}.zip"
    $oldExtractPath = Join-Path $downloadLocation "${packageName}.${oldPackageVersion}"
    $newExtractPath = Join-Path $downloadLocation "${packageName}.${newPackageVersion}"

    $ignoreList = @("package", "_rels", "``[Content_Types``].xml")

    #Get old and new packages
    Get-ChocolateyPackage -packageName $packageName -packageVersion $oldPackageVersion -useZipExtension
    Get-ChocolateyPackage -packageName $packageName -packageVersion $newPackageVersion -useZipExtension

    $nonPrintable = [char[]] (0..8 + 10..31 + 127 + 129 + 141 + 143 + 144 + 157)

    if (-Not $useBeyondCompare) {

        #Extract the package files
        Expand-ArchiveEx -Path $oldFileName -DestinationPath $oldExtractPath -Force
        Expand-ArchiveEx -Path $newFileName -DestinationPath $newExtractPath -Force
        [System.Collections.ArrayList]$oldItems = (Get-ChildItem -Exclude $ignoreList -Path $oldExtractPath | Get-ChildItem -Recurse -File | Select-Object -Expand FullName)
        [System.Collections.ArrayList]$newItems = (Get-ChildItem -Exclude $ignoreList -Path $newExtractPath | Get-ChildItem -Recurse -File | Select-Object -Expand FullName)
       
        ForEach ($oldItem in $oldItems) {
            $file = $oldItem -replace [Regex]::Escape("${oldExtractPath}")

            $newItem = $oldItem -replace $oldPackageVersion, $newPackageVersion

            $lines = Get-Content $oldItem -ErrorAction Ignore -TotalCount 5
            $result = @($lines | Where-Object { $_.IndexOfAny($nonPrintable) -ge 0 })
            if ($result.Count -gt 0) {
                Write-Warning "${file} is binary, ignoring." 
                Continue
            }

            if (-Not (Test-Path $newItem -PathType Leaf)) {
                Write-Warning "${file} does not exist in the new package"
            }

            Write-Host "Diff for ${file}:"
            Invoke-DiffTool -Path1 $oldItem -Path2 $newItem
            while ($newItems -contains $newItem) {
                $newItems.Remove($newItem)
            }
        }

        ForEach ($newItem in $newItems) {
            $file = $newItem -replace [Regex]::Escape("${newExtractPath}")

            $lines = Get-Content $newItem -ErrorAction Ignore -TotalCount 5
            $result = @($lines | Where-Object { $_.IndexOfAny($nonPrintable) -ge 0 })
            if ($result.Count -gt 0) {
                Write-Warning "${file} is binary, ignoring." 
                Continue
            }

            Write-Warning "The ${file} is new. Manual verification required"
        }

    }
    else {
        $bcompare = "C:\Program Files\Beyond Compare 4\BCompare.exe"
        Start-Process -NoNewWindow -Wait -FilePath $bcompare -ArgumentList "${oldFileName}", "${newFileName}"
    }

    if (-Not $keepFiles) {
        Write-Warning "Deleting downloaded files"
        Remove-Item $oldFileName -Force -ErrorAction SilentlyContinue
        Remove-Item $newFileName -Force -ErrorAction SilentlyContinue
        Remove-Item $oldExtractPath -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item $newExtractPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    $ProgressPreference = $currentProgressPreference
}