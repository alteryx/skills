---
name: alteryx-asset-discovery
description: Find and verify existing Alteryx assets and datasets before designing or building a solution. Use when a request depends on knowing what already exists — locating workflows, macros, or data related to a business question, checking whether logic is already implemented, grounding a build in real data, verifying a dataset's schema, or finding example XML for an unsupported tool. Read-only.
---

# Alteryx Asset Discovery

Answer one question: **what existing Alteryx assets or datasets could help solve this problem?**

Discover and verify candidates, then report the evidence. Never create, modify, or run an asset as part of this process. Deciding whether an asset should be reused, extended, or replaced, proposing a solution topology, and judging what the product supports are all out of scope: they come after discovery, once the evidence is in hand. Finish discovery and report first, then perform these follow-on tasks if required.

## Discovery Scope

- Governed Alteryx One datasets, workflows, and macros returned by asset search.
- Local Alteryx workflows (`.yxmd`) and macros (`.yxmc`).
- Local datasets such as CSV, Excel, and YXDB files.

Search governed assets whenever the relevant MCP tools are available, even for a request that started with a local file.

## Agent Workflow

1. **Frame the need.** Extract the business objective, domain terms, expected inputs and outputs, time range, geography, system names, and other constraints worth searching on. Establish which environments are in play: local files, cloud, or both.
2. **Search broadly.** Search governed cloud assets, local files, or both, depending on which environments are in play and the scope of the request.
3. **Inspect candidates.** Never rely on names or search snippets alone. Establish a workflow's or macro's analytical purpose, inputs, outputs, transformations, and referenced assets, and verify a dataset's column names and types before presenting it as grounded context.
4. **Use workflows as discovery evidence.** Treat workflow Input and Output tools as pointers to canonical datasets, and referenced macros as reusable-logic candidates. Follow them to assets that did not match the original query.
5. **Refine and repeat.** Re-search using names, business concepts, owners, tags, and tool usage learned during inspection — but only when it could materially improve the candidate set.
6. **Return grounded candidates.** Report what was found, why each candidate is relevant, what was verified, and every gap.

## Cloud Discovery

Use the read-only tools below through the `alteryx` MCP server. Client prefixes vary; use the exact tool names the active client exposes rather than inventing names.

| Tool                                            | When to use it                                                 | Required handling                                                     |
|-------------------------------------------------|----------------------------------------------------------------|-----------------------------------------------------------------------|
| `assets__search_alteryx_assets(query)`          | Search governed assets with a focused natural-language query.  | Treat results as candidates, not verified facts.                      |
| `designer__get_condensed_workflow(workflow_id)` | Inspect a cloud workflow or macro.                             | This is the evidence that verifies a workflow candidate.              |
| `datasets__preview_dataset(datasetId, limit)`   | Verify a governed dataset's schema and inspect a small sample. | Pass the dataset ID in the current preview contract; respect returned limits and never use repeated previews to bulk-extract. |

### Cloud asset identifiers

Search results may identify cloud assets with URNs or other wrappers, for example
`urn:li:ayxDataset:(workspaceId,datasetId)`. Do not pass a full URN directly to
a follow-on tool. Extract the asset ID required by that tool and pass it in the
documented parameter, preserving the ID exactly. Remove only a recognized
wrapper; do not guess or otherwise transform the ID.

For example, a dataset preview passes the `datasetId` component:

```json
{"datasetId":"<datasetId>","limit":5}
```

Translate the business question into focused searches rather than broad ones. Search relevance depends on the metadata indexed for each asset, so an asset with thin metadata may only be findable by name or path — try both.

## Local Discovery

Local assets need no MCP server — use the agent's own file search and read capabilities. Two constraints are specific to discovery:

- **Keep the search scoped.** Search the directories the request puts in scope — those it names, or the working directory — and do not open files unrelated to the stated need even inside one. Widening to the home directory or the whole drive requires explicit user direction.
- **Minimize what you read.** Establish relevance from filenames, structure, headers, and column types; sample rows only to verify a live candidate's schema, tens of rows at most.

## Effort

Scale depth to the request shape:

- **Locate-only** — "Which workflows relate to customer churn?" Rank candidates and verify enough to justify each one's relevance. Do not inspect every candidate in depth.
- **Grounding a build** — "I need a weekly churn dataset" Verify the leading candidates properly: schemas for datasets that may be consumed, condensed inspection for workflows that may be reused.

When the request shape is ambiguous, treat it as locate-only and either offer to verify further or record the ambiguity as a discovery gap, rather than spending the deeper budget uninvited.

Stop searching at whichever comes first: the most recent refinement produced no new material candidates, the evidence is sufficient for the request shape, or five search iterations have completed. Inspect at most five candidates in depth per request — rank first, then inspect in rank order.

These counts are tunable defaults, not protocol. When a bound stops the work, report which bound was hit and what was left uninspected. Silent truncation reads to the user as "nothing else exists."

## Reporting Rules

- **Surface reuse candidacy.** When an inspected asset appears to already fulfill the stated need in whole or in part, say so explicitly and cite the evidence. Do not decide whether to reuse, extend, or replace it at this stage — but never return a strong candidate without flagging that it may make new work unnecessary. Avoiding duplicated business logic is the primary reason to perform discovery.
- **Report empty results as searched, not absent.** Asset search returns only what the user has access to, so finding nothing does not establish that nothing exists. State which locations, asset types, and terms were searched, and offer the terms or locations most likely to change the outcome.
- **Keep evidence and inference separate.** Distinguish what was observed in metadata, workflow content, schemas, or samples from what you inferred.

A candidate is **verified** only when the evidence below was actually obtained. Everything else is unverified, however strong the search relevance was. Search metadata alone never verifies a candidate.

| Asset type                | Required before labeling verified                                                                                                       |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| Local or governed dataset | Column names and, where available, types, plus a bounded sample — or an explicit statement of why preview was unavailable or prohibited |
| Workflow or macro         | Condensed inspection establishing analytical purpose, inputs, outputs, and referenced assets                                            |

## Result Contract

Report in this structure. Always return a stable identifier — `workflow_id`, `dataset_id`, or absolute path — for every candidate, so follow-up questions can re-fetch a specific asset instead of re-running discovery.

```markdown
## Verified Candidates

### <Asset name> (<type>)
- Location / identifier:
- Relevance:
- Verified evidence:
- Evidence source:
- Already fulfills the need: yes / partially / no — with the evidence for that reading
- Related assets discovered:
- Freshness / ownership / certification:

## Unverified Candidates

### <Asset name> (<type>)
- Location / identifier:
- Why it may be relevant:
- What could not be verified, and why:

## Discovery Gaps

- <Access restriction, preview failure, unsearched location, or unresolved capability question>
- <Bound reached, and what was left uninspected>
```

Include a section even when it is empty, and say so. An omitted Discovery Gaps section reads as "there were none."

## Running In A Subagent

Discovery reads far more than it reports, so a caller may run it in an isolated subagent and keep only the report. Prefer a subagent when grounding a build, where deep verification is high-volume and the output feeds a build loop that needs its own context; prefer inline for locate-only requests, where the report is the answer and the user will ask about individual candidates conversationally.

Isolation is an optimization, never a precondition: behave identically either way, and do not depend on prior conversation history or on asking a clarifying question mid-run.

When invoked as a subagent:

- **Expect the framing in the spawn prompt.** The business objective, domain terms, known constraints, authorized local roots, and environment mode should arrive up front.
- **Return the result contract verbatim.** Return the sections above, not a prose summary of them. Reuse candidacy and discovery gaps are exactly what summarization flattens.
- **Report unresolved framing as a gap.** State the ambiguity, the interpretation used, and what you would have asked.
- **Return no row-level samples.** Cross the boundary with schemas, column types, and characterizations of the data — never the sampled rows themselves.

When spawning this skill as a subagent, supply that framing and expect that contract back.
