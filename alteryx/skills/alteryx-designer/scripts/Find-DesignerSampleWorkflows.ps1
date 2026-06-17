<#
.SYNOPSIS
Finds sample and example Alteryx workflows in a local Designer install.

.DESCRIPTION
Searches likely Alteryx Designer install roots from explicit arguments, environment
variables, registry entries, per-user installs, and common Program Files paths.
Returns the first root containing sample/example/tutorial workflows.

.PARAMETER DesignerRoot
Explicit Alteryx Designer install root to search first.

.PARAMETER Limit
Maximum number of workflows to include in the result. Use 0 to include all matches.

.PARAMETER Json
Emit structured JSON instead of plain text.
#>
[CmdletBinding()]
param(
    [string] $DesignerRoot,
    [int] $Limit = 50,
    [switch] $Json
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

$workflowExtensions = @(".yxmd", ".yxmc", ".yxwz")
$sampleMarkers = @("sample", "samples", "example", "examples", "tutorial", "tutorials")

# Load shared discovery utilities relative to this script's path
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Path $MyInvocation.MyCommand.Path -Parent } else { "." }
. (Join-Path $scriptDir "AlteryxDiscoveryUtils.ps1")

function Test-SamplePath {
    param([string] $Path)

    $lower = $Path.ToLowerInvariant()
    foreach ($marker in $sampleMarkers) {
        if ($lower.Contains($marker)) {
            return $true
        }
    }
    return $false
}

function Find-EngineExecutable {
    param([string] $Root)

    $candidates = @(
        (Join-Path $Root "bin\AlteryxEngineCmd.exe"),
        (Join-Path $Root "AlteryxEngineCmd.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -Path $candidate -PathType Leaf) {
            return $candidate
        }
    }
    return $null
}

$checkedRoots = @()
foreach ($root in Get-CandidateDesignerRoots -ExplicitDesignerRoot $DesignerRoot) {
    $checkedRoots += $root
    if (-not (Test-Path -Path $root -PathType Container)) {
        continue
    }

    $sampleDirectories = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $sampleWorkflows = [System.Collections.Generic.List[string]]::new()

    # Opt-in to high-performance localized directory scan first
    $samplesPath = Join-Path $root "RuntimeData\Samples"
    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    if (Test-Path -Path $samplesPath -PathType Container) {
        $found = Get-ChildItem -Path $samplesPath -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $workflowExtensions -contains $_.Extension.ToLowerInvariant() }
        if ($null -ne $found) {
            foreach ($file in $found) {
                $files.Add($file)
            }
        }
    } else {
        # Search the install root, but skip giant dependency subdirectories
        # (bin, Python, Miniconda3, webview2, cef, node_modules, Plugins) to prevent massive scan drag
        $subDirs = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notin "bin", "Miniconda3", "Python", "webview2", "cef", "node_modules", "Plugins" }

        $rootFiles = Get-ChildItem -Path $root -File -ErrorAction SilentlyContinue |
            Where-Object { $workflowExtensions -contains $_.Extension.ToLowerInvariant() -and (Test-SamplePath -Path $_.FullName) }
        if ($null -ne $rootFiles) {
            foreach ($file in $rootFiles) {
                $files.Add($file)
            }
        }

        foreach ($dir in $subDirs) {
            $subDirFiles = Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object {
                    $workflowExtensions -contains $_.Extension.ToLowerInvariant() -and
                    (Test-SamplePath -Path $_.FullName)
                }
            if ($null -ne $subDirFiles) {
                foreach ($file in $subDirFiles) {
                    $files.Add($file)
                }
            }
        }
    }

    foreach ($file in $files) {
        [void] $sampleWorkflows.Add($file.FullName)
        [void] $sampleDirectories.Add($file.DirectoryName)
    }

    if ($sampleWorkflows.Count -eq 0) {
        continue
    }

    $orderedWorkflows = $sampleWorkflows | Sort-Object
    $visibleWorkflows = if ($Limit -eq 0) { $orderedWorkflows } else { $orderedWorkflows | Select-Object -First $Limit }

    $result = [pscustomobject]@{
        designer_root = $root
        engine_executable = Find-EngineExecutable -Root $root
        sample_directories = @($sampleDirectories | Sort-Object)
        workflow_count = $sampleWorkflows.Count
        sample_workflows = @($visibleWorkflows)
        omitted_workflow_count = [Math]::Max($sampleWorkflows.Count - @($visibleWorkflows).Count, 0)
    }

    if ($Json) {
        $result | ConvertTo-Json -Depth 5
    } else {
        "Designer root: $($result.designer_root)"
        "Engine executable: $($result.engine_executable)"
        "Sample directories: $($result.sample_directories.Count)"
        "Sample workflows: $($result.workflow_count)"
        ""
        "Sample directories:"
        $result.sample_directories | ForEach-Object { "- $_" }
        ""
        "Sample workflows:"
        $result.sample_workflows | ForEach-Object { "- $_" }
        if ($result.omitted_workflow_count -gt 0) {
            "... $($result.omitted_workflow_count) more workflow(s) omitted. Use -Limit 0 to show all."
        }
    }
    exit 0
}

$errorResult = [pscustomobject]@{
    error = "designer_samples_not_found"
    message = "Could not find sample/example workflows in the Alteryx Designer install."
    checked_roots = $checkedRoots
}

if ($Json) {
    [Console]::Error.WriteLine(($errorResult | ConvertTo-Json -Depth 5))
} else {
    [Console]::Error.WriteLine("$($errorResult.message) Checked roots: $($checkedRoots -join '; ')")
}
exit 1
