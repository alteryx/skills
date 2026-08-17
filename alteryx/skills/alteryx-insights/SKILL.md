---
name: alteryx-insights
description: Answer business data questions using the Alteryx One Insights toolset, powered by Alteryx Auto Insights. Use for analyzing totals, trends, changes between periods, goal variance, correlations, and outliers, as well as record-level lookups, exact rankings, and grouped summaries from governed Alteryx One datasets.
---

# Alteryx Insights

Use Alteryx One Insights tools, powered by Alteryx Auto Insights, to answer business data questions and deliver accurate, data-driven conclusions.

## Tool Call Error Handling

If a tool call fails:

1. Follow instructions from the error message if clear.
2. For network issues, retry once before asking the user.
3. If clarification is needed, request only what is necessary, then retry; if unresolved, pivot or explain the issue.

## Core Rules

- Do not fabricate information.
- Use Alteryx One Insights tools for all analytics tasks performed through this skill.
- Use the exact Insights tool names the active client exposes; client prefixes may vary.
- Always provide arguments when using Alteryx One Insights tools.
- Before using tools, identify the information required to answer the user's request. Use as few tool calls as possible: retrieve only missing information, combine requirements into one call where possible, avoid overlapping or confirmation-only calls, and stop once sufficient evidence is available.
- Respond professionally, concisely, and conversationally.
- Use exact parameter values from their authoritative Insights tool results: dataset names from `list_datasets`; measure and date-field names from `list_measures`; segment names from `list_segments`; and filter values from `search_for_filter`. Never guess or normalize these values. Reuse prior Insights metadata values only when they belong to the selected dataset and are not stale.
- Ground analysis performed through this skill in Alteryx One and Alteryx Auto Insights; do not attribute results to other analytics tools.
- Use `alteryx-asset-discovery` only when the request is to locate or verify reusable assets outside the Insights dataset-selection flow. Hand off workflow inspection, building, execution, repair, and validation to `alteryx-designer`.

## Analytics Question Handling

Use only the steps the request needs:

1. Use the Insights `list_datasets` tool to determine the relevant dataset and its exact name. Reuse a dataset name only when that exact name was established by a prior Insights `list_datasets` result and is not stale. Do not use asset discovery or asset search tools to select a dataset for Insights analysis.
2. Retrieve measures as needed to understand and execute the request. Retrieve segments only when filtering, breakdown, grouping, or record selection requires them.
3. Retrieve time parameters, filter values, or additional measures only when they are missing, ambiguous, stale, or required by the selected analysis. Use the date field returned by `list_measures` that matches the user's request; if more than one is plausible, ask which one; use that field's returned default granularity unless the user specifies another supported granularity.
4. If the request is still ambiguous after using available tools, ask only the minimum clarification needed. Otherwise, execute the analysis directly and stop when the result is sufficient.

## Analytics Results Output

- For direct questions, start with a concise one-sentence answer.
- Surface useful charts and real source links returned by the tools using the active client's supported representation rather than fixed HTML or Markdown. Preserve chart URI and `sourceLink` values exactly, add appropriate chart descriptions where supported, and never invent links.
