$testdir = Split-Path -Parent $MyInvocation.MyCommand.Path

$global:MyModule = 'chocolatey-diff'

$global:here = Join-Path -Resolve -Path $testdir -ChildPath "..\${MyModule}"

Describe "${MyModule} Module Tests" {

    Context 'Module Setup' {
        It "has the root module ${MyModule}.psm1" {
            "${here}\${MyModule}.psm1" | Should -Exist
        }

        It "has the a manifest file of ${MyModule}.psd1" {
            "$here\${MyModule}.psd1" | Should -Exist
            "$here\${MyModule}.psd1" | Should -FileContentMatch "${MyModule}.psm1"
        }

        It "${MyModule} folder has private functions" {
            "$here\Private\*.ps1" | Should -Exist
        }

        It "${MyModule} folder has public functions" {
            "$here\Public\*.ps1" | Should -Exist
        }

        It "${MyModule} is valid PowerShell code" {
            $psFile = Get-Content -Path "$here\${MyModule}.psm1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }

    } # Context 'Module Setup'

    $folders = @('Private', 'Public')

    $TestCases = @()

    foreach ($folder in $folders) {
        $functions = Get-ChildItem "$here\$folder" -Filter "*.ps1" | Where-Object BaseName -NotMatch ".class" | Select-Object -ExpandProperty BaseName

        $functions.ForEach{ $TestCases += @{function = $_; folder = $folder }; }
    }

    Context "Test Functions" {

        It "<folder>\<function>.ps1 should exist" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -Exist
        }

        It "<folder>\<function>.ps1 should have help block" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -FileContentMatch '<#'
            "$here\$folder\$function.ps1" | Should -FileContentMatch '#>'
        }

        It "<folder>\<function>.ps1 should have a SYNOPSIS section in the help block" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
        }

        It "<folder>\<function>.ps1 should have a DESCRIPTION section in the help block" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
        }

        It "<folder>\<function>.ps1 should have a EXAMPLE section in the help block" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
        }

        It "<folder>\<function>.ps1 should be an advanced function" -TestCases $TestCases {
            Param($function, $folder)
            "$here\$folder\$function.ps1" | Should -FileContentMatch 'function'
            # "$here\$folder\$function.ps1" | Should -FileContentMatch 'cmdletbinding'
            # "$here\$folder\$function.ps1" | Should -FileContentMatch 'param'
        }

        It "<folder>\<function>.ps1 is valid PowerShell code" -TestCases $TestCases {
            Param($function, $folder)
            $psFile = Get-Content -Path "$here\$folder\$function.ps1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }

    } # Context "Test Function $function"

    Context "Functions have tests" {
        It "Tests\<folder>\<function>.Tests.ps1 should exist" -TestCases $TestCases {
            Param($function, $folder)
            "$here\..\Tests\$folder\$function.Tests.ps1" | Should -Exist
        }
    }
}
