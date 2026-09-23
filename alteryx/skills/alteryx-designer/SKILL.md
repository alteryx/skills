---
name: alteryx-designer
description: Inspect, build, edit, run, repair, and validate Alteryx workflows, macros, and analytic apps, including `.yxmd`, `.yxmc`, and `.yxwz` artifacts. Use for data preparation, reconciliation, compliance reporting, operational analytics, governed calculations, file transformations, joins, filters, summaries, formulas, macro/app interfaces, execution failures, or output validation. Prefer the Alteryx MCP workflow tools and fall back to workflow XML, Designer samples, bundled scripts, and `AlteryxEngineCmd.exe` only when the required MCP capabilities are unavailable.
---

# Alteryx Designer

Use this skill to build and validate Alteryx workflows locally or in the cloud. The build loop, safety rules, and completion bar are the same everywhere; only the target identifier, tool namespace, and available operations change.

## Select One Execution Path

1. Establish the target, its inputs, expected outputs, and artifact type.
2. Identify the target's environment from the user's request. If the request is unclear, try in this order:
   1. Local mode if `alteryx_local__*` or `designer_local__*` tools available
   2. Cloud mode if `designer__*` tools available
   3. Local fallback mode ONLY if neither MCP toolsets are available and functional
3. Read the build-mode specific guidance. Both Local and cloud mode are documented at `references/building-with-mcp.md`. Fallback mode is documented at `references/building-with-fallback.md`.

You may also use fallback mode for `.yxwz` or custom constructs when MCP does not explicitly support them.

## Mode Contract

| Concern            | Local mode                                 | Cloud mode                   |
|--------------------|--------------------------------------------|------------------------------|
| Target identifier  | `file_path` (absolute)                     | `workflow_id`                |
| Workflow tools     | `alteryx_local__*` / `designer_local__*`   | `designer__*`, `formulas__*` |
| Durable state      | The local `.yxmd` / `.yxmc` / `.yxwz` file | Alteryx One workflow storage |
| Input/output data  | Direct reference or governed datasets      | Governed datasets only       |
| MCP server         | `alteryx-local` (Designer 2026.2+)         | `alteryx`                    |
| Fallback available | Yes — XML and `AlteryxEngineCmd.exe`       | No                           |

Client prefixes vary. Use the exact tool names the active client exposes rather than inventing names.

## Build With Native Designer Tools

Compose workflows from native Designer tools. When the native approach is unclear, use tool discovery and knowledge search, or ask.

Use a code tool (Python, R, or Run Command) ONLY when the requirement cannot be met natively: state the specific gap, get user approval, and scope the code to that gap with native tools on both sides of it.

## Ground The Build Before Building

When the request depends on assets or data that may already exist — reusable logic, a canonical dataset, an example of an unsupported tool's XML — use `alteryx-asset-discovery` to find and verify them before designing the workflow. Do not duplicate business logic that already exists.

Always discover the Designer tools available in the environment before making any modifications.

## Build Loop

1. Decompose the problem into an ordered list of named Designer tools.
2. Discover configuration evidence for the tools as needed.
3. Apply a batch of related mutations.
4. Run the workflow or refresh metadata.
5. Inspect run messages, get metadata, or sample data as required.
6. Repair any errors. If there are more mutations required, restart the loop.

## Build Rules

- Do not claim success based only on a mutation. Completion requires a successful run and evidence that relevant outputs satisfy the request.
- For formulas, read `references/formula-syntax.md`. Validate complex formulas before use when formula validation is available.
- Never expose or embed credentials, connection strings, DCM payloads, or sensitive values unless the user explicitly provides and approves them.

## Completion And Response

Verify all applicable evidence:

- The workflow is composed of native Designer tools. Any code tool present was approved by the user.
- The requested workflow structure contains the expected changes.
- The workflow run succeeded and produced substantive diagnostics.
- Expected files, databases, metadata, or sampled anchor results were created or updated.
- The inspected output evidence supports the requested business logic.

Summarize the selected execution path, the target identifier, what changed, the run result, the evidence checked, and any remaining user action.