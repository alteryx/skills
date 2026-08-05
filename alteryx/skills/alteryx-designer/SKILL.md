---
name: alteryx-designer
description: Inspect, build, edit, run, repair, and validate local Alteryx Designer workflows, macros, and analytic apps. Use for `.yxmd`, `.yxmc`, and `.yxwz` work involving data preparation, reconciliation, compliance reporting, operational analytics, governed calculations, file transformations, joins, filters, summaries, formulas, macro/app interfaces, execution failures, or output validation. Prefer installed Alteryx MCP workflow tools and fall back to local workflow XML, Designer samples, bundled scripts, and `AlteryxEngineCmd.exe` when the required MCP capabilities are unavailable.
---

# Alteryx Designer

Use this skill for local Alteryx Designer work. Operate on local `.yxmd` workflows, `.yxmc` macros, `.yxwz` analytic apps, input files, Designer samples, and Engine execution.

## Select One Execution Path

1. Establish the absolute target path, input files, expected outputs, artifact type, and whether the task is create, inspect, edit, run, or repair.
2. Inspect the workflow-management tools exposed by the client. Select the MCP path when the local Alteryx MCP server exposes the operations required for the task. Read `references/building-with-mcp.md` before the first MCP workflow call.
3. Select the fallback path when the required MCP operations are absent, the server cannot start, or the requested artifact or operation is unsupported. Tell the user that the XML/scripts fallback is active, then read `references/building-with-fallback.md` before inspecting or changing workflow XML.
4. Choose the path before the first mutation. Do not mix MCP mutations with direct XML edits in the same build loop or silently switch paths after a mutation. If a selected backend fails after mutation, inspect its persisted state and repair through that backend or stop with a clear blocker.

Treat capability availability, not a server name alone, as decisive. An MCP server that lacks a required create, edit, run, or inspection operation does not cover that task. Use fallback for `.yxwz` or custom constructs when MCP does not explicitly support them.

## Build With Native Designer Tools

Compose workflows from native Designer tools. Assume a native tool exists until discovery shows otherwise. Use a code tool (Python, R, or Run Command) only when the requirement cannot be met natively: state the specific gap, get user approval, and scope the code to that gap with native tools on both sides of it.

When the native approach is unclear, use tool discovery and knowledge search, or ask.

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
- Prefer installed, schema-backed, or locally observed tool configuration over invented configuration.
- For formulas, read `references/formula-syntax.md`. Validate complex formulas before use when the selected path supports formula validation, then validate them again through workflow execution.
- Never expose or embed credentials, connection strings, DCM payloads, or sensitive values unless the user explicitly provides and approves them.
- Inspect only the metadata and sampled data needed to validate the request. Do not load full datasets into context.

## Completion And Response

Verify all applicable evidence:

- The workflow is composed of native Designer tools. Any code tool present was approved by the user.
- The requested workflow changes are saved at the intended path.
- The Engine-backed run succeeded and produced substantive diagnostics, not only start/finish banners.
- Expected files, databases, metadata, or sampled anchor results were created or updated.
- The inspected output evidence supports the requested business logic.

Summarize the selected execution path, what changed, where the artifact was saved, the run result, and the evidence checked. Do not dump full workflow XML, sensitive configuration, or large data samples unless the user explicitly asks.
