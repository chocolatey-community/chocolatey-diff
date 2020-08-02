function Get-ChocolateyPackage {
    <#
.SYNOPSIS
    Downloads a version of a Chocolatey package.

.DESCRIPTION
    This will try and download a version of a Chocolatey package.

.NOTES
    Chocolatey is copyrighted by its rightful owners. See: https://chocolatey.org

.INPUTS
    None

.OUTPUTS
    None

.PARAMETER PackageName
    The name of the package to Download

.PARAMETER PackageVersion
    The version of the package to Download

.PARAMETER DownloadLocation
    OPTIONAL - The folder to download the file to.
    The folder will be created when it does not exists
    Defaults to $env:Temp

.PARAMETER UseZipExtension
    OPTIONAL - Use the .zip extension instead of .nupkg

.EXAMPLE
    >
    Get-ChocolateyPackage -packageName chocolatey -packageVersion 0.10.15

#>    
    param(
        [parameter(Mandatory = $true, Position = 0)][string] $packageName,
        [parameter(Mandatory = $true, Position = 1)][string] $packageVersion,
        [parameter(Mandatory = $false)][string] $downloadLocation = $(Get-TempPath),
        [parameter(Mandatory = $false)][switch] $useZipExtension = $false
    )

    # Supress download bar to improve speed massively!
    $currentProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'


    if (-Not (Test-Path -Path $downloadLocation -PathType Container)) {
        New-Item -Path $downloadLocation -ItemType Directory | Out-Null
    }

    $extension = If ($useZipExtension) { "zip" } Else { "nupkg" }

    $fileName = Join-Path $downloadLocation "${packageName}.${packageVersion}.${extension}"

    if (Test-Path $fileName -PathType Leaf) {
        Write-Warning "File already exists, will be deleted"
        Remove-Item $fileName -Force
    }

    $repoBaseUrl = Get-ChocolateyRepositoryUrl
    $downloadUrl = "${repoBaseUrl}/package/${packageName}/${packageVersion}"

    #Download the file
    Write-Warning "Downloading file from ${downloadUrl}"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $fileName

    $ProgressPreference = $currentProgressPreference
}