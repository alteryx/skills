---
name: alteryx-designer
description: Inspect, build, edit, run, repair, and validate local Alteryx Designer workflows for repeatable business analysis. Use when an agent needs to create or modify `.yxmd` workflows, `.yxmc` macros, or `.yxwz` analytic apps for data preparation, reconciliation, compliance reporting, operational analytics, governed calculations, file transformations, joins, filters, summaries, formulas, macro/app interfaces, or other Designer-based business logic; inspect existing workflow XML; discover installed Designer samples; run Designer workflows; perform validation runs; diagnose execution failures; or validate workflow outputs.
---

# Alteryx Designer

Use this skill for local Alteryx Designer workflow work only. Operate on `.yxmd` workflows, `.yxmc` macros, `.yxwz` analytic apps, local inputs, local Designer samples, and local Engine execution.

Build workflows by inspecting local evidence, editing workflow XML directly, and running the local Alteryx Engine.

## Standard Process

1. Establish the target workflow path, input files, expected outputs, and whether the task is create, inspect, edit, run, or repair.
2. Discover the local Designer install and sample workflows with `scripts/Find-DesignerSampleWorkflows.ps1`.
3. For existing workflows, inspect the `.yxmd` / `.yxmc` / `.yxwz` XML before changing it. Preserve root attributes, tool IDs, connection anchors, annotations, metadata, and layout unless the requested edit requires changing them.
4. For existing workflows, identify the AMP/E2 engine-selection flags before editing. Preserve the existing AMP/E2 vs legacy E1 setting unless the user explicitly confirms changing it.
5. For structural XML edits, read `references/workflow-xml.md` before changing nodes, connections, containers, root properties, runtime properties, metadata, annotations, AMP/E2 flags, or macro/app interface wiring.
6. For new workflows, use AMP/E2 by default unless the user explicitly asks for the legacy E1 engine.
7. For new or changed tools, use `references/designer-tool-reference.yaml` to identify likely tool names, plugin names, palettes, and anchors.
8. Verify exact XML shape from local evidence whenever possible: existing workflows, Designer sample workflows, installed macro files, or installed tool package files.
9. Make the smallest useful XML edit. Use structured XML tooling when practical rather than ad hoc string replacement.
10. Run the workflow with `scripts/Invoke-AlteryxWorkflow.ps1`. Use a normal run to validate end-to-end behavior and generated outputs. Use a full update run to validate configuration and schema propagation without passing records between tools.
11. Inspect Engine stdout/stderr and apply the verification rules for the selected run type. Repair XML and rerun until the workflow succeeds or a blocking issue is clear.

Do not claim success based only on saved XML. Completion requires saved changes plus a successful Engine run, unless running is explicitly out of scope or blocked by missing local Designer access.

## Subagents

Searching local Designer samples, installed macros, package files, and existing workflows for example XML can consume a large amount of context. When subagents are available, use them to collect narrow examples before adding or repairing tools.

Use subagents for targeted example searches such as:

- Finding known-good XML for a specific Designer tool, plugin name, macro, anchor pattern, or configuration element.
- Comparing how several local workflows express the same pattern, such as joins, formulas, summaries, filters, unions, input/output tools, layout metadata, or connection wiring.
- Locating the smallest source workflow or installed file that demonstrates a needed tool shape.

Keep each subagent request specific. Include the target tool or behavior, relevant file types, expected anchors, nearby tools, and the exact XML fields or configuration shape needed. Ask the subagent to return only:

- The minimal relevant XML snippet, preserving enough surrounding context to identify tool IDs, plugin names, anchors, connections, and configuration nodes.
- The absolute or workspace-relative source file path for each snippet.
- A one-sentence explanation of why the snippet is relevant.

Do not ask subagents to return full workflow XML unless the whole file is the minimal useful example. Do not include credentials, connection strings, DCM payloads, or sensitive values in returned snippets. Use the returned examples as local evidence for the edit, and inspect only the cited source files or snippets needed for the current task.

## Available Scripts

Run scripts with PowerShell from the skill directory, or use absolute paths to the scripts.

- `scripts/Get-DesignerVersion.ps1`: discover the installed Designer/Engine version.
- `scripts/Find-DesignerSampleWorkflows.ps1`: locate Designer sample workflows and the Designer install root.
- `scripts/Invoke-AlteryxWorkflow.ps1`: run a workflow through `AlteryxEngineCmd.exe`.

The scripts try explicit arguments, environment variables, registry keys, Windows uninstall entries, and common `Program Files` paths. If discovery fails, ask the user for the Designer install path and retry with `-DesignerRoot`.

## Tool And XML Rules

- Treat `references/designer-tool-reference.yaml` as a discovery aid, not an authoritative schema.
- Read `references/workflow-xml.md` for non-trivial workflow XML edits, especially changes involving `ToolID` references, root `Connections`, containers, root `Properties`, AMP/E2 engine-selection flags, macro/app `RuntimeProperties`, node-level `MetaInfo`, or annotations.
- Prefer known-good XML copied from local samples or existing workflows over invented tool XML.
- Be cautious with SDK-based tools and Connector palette tools. Plugin names can be versioned or installation-specific; confirm them from local files before adding or repairing those tools.
- Use AMP/E2 for newly created workflows unless the user explicitly requests legacy E1. Some tools require AMP/E2, and AMP/E2 generally performs better, but E1 and AMP/E2 have minor behavioral differences.
- For existing workflows, do not change the effective engine path unless the user confirms it. Preserve existing `RunE2` and `RunWithE2` values during unrelated edits.
- Use unique tool IDs when adding tools.
- Treat `ToolID` values as document-wide, including nodes nested inside `ChildNodes`.
- Keep graph edges in root `Connections`; containers can be nested, and neither ordinary nor nested containers create a separate connection namespace.
- Update connections, runtime properties, questions, actions, constants, wizard fields, metadata references, and action destination paths consistently when adding, removing, renumbering, or rewiring tools.
- Preserve connection names, wireless flags, root properties, workflow identity/telemetry, events, annotations, layout, and cached metadata unless the requested edit requires changing them.
- Keep edits small and run the workflow after each meaningful change.
- For formulas, always read `references/formula-syntax.md`. Validate formulas by running the workflow and checking Engine messages or downstream outputs.
- Do not embed credentials, connection strings, DCM payloads, or sensitive values in workflow XML unless the user explicitly provides and approves them.

## Running Workflows

Run local Engine execution in a normal host execution context. Some agent sandboxes can make native Engine execution appear successful while blocking real output materialization.

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

Use `-Json` on `Invoke-AlteryxWorkflow.ps1` when structured output helps automated inspection.

After every Engine run, verify all of:

- The process exit code is `0`.
- stdout/stderr contains normal diagnostics or workflow messages, not only banner/start/finish lines.
- For a normal run, expected output files, databases, or sampled results were actually created or updated.

Treat banner-only output or missing diagnostics as an indeterminate failed run. For a normal run, treat missing expected outputs the same way. Rerun outside sandbox restrictions or ask the user to run the exact command in a normal terminal.

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

## User-Facing Responses

Summarize what changed, where the workflow was saved, the run result, and the evidence checked. Do not dump full workflow XML or sensitive configuration values unless the user explicitly asks for them.
