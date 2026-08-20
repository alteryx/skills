# Alteryx Skills

This repository packages the `alteryx` plugin for Codex, Antigravity, Claude Code,
and Claude Desktop.
The public repository is owned and maintained by the Ask Alteryx team.

For full installation, usage, runtime requirements, and troubleshooting
documentation, see
[Get Started with Alteryx Skills](https://help.alteryx.com/current/en/developer-help/get-started-with-alteryx-skills.html).

## Features

- **Alteryx Designer**: Build, inspect, run, and repair trusted workflows, and validate their outputs against what you actually asked for.
- **Alteryx Asset Discovery**: Find and verify the workflows, macros, and datasets that already exist, so a build starts from real assets and real schemas instead of duplicating logic.
- **Alteryx Insights**: Answer business questions with governed Alteryx One data using analysis powered by Alteryx Auto Insights.
- Use AI-assisted workflow authoring and execution for data preparation, reconciliation, compliance reporting, operational analytics, governed calculations, and other reusable business logic.

## Installation

### Codex

```bash
codex plugin marketplace add alteryx/skills
codex plugin add alteryx@alteryx
```

### Antigravity

```bash
agy plugin install https://github.com/alteryx/skills.git
```

**Required manual step.** Antigravity CLI does not load MCP servers from
installed plugins (see
[Known Issues](#antigravity-does-not-load-plugin-provided-mcp-servers)). Add
the `alteryx` server to Antigravity's user-level configuration:

| Platform      | Configuration file                             |
|----------------|------------------------------------------------|
| macOS / Linux | `~/.gemini/config/mcp_config.json`              |
| Windows       | `%USERPROFILE%\.gemini\config\mcp_config.json`  |

Create the file if it doesn't exist. If it already contains other servers,
merge this entry into the existing `mcpServers` object rather than replacing
the file:

```json
{
  "mcpServers": {
    "alteryx": {
      "serverUrl": "https://us1.alteryxcloud.com/mcp/v1"
    }
  }
}
```

Use the endpoint for your workspace's region — see
[Set Your Regional Endpoint](#set-your-regional-endpoint).

Restart `agy` and run `/mcp` to confirm `alteryx` is connected.

### Claude Code

```bash
claude plugin marketplace add alteryx/skills
claude plugin install alteryx@alteryx
```

### Claude Desktop

Install the Alteryx plugin from **Settings > Plugins** in Claude Desktop. See
the [official guide](https://help.alteryx.com/current/en/developer-help/get-started-with-alteryx-skills.html#claude-desktop)
for step-by-step instructions.

### Skills Only

```bash
npx skills add alteryx/skills
```

## Authenticate with Alteryx One

The cloud `alteryx` MCP server requires an Alteryx One account. Cloud calls run
as the signed-in user and are subject to workspace permissions and data-access
policy.

### Codex

Run:

```bash
codex mcp login alteryx
```

Complete the browser sign-in flow, then restart Codex so the cloud tools are
connected.

### Claude Code

1. Run `/plugin` to open the plugin manager.
2. Open the **Installed** tab.
3. Select **alteryx MCP** under **Needs attention** to start the Alteryx One
   sign-in flow.

### Antigravity

1. Run `/mcp` to open the MCP server manager.
2. Use the arrow keys to select `alteryx`.
3. Press `Enter`. Antigravity starts the Alteryx One sign-in flow
   automatically and opens your browser.
4. Complete sign-in. The panel shows `alteryx` as `[Authed]` once connected.

## Usage

The plugin contains three skills.

`alteryx-designer` handles workflow work: building a workflow, editing a `.yxmd`, running a workflow, repairing execution errors, and validating outputs. It works on both local files and Alteryx One workflows, using whichever tools your environment makes available.

`alteryx-asset-discovery` is read-only. It searches the directories you authorize and the Alteryx assets you can access, verifies the promising candidates, and reports the evidence — including when something it found may already do what you were about to build.

`alteryx-insights` answers business data questions using the Alteryx One Insights toolset. It supports analysis such as totals, trends, period changes, goal variance, correlations, and outliers, along with record-level lookups, exact rankings, and grouped summaries.

Agents can select the appropriate skill automatically. Example invocations:

```text
Build an Alteryx workflow that joins these customer and order files, filters inactive accounts, and writes a reconciled output.
```

```text
Inspect this .yxmd and explain why the final output is missing the expected revenue column.
```

```text
Run this Designer workflow and fix any configuration errors that prevent it from completing.
```

```text
What workflows and datasets in my workspace already deal with customer churn?
```

```text
Before we build a weekly revenue summary, check whether something like it already exists.
```

```text
What drove the change in monthly revenue, and were there any unusual regional results?
```

### Codex

Use `@Alteryx` to invoke the Alteryx plugin as a whole:

```text
@Alteryx build a Designer workflow that summarizes monthly sales by region
```

Use `$alteryx:<skill>` to force a specific skill:

```text
$alteryx:alteryx-designer inspect ./workflows/reconciliation.yxmd and repair the failing join
```

```text
$alteryx:alteryx-asset-discovery find macros in ./workflows that already standardize address fields
```

```text
$alteryx:alteryx-insights compare this month's revenue with last month and explain the strongest drivers
```

### Claude Code

Use `/alteryx:<skill>` to invoke a skill:

```text
/alteryx:alteryx-designer create a workflow that cleans this CSV, applies the required formulas, and writes a YXDB
```

```text
/alteryx:alteryx-asset-discovery what datasets in my workspace hold monthly order history?
```

```text
/alteryx:alteryx-insights show the trend in customer churn over the past year
```

### Claude Desktop

Use `/<skill>` to invoke a skill:

```text
/alteryx-designer inspect this workflow and explain what it does
```

```text
/alteryx-asset-discovery find existing workflows related to sales tax reconciliation
```

```text
/alteryx-insights which regions had unusual sales results last quarter?
```

### Antigravity

Use `/alteryx:<skill>` to invoke a skill:

```text
/alteryx:alteryx-designer inspect this workflow XML and fix the broken output configuration
```

```text
/alteryx:alteryx-asset-discovery locate the canonical customer dataset these workflows read from
```

```text
/alteryx:alteryx-insights rank the top five products by total revenue
```

## Runtime Requirements

The full plugin configures two optional MCP servers.

`alteryx-local` runs on your machine and exposes local workflow tools (requires Alteryx Designer 2026.2 or newer):

```powershell
alteryx-mcp-server
```

`alteryx` connects over HTTP to Alteryx One and exposes the Insights analysis, cloud workflow, asset search, and dataset preview tools:

```text
https://us1.alteryxcloud.com/mcp/v1
```

### Set Your Regional Endpoint

Alteryx One is hosted in three regions, and the plugin ships the United States endpoint. **If your workspace is in the Europe or Asia Pacific region, you must change the endpoint before the cloud tools will work.**

| Region               | Endpoint                              |
|----------------------|---------------------------------------|
| United States        | `https://us1.alteryxcloud.com/mcp/v1` |
| Europe / Middle East | `https://eu1.alteryxcloud.com/mcp/v1` |
| Asia Pacific         | `https://au1.alteryxcloud.com/mcp/v1` |

There is no global endpoint. A single shared host would route requests through infrastructure outside the caller's region, which some data-residency commitments do not permit. The endpoint must therefore match your workspace's region, and no client can pick it for you.

To change it, replace `us1` with `eu1` or `au1` in the endpoint used by your
client:

- `alteryx/.mcp.json`, field `url` — Codex, Claude Code, and Claude Desktop. Restart your client, or reload plugins, so it reconnects. Re-apply the edit after upgrading the plugin, because an upgrade replaces the bundled configuration file.
- Antigravity — set `serverUrl` in your user-level `mcp_config.json` (see [Antigravity](#antigravity) under Installation). Editing the plugin's bundled `alteryx/mcp_config.json` has no effect, since Antigravity doesn't read it — see [Known Issues](#antigravity-does-not-load-plugin-provided-mcp-servers). Restart `agy` after changing it.

Claude Code and Claude Desktop also support `${VAR}` and `${VAR:-default}` expansion in an MCP server `url`, so you can make the edit once as
`"url": "${ALTERYX_MCP_URL:-https://us1.alteryxcloud.com/mcp/v1}"` and set `ALTERYX_MCP_URL` in your environment. The bundled configuration does not use expansion, because Codex reads the same file and does not support that syntax.

If you define your own regional `alteryx` server instead of editing the bundled one, expect both to appear: Claude Code matches plugin-provided servers by endpoint, so a different URL registers as an additional server rather than replacing the bundled US entry.

When a server and its required tools are available, the skills use them by default. Local workflow work falls back to the bundled XML and PowerShell path when no local workflow tools are present; cloud workflow work has no fallback. Local asset discovery needs neither server — it uses your agent's own file search and read capabilities within the directories you authorize.

Local workflow execution requires an Alteryx Designer installation with `AlteryxEngineCmd.exe`, whether invoked through MCP or the fallback scripts. Local MCP workflow tools (`alteryx-local`) require Designer 2026.2 or newer; earlier versions use the bundled XML and PowerShell fallback path. XML inspection and editing can proceed in fallback mode without Designer, but run validation requires local Engine access. Designer 2026.2 or newer is recommended for best performance. Visit the downloads area of the Alteryx One App to obtain the latest version. 

Cloud workflow execution runs in Alteryx One and needs no local Designer install.

## Known Issues

### Antigravity does not load plugin-provided MCP servers

Antigravity CLI (`agy`) 1.1.14 does not start MCP servers bundled with an
installed plugin. Skills load normally and the plugin reports as enabled,
but `/mcp` reports no configured servers.

**Workaround:** declare the `alteryx` server in Antigravity's user-level
configuration. See [Antigravity](#antigravity) under Installation for the
file location and the exact entry.

This is a defect in Antigravity, tracked upstream as
[google-antigravity/antigravity-cli#761](https://github.com/google-antigravity/antigravity-cli/issues/761).
It is not specific to this plugin and cannot be resolved from this
repository. Remove the workaround once Antigravity ships a fix.

Verified on `agy` 1.1.14, macOS. Windows is untested.

## Releases

Public releases use semver tags and are documented in [CHANGELOG.md](CHANGELOG.md).
Maintainer release steps are maintained internally for maintainers of the
canonical repository.

## License and Notices

Repository materials are licensed under the Apache License, Version 2.0. See
[LICENSE](LICENSE) and [NOTICE](NOTICE).

Repository materials are provided on an "AS IS" basis, without warranties or
conditions of any kind, express or implied.

The license applies only to the materials in this repository. It does not grant
rights to Alteryx products, hosted services, APIs, customer data, non-public
documentation, trademarks, logos, or branding. See [TRADEMARKS.md](TRADEMARKS.md).

This GitHub repository is a read-only public mirror. Pull requests opened here
are not accepted. Contributions are handled under the DCO-first process in
[CONTRIBUTING.md](CONTRIBUTING.md). Security reports must follow
[SECURITY.md](SECURITY.md). Repository ownership and maintenance expectations
are documented in [GOVERNANCE.md](GOVERNANCE.md) and [MAINTENANCE.md](MAINTENANCE.md).

## Product and Service Access

These skills do not bypass Alteryx authentication, authorization, workspace
controls, product terms, service terms, or entitlement checks. Users are
responsible for using authorized Alteryx accounts, workspaces, products,
services, and permissions.
