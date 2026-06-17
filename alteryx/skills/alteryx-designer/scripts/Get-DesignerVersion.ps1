<#
.SYNOPSIS
Retrieves the installed version of Alteryx Designer/Engine.

.DESCRIPTION
Discovers the Alteryx Designer/Engine install path and queries its file metadata
to return the exact product version.

.PARAMETER DesignerRoot
Explicit Alteryx Designer install root to check first.

.PARAMETER Json
Emit structured JSON instead of plain text.
#>
[CmdletBinding()]
param(
    [string] $DesignerRoot,
    [switch] $Json
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

# Load shared discovery utilities relative to this script's path
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Path $MyInvocation.MyCommand.Path -Parent } else { "." }
. (Join-Path $scriptDir "AlteryxDiscoveryUtils.ps1")

function Find-Version {
    param([string] $Root)

    $candidates = @(
        (Join-Path $Root "bin\AlteryxEngineCmd.exe"),
        (Join-Path $Root "AlteryxEngineCmd.exe"),
        (Join-Path $Root "bin\AlteryxGui.exe"),
        (Join-Path $Root "AlteryxGui.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -Path $candidate -PathType Leaf) {
            $item = Get-Item -Path $candidate
            $versionInfo = $item.VersionInfo
            return [pscustomobject]@{
                executable_path = $item.FullName
                product_version = $versionInfo.ProductVersion
                file_version    = $versionInfo.FileVersion
                description     = $versionInfo.FileDescription
            }
        }
    }
    return $null
}

$discovered = $null
$checkedRoots = @()
foreach ($root in Get-CandidateDesignerRoots -ExplicitDesignerRoot $DesignerRoot) {
    $checkedRoots += $root
    if (-not (Test-Path -Path $root -PathType Container)) {
        continue
    }

    $discovered = Find-Version -Root $root
    if ($null -ne $discovered) {
        $discovered | Add-Member -MemberType NoteProperty -Name "designer_root" -Value $root
        break
    }
}

if ($null -ne $discovered) {
    if ($Json) {
        $discovered | ConvertTo-Json -Depth 3
    } else {
        "Alteryx Designer Root : $($discovered.designer_root)"
        "Executable Found     : $($discovered.executable_path)"
        "Product Version      : $($discovered.product_version)"
        "File Version         : $($discovered.file_version)"
        "Description          : $($discovered.description)"
    }
    exit 0
}

# Not found error
$errorResult = [pscustomobject]@{
    error = "designer_not_found"
    message = "Could not locate Alteryx Designer/Engine executable or determine version."
    checked_roots = $checkedRoots
}

if ($Json) {
    [Console]::Error.WriteLine(($errorResult | ConvertTo-Json -Depth 5))
} else {
    [Console]::Error.WriteLine("$($errorResult.message) Checked roots: $($checkedRoots -join '; ')")
}
exit 1
