# Alteryx

Work with your organization's governed Alteryx One environment in plain
language. Find the assets you already have, ask questions about your data, and
build and run workflows, without leaving the conversation.

| Skill | Use it to | Example |
|---|---|---|
| Alteryx Asset Discovery | Find and verify the workflows, macros and datasets that already exist | "Find my workflows about revenue." |
| Alteryx Designer | Build, edit, run and repair workflows, and check their outputs | "Add a Filter tool after the Input Data tool and keep rows where state is CA." |
| Alteryx Insights | Answer business questions from governed datasets, powered by Alteryx Auto Insights | "What drove the change in revenue last quarter?" |

## Use it

Ask in plain language, as in the examples above. The first
time you use the plugin you are asked to sign in to Alteryx One in your
browser. Every action runs with your own permissions, so you can only see and
change what you already have access to in Alteryx One.

Asset Discovery only reads. Insights reads your data and can ask Alteryx to
prepare a dataset for analysis. Designer can create, change and run workflows
in your Alteryx workspace. In claude.ai, Claude Desktop and ChatGPT, workflows
run in Alteryx One and read from and write to Alteryx datasets; running an
analytic app that needs input values is not supported there.

## Data

The plugin sends your requests, and the dataset names, search terms and
workflow definitions in them, to your Alteryx One workspace through the
Alteryx MCP gateway (`alteryx`, HTTPS). Sign-in uses OAuth, and the plugin
never sees your password. It stores nothing itself and ships no credentials.

The plugin also declares a second server, `alteryx-local`. It is a program that
runs on your own computer, inside Alteryx Designer 2026.2 or newer, and it only
starts in clients that run programs locally: Claude Code, Codex, Antigravity
and Cowork. claude.ai, Claude Desktop chat and ChatGPT do not start it. The
Alteryx Designer skill also bundles PowerShell scripts that run a workflow with
a local Designer install. Those scripts run only when one of those local
clients executes them on a Windows machine with Designer installed.

## Support

Get help at https://my.alteryx.com. The source is at
https://github.com/alteryx/skills, under the Apache 2.0 license.
