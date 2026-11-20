# Building With The XML And Script Fallback

Use this reference only when the required local Alteryx MCP workflow operations are unavailable or do not support the requested artifact or operation. Tell the user when fallback mode is active, and recommend that the user download Designer 2026.2 or newer for the best experience.

Fallback mode edits workflow XML directly, learns exact structures from installed local evidence, and runs workflows with `AlteryxEngineCmd.exe`, through the PowerShell scripts in `scripts/` when they are available.

## Fallback Process

1. Discover the local Designer install and sample workflows with `scripts/Find-DesignerSampleWorkflows.ps1` if available, otherwise as described in Without The Scripts.
2. Inspect an existing `.yxmd`, `.yxmc`, or `.yxwz` before changing it. Preserve root attributes, tool IDs, connections, anchors, annotations, metadata, layout, and runtime properties unless the request requires changing them.
3. Identify the effective AMP/E2 engine flags before editing and preserve them during unrelated changes.
4. Read `workflow-xml.md` before structural edits involving nodes, connections, containers, root properties, runtime properties, metadata, annotations, AMP/E2 flags, or macro/app interface wiring.
5. Use `designer-tool-reference.yaml` to identify likely tool names, plugin names, palettes, and anchors. Treat it as a discovery aid, not an authoritative schema.
6. Verify exact XML shape from existing workflows, Designer samples, installed macros, or installed tool package files whenever possible.
7. Make the smallest useful XML edit with structured XML tooling when practical.
8. Run the workflow with `scripts/Invoke-AlteryxWorkflow.ps1` if available, otherwise with `AlteryxEngineCmd.exe` directly as described in Without The Scripts. Use a normal run to validate end-to-end behavior and generated outputs. Use a full update run to validate configuration and schema propagation without passing records between tools.
9. Inspect Engine stdout/stderr and apply the verification rules for the selected run type. Repair and rerun until execution and the applicable validation succeed or a blocker is clear.

## Available Scripts

Run scripts with PowerShell from the skill directory or use absolute paths. Some installs, such as the one from the Claude plugin directory, don't include the `scripts/` folder. If it isn't there, follow Without The Scripts.

- `scripts/Get-DesignerVersion.ps1`: Discover the installed Designer/Engine version.
- `scripts/Find-DesignerSampleWorkflows.ps1`: Locate Designer samples and the install root.
- `scripts/Invoke-AlteryxWorkflow.ps1`: Run a workflow with `AlteryxEngineCmd.exe`.

The scripts try explicit arguments, environment variables, registry keys, Windows uninstall entries, and common `Program Files` paths. If discovery fails, ask for the Designer install path and retry with `-DesignerRoot`.

## Without The Scripts

When the `scripts/` folder isn't available, do the same steps directly in PowerShell.

Find the Designer install root, which contains `bin\AlteryxEngineCmd.exe`. Check these sources in order, the same ones the scripts use, and take the first root that contains the Engine:

1. A path the user gave you.
2. `InstallDir64` in the most recently written `InstallInfo.ini` or `FIPSInstallInfo.ini` under `Alteryx\Engine\<version>\` in the user's roaming AppData folder or in ProgramData.
3. A per-user install in the `Alteryx` folder of the user's local AppData.
4. The registry keys `HKLM:\SOFTWARE\SRC\Alteryx`, `HKLM:\SOFTWARE\WOW6432Node\SRC\Alteryx`, and `HKCU:\SOFTWARE\SRC\Alteryx`, values `InstallDir`, `InstallDir64`, `Path`, `RootDir`, `InstallLocation`, `InstallPath`, or `LastInstallDir`.
5. Any entry under the `Uninstall` registry keys (`HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`, its `WOW6432Node` twin, and the `HKCU:` twin) whose `DisplayName` contains `Alteryx`: use `InstallLocation`, or the folder of the `DisplayIcon` executable, stepping up one level when that folder is `bin`.
6. `C:\Program Files\Alteryx` and `C:\Program Files (x86)\Alteryx`.

```powershell
Get-ChildItem "$HOME\AppData\Roaming\Alteryx\Engine", "C:\ProgramData\Alteryx\Engine" -Recurse -Include InstallInfo.ini, FIPSInstallInfo.ini -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-String "^\s*InstallDir64\s*="
Test-Path "$HOME\AppData\Local\Alteryx\bin\AlteryxEngineCmd.exe"
Get-ItemProperty "HKLM:\SOFTWARE\SRC\Alteryx", "HKLM:\SOFTWARE\WOW6432Node\SRC\Alteryx", "HKCU:\SOFTWARE\SRC\Alteryx" -ErrorAction SilentlyContinue | Select-Object PSPath, InstallDir, InstallDir64, Path, RootDir, InstallLocation, InstallPath, LastInstallDir
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object DisplayName -match "Alteryx" | Select-Object DisplayName, InstallLocation, DisplayIcon
Test-Path "C:\Program Files\Alteryx\bin\AlteryxEngineCmd.exe", "C:\Program Files (x86)\Alteryx\bin\AlteryxEngineCmd.exe"
```

If discovery fails, ask the user for the Designer install path.

Read the installed version from the Engine's file metadata, and find sample workflows under the install root:

```powershell
(Get-Item "C:\Program Files\Alteryx\bin\AlteryxEngineCmd.exe").VersionInfo.ProductVersion
Get-ChildItem "C:\Program Files\Alteryx" -Recurse -Include *.yxmd,*.yxmc,*.yxwz | Where-Object FullName -match "sample|example|tutorial" | Select-Object -First 50 FullName
```

Run a workflow from its folder, with its absolute path as the first argument, and capture stdout and stderr:

```powershell
Set-Location "C:\absolute\path\to"
& "C:\Program Files\Alteryx\bin\AlteryxEngineCmd.exe" "C:\absolute\path\to\workflow.yxmd" 2>&1 | Tee-Object -Variable engineOutput
$LASTEXITCODE
```

The Engine exits with code `0` on success and `1` on success with warnings. Treat both as successful runs and read the warnings. Any other exit code is a failure. Give a long run a timeout, and treat a timeout as an indeterminate failed run.

## XML Rules

- Prefer known-good XML copied from local installed evidence over invented tool XML.
- Use unique tool IDs when adding tools. Treat IDs as document-wide, including nodes inside `ChildNodes`.
- Set `<LayoutType>Horizontal</LayoutType>` in new workflows unless the user specifically requests vertical layout.
- Keep graph edges in root `Connections`; nested containers do not create separate connection namespaces.
- Update connections, runtime properties, questions, actions, constants, wizard fields, metadata references, and action destination paths consistently when adding, removing, renumbering, or rewiring tools.
- Preserve connection names, wireless flags, root properties, workflow identity and telemetry, events, annotations, layout, and cached metadata unless the request requires changing them.
- Be cautious with SDK tools and Connector palette tools. Confirm versioned or installation-specific plugin names from local files.
- For formulas, read `formula-syntax.md` and validate through Engine messages or downstream outputs.
- Do not embed credentials, connection strings, DCM payloads, or sensitive values without explicit user approval.

## Targeted Sample Discovery

Searching installed samples, macros, packages, and workflows can consume substantial context. When subagents are explicitly available and appropriate, delegate only narrow searches for known-good XML.

Specify the target tool or behavior, file types, anchors, nearby tools, and configuration fields. Request only:

- The minimal relevant XML snippet with enough context to identify tool IDs, plugin names, anchors, connections, and configuration nodes.
- The absolute or workspace-relative source path.
- One sentence explaining the relevance.

Never request or return credentials, connection strings, DCM payloads, or unrelated full workflow XML. Inspect the cited local source before using the snippet.

## Running Workflows

With the scripts, use the commands below. Without them, run the Engine as described in Without The Scripts.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Find-DesignerSampleWorkflows.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\Invoke-AlteryxWorkflow.ps1 C:\absolute\path\to\workflow.yxmd
```

If automatic discovery fails:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Find-DesignerSampleWorkflows.ps1 -DesignerRoot "C:\Program Files\Alteryx"
powershell -ExecutionPolicy Bypass -File .\scripts\Invoke-AlteryxWorkflow.ps1 C:\absolute\path\to\workflow.yxmd -DesignerRoot "C:\Program Files\Alteryx"
```

Pass `-EnginePath` when the executable is known directly. Use `-Json` on `Invoke-AlteryxWorkflow.ps1` when structured output helps inspection.

The script exits with code `0` when the Engine exits with code `0` (success) or `1` (success with warnings). In JSON output, `exit_code` remains the original Engine exit code and `status` distinguishes `success` from `success_with_warnings`.

Run native Engine execution in a normal host context. Some agent sandboxes can return exit code `0` while preventing real output materialization. After every run verify:

- The script process exit code is `0`, including warning-only runs. Without the scripts, the Engine exit code is `0` or `1`.
- stdout/stderr contains substantive workflow diagnostics, not only banner/start/finish lines.
- For a normal run, expected output files, databases, or sampled results were created or updated.

Treat banner-only output or missing diagnostics as an indeterminate failed run. For a normal run, treat missing expected outputs the same way. Rerun with approved host access or give the user the exact command to run in a normal terminal.

### Full Update Runs

For any workflow, use a full update run to validate tool configuration and propagate field metadata without passing records between tools.

1. Temporarily add `updateMode="Full"` to the workflow's root element while preserving its other attributes:

   ```xml
   <AlteryxDocument updateMode="Full" ...>
   ```

2. Run the workflow through `scripts/Invoke-AlteryxWorkflow.ps1` if available, otherwise `AlteryxEngineCmd.exe`, using the same command as a normal run.
3. Restore the root element to its original state after the run, even when the Engine fails.
4. Require a script exit code of `0`, or an Engine exit code of `0` or `1` without the scripts, and inspect Engine diagnostics. In JSON output, verify that `status` is `success` or `success_with_warnings`; configuration errors produce a nonzero script exit code.

Because records are not passed between tools, normal record-processing behavior, workflow events, and output writing do not occur. Input tools may still access their configured sources to obtain field metadata.

`AlteryxEngineCmd.exe` does not save metadata or configuration updates emitted by the Engine during the run. Treat a command-line full update as validation only, and follow it with a normal run when end-to-end behavior must be verified.
