# Alteryx Workflow XML Structure

Use this reference for structural edits to `.yxmd`, `.yxmc`, and `.yxwz` files. It covers the shared workflow XML model: documents, nodes, connections, root properties, macro/runtime properties, metadata, annotations, and containers.

It does not define every individual Designer tool's `Configuration` schema. For exact tool configuration XML, inspect known-good local workflows, Designer samples, installed macros, or installed tool package files.

## Contents

- [Document Shape](#document-shape)
- [Global Editing Invariants](#global-editing-invariants)
- [Nodes](#nodes)
- [Connections](#connections)
- [Root Properties](#root-properties)
- [AMP/E2 Engine Selection](#ampe2-engine-selection)
- [Configuration/Update Mode](#configurationupdate-mode)
- [Runtime Properties](#runtime-properties)
- [MetaInfo](#metainfo)
- [Annotations](#annotations)
- [Containers](#containers)
- [Structural Edit Checklist](#structural-edit-checklist)

## Document Shape

Workflow, macro, and analytic app XML commonly uses this root shape:

```xml
<?xml version="1.0"?>
<AlteryxDocument yxmdVer="2023.1">
  <Nodes>
    ...
  </Nodes>
  <Connections>
    ...
  </Connections>
  <Properties>
    ...
  </Properties>
</AlteryxDocument>
```

Common file types:

- `.yxmd`: standard workflow
- `.yxmc`: macro workflow
- `.yxwz`: analytic app workflow

The root element is `AlteryxDocument`. Preserve root attributes such as `yxmdVer` and `RunE2`.

## Global Editing Invariants

- `ToolID` values are document-wide identifiers, including nodes nested inside `ChildNodes`.
- Connections reference tools by `ToolID` regardless of whether tools are top-level or inside containers.
- Containers group nodes but do not create a separate connection namespace.
- Root `Connections` contains graph edges for the whole document.
- Root `Properties` describes workflow-level settings. Node-level `Properties` describes a single tool.
- Macro and analytic app questions, actions, constants, wizard fields, and action destinations can reference tools by `ToolID`.
- Preserve local XML style: element order, spacing, empty element style, plugin names, attribute formatting, and generated metadata unless the edit intentionally changes them.
- Preserve the effective AMP/E2 vs legacy E1 engine selection in existing workflows unless the user explicitly confirms changing it.
- Verify exact tool-specific `Configuration` shape from local evidence before adding or substantially changing a tool.

## Nodes

Nodes are workflow graph vertices. Top-level nodes live under root `Nodes`; contained tools live under a container node's `ChildNodes`.

Common node shape:

```xml
<Node ToolID="1">
  <GuiSettings Plugin="AlteryxBasePluginsGui.TextInput.TextInput">
    <Position x="54" y="102" />
  </GuiSettings>
  <Properties>
    <Configuration>
      ...
    </Configuration>
    <Annotation DisplayMode="0">
      ...
    </Annotation>
  </Properties>
  <EngineSettings EngineDll="AlteryxBasePluginsEngine.dll" EngineDllEntryPoint="AlteryxTextInput" />
</Node>
```

Common child elements:

- `GuiSettings`: Designer-side plugin and canvas position.
- `Position`: layout data; containers and interface tools may include `width` and `height`.
- `Properties`: node-level properties, usually including `Configuration`, `Annotation`, and sometimes `MetaInfo`.
- `Configuration`: tool-specific configuration.
- `Annotation`: per-tool annotation block.
- `MetaInfo`: cached schema metadata.
- `EngineSettings`: runtime implementation, when applicable.
- `ChildNodes`: nested tools for containers.

`GuiSettings Plugin` and `EngineSettings` are related but separate identities. Do not derive one from the other unless local examples prove the pairing.

When adding a node, use a new `ToolID` unique across the whole workflow, including nested nodes. When removing or renumbering a node, update every reference to that `ToolID`.

Before deleting or renumbering a node, search for references as:

- `ToolID="N"`
- `ToolId value="N"`
- `ToolId="N"`
- action destinations such as `N/...`
- connection endpoints
- macro constants, questions, actions, wizard fields, and metadata references

## Connections

Connections define graph edges and live in one root-level `Connections` block:

```xml
<Connection>
  <Origin ToolID="12" Connection="Output" />
  <Destination ToolID="16" Connection="Input" />
</Connection>
```

The `Connection` attribute on `Origin` and `Destination` is the tool anchor name. Anchor names are tool-specific. Examples include `Input`, `Output`, `True`, `False`, `Left`, `Right`, `Join`, `Question`, `Action`, `Condition`, numbered anchors such as `Input8`, and condition anchors such as `False Condition`.

Connection elements can have a `name` attribute:

```xml
<Connection name="#1">
  <Origin ToolID="9" Connection="Right" />
  <Destination ToolID="11" Connection="Input" />
</Connection>
```

Connection names can be referenced by tool configuration, for example under output ordering. Before renaming or removing a named connection, search for the name.

Wireless links are still normal graph edges:

```xml
<Connection Wireless="True">
  <Origin ToolID="12" Connection="Action" />
  <Destination ToolID="3" Connection="Action" />
</Connection>
```

Preserve `Wireless="True"` and connection `name` attributes unless intentionally changing Designer presentation or connection semantics.

An empty graph may use:

```xml
<Connections />
```

Do not infer execution order from XML connection order alone. Preserve existing order for unrelated edits to reduce churn.

## Root Properties

Root workflow `Properties` appears directly under `AlteryxDocument` as a sibling of `Nodes` and `Connections`.

Common root properties include execution settings, UI/layout settings, workflow metadata, events, constants, and macro/app runtime properties:

```xml
<Properties>
  <Memory default="True" />
  <GlobalRecordLimit value="0" />
  <TempFiles default="True" />
  <RunWithE2 value="True" />
  <Annotation on="True" includeToolName="False" />
  <ConvErrorLimit value="10" />
  <ConvErrorLimit_Stop value="False" />
  <CancelOnError value="False" />
  <DisableBrowse value="False" />
  <EnablePerformanceProfiling value="False" />
  <DisableAllOutput value="False" />
  <ShowAllMacroMessages value="False" />
  <ShowConnectionStatusIsOn value="True" />
  <ShowConnectionStatusOnlyWhenRunning value="False" />
  <ZoomLevel value="0" />
  <LayoutType>Horizontal</LayoutType>
  <MetaInfo>
    ...
  </MetaInfo>
  <Events>
    ...
  </Events>
</Properties>
```

Preserve root execution settings, AMP/E2 engine-selection settings, layout settings, workflow metadata, identity and telemetry fields, events, constants, and runtime properties unless the requested edit targets them.

Workflow identity and telemetry fields can include `WorkflowId`, `Telemetry`, `PreviousWorkflowId`, and `OriginWorkflowId`. Do not rewrite them during unrelated edits.

## AMP/E2 Engine Selection

Alteryx workflows can run through the AMP/E2 engine path or the legacy E1 path. AMP/E2 is the default for newly created workflows in this skill unless the user explicitly asks for legacy E1. Some tools are supported only on AMP/E2, and AMP/E2 generally has better performance, but there are minor behavioral differences between AMP/E2 and E1.

Two XML flags can select AMP/E2:

```xml
<AlteryxDocument yxmdVer="2026.1" RunE2="T">
```

```xml
<Properties>
  <RunWithE2 value="True" />
</Properties>
```

The effective engine path is:

```text
use_amp_e2 = RunE2 || RunWithE2
```

Either `RunE2="T"` on the root `AlteryxDocument` or `<RunWithE2 value="True" />` under root `Properties` is enough to select AMP/E2. Both flags false or absent selects the legacy E1 path. In the known loader path, `RunWithE2` is read only for non-macro modules, so do not rely on `RunWithE2` alone for macro XML.

When creating a new workflow, set AMP/E2 explicitly. Prefer matching the XML style used by local Designer samples for the target version; if no stronger local pattern exists, include `RunE2="T"` on the root document and `<RunWithE2 value="True" />` under root `Properties` for standard workflows and analytic apps. For macros, include `RunE2="T"` on the root document.

When editing an existing workflow:

- Check both the root `RunE2` attribute and root `Properties > RunWithE2`.
- Preserve both flags during unrelated edits.
- Do not convert E1 to AMP/E2, or AMP/E2 to E1, without explicit user confirmation.
- If the user asks to add a tool that requires AMP/E2 to an existing E1 workflow, stop and ask for confirmation before changing the engine-selection flags.

## Configuration/Update Mode

For a full update run, set `updateMode="Full"` on the root document:

```xml
<AlteryxDocument updateMode="Full" ...>
```

Preserve the other root attributes, run the workflow, and then restore the root element to its original state even if the run fails.

In a full update, the Engine validates tool configuration and propagates field metadata without passing records between tools. Input tools may access their configured sources to obtain metadata, but normal record processing, workflow events, and output writing do not occur. A valid run exits `0`; configuration errors emit diagnostics and exit nonzero.

`AlteryxEngineCmd.exe` does not apply metadata or configuration update callbacks to the saved workflow, so use its full update run for validation rather than refreshing persisted workflow XML.

## Runtime Properties

`RuntimeProperties` appears under root `Properties` in macro and analytic app workflows. It connects interface tools, questions, actions, macro inputs/outputs, wizard fields, and app behavior.

Common structure:

```xml
<RuntimeProperties>
  <Actions>
    ...
  </Actions>
  <Questions>
    ...
  </Questions>
  <ModuleType>Macro</ModuleType>
  <MacroCustomHelp value="False" />
  <MacroDynamicOutputFields value="False" />
  <MacroInputs />
  <MacroOutputs />
  <Wiz_OpenOutputTools>
    <Tool ToolId="11" Selected="True" />
  </Wiz_OpenOutputTools>
</RuntimeProperties>
```

Actions describe how interface inputs update tools or workflow behavior. Important fields include:

- `ToolId`: interface/action tool driving the behavior.
- `Expression`: expression or interface value.
- `Destination`: target XML path, often starting with a target `ToolID`, such as `4/Disabled/@value`.
- `Mapping`: Designer-facing mapping description.
- `Mode`: update mode.

Questions describe macro/app interface elements and commonly map to interface tools through `ToolId` fields. Questions can be nested.

Root `Constants` often correspond to runtime questions:

```xml
<Constants>
  <Constant>
    <Namespace>Question</Namespace>
    <Name>Check Box (7)</Name>
    <Value />
    <IsNumeric value="False" />
  </Constant>
</Constants>
```

When editing macro or analytic app XML:

- Keep `RuntimeProperties`, root `Connections`, and root `Constants` aligned.
- Update `ToolId` fields when referenced tool IDs change.
- Update action `Destination` paths when target tool IDs or target XML paths change.
- Check `Wiz_OpenOutputTools` and other `Wiz_*` fields for tool references.
- Do not treat `RuntimeProperties` as disposable metadata.

## MetaInfo

There are two different `MetaInfo` concepts:

- root `Properties > MetaInfo`: workflow-level metadata.
- node `Properties > MetaInfo`: cached schema metadata.

Node-level `MetaInfo` commonly appears as:

```xml
<Properties>
  <Configuration>
    ...
  </Configuration>
  <Annotation DisplayMode="0">
    ...
  </Annotation>
  <MetaInfo connection="Output">
    <RecordInfo>
      <Field name="NewField" type="DateTime" />
    </RecordInfo>
  </MetaInfo>
</Properties>
```

The `connection` attribute identifies the output anchor whose schema is cached. A node can have multiple `MetaInfo` blocks for different output anchors such as `Left`, `Join`, and `Right`.

`MetaInfo connection="..."` names an output anchor, not a root-level `Connection name`.

Preserve node-level `MetaInfo` for unrelated edits. If changing schema, field names, field types, tool configuration, output anchors, or macro input/output behavior, expect cached metadata to become stale.

Agents using this skill generally cannot refresh saved `MetaInfo` by running Alteryx Engine. Engine execution can validate behavior and outputs, but saved workflow XML metadata is refreshed when a user opens and saves the workflow in Designer. After schema-changing edits, report that `MetaInfo` may remain stale until the workflow is opened in Designer.

## Annotations

Per-tool annotations live under node-level `Properties`:

```xml
<Annotation DisplayMode="0">
  <Name />
  <AnnotationText>UPPER</AnnotationText>
  <DefaultAnnotationText />
  <Left value="False" />
</Annotation>
```

`Name` is the tool annotation name. For workflows that run on the legacy E1 engine path, non-empty tool annotation `Name` values must be unique across the workflow. Duplicate names can fail E1 validation; AMP/E2 does not use the same validation path. Preserve existing names during unrelated edits, but when adding or renaming tool annotation names in an E1 workflow, check for duplicates first.

`AnnotationText` is usually explicit user-defined text. `DefaultAnnotationText` is often generated by tools. Preserve annotations unless intentionally changing labels.

Workflow-level annotation settings live under root `Properties`:

```xml
<Annotation on="True" includeToolName="False" />
```

Do not confuse workflow annotation settings with per-tool annotation blocks.

## Containers

Tool containers and control containers are represented as normal `Node` elements. Their distinguishing features are container-specific plugins, container configuration, and optional `ChildNodes`.

Common container shape:

```xml
<Node ToolID="1">
  <GuiSettings Plugin="AlteryxGuiToolkit.ToolContainer.ToolContainer">
    <Position x="41" y="65" width="145" height="133" />
  </GuiSettings>
  <Properties>
    <Configuration>
      <Caption>Container 1</Caption>
      <Style TextColor="#314c4a" FillColor="#ecf2f2" BorderColor="#314c4a" Transparency="25" Margin="25" />
      <Disabled value="False" />
      <Folded value="False" />
    </Configuration>
    <Annotation DisplayMode="0">
      <Name />
      <DefaultAnnotationText />
      <Left value="False" />
    </Annotation>
  </Properties>
  <ChildNodes>
    <Node ToolID="2">
      ...
    </Node>
  </ChildNodes>
</Node>
```

Container child nodes keep normal node structure, and their `ToolID` values are still global across the document.

Containers can be nested by placing a container `Node` inside another container's `ChildNodes`. Nested containers do not change `ToolID` scope or connection scope. A node inside any nesting depth is still referenced by its document-wide `ToolID`, and its graph edges still live in root `Connections`.

Connections involving contained tools remain in root `Connections`. Connections between child tools, top-level tools, and nested tools all use global `ToolID` references.

Tool containers commonly use:

```text
AlteryxGuiToolkit.ToolContainer.ToolContainer
```

Control containers commonly use:

```text
AlteryxGuiToolkit.ControlContainer.ControlContainer
```

Older files may use:

```text
AlteryxGuiToolkit.CtrlContainer.CtrlContainer
```

Preserve the plugin naming style already used in the file.

Control containers usually carry runtime settings:

```xml
<EngineSettings EngineDll="AlteryxBasePluginsEngine.dll" EngineDllEntryPoint="AlteryxCtrlContainer" />
```

Do not add or remove container `EngineSettings` by assumption. Preserve the local generated style unless local evidence shows a required change.

Macro runtime actions can target container configuration, especially enable/disable behavior:

```xml
<Destination>4/Disabled/@value</Destination>
<Mapping>Enable/Disable Container</Mapping>
```

## Structural Edit Checklist

Before editing:

- Determine whether the file is `.yxmd`, `.yxmc`, or `.yxwz`.
- Identify all affected `ToolID` values, including nested `ChildNodes`.
- Inspect affected nodes to confirm plugin names, engine settings, anchor names, annotations, and metadata.
- Inspect root `Connections` for affected graph edges.
- Inspect the root `RunE2` attribute and root `Properties > RunWithE2` before changing root document or root property XML.
- Search for affected `ToolID` references in runtime properties, questions, actions, constants, wizard fields, action destinations, and tool configuration.
- Search for affected connection names if changing named connections.
- For workflows that run on E1, search for duplicate non-empty tool annotation `Name` values before adding or renaming annotation names.
- Check whether affected nodes live inside ordinary or nested containers.

After editing:

- Every `Node ToolID` is unique across the full document.
- Every connection `Origin ToolID` and `Destination ToolID` resolves to an existing node.
- Every connection uses source and destination anchors verified from local evidence.
- Named connections still match any configuration references.
- `Wireless="True"` flags and connection names are preserved unless intentionally changed.
- Macro/app `RuntimeProperties`, root `Constants`, interface connections, action destinations, and wizard tool IDs still align.
- Root `Properties` remains a sibling of `Nodes` and `Connections`.
- Node-level and root-level `Properties` have not been confused.
- Existing workflows keep the same effective AMP/E2 vs legacy E1 engine path unless the user explicitly confirmed a change.
- E1 workflows do not contain duplicate non-empty tool annotation `Name` values introduced by the edit.
- Root metadata, telemetry, events, layout settings, annotations, and cached `MetaInfo` are preserved unless intentionally changed.
- Containers and nested containers keep intended `ChildNodes`, geometry, disabled/folded state, style, captions, plugin naming style, and engine settings.
- The workflow has been run with Engine when execution validation is in scope.
