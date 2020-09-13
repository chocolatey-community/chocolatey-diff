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
    OPTIONAL - The old version of the package to Compare

.PARAMETER NewPackageVersion
    OPTIONAL - The new version of the package to Compare

.PARAMETER IgnoreExpectedChanges
    OPTIONAL - This switch will ignore expected changes
    in the package files.

.PARAMETER DownloadLocation
    OPTIONAL - The folder to download the file to.
    The folder will be created when it does not exists
    Defaults to $env:Temp

.PARAMETER KeepFiles
    OPTIONAL - Keep the downloaded files

.PARAMETER CompareFolder
    OPTIONAL - Pass in directories to compare instead of
    files when calling Diff Tools.

.PARAMETER useDiffTool
    OPTIONAL - Use an external diff tool instead of Compare-Object

.EXAMPLE
    >
    Get-ChocolateyPackageDiff -packageName chocolatey -oldPackageVersion 0.10.14 -newPackageVersion 0.10.15

#>
    [cmdletbinding(DefaultParameterSetName='Default')]
    param(
        [parameter(Mandatory = $true, Position = 0, ParameterSetName='Default')]
        [parameter(Mandatory = $true, Position = 0, ParameterSetName='DiffTool')]
            [string] $packageName,
        [parameter(Mandatory = $false, Position = 1, ParameterSetName='Default')]
        [parameter(Mandatory = $false, Position = 1, ParameterSetName='DiffTool')]
            [string] $oldPackageVersion,
        [parameter(Mandatory = $false, Position = 2, ParameterSetName='Default')]
        [parameter(Mandatory = $false, Position = 2, ParameterSetName='DiffTool')]
            [string] $newPackageVersion,
        [parameter(Mandatory = $false, ParameterSetName='Default')]
        [parameter(Mandatory = $false, ParameterSetName='DiffTool')]
            [string] $downloadLocation = $(Get-TempPath),
        [parameter(Mandatory = $false, ParameterSetName='Default')]
        [parameter(Mandatory = $false, ParameterSetName='DiffTool')]
            [switch] $keepFiles = $false,
        [parameter(Mandatory = $false, 	ParameterSetName='Default')]
            [switch] $ignoreExpectedChanges = $false,
        [parameter(Mandatory = $false, ParameterSetName='DiffTool')]
            [switch] $compareFolder = $false,
        [parameter(Mandatory = $false, ParameterSetName='DiffTool')]
            [switch] $useDiffTool = $false
    )
    $currentProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    if (-Not $oldPackageVersion) {
        $pkg = Get-LatestApprovedPackageVersion -PackageId $packageName
        $oldPackageVersion = $pkg.Version
        Write-Verbose "dynamically determined oldPackageVersion: '$oldPackageVersion'"
    }
    if (-Not $oldPackageVersion) {
        throw "unable to diff without 'oldPackageVersion'"
    }
    if (-Not $newPackageVersion) {
        $pkg = Get-LatestUnapprovedPackageVersion -PackageId $packageName
        $newPackageVersion = $pkg.Version
        Write-Verbose "dynamically determined newPackageVersion: '$newPackageVersion'"
    }
    if (-Not $newPackageVersion) {
        throw "unable to diff without 'newPackageVersion'"
    }

    $oldFileName = Join-Path $downloadLocation "${packageName}.${oldPackageVersion}.zip"
    $newFileName = Join-Path $downloadLocation "${packageName}.${newPackageVersion}.zip"
    $oldExtractPath = Join-Path $downloadLocation "${packageName}.${oldPackageVersion}"
    $newExtractPath = Join-Path $downloadLocation "${packageName}.${newPackageVersion}"

    $ignoreList = @("package", "_rels", "``[Content_Types``].xml")

    #Get old and new packages
    Get-ChocolateyPackage -packageName $packageName -packageVersion $oldPackageVersion -useZipExtension
    Get-ChocolateyPackage -packageName $packageName -packageVersion $newPackageVersion -useZipExtension

    #Extract the package files
    Expand-Archive -Path $oldFileName -DestinationPath $oldExtractPath -Force
    Expand-Archive -Path $newFileName -DestinationPath $newExtractPath -Force

    if ($compareFolder) {
        # We need to remove files that should not be compared
        $fullIgnoreList = $ignoreList | ForEach-Object { Join-Path $oldExtractPath $_ }
        $fullIgnoreList += $ignoreList | ForEach-Object { Join-Path $newExtractPath $_ }
        $fullIgnoreList | Where-Object { Test-Path $_ } | ForEach-Object { Remove-item $_ -Recurse -Force }

        Write-Verbose "Diff for root directories"
        Invoke-DiffTool -Path1 $oldExtractPath -Path2 $newExtractPath
    } else {
        [System.Collections.ArrayList]$oldItems = (Get-ChildItem -Exclude $ignoreList -Path $oldExtractPath | Get-ChildItem -Recurse -File | Select-Object -Expand FullName)
        [System.Collections.ArrayList]$newItems = (Get-ChildItem -Exclude $ignoreList -Path $newExtractPath | Get-ChildItem -Recurse -File | Select-Object -Expand FullName)

        ForEach ($oldItem in $oldItems) {
            $file = $oldItem -replace [Regex]::Escape("${oldExtractPath}")

            $newItem = $oldItem -replace $oldPackageVersion, $newPackageVersion

            if (Test-IsBinary -Path $oldItem) {
                Write-Warning "${file} is binary, ignoring."
                Continue
            }

            if (-Not (Test-Path $newItem -PathType Leaf)) {
                Write-Warning "${file} does not exist in the new package"
            }

            Write-Output "Diff for ${file}:"
            if ($useDiffTool) {
                Invoke-DiffTool -Path1 $oldItem -Path2 $newItem
            } else {
                $oldItemData = Get-Content $oldItem
                $newItemData = Get-Content $newItem
                $Data = Compare-Object -ReferenceObject $oldItemData -DifferenceObject $newItemData -PassThru

                if ($ignoreExpectedChanges) {
                    $regex = Get-ChangesRegexForFile($oldItem)
                    if (![string]::IsNullOrEmpty($regex)) {
                        foreach ($re in $regex) {
                            $Data = $Data | Select-String -Pattern $re -NotMatch
                        }
                    }
                }
                $Data
            }

            while (($item = $newItems -eq $newItem | Select-Object -First 1)) {
                $newItems.Remove($item)
            }
        }

        ForEach ($newItem in $newItems) {
            $file = $newItem -replace [Regex]::Escape("${newExtractPath}")

            if (Test-IsBinary -Path $newItem) {
                Write-Warning "${file} is binary, ignoring."
                Continue
            }

            Write-Warning "The ${file} is new. Manual verification required"
        }
    }

    if (-Not $keepFiles) {
        Write-Verbose "Deleting downloaded files"
        Remove-Item $oldFileName -Force -ErrorAction SilentlyContinue
        Remove-Item $newFileName -Force -ErrorAction SilentlyContinue
        Remove-Item $oldExtractPath -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item $newExtractPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    $ProgressPreference = $currentProgressPreference
}
