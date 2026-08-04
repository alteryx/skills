# Building With The XML And Script Fallback

Use this reference only when the required local Alteryx MCP workflow operations are unavailable or do not support the requested artifact or operation. Tell the user when fallback mode is active.

Fallback mode edits workflow XML directly, learns exact structures from installed local evidence, and runs workflows with the bundled PowerShell scripts and `AlteryxEngineCmd.exe`.

## Fallback Process

1. Discover the local Designer install and sample workflows with `scripts/Find-DesignerSampleWorkflows.ps1`.
2. Inspect an existing `.yxmd`, `.yxmc`, or `.yxwz` before changing it. Preserve root attributes, tool IDs, connections, anchors, annotations, metadata, layout, and runtime properties unless the request requires changing them.
3. Identify the effective AMP/E2 engine flags before editing and preserve them during unrelated changes.
4. Read `workflow-xml.md` before structural edits involving nodes, connections, containers, root properties, runtime properties, metadata, annotations, AMP/E2 flags, or macro/app interface wiring.
5. Use `designer-tool-reference.yaml` to identify likely tool names, plugin names, palettes, and anchors. Treat it as a discovery aid, not an authoritative schema.
6. Verify exact XML shape from existing workflows, Designer samples, installed macros, or installed tool package files whenever possible.
7. Make the smallest useful XML edit with structured XML tooling when practical.
8. Run the workflow with `scripts/Invoke-AlteryxWorkflow.ps1`. Use a normal run to validate end-to-end behavior and generated outputs. Use a full update run to validate configuration and schema propagation without passing records between tools.
9. Inspect Engine stdout/stderr and apply the verification rules for the selected run type. Repair and rerun until execution and the applicable validation succeed or a blocker is clear.

## Available Scripts

Run scripts with PowerShell from the skill directory or use absolute paths.

- `scripts/Get-DesignerVersion.ps1`: Discover the installed Designer/Engine version.
- `scripts/Find-DesignerSampleWorkflows.ps1`: Locate Designer samples and the install root.
- `scripts/Invoke-AlteryxWorkflow.ps1`: Run a workflow with `AlteryxEngineCmd.exe`.

The scripts try explicit arguments, environment variables, registry keys, Windows uninstall entries, and common `Program Files` paths. If discovery fails, ask for the Designer install path and retry with `-DesignerRoot`.

## XML Rules

- Prefer known-good XML copied from local installed evidence over invented tool XML.
- Use unique tool IDs when adding tools. Treat IDs as document-wide, including nodes inside `ChildNodes`.
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

Use:

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

Run native Engine execution in a normal host context. Some agent sandboxes can return exit code `0` while preventing real output materialization. After every run verify:

- The process exit code is `0`.
- stdout/stderr contains substantive workflow diagnostics, not only banner/start/finish lines.
- For a normal run, expected output files, databases, or sampled results were created or updated.

Treat banner-only output or missing diagnostics as an indeterminate failed run. For a normal run, treat missing expected outputs the same way. Rerun with approved host access or give the user the exact command to run in a normal terminal.

### Full Update Runs

For any workflow, use a full update run to validate tool configuration and propagate field metadata without passing records between tools.

1. Temporarily add `updateMode="Full"` to the workflow's root element while preserving its other attributes:

   ```xml
   <AlteryxDocument updateMode="Full" ...>
   ```

2. Run the workflow through `scripts/Invoke-AlteryxWorkflow.ps1` using the same command as a normal run.
3. Restore the root element to its original state after the run, even when the Engine fails.
4. Require exit code `0` and inspect Engine diagnostics. Configuration errors produce diagnostic details and a nonzero exit code.

Because records are not passed between tools, normal record-processing behavior, workflow events, and output writing do not occur. Input tools may still access their configured sources to obtain field metadata.

`AlteryxEngineCmd.exe` does not save metadata or configuration updates emitted by the Engine during the run. Treat a command-line full update as validation only, and follow it with a normal run when end-to-end behavior must be verified.
