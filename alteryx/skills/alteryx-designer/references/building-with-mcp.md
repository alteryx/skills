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

For a cloud target:

- Never construct or guess a `workflow_id`. Get it from the user, or from `alteryx-asset-discovery`, which returns stable identifiers for the assets it finds.
- A cloud workflow has no local file. Do not report a path for it or claim a local artifact was written.

## Semantic Operations

Map the active MCP tools to these operations. Require only the operations the current task needs.

| Semantic operation              | Purpose                                       |
|---------------------------------|-----------------------------------------------|
| `get_available_tools`           | List supported Designer tools                 |
| `get_tool_configuration_schema` | Get schema-backed tool configuration          |
| `get_condensed_workflow`        | Inspect workflow structure and configuration  |
| `validate_formula`              | Validate an Alteryx formula                   |
| `create_workflow`               | Create a workflow                             |
| `add_tool`                      | Add and connect a schema-supported tool       |
| `edit_tool`                     | Edit a schema-supported tool                  |
| `add_custom_tool_with_xml`      | Add a custom or unsupported XML tool          |
| `edit_custom_tool_with_xml`     | Edit a custom or unsupported XML tool         |
| `remove_tool`                   | Remove a tool                                 |
| `replace_tool_connections`      | Replace or update connections                 |
| `refresh_metadata`              | Validate configuration and refresh metadata   |
| `run_workflow`                  | Run the workflow through the Alteryx Engine   |
| `get_metadata`                  | Inspect persisted field names and types       |
| `get_data_at_anchor`            | Sample data at an output anchor               |
| `add_tools_to_container`        | Create or populate a tool/control container   |
| `remove_tools_from_container`   | Move tools out of a container                 |
| `delete_container`              | Delete a container while preserving its tools |
| `set_container_enabled`         | Enable or disable a container                 |
| `update_tool_positions`         | Update tool positions on the canvas           |
| `annotate_tool`                 | Update a tool's name and annotation           |
| `update_workflow_description`   | Set or clear the workflow description         |

Local tools may appear with an `alteryx_local` namespace and cloud tools with a `designer` or `formulas` namespace. Use the exact names and schemas the active client exposes rather than inventing names.

Not all tools are necessarily available for both modes. Check what the client exposes and say so when a request cannot be satisfied.

## Helpers

Two capabilities sit outside the operations above. They are not workflow operations, they take no workflow identifier, and they are equally relevant to local and cloud work.

### Knowledge Search

`knowledge__search_knowledge_sources` answers what the product supports. Use it when the appropriate Designer tool, configuration approach, formula behavior, or recommended workflow pattern is unclear. Do not search routinely when the required configuration is already established.

Provide both required inputs:

- `query`: A focused question or set of search terms describing the specific information needed.
- `intent`: A short statement of the workflow outcome the user is trying to achieve.

Prefer a few targeted searches over broad discovery. Use returned documentation chunks to guide tool choice and configuration, but treat exposed tool schemas and installed capabilities as authoritative for mutations. Summarize only the relevant guidance; do not copy large documentation passages into context or user-facing responses.

### Asset Discovery

The `alteryx-asset-discovery` skill answers what already exists in this environment. Use it to find reusable logic, locate and verify a canonical dataset, or find example configuration XML for a tool with no configuration schema.

## MCP Build Process

1. Inspect an existing artifact with the condensed-workflow operation before mutation.
2. Discover available Designer tools when the requested tool support is not already established.
3. Get the configuration schema before adding or editing a schema-supported tool unless the exact current schema is already present in task context.
4. Use human-readable Designer tool names expected by the schema, such as `Filter`, `Formula`, or `Summarize`.
5. Make one small mutation at a time and retain the returned identifiers needed by later calls, such as an assigned `tool_id`.
6. Run the workflow after changes that require execution or output validation.
7. Inspect run messages, relevant metadata, and small anchor samples as needed.
8. Repair through MCP and rerun until validation succeeds or a blocker is clear.

## Configuration Rules

- Prefer schema-driven add/edit operations over custom XML.
- Use custom XML operations only when schema-driven configuration cannot express the required installed tool, custom macro, interface construct, or analytic app behavior.
- Manage containers with the container operations. Use `annotate_tool`, `update_tool_positions`, and `update_workflow_description` for their respective changes.
- `delete_container` removes the container and moves its contained tools to the parent canvas. To delete an individual tool, use `remove_tool`.
- Do not directly edit a local workflow file while using MCP.
- Gather upstream metadata before authoring field-dependent formulas or configurations.
- Read `formula-syntax.md` for formulas. Use formula validation when exposed, then confirm behavior with a workflow run.
- Preserve the existing engine selection unless the user requests a change. Use AMP/E2 for new workflows when the create operation exposes that choice.
- Confirm custom and connector tool availability instead of assuming a plugin or package is installed. Availability differs between a local Designer install and a cloud workspace.

## Dataset Inputs And Outputs

Input Data and Output Data tools can read and write data (1) via a file path or other direct configuration or (2) via a governed dataset referenced by `dataset_id`. A local workflow may use either direct configuration or a dataset reference. A cloud workflow MUST use datasets only.

- Never guess a `dataset_id`. For a dataset that already exists, take it from the user or from `alteryx-asset-discovery`.
- To write to a dataset that does not exist yet, call `datasets__create_empty_dataset` first, then configure the Output Data tool with the `dataset_id` it returns.

## Run, Metadata, And Validation Rules

- Call `run_workflow` before `get_data_at_anchor`; anchor data comes from the latest successful run.
- Call either `run_workflow` or `refresh_metadata` before `get_metadata`.
- `refresh_metadata` validates tool configuration and persists metadata updates without processing records. Use `run_workflow` to validate record-dependent behavior and outputs.
- Batch related execution-affecting mutations and refresh once. Skip the refresh entirely when `run_workflow` is next.
- Annotation, position, and description changes do not require a workflow run.
- Assume all prior run context and samples are invalid after mutation.
- Use run messages to identify the failing tool and inspect its immediate upstream metadata when possible.
- Verify field names and data types with metadata rather than inferring them from configuration.
- Validate transformations and outputs with the smallest useful anchor sample.
- A successful engine run does not prove logical correctness. Sample the output and check it against the original business intent before reporting completion.
- Stop and report authentication, licensing, entitlement, permission, unsupported-version, or unavailable-plugin errors clearly.
- Treat a successful tool call as mutation evidence, not workflow-completion evidence.
