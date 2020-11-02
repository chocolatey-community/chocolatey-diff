# Based on the script from https://github.com/poshbotio/PoshBot

[cmdletbinding(DefaultParameterSetName = 'task')]
param(
    # Build task(s) to execute
    [parameter(ParameterSetName = 'task', Position = 0)]
    [ValidateSet('Clean','default','Pester','Init','OutputDir','Build','Publish','Test','Analyze')]
    [string[]]$Task = 'default',

    # Bootstrap dependencies
    [switch]$Bootstrap,

    [hashtable]$Properties = @{},

    # List available build tasks
    [parameter(ParameterSetName = 'Help')]
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap > $null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module -Name PSDepend -Verbose:$false
    Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
    dotnet tool restore
}

# Execute psake task(s)
$psakeFile = './psakeFile.ps1'
if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Get-PSakeScriptTasks -buildFile $psakeFile  |
        Format-Table -Property Name, Description, Alias, DependsOn
} else {
    Set-BuildEnvironment -Force

    Invoke-psake -buildFile $psakeFile -taskList $Task -properties $properties -nologo
    exit ( [int]( -not $psake.build_success ) )
}
