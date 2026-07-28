---
description: >-
  Cut an AI coding agent's always-on / standing context and keep it cut. Use
  when the instruction file (CLAUDE.md, AGENTS.md, .cursorrules, copilot-
  instructions) has grown large or carries project memory inline; when a
  session front-loads big docs (CONTEXT.md, LEARNINGS.md) at start; when someone
  wants to reduce token cost, tier their knowledge base into load-on-demand
  structure, or measure and shrink standing context. Also use to audit a repo's
  context system or to scaffold one on a fresh repo. Keywords: context bloat,
  token optimization, front-loading, tiering, window × turns, CLAUDE.md too big.
---

# Lean Context — cut standing context, keep it cut

This skill runs the context-engineering half of this repo. The full material is
on disk; load only what the task needs.

## The rule that governs everything

Hold the minimum needed to **choose the next action**; fetch, isolate, or defer
everything else. The token bill is `window size × turns` — a file loaded at
session start is paid every turn, not once. Cost and quality are the same
problem: a crowded window also reasons worse.

## What to do

1. **If the task is to actually migrate/refactor a repo's context system** (new
   or existing): read and execute `${CLAUDE_PLUGIN_ROOT}/DIRECTIVE.md`. It is a
   self-contained, STOP-gated procedure — Discover → Propose → Migrate → Verify.
   Honor every **STOP**: wait for explicit human approval before writing, moving,
   or deleting anything. Do not summarize records to shrink them; move verbatim.

2. **If the task is to understand the why, or diagnose a bloat problem**: read
   `${CLAUDE_PLUGIN_ROOT}/PLAYBOOK.md`. It carries the economics, the three-way
   test (lesson vs history vs state), the guard failure modes, and the
   measurement discipline.

3. **If the task also touches the harness** (loops, gates, routing, session
   ritual): the context tiers connect to `${CLAUDE_PLUGIN_ROOT}/HARNESS.md` §9.
   Use `${CLAUDE_PLUGIN_ROOT}/INDEX.md` as the map.

## Non-negotiables (pulled forward so they can't be missed)

- **Measure, don't estimate.** Never report a token count from `chars ÷ 4` — it
  has undercounted by ~65%. Measure one file with the real tokenizer, scale the
  rest, label which numbers are measured vs scaled.
- **Snapshot before touching.** Copy any file to `_archive/` before editing.
- **Preserve every fact.** This is a re-filing, not a rewrite. Unsure if a line
  is live? Keep it and flag it. Verify a fact landed before removing the source.
- **A guard you haven't watched go red is faith, not enforcement.**
- Anything that must be *guaranteed* (a commit gate, a forbidden command)
  belongs in a hook or deny-list, not in prose.

Read the referenced file(s) now, then proceed against them — do not act from
this summary alone for a real migration.
