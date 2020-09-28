# Chocolatey Diff utility

[![build](https://github.com/chocolatey-community/chocodiff/workflows/build/badge.svg)](https://github.com/chocolatey-community/chocodiff/actions?query=workflow%3Abuild)

This Powershell module allows you to view the diff of two package versions.

## Required - Powershell 6.0+

### On Windows

Easiest:

```powershell
choco install powershell-core
```

Other options:

See this [document](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7) from Microsoft to install POSH on Windows

### On Mac

Easiest:

```sh
brew cask install powershell
```

Other options:

See this [document](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7) from Microsoft to install POSH on macOS

### On Linux

See this [document](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7) from Microsoft to install POSH on Linux.

## Optional - diffutils

This software allows you to use some diff-tool (such as diff or meld):
You can always specify the the diff-tool to use manually by utilizing the `env:difftool` variable.

### On Windows

NOTE: Required for `-useDiffTool` parameter

```powershell
choco install git
```

### On Linux/Mac

ensure at least `diff` is installed and available through PATH environment variable.

### Optional

If you want to use a different diff-tool, set `env:difftool`:

```powershell
$env:difftool = "C:\Program Files (x86)\Meld\meld.exe"
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
Get-ChocolateyPackageDiff ...
```

By default, `C:\Program Files\Git\usr\bin\diff.exe` is used on Windows OS and `diff` on Unix-like systems.

## Example / Usage

### Syntax

The Get-ChocolateyPacageDiff Syntax:

```powershell
Get-ChocolateyPackageDiff [-packageName] <string> [[-oldPackageVersion] <string>] [[-newPackageVersion] <string>] [-downloadLocation <string>] [-keepFiles] [-ignoreExpectedChanges] [<CommonParameters>]

Get-ChocolateyPackageDiff [-packageName] <string> [[-oldPackageVersion] <string>] [[-newPackageVersion] <string>] [-downloadLocation <string>] [-keepFiles] [-compareFolder] [-useDiffTool] [<CommonParameters>]
```

### Example: exact source and target version given

```powershell
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
PS > Get-ChocolateyPackageDiff -packageName grafana -oldPackageVersion 7.1.0 -newPackageVersion 7.1.1
Diff for \legal\LICENSE.txt:
Diff for \legal\VERIFICATION.txt:
  32-Bit: <https://dl.grafana.com/oss/release/grafana-7.1.1.windows-amd64.zip>
  checksum32: DE586C6232CE9026DF097AFE3AF843F0097AB578409BE634F5BA4420FF3E786E
  32-Bit: <https://dl.grafana.com/oss/release/grafana-7.1.0.windows-amd64.zip>
  checksum32: 84961388ACDB8134E29558EF80AD989178BE95098808FB75DDD0AD3268BE570C
Diff for \tools\chocolateyinstall.ps1:
  file           = "$toolsdir\grafana-7.1.1.windows-amd64.zip"
  file           = "$toolsdir\grafana-7.1.0.windows-amd64.zip"
WARNING: \tools\grafana-7.1.0.windows-amd64.zip is binary, ignoring.
Diff for \grafana.nuspec:
    <version>7.1.1</version>
    <version>7.1.0</version>
WARNING: \tools\grafana-7.1.1.windows-amd64.zip is binary, ignoring.
```

### Example: single package ID as input

Latest approved and unapproved versions are selected automatically.

```powershell
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
PS > Get-ChocolateyPackageDiff elasticsearch
Diff for \tools\chocolateyBeforeModify.ps1:
$version      = "7.8.1"
$version      = "7.8.0"
Diff for \tools\chocolateyInstall.ps1:
$url          = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.1-windows-x86_64.zip'
$checksum     = '800720331e64f091f87bb5ca1755c948c75718cb3723497d861b28fab2067e7a'
$version      = "7.8.1"
$url          = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-windows-x86_64.zip'
$checksum     = 'e6e8160fcb0837cf2d5602e9c5ecb637b9cb46b7e333dfd681f65a235eed85d4'
$version      = "7.8.0"
Diff for \tools\Uninstall-ChocolateyPath.psm1:
Diff for \elasticsearch.nuspec:
    <version>7.8.1</version>
    <releaseNotes>https://www.elastic.co/guide/en/elasticsearch/reference/7.8/release-notes-7.8.1.html</releaseNotes>
    <version>7.8.0</version>
    <releaseNotes>https://www.elastic.co/guide/en/elasticsearch/reference/7.8/release-notes-7.8.0.html</releaseNotes>
```
