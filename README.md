# Alteryx Skills

This repository packages the `alteryx` plugin for Codex, Antigravity, and Claude Code.
The public repository is owned and maintained by the Ask Alteryx team.

## Features

- **Alteryx Designer**: Build, inspect, run, and repair trusted workflows for repeatable business analysis.
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

### Skills Only

```bash
npx skills add alteryx/skills
```

## Usage

The plugin contains one skill, `alteryx-designer`. Agents can select it automatically when your request clearly involves local Alteryx Designer workflows, such as building a workflow, editing a `.yxmd`, running a workflow with Designer Engine, repairing execution errors, or validating workflow outputs.

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

### Antigravity

Use `/alteryx:alteryx-designer` to invoke the Designer skill:

```text
/alteryx:alteryx-designer inspect this workflow XML and fix the broken output configuration
```

## Runtime Requirements

Workflow execution requires a local Alteryx Designer installation with `AlteryxEngineCmd.exe`. Workflow inspection and XML editing can proceed without Designer, but run validation requires local Engine access.

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
