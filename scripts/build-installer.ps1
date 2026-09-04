# RSAM installer build script.
# Copyright (c) 2026 Daniel Riggi (riggi89).
# Distributed under the project license; see LICENSE.md and NOTICE.md.

#requires -Version 5.1

param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    [ValidateSet('x86', 'x64', 'All')]
    [string]$Architecture = 'All',

    [switch]$SkipPublish,

    [string]$InnoCompiler = ''
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$propsPath = Join-Path $root 'Directory.Build.props'
$installerScript = Join-Path $root 'installer\RSAM.iss'
$installerOutput = Join-Path $root 'artifacts\installer'
$installerLicense = Join-Path $installerOutput 'LICENSE.txt'

$targetArchitectures = if ($Architecture -eq 'All') {
    @('x86', 'x64')
}
else {
    @($Architecture)
}

[xml]$props = Get-Content -LiteralPath $propsPath -Raw
$version = [string](($props.Project.PropertyGroup | Select-Object -First 1).Version)

if ([string]::IsNullOrWhiteSpace($version)) {
    throw 'Version not found in Directory.Build.props.'
}

if (-not $SkipPublish) {
    & (Join-Path $PSScriptRoot 'publish.ps1') `
        -Configuration $Configuration `
        -Architecture $Architecture

    if ($LASTEXITCODE -ne 0) {
        throw "Publishing failed with exit code $LASTEXITCODE."
    }
}

$requiredFiles = @(
    'RSAM.exe',
    'RSAM.dll',
    'RSAM.Core.dll',
    'RSAM.API.dll',
    'WinUI.TableView.dll',
    'Microsoft.UI.Xaml.dll',
    'Microsoft.WindowsAppRuntime.dll',
    'resources.pri',
    'coreclr.dll',
    'hostfxr.dll',
    'hostpolicy.dll'
)

foreach ($targetArchitecture in $targetArchitectures) {
    $runtimeIdentifier = "win-$targetArchitecture"
    $publishDirectory = Join-Path $root "artifacts\publish\$runtimeIdentifier"

    if (-not (Test-Path -LiteralPath $publishDirectory)) {
        throw "Publish directory does not exist: $publishDirectory"
    }

    $missingFiles = @(
        $requiredFiles |
            Where-Object {
                -not (Test-Path -LiteralPath (
                    Join-Path $publishDirectory $_
                ))
            }
    )

    if ($missingFiles.Count -gt 0) {
        throw (
            "Incomplete $runtimeIdentifier publish output. " +
            "Missing required files: " +
            ($missingFiles -join ', ')
        )
    }
}

New-Item `
    -ItemType Directory `
    -Force `
    -Path $installerOutput |
    Out-Null

# Inno Setup requires a TXT or RTF file for its license page.
# LICENSE.md remains the source license.
Copy-Item `
    -LiteralPath (Join-Path $root 'LICENSE.md') `
    -Destination $installerLicense `
    -Force

if ([string]::IsNullOrWhiteSpace($InnoCompiler)) {
    $command = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue

    if ($null -ne $command) {
        $InnoCompiler = $command.Source
    }
}

if ([string]::IsNullOrWhiteSpace($InnoCompiler)) {
    $compilerCandidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $compilerCandidates += Join-Path `
            $env:LOCALAPPDATA `
            'Programs\Inno Setup 6\ISCC.exe'
    }

    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $compilerCandidates += Join-Path `
            ${env:ProgramFiles(x86)} `
            'Inno Setup 6\ISCC.exe'
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $compilerCandidates += Join-Path `
            $env:ProgramFiles `
            'Inno Setup 6\ISCC.exe'
    }

    $InnoCompiler = $compilerCandidates |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
}

if (
    [string]::IsNullOrWhiteSpace($InnoCompiler) -or
    -not (Test-Path -LiteralPath $InnoCompiler)
) {
    throw (
        'Inno Setup 6 compiler (ISCC.exe) was not found. ' +
        'Install Inno Setup 6 or pass -InnoCompiler.'
    )
}

$previousVersion = $env:RSAM_VERSION
$previousSourceRoot = $env:RSAM_SOURCE_ROOT
$previousLicense = $env:RSAM_INSTALLER_LICENSE
$previousArchitecture = $env:RSAM_ARCHITECTURE

$createdInstallers = @()

try {
    $env:RSAM_VERSION = $version
    $env:RSAM_SOURCE_ROOT = $root
    $env:RSAM_INSTALLER_LICENSE = $installerLicense

    foreach ($targetArchitecture in $targetArchitectures) {
        $env:RSAM_ARCHITECTURE = $targetArchitecture

        Write-Host "Building $targetArchitecture installer..."

        & $InnoCompiler $installerScript

        if ($LASTEXITCODE -ne 0) {
            throw (
                "Inno Setup failed for $targetArchitecture " +
                "with exit code $LASTEXITCODE."
            )
        }

        $setupPath = Join-Path `
            $installerOutput `
            "RSAM_$version-win-$targetArchitecture-Setup.exe"

        if (-not (Test-Path -LiteralPath $setupPath)) {
            throw (
                'The setup compiler completed without creating ' +
                "the expected file: $setupPath"
            )
        }

        $createdInstallers += $setupPath
    }
}
finally {
    $env:RSAM_VERSION = $previousVersion
    $env:RSAM_SOURCE_ROOT = $previousSourceRoot
    $env:RSAM_INSTALLER_LICENSE = $previousLicense
    $env:RSAM_ARCHITECTURE = $previousArchitecture
}

Write-Host ''
Write-Host 'Unsigned RSAM installers created:'

foreach ($createdInstaller in $createdInstallers) {
    Write-Host "  $createdInstaller"
}