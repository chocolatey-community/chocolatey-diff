[![build](https://github.com/chocolatey-community/chocodiff/workflows/build/badge.svg)](https://github.com/chocolatey-community/chocodiff/actions?query=workflow%3Abuild)

# Chocolatey Diff utility

This Powershell module allows you to view the diff of two package versions.

## Requirements - diff tool

This software requires you to have some diff-tool (such as kdiff3 or meld) package installed:
You can always specify the the diff-tool to use manually by utilizing the `env:difftool` variable.

**On Windows:**

```powershell
choco install kdiff3
```

**On Linux/Mac** ensure at least `diff` and `unzip` are installed and available through PATH environment variable.

If you want to use a different diff-tool, set `env:difftool`:

```powershell
$env:difftool = "C:\Program Files (x86)\Meld\meld.exe"
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
Get-ChocolateyPackageDiff ...
```

By default, `C:\Program Files\KDiff3\bin\diff.exe` is used on Windows OS and `diff` on Unix-like systems.

## Example / Usage

### Example: exact source and target version given

```powershell
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
D:\Projects\chocolatey-diff [master ≡ +5 ~0 -0 !]> Get-ChocolateyPackageDiff -packageName grafana -oldPackageVersion 7.1.0 -newPackageVersion 7.1.1
WARNING: Downloading file from https://chocolatey.org/api/v2/package/grafana/7.1.0
WARNING: Downloading file from https://chocolatey.org/api/v2/package/grafana/7.1.1
Diff for \legal\LICENSE.txt:
Diff for \legal\VERIFICATION.txt:
9c9
<   32-Bit: <https://dl.grafana.com/oss/release/grafana-7.1.0.windows-amd64.zip>
---
>   32-Bit: <https://dl.grafana.com/oss/release/grafana-7.1.1.windows-amd64.zip>
15c15
<   checksum32: 84961388ACDB8134E29558EF80AD989178BE95098808FB75DDD0AD3268BE570C
---
>   checksum32: DE586C6232CE9026DF097AFE3AF843F0097AB578409BE634F5BA4420FF3E786E
Diff for \tools\chocolateyinstall.ps1:
8c8
<   file           = "$toolsdir\grafana-7.1.0.windows-amd64.zip"
---
>   file           = "$toolsdir\grafana-7.1.1.windows-amd64.zip"
WARNING: \tools\grafana-7.1.0.windows-amd64.zip is binary, ignoring.
Diff for \grafana.nuspec:
5c5
<     <version>7.1.0</version>
---
>     <version>7.1.1</version>
WARNING: \tools\grafana-7.1.1.windows-amd64.zip is binary, ignoring.
WARNING: Deleting downloaded files
```

### Example: single package ID as input

Latest approved and unapproved versions are selected automatically.

```powershell
Import-Module .\chocolatey-diff\chocolatey-diff.psm1
chocolatey-diff on  gh8_versiondetect [✘!?] took 44s
❯ Get-ChocolateyPackageDiff elasticsearch
WARNING: Downloading file from https://chocolatey.org/api/v2//package/elasticsearch/6.7.1
WARNING: Downloading file from https://chocolatey.org/api/v2//package/elasticsearch/7.8.1
Diff for \tools\chocolateyBeforeModify.ps1:
1c1
< elasticsearch-service.bat stop
---
> 2a3,10
>
> $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
> $unPath = Join-Path $toolsDir 'Uninstall-ChocolateyPath.psm1'
> Import-Module $unPath
>
> $version      = "7.8.1"
> $binPath = Join-Path $toolsDir "elasticsearch-$($version)\bin"
> Uninstall-ChocolateyPath $binPath 'Machine'
...
...
WARNING: The \tools\Uninstall-ChocolateyPath.psm1 is new. Manual verification required
WARNING: Deleting downloaded files
```