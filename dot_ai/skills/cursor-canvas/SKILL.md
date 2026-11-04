---
name: cursor-canvas
description: >-
  Create, edit, or debug Cursor Canvas artifacts from Codex by writing single-file
  .canvas.tsx React components that Cursor can open beside the chat. Use when
  the user asks for a canvas, wants a visual/shareable representation of
  analysis or structured data, or asks to present findings as charts, tables,
  dashboards, timelines, or other standalone analytical artifacts in Cursor.
---

# Cursor Canvas

Cursor canvases are single `.canvas.tsx` files that Cursor detects and renders
as React apps beside the chat. Codex can create them by writing the file into
the Cursor-managed project canvas directory.

## Source of Truth

Before creating, editing, or debugging any canvas, read Cursor's live canvas
skill documentation:

```text
/home/user/.cursor/skills-cursor/canvas/SKILL.md
```

Treat that file as the source of truth for current workflow, policy, component
usage, design rules, troubleshooting, and any syntax changes. The instructions
below are only a compact fallback for discovery and orientation; if they differ
from Cursor's live `SKILL.md`, follow Cursor's file.

## When to Use

Use a canvas when the deliverable is a standalone analytical artifact:

- Quantitative analysis, investigations, audits, timelines, reports, or reviews
- Data-heavy findings that would otherwise become a large markdown table
- Charts, tables, summaries, comparison views, or repeatable small tools
- MCP/tool output where the structured data is the final deliverable

Skip a canvas for ordinary code changes, short factual answers, drafts intended
for another tool, or when the user asked for a specific non-canvas deliverable.

## File Location

Write the canvas directly under the Cursor project directory for the current
workspace:

```text
/home/user/.cursor/projects/<cursor-project>/canvases/<name>.canvas.tsx
```

Derive `<cursor-project>` from the active workspace path rather than hard-coding
it. Cursor commonly encodes `/home/user/my-project` as
`home-user-my-project`. If that inferred directory is not present, list:

```text
/home/user/.cursor/projects/
```

Choose the directory matching the current workspace path, then write into its
`canvases/` directory. Use a descriptive kebab-case filename ending in
`.canvas.tsx`.

## Hard Rules

- Exactly one `.canvas.tsx` file per canvas.
- Import only from `cursor/canvas`.
- Default-export the top-level React component.
- Embed data inline. No `fetch()`, network calls, relative imports, npm package
  imports, Node built-ins, helper files, or separate CSS files.
- Do not render placeholder or empty sections. If there is no real data for a
  section, omit it.

## SDK Reference

Before using unfamiliar components or props, read Cursor's SDK declarations:

```text
/home/user/.cursor/skills-cursor/canvas/sdk/index.d.ts
```

Use built-in `cursor/canvas` components where possible. Common exports include
`Card`, `CardHeader`, `CardBody`, `Grid`, `Row`, `Stack`, `Stat`, `Table`,
`LineChart`, `BarChart`, `PieChart`, `DiffView`, `Pill`, `Callout`, and
`useHostTheme`.

## Minimal Pattern

```tsx
import { Card, CardBody, CardHeader, useHostTheme } from "cursor/canvas";

export default function MyCanvas() {
  const theme = useHostTheme();

  return (
    <div
      style={{
        padding: 24,
        background: theme.colors.background,
        color: theme.colors.foreground,
      }}
    >
      <Card>
        <CardHeader title="My Analysis" />
        <CardBody>{/* real content */}</CardBody>
      </Card>
    </div>
  );
}
```

## Design Rules

- Use colors from `useHostTheme()` or exported canvas tokens. Avoid hardcoded
  color values unless the SDK requires a named palette token.
- Keep the layout flat, minimal, and purposeful.
- Avoid gradients, box shadows, decorative borders, emojis, and rainbow color.
- Do not wrap every section in identical cards; mix open layout, grids, stats,
  tables, and cards based on information hierarchy.
- Label charts with the metric, axes and units, legend for multiple series,
  source, time range, and any transformation such as average, p95, normalized,
  or smoothed values.

## Verification

After writing a canvas:

1. Check the file is in the exact Cursor `canvases/` directory.
2. Optionally read any `<name>.canvas.status.json` sidecar in that directory if
   Cursor created one; use diagnostics there to fix compile/runtime issues.
3. In the final response, link the created `.canvas.tsx` file and say it can be
   opened as a Cursor canvas.
