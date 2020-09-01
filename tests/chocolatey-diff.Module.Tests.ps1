$testdir = Split-Path -Parent $MyInvocation.MyCommand.Path

$global:module = 'chocolatey-diff'

$global:here = Join-Path -Resolve -Path $testdir -ChildPath "..\${module}"

Describe "${module} Module Tests" {

    Context 'Module Setup' {
        It "has the root module ${module}.psm1" {
            "${here}\${module}.psm1" | Should -Exist
        }

        It "has the a manifest file of $module.psd1" {
            "$here\$module.psd1" | Should -Exist
            "$here\$module.psd1" | Should -FileContentMatch "$module.psm1"
        }

        It "$module folder has private functions" {
            "$here\private\*.ps1" | Should -Exist
        }

        It "$module folder has public functions" {
            "$here\public\*.ps1" | Should -Exist
        }

        It "$module is valid PowerShell code" {
            $psFile = Get-Content -Path "$here\$module.psm1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }

    } # Context 'Module Setup'

    $folders = @('private', 'public')

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
        It "tests\<folder>\<function>.Tests.ps1 should exist" -TestCases $TestCases {
            Param($function, $folder)
            "$here\..\tests\$folder\$function.Tests.ps1" | Should -Exist
        }
    }




}