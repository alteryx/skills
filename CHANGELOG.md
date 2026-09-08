# alteryx-skills

## 0.3.0

- Add the `alteryx-asset-discovery` skill: a read-only workflow for finding and
  verifying existing Alteryx assets and governed datasets before designing or
  building a solution.
- Add the `alteryx-insights` skill for answering business data questions with
  the Alteryx One Insights toolset, powered by Alteryx Auto Insights — totals,
  trends, period-over-period change, goal variance, correlations, outliers,
  and record-level lookups over governed datasets.
- Support cloud mode in the `alteryx-designer` skill via the `alteryx` HTTP MCP
  server, alongside the existing local `alteryx-local` mode, and document how to
  choose between them by available capability rather than by server name.
- Document Alteryx plugin authentication in the README.
- Document that Antigravity does not load MCP servers from installed plugins,
  and add the user-level `mcp_config.json` workaround to the Antigravity
  install instructions. Upstream:
  [google-antigravity/antigravity-cli#761](https://github.com/google-antigravity/antigravity-cli/issues/761).
- Update `alteryx/mcp_config.json` to the `serverUrl` schema for conformance
  with `agy plugin validate`.
- Document the Alteryx Designer 2026.2+ requirement for the `alteryx-local`
  MCP server.
- Treat an `AlteryxEngineCmd` exit code of 1 as `success_with_warnings` rather
  than a failure in `Invoke-AlteryxWorkflow.ps1`, so a workflow that completes
  with warnings no longer reports as failed.
- Correct the `alteryx-local` MCP tool prefix to `alteryx_local__*`.
- Document cloud asset identifier handling — extract the ID from a URN wrapper
  rather than passing the URN — and correct the `datasets__preview_dataset`
  parameters to the current preview contract.

## 0.2.0

- The `alteryx-designer` skill is now MCP-first: it uses the `alteryx-local`
  MCP server's workflow tools when they are available, and falls back to the
  bundled workflow XML and PowerShell Engine path when they are not.
- Ship the optional `alteryx-local` MCP server configuration with the plugin
  (`alteryx/.mcp.json` and `alteryx/mcp_config.json`), and register it from the
  Codex manifest via `mcpServers`.
- Require native Designer tools over code tools when authoring workflows, so
  generated workflows stay inspectable and reusable in Designer.
- Split the build guidance into dedicated `building-with-mcp.md` and
  `building-with-fallback.md` references, and expand the Designer tool
  reference and workflow XML notes, including Full Update workflow validation.
- Document Claude Desktop installation and usage, and link the public
  Get Started with Alteryx Skills guide from the README.

## 0.1.0

- Baseline public release of the `alteryx` plugin bundle for Codex,
  Antigravity, and Claude Code.
- Includes the `alteryx-designer` skill for building, inspecting, running, and
  repairing trusted local Alteryx Designer workflows.
- Includes Apache-2.0 licensing, security reporting guidance, trademark
  guidance, contribution rules, governance notes, and maintenance expectations
  for the public distribution repository.
