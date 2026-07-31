# Lean Context

**Making an AI coding agent reliable: keep its context lean, and build the harness around it.**

Two halves of one discipline, from one real migration and the failures that taught it:

```
        MODEL  ──  the engine (raw capability; choose & route it)
      HARNESS  ──  the car    (steps, tools, loops, gates; build it)
      CONTEXT  ──  windscreen  (what the model sees; keep it lean)
```

Most "the AI did something wrong" moments are a **missing harness pillar** or **bad
context** — rarely a weak model. This repo is a plug-and-play knowledge base for the two
you control. It's portable markdown that any agent can read, and it ships as a Claude Code
plugin so the right piece loads *only when a task needs it* — at zero standing cost, which
is the whole thesis embodied.

> **New here?** Read **[GETTING-STARTED.md](GETTING-STARTED.md)** — plain-language
> steps to add this to any project and what you get out of it. No jargon.

---

## The context half — the economics that drive it

The whole context window is re-sent and re-charged on every turn. A file loaded at
session start is not paid once — it is paid `window × turns`. A 50k-token standing
load across a 40-turn session is 2M tokens of re-sending, and a diluted window
reasons measurably worse besides. Cost and quality are the same problem.

> **The one-line rule:** hold the minimum needed to *choose the next action*;
> fetch, isolate, or defer everything else.

## The harness half — the four pillars

A capable model still ships wrong work if the machine around it is missing a pillar. Every
task needs all four; remove one and the task ships wrong or silently bypasses you:

```
① STEPS   sequence that makes errors cheap to catch  (slow front, fast back)
② TOOLS   least privilege — worst mistake stays survivable
③ LOOPS   automated checks that go red on the ACTUAL problem
④ GATES   sign-offs that can't be performed as theater (silence = STOP)
```

> **The one-line rule:** a capable model still ships wrong work without a harness — build
> all four pillars, and put the gates that must hold in **hooks, not prose.**

---

## What's here

| File | For | How to use |
|---|---|---|
| **[GETTING-STARTED.md](GETTING-STARTED.md)** | A newcomer | Plain-language: how to add it to a project and how it helps. Start here. |
| **[INDEX.md](INDEX.md)** | Anyone / an agent | The thin map. Read it, then fetch exactly one file. |
| **[PLAYBOOK.md](PLAYBOOK.md)** | A human, once | The *why* of lean context, plus the failures — which are the useful part. |
| **[DIRECTIVE.md](DIRECTIVE.md)** | An agent, per repo | Drop in the repo root. Say: *"Read `DIRECTIVE.md` and execute it. Stop at each STOP for my approval."* |
| **[HARNESS.md](HARNESS.md)** | An agent / a human | The harness reference — pillars, loops, gates, model routing, session architecture, failure modes. Fetched on demand. |

Works on a fresh repo (it scaffolds) and on an ongoing one (it audits and refactors
in place). Tool-agnostic: Claude Code, Cursor, Codex, Aider, or anything else that
auto-loads an instruction file at session start.

---

## Install as a plugin (Claude Code)

The same markdown, packaged so it's genuinely plug-and-play. The skills auto-invoke only
when a task matches, so nothing sits in your standing context until it's needed:

```
/plugin marketplace add sayeediftekhar/lean-context
/plugin install lean-context@lean-context
```

What you get:

- **Skill `lean-context`** — fires on context-bloat / tiering / token-cost tasks; runs the
  DIRECTIVE and the PLAYBOOK's disciplines.
- **Skill `harness-engineering`** — fires on loop design, model routing, gates, least-
  privilege tool design, or debugging a silent / false-green failure.
- **Command `/lean-context:lean-context`** — runs the STOP-gated migration directive on the
  current repo.
- **Hook `commit-gate`** — the demonstrator for HARNESS §6: a commit gate that's a *wall*,
  not a suggestion. **Opt-in** — it does nothing until you set `LEAN_CONTEXT_COMMIT_GATE=warn`
  (advisory) or `=block` (hard-block the commit). A plugin that blocked every commit by
  default would be user-hostile; you choose when the gate is live.

Prefer no plugin? Ignore all of the above — the four markdown files work in any agent on
their own. The plugin is a convenience wrapper over them, not a dependency.

---

## The structure it installs

- **Tier 1 — always-on.** Your agent instruction file (`CLAUDE.md`, `AGENTS.md`,
  `.cursorrules`, …). Per-turn imperatives, the project's hard invariants, and an
  **authorities index**: a table of *authority → path → what it governs*. Hard budget.
- **Tier 2 — the bookshelf.** Procedures as skills or slash commands, loaded only
  when a task matches.
- **Tier 3 — deep reference.** A `docs/` folder in the target repo — here, `HARNESS.md` itself — fetched on demand, never standing.

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

The plugin's skills, by contrast, do **not** restate the docs — they point at them via
`${CLAUDE_PLUGIN_ROOT}`, single source of truth, so the two never drift. That's the same
anti-duplication discipline the PLAYBOOK preaches, applied to the packaging.

---

## Provenance

The context half was written after one migration on one real codebase, in July 2026:
standing context cut from ~112k to ~47k tokens. Both figures are tokenizer-measured, not
character-estimated — §6 of the playbook explains why that distinction cost a day to
learn. The harness half generalizes the same author's mental model of the machine around
the model. Everything here is generalization from limited real practice, and should be
treated as such: the mechanisms are sound, the numbers are one data point.

The failures are documented as carefully as the successes. Three separate times in
one session a guard fired and **the guard was wrong, not the content**. Budget for that.

---

*Sayeed Iftekhar · Chattogram, Bangladesh*
