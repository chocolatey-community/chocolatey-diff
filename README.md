# Chocolatey Diff functionality

This Powershell module allows you to view the diff of two package versions.

This software requires to have kdiff3 package installed:
```powershell
choco install kdiff3
```

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