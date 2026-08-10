---
name: alteryx-designer
description: Inspect, build, edit, run, repair, and validate Alteryx workflows, macros, and analytic apps, including `.yxmd`, `.yxmc`, and `.yxwz` artifacts. Use for data preparation, reconciliation, compliance reporting, operational analytics, governed calculations, file transformations, joins, filters, summaries, formulas, macro/app interfaces, execution failures, or output validation. Prefer the Alteryx MCP workflow tools and fall back to workflow XML, Designer samples, bundled scripts, and `AlteryxEngineCmd.exe` only when the required MCP capabilities are unavailable.
---

# Alteryx Designer

Use this skill to build and validate Alteryx workflows locally or in the cloud. The build loop, safety rules, and completion bar are the same everywhere; only the target identifier, tool namespace, and available operations change.

## Select One Execution Path

1. Establish the target, its inputs, expected outputs, artifact type, and whether the task is create, inspect, edit, run, or repair.
2. Identify the target's environment. A local absolute file path means local mode. An Alteryx One workflow ID, or a request scoped to a cloud workspace, means cloud mode. Ask when the request names neither.
3. Inspect the workflow tools the client actually exposes. Select the MCP path for that mode when it exposes the operations the task requires. Read `references/building-with-mcp.md` before the first MCP workflow call; it covers both local and cloud targets.
4. Select the local XML/scripts fallback only when the required local MCP operations are absent, the local server cannot start, or the requested artifact or operation is unsupported. Tell the user fallback is active, then read `references/building-with-fallback.md`. There is no fallback for cloud workflows: without the cloud tools, report the blocker.
5. Choose the path before the first mutation. Do not mix MCP mutations with direct XML edits in the same build loop, do not mix local and cloud targets in one loop, and do not silently switch paths after a mutation. If a backend fails after a mutation, inspect its persisted state and repair through that same backend or stop with a clear blocker.

Treat capability availability, not a server name alone, as decisive. An MCP server that lacks a required create, edit, run, or inspection operation does not cover that task. Use the fallback for `.yxwz` or custom constructs when local MCP does not explicitly support them.

## Mode Contract

| Concern            | Local mode                                 | Cloud mode                   |
|--------------------|--------------------------------------------|------------------------------|
| Target identifier  | `file_path` (absolute)                     | `workflow_id`                |
| Workflow tools     | `alteryx_local.*`                          | `designer__*`, `formulas__*` |
| Durable state      | The local `.yxmd` / `.yxmc` / `.yxwz` file | Alteryx One workflow storage |
| Input/output data  | Direct reference or governed datasets      | Governed datasets only       |
| MCP server         | `alteryx-local` (stdio)                    | `alteryx` (HTTP)             |
| Fallback available | Yes — XML and `AlteryxEngineCmd.exe`       | No                           |

Client prefixes vary. Use the exact tool names the active client exposes rather than inventing names.

## Build With Native Designer Tools

Compose workflows from native Designer tools. Assume a native tool exists until discovery shows otherwise. Use a code tool (Python, R, or Run Command) only when the requirement cannot be met natively: state the specific gap, get user approval, and scope the code to that gap with native tools on both sides of it.

When the native approach is unclear, use tool discovery and knowledge search, or ask.

## Ground The Build Before Building

When the request depends on assets or data that may already exist — reusable logic, a canonical dataset, an example of an unsupported tool's XML — use `alteryx-asset-discovery` to find and verify them before designing the workflow. Do not duplicate business logic that already exists, and do not invent a schema you could have verified.

Discovery is not only for cloud builds. A local workflow can read or write a governed dataset, and existing workflows in either place are evidence for the one you are about to build.

## Standard Build Loop

1. Inspect the existing workflow before changing it.
2. Decompose the request into an ordered list of named Designer tools before the first mutation.
3. Discover supported tools and configuration evidence as needed.
4. Make the smallest useful mutation.
5. Run the workflow after meaningful changes.
6. Inspect run messages and relevant output evidence.
7. Repair and rerun until the workflow satisfies the request or a blocking condition is clear.

Do not claim success based only on a saved mutation or valid XML. Completion requires saved changes, a successful Engine-backed run unless execution is explicitly out of scope or blocked, and evidence that relevant outputs satisfy the request.

## Shared Rules

- Preserve the existing AMP/E2 versus legacy E1 setting during unrelated edits. Use AMP/E2 for new workflows unless the user explicitly requests E1.
- Make small, reversible changes and validate incrementally.
- Treat workflow overwrites, tool removal, connection replacement, and broad rewrites as destructive operations.
- Treat run context, metadata, and sampled output as stale after every mutation.
- Batch related execution-affecting canvas mutations, then refresh metadata once. Skip the refresh when a run is next, because a run also applies and persists metadata updates.
- Prefer installed, schema-backed, or locally observed tool configuration over invented configuration.
- For formulas, read `references/formula-syntax.md`. Validate complex formulas before use when the selected path supports formula validation, then validate them again through workflow execution.
- Never expose or embed credentials, connection strings, DCM payloads, or sensitive values unless the user explicitly provides and approves them.
- Inspect only the metadata and sampled data needed to validate the request. Do not load full datasets into context.
- Report authentication, licensing, entitlement, permission, unsupported-version, and unavailable-plugin failures as blockers instead of working around them.

## Completion And Response

Verify all applicable evidence:

- The workflow is composed of native Designer tools. Any code tool present was approved by the user.
- The requested workflow changes are saved to the intended target — the local path or the cloud workflow.
- The Engine-backed run succeeded and produced substantive diagnostics, not only start/finish banners.
- Expected files, databases, metadata, or sampled anchor results were created or updated.
- The inspected output evidence supports the requested business logic.

Summarize the selected execution path, the target identifier, what changed, the run result, the evidence checked, and any remaining user action. Do not dump full workflow XML, sensitive configuration, or large data samples unless the user explicitly asks.
