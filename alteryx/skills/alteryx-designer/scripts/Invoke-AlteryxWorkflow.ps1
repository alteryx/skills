<#
.SYNOPSIS
Runs an Alteryx workflow with AlteryxEngineCmd.exe.

.DESCRIPTION
Finds an Alteryx engine executable from explicit arguments, environment variables,
registry entries, and common install roots, then runs the supplied workflow and
captures stdout, stderr, timeout state, and the true engine exit code.

.PARAMETER WorkflowPath
Path to the .yxmd, .yxmc, or .yxwz workflow to run.

.PARAMETER EnginePath
Explicit path to AlteryxEngineCmd.exe.

.PARAMETER DesignerRoot
Explicit Alteryx Designer install root. The script will also look for the engine
under its bin directory.

.PARAMETER WorkingDirectory
Working directory for the engine process. Defaults to the workflow's parent directory.

.PARAMETER TimeoutSeconds
Optional timeout in seconds. Use 0 to wait indefinitely.

.PARAMETER EngineArgument
Additional arguments passed to AlteryxEngineCmd.exe after the workflow path.

.PARAMETER Json
Emit structured JSON instead of plain text.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $WorkflowPath,

    [string] $EnginePath,
    [string] $DesignerRoot,
    [string] $WorkingDirectory,
    [int] $TimeoutSeconds = 0,
    [string[]] $EngineArgument = @(),
    [switch] $Json
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

# Load shared discovery utilities relative to this script's path
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Path $MyInvocation.MyCommand.Path -Parent } else { "." }
. (Join-Path $scriptDir "AlteryxDiscoveryUtils.ps1")

function Get-CandidateEnginePaths {
    param(
        [string] $ExplicitEnginePath,
        [string] $ExplicitDesignerRoot
    )

    $paths = [System.Collections.Generic.List[string]]::new()
    Add-CandidatePath -Paths $paths -Path $ExplicitEnginePath
    Add-CandidatePath -Paths $paths -Path $env:ALTERYX_ENGINE_EXE

    $roots = Get-CandidateDesignerRoots -ExplicitDesignerRoot $ExplicitDesignerRoot

    foreach ($root in $roots) {
        Add-CandidatePath -Paths $paths -Path (Join-Path $root "bin\AlteryxEngineCmd.exe")
        Add-CandidatePath -Paths $paths -Path (Join-Path $root "AlteryxEngineCmd.exe")
    }

    return $paths
}

function ConvertTo-WindowsCommandLineArgument {
    param([string] $Argument)

    if ($null -eq $Argument) {
        return '""'
    }
    if ($Argument.Length -eq 0) {
        return '""'
    }
    if ($Argument -notmatch '[\s"]') {
        return $Argument
    }

    $builder = New-Object System.Text.StringBuilder
    [void] $builder.Append('"')
    $backslashCount = 0

    foreach ($char in $Argument.ToCharArray()) {
        if ($char -eq '\') {
            $backslashCount++
            continue
        }

        if ($char -eq '"') {
            [void] $builder.Append(('\' * (($backslashCount * 2) + 1)))
            [void] $builder.Append('"')
            $backslashCount = 0
            continue
        }

        if ($backslashCount -gt 0) {
            [void] $builder.Append(('\' * $backslashCount))
            $backslashCount = 0
        }
        [void] $builder.Append($char)
    }

    if ($backslashCount -gt 0) {
        [void] $builder.Append(('\' * ($backslashCount * 2)))
    }
    [void] $builder.Append('"')
    return $builder.ToString()
}

function New-JsonSafeText {
    param([string] $Value)

    if ($null -eq $Value) {
        return ""
    }
    return $Value
}

function Write-StructuredErrorAndExit {
    param(
        [int] $Code,
        [string] $ErrorCode,
        [string] $Message,
        [object] $Extra = $null
    )

    if ($Json) {
        $payload = [ordered]@{
            error = $ErrorCode
            message = $Message
        }
        if ($null -ne $Extra) {
            foreach ($property in $Extra.PSObject.Properties) {
                $payload[$property.Name] = $property.Value
            }
        }
        [Console]::Error.WriteLine(([pscustomobject]$payload | ConvertTo-Json -Depth 6))
    } else {
        [Console]::Error.WriteLine($Message)
    }
    exit $Code
}

function Invoke-ProcessCapture {
    param(
        [string] $FilePath,
        [string[]] $ArgumentList,
        [string] $WorkingDirectory,
        [int] $TimeoutSeconds
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.Arguments = (($ArgumentList | ForEach-Object {
                ConvertTo-WindowsCommandLineArgument -Argument $_
            }) -join " ")
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    try {
        try {
            if (-not $process.Start()) {
                throw "Failed to start process: $FilePath"
            }
        } catch [System.Exception] {
            Write-StructuredErrorAndExit -Code 4 -ErrorCode "engine_startup_failed" -Message "Failed to start Alteryx engine process: $($_.Exception.Message)"
        }

        # Start asynchronous reading of standard output and standard error streams
        # to prevent deadlocks when the child process writes heavily to them.
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        $timedOut = $false
        if ($TimeoutSeconds -gt 0) {
            if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
                $timedOut = $true
                if (-not $process.HasExited) {
                    try {
                        $process.Kill()
                    } catch {
                        # Suppress any exceptions if the process has already exited
                    }
                }
            }
        }

        $process.WaitForExit()
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result

        return [pscustomobject]@{
            timed_out = $timedOut
            exit_code = $process.ExitCode
            stdout = $stdout.TrimEnd("`r", "`n")
            stderr = $stderr.TrimEnd("`r", "`n")
        }
    } finally {
        if ($null -ne $process) {
            $process.Dispose()
        }
    }
}

$workflow = Resolve-Path -Path $WorkflowPath -ErrorAction SilentlyContinue
if ($null -eq $workflow) {
    Write-StructuredErrorAndExit -Code 2 -ErrorCode "workflow_not_found" -Message "Workflow not found: $WorkflowPath"
}
$workflowPathResolved = $workflow.Path

$checkedEnginePaths = @()
$enginePathResolved = $null
foreach ($candidate in Get-CandidateEnginePaths -ExplicitEnginePath $EnginePath -ExplicitDesignerRoot $DesignerRoot) {
    $checkedEnginePaths += $candidate
    if (Test-Path -Path $candidate -PathType Leaf) {
        $enginePathResolved = (Resolve-Path -Path $candidate).Path
        break
    }
}

if ($null -eq $enginePathResolved) {
    $extra = [pscustomobject]@{
        checked_paths = $checkedEnginePaths
    }
    Write-StructuredErrorAndExit -Code 1 -ErrorCode "engine_not_found" -Message "Could not find AlteryxEngineCmd.exe. Checked paths: $($checkedEnginePaths -join '; ')" -Extra $extra
}

$cwd = if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) {
    Split-Path -Path $workflowPathResolved -Parent
} else {
    $resolvedWorkingDirectory = Resolve-Path -Path $WorkingDirectory -ErrorAction SilentlyContinue
    if ($null -eq $resolvedWorkingDirectory) {
        Write-StructuredErrorAndExit -Code 3 -ErrorCode "working_directory_not_found" -Message "Working directory not found: $WorkingDirectory"
    }
    $resolvedWorkingDirectory.Path
}

$execution = Invoke-ProcessCapture -FilePath $enginePathResolved -ArgumentList (@($workflowPathResolved) + $EngineArgument) -WorkingDirectory $cwd -TimeoutSeconds $TimeoutSeconds

if ($execution.timed_out) {
    $timeoutResult = [pscustomobject]@{
        status = "timeout"
        timeout_seconds = $TimeoutSeconds
        exit_code = 124
        engine = $enginePathResolved
        workflow = $workflowPathResolved
        cwd = $cwd
        stdout = (New-JsonSafeText -Value $execution.stdout)
        stderr = (New-JsonSafeText -Value $execution.stderr)
    }
    if ($Json) {
        $timeoutResult | ConvertTo-Json -Depth 6
    } else {
        [Console]::Error.WriteLine("Workflow run timed out after $TimeoutSeconds seconds.")
        if ($execution.stdout) { $execution.stdout }
        if ($execution.stderr) { [Console]::Error.WriteLine($execution.stderr) }
    }
    exit 124
}

$exitCode = [int]$execution.exit_code
$result = [pscustomobject]@{
    status = if ($exitCode -eq 0) { "success" } else { "failed" }
    exit_code = $exitCode
    engine = $enginePathResolved
    workflow = $workflowPathResolved
    cwd = $cwd
    stdout = (New-JsonSafeText -Value $execution.stdout)
    stderr = (New-JsonSafeText -Value $execution.stderr)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    if ($execution.stdout) { $execution.stdout }
    if ($execution.stderr) { [Console]::Error.WriteLine($execution.stderr) }
    "AlteryxEngineCmd exited with code $exitCode."
}

exit $exitCode
