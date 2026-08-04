# Building With Local MCP Tools

Use this reference when the client exposes local Alteryx MCP workflow-management tools that cover the requested operation.

## Workflow Identity

Address local workflows by absolute file path. Use `.yxmd` for workflows, `.yxmc` for macros, and `.yxwz` for analytic apps only when the exposed tools explicitly support that artifact type.

Pass the path through the target field required by the tool schema, normally:

```json
{
  "file_path": "C:\\absolute\\path\\to\\workflow.yxmd"
}
```

Local tools may appear with an `alteryx_local` namespace or a client-specific prefix. Use the exact names and schemas exposed by the active client rather than inventing names.

## Semantic Operations

Map the active MCP tools to these operations. Require only the operations needed for the current task.

| Semantic operation              | Purpose                                      |
|---------------------------------|----------------------------------------------|
| `get_available_tools`           | List supported Designer tools                |
| `get_tool_configuration_schema` | Get schema-backed tool configuration         |
| `get_condensed_workflow`        | Inspect workflow structure and configuration |
| `search_knowledge_sources`      | Search Alteryx product knowledge             |
| `validate_formula`              | Validate an Alteryx formula                  |
| `create_workflow`               | Create a local workflow                      |
| `add_tool`                      | Add and connect a schema-supported tool      |
| `edit_tool`                     | Edit a schema-supported tool                 |
| `add_custom_tool_with_xml`      | Add a custom or unsupported XML tool         |
| `edit_custom_tool_with_xml`     | Edit a custom or unsupported XML tool        |
| `remove_tool`                   | Remove a tool                                |
| `replace_tool_connections`      | Replace or update connections                |
| `add_tools_to_container`        | Create or populate a tool/control container  |
| `remove_tools_from_container`   | Move tools out of a container                |
| `delete_container`              | Delete a container while preserving its tools |
| `set_container_enabled`         | Enable or disable a container                |
| `update_tool_positions`         | Update tool positions on the canvas          |
| `annotate_tool`                 | Update a tool's name and annotation           |
| `update_workflow_description`   | Set or clear the workflow description        |
| `refresh_metadata`              | Validate configuration and refresh metadata  |
| `run_workflow`                  | Run the workflow through Designer Engine     |
| `get_metadata`                  | Inspect field names and types                |
| `get_data_at_anchor`            | Sample data at an output anchor              |

Small naming differences are acceptable only when the exposed tool description and schema establish the same semantics.

## Knowledge Search

Use `search_knowledge_sources` when the appropriate Designer tool, configuration approach, formula behavior, or recommended workflow pattern is unclear. Do not search routinely when the required configuration is already established.

Provide both required inputs:

- `query`: A focused question or set of search terms describing the specific information needed.
- `intent`: A short statement of the workflow outcome the user is trying to achieve.

Prefer a few targeted searches over broad discovery. Use returned documentation chunks to guide tool choice and configuration, but treat exposed tool schemas and installed capabilities as authoritative for mutations. Summarize only the relevant guidance; do not copy large documentation passages into context or user-facing responses.

## MCP Build Process

1. Inspect an existing artifact with the condensed-workflow operation before mutation.
2. Discover available Designer tools when the requested tool support is not already established.
3. Get the configuration schema before adding or editing a schema-supported tool unless the exact current schema is already present in task context.
4. Use human-readable Designer tool names expected by the schema, such as `Filter`, `Formula`, or `Summarize`.
5. Make one small mutation at a time and retain the returned workflow state or identifiers needed by later calls.
6. Run the workflow after changes that require execution or output validation.
7. Inspect run messages, relevant metadata, and small anchor samples as needed.
8. Repair through MCP and rerun until validation succeeds or a blocker is clear.

## Configuration Rules

- Prefer schema-driven add/edit operations over custom XML.
- Use custom XML operations only when schema-driven configuration cannot express the required installed tool, custom macro, interface construct, or analytic app behavior.
- Manage containers with the container operations. Use `annotate_tool`, `update_tool_positions`, and `update_workflow_description` for their respective changes.
- `delete_container` removes the container and moves its contained tools to the parent canvas. To delete an individual tool, use `remove_tool`.
- Do not directly edit the workflow file while using the MCP path.
- Gather upstream metadata before authoring field-dependent formulas or configurations.
- Read `formula-syntax.md` for formulas. Use formula validation when exposed, then confirm behavior with a workflow run.
- Preserve the existing engine selection unless the user requests a change. Use AMP/E2 for new workflows when the create operation exposes that choice.
- Confirm custom and connector tool availability instead of assuming a plugin or package is installed.

## Run, Metadata, And Validation Rules

- Call `run_workflow` before `get_data_at_anchor`; anchor data comes from the latest successful run.
- Call either `run_workflow` or `refresh_metadata` before `get_metadata`.
- `refresh_metadata` validates tool configuration and persists metadata updates without processing records. Use `run_workflow` to validate record-dependent behavior and outputs.
- Annotation, position, and description changes do not require a workflow run.
- Assume all prior run context and samples are invalid after mutation.
- Use run messages to identify the failing tool and inspect its immediate upstream metadata when possible.
- Verify field names and data types with metadata rather than inferring them from configuration.
- Validate transformations and outputs with the smallest useful anchor sample.
- Stop and report authentication, licensing, entitlement, unsupported-version, or unavailable-plugin errors clearly.
- Treat a successful tool call as mutation evidence, not workflow-completion evidence.
