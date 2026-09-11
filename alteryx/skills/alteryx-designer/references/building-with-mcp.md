# Building With Alteryx MCP Tools

Use this reference when the client exposes Alteryx MCP workflow-management tools that cover the requested operation. It applies to both local and cloud targets.

## Workflow Identity

Address workflows by their mode-specific identifier:

| Mode  | Identifier                                           | Passed as     |
|-------|------------------------------------------------------|---------------|
| Local | Absolute path to a `.yxmd`, `.yxmc`, or `.yxwz` file | `file_path`   |
| Cloud | The Alteryx One workflow ID                          | `workflow_id` |

```json
{ "file_path": "C:\\absolute\\path\\to\\workflow.yxmd" }
```

```json
{ "workflow_id": "3f9c2b7e-1d4a-4c58-9a02-8e6b1f0d77aa" }
```

## Helpers

Two capabilities are available to assist the build process apart from the core build tools.

### Knowledge Search

Use `knowledge__*` tools to answer what the product supports, when the appropriate Designer tool, configuration approach, formula behavior, or recommended workflow pattern is unclear.

Prefer a few targeted searches over broad discovery.

Use returned documentation chunks to guide tool choice and configuration, but treat exposed tool schemas and installed capabilities as authoritative for mutations.

### Asset Discovery

The `alteryx-asset-discovery` skill answers what already exists in the environment. Use it to find reusable logic, locate and verify a canonical dataset, or find example configuration XML for a tool with no configuration schema.

## MCP Build Rules

- Prefer schema-driven add/edit operations over custom XML.
- Do not directly edit a local workflow file while using MCP.

## Dataset Inputs And Outputs

Input Data and Output Data tools can read and write data via a governed dataset referenced by `dataset_id`.

- Never guess a `dataset_id`. For a dataset that already exists, take it from the user or from `alteryx-asset-discovery`.
- To write to a dataset that does not exist yet, call `datasets__create_empty_dataset` first, then configure the Output Data tool with the `dataset_id` it returns.
