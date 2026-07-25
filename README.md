# Lean Context

**Two files for cutting an AI coding agent's always-on context, and keeping it cut.**

The whole context window is re-sent and re-charged on every turn. A file loaded at
session start is not paid once — it is paid `window × turns`. A 50k-token standing
load across a 40-turn session is 2M tokens of re-sending, and a diluted window
reasons measurably worse besides. Cost and quality are the same problem.

> **The one-line rule:** hold the minimum needed to *choose the next action*;
> fetch, isolate, or defer everything else.

---

## What's here

| File | For | How to use |
|---|---|---|
| **[PLAYBOOK.md](PLAYBOOK.md)** | A human, once | Read it. It is the *why*, plus the failures — which are the useful part. |
| **[DIRECTIVE.md](DIRECTIVE.md)** | An agent, per repo | Drop in the repo root. Say: *"Read `DIRECTIVE.md` and execute it. Stop at each STOP for my approval."* |

Works on a fresh repo (it scaffolds) and on an ongoing one (it audits and refactors
in place). Tool-agnostic: Claude Code, Cursor, Codex, Aider, or anything else that
auto-loads an instruction file at session start.

---

## The structure it installs

- **Tier 1 — always-on.** Your agent instruction file (`CLAUDE.md`, `AGENTS.md`,
  `.cursorrules`, …). Per-turn imperatives, the project's hard invariants, and an
  **authorities index**: a table of *authority → path → what it governs*. Hard budget.
- **Tier 2 — the bookshelf.** Procedures as skills or slash commands, loaded only
  when a task matches.
- **Tier 3 — deep reference.** `docs/`, fetched on demand, never standing.

Plus session-typed context (a coding session shouldn't pay for learning context) and
a handoff ritual that runs *before* the window degrades, not after.

**The most common failure this fixes:** Tier 1 carrying project memory — architecture,
business rules, schema values, units, column names, design tokens, a build queue —
inlined into the one file that loads every single session.

---

## A note on the duplication

`DIRECTIVE.md` ends with an Appendix restating principles that `PLAYBOOK.md` also
covers. That is deliberate. The directive is self-contained so that running it never
requires loading a second document — a directive about lean context that demanded an
extra file at session start would refute itself. The playbook is prose for a person;
the appendix is a compressed rule set for an agent. Same ideas, different readers,
different lifetimes.

---

## Provenance

Written after one migration on one real codebase, in July 2026: standing context cut
from ~112k to ~47k tokens. Both figures are tokenizer-measured, not
character-estimated — §6 of the playbook explains why that distinction cost a day to
learn. Everything else is generalization from a single project, and should be treated
as such: the mechanisms are sound, the numbers are one data point.

The failures are documented as carefully as the successes. Three separate times in
one session a guard fired and **the guard was wrong, not the content**. Budget for that.

---

*Sayeed Iftekhar · Chattogram, Bangladesh*
