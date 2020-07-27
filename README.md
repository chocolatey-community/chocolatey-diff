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
Import-Module .\chocolatey-diff.psm1
Get-ChocolateyPackageDiff ...
```

By default, `C:\Program Files\KDiff3\bin\diff.exe` is used on Windows OS and `diff` on Unix-like systems.

## Example / Usage

Example output:

```powershell
Import-Module .\chocolatey-diff.psm1
D:\Projects\chocodiff [master ≡ +5 ~0 -0 !]> Get-ChocolateyPackageDiff -packageName grafana -oldPackageVersion 7.1.0 -newPackageVersion 7.1.1
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
