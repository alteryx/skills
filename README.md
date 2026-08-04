# Alteryx Skills

This repository packages the `alteryx` plugin for Codex, Antigravity, Claude Code,
and Claude Desktop.
The public repository is owned and maintained by the Ask Alteryx team.

For full installation, usage, runtime requirements, and troubleshooting
documentation, see
[Get Started with Alteryx Skills](https://help.alteryx.com/current/en/developer-help/get-started-with-alteryx-skills.html).

## Features

- **Alteryx Designer**: Build, inspect, run, and repair trusted workflows through local Alteryx MCP tools, with an XML and Engine fallback when MCP is unavailable.
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

## Usage

The plugin contains one skill, `alteryx-designer`. Agents can select it automatically when your request clearly involves local Alteryx Designer workflows, such as building a workflow, editing a `.yxmd`, running a workflow with Designer Engine, repairing execution errors, or validating workflow outputs. The skill prefers the `alteryx-local` MCP server when its workflow tools are available and otherwise uses its bundled XML and PowerShell fallback.

Example automatic invocations:

```text
Build an Alteryx workflow that joins these customer and order files, filters inactive accounts, and writes a reconciled output.
```

```text
Inspect this .yxmd and explain why the final output is missing the expected revenue column.
```

```text
Run this Designer workflow and fix any configuration errors that prevent it from completing.
```

### Codex

Use `@Alteryx` to invoke the Alteryx plugin as a whole:

```text
@Alteryx build a Designer workflow that summarizes monthly sales by region
```

Use `$alteryx:alteryx-designer` to force the specific Designer skill:

```text
$alteryx:alteryx-designer inspect ./workflows/reconciliation.yxmd and repair the failing join
```

### Claude Code

Use `/alteryx:alteryx-designer` to invoke the Designer skill:

```text
/alteryx:alteryx-designer create a workflow that cleans this CSV, applies the required formulas, and writes a YXDB
```

### Claude Desktop

Use `/alteryx-designer` to invoke the Designer skill:

```text
/alteryx-designer inspect this workflow and explain what it does
```

### Antigravity

Use `/alteryx:alteryx-designer` to invoke the Designer skill:

```text
/alteryx:alteryx-designer inspect this workflow XML and fix the broken output configuration
```

## Runtime Requirements

The full plugin configures the optional `alteryx-local` MCP server using:

```powershell
alteryx-mcp-server
```

When that command and its required workflow tools are available, the skill uses them by default. Skills-only installs and clients without the server continue to use the bundled XML and PowerShell fallback.

Workflow execution requires a local Alteryx Designer installation with `AlteryxEngineCmd.exe`, whether invoked through MCP or the fallback scripts. XML inspection and editing can proceed in fallback mode without Designer, but run validation requires local Engine access.

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
