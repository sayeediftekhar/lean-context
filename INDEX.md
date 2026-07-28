<!-- INDEX.md — the thin map. Read this first; fetch exactly one file from it.
     This is Tier 3 itself: ~40 lines, topic → file, nothing more. It exists so
     an agent never has to load four documents to find the one it needs. -->

# Harness & Context Engineering — Index

Two halves of one discipline for making an AI coding agent reliable:

```
        MODEL  ──  the engine (raw capability; choose & route it)
      HARNESS  ──  the car    (steps, tools, loops, gates; build it)
      CONTEXT  ──  windscreen  (what the model sees; keep it lean)
```

Most "the AI did something wrong" moments are a **missing harness pillar** or
**bad context** — rarely a weak model. This repo covers the two you control.

---

## The map — read this, then fetch ONE file

| If you are… | Read | Half |
|---|---|---|
| New here, want the whole idea | `README.md` | both |
| Cutting an agent's always-on context / token bloat | `PLAYBOOK.md` | context |
| Ready to refactor a repo into tiers (drop-in for the agent) | `DIRECTIVE.md` | context |
| Designing steps, tools, loops, or gates for a task | `HARNESS.md` §2–6 | harness |
| Deciding which model a task needs | `HARNESS.md` §7 + `PLAYBOOK.md` §8 | both |
| Debugging a silent / false-green failure | `HARNESS.md` §10 | harness |
| Setting up a session / handoff ritual | `HARNESS.md` §8 + `PLAYBOOK.md` §7 | both |
| Installing this as a Claude Code plugin | `README.md` → "Install as a plugin" | — |

---

## How the two halves connect

- **Context is one pillar of the harness.** `HARNESS.md` §9 (context tiers) is
  the doorway; `PLAYBOOK.md` + `DIRECTIVE.md` are the full room behind it.
- **Routing lives in both.** `HARNESS.md` §7 argues it from *loops* (a loop is
  a routing unlock); `PLAYBOOK.md` §8 argues it from *cost per correct task*.
  Neither is complete without the other.
- **Gates are the hinge.** Both halves land on the same rule: what must be
  guaranteed goes in a **hook or a deny-list**, never in prose. See
  `HARNESS.md` §6 and `DIRECTIVE.md` §6.

---

## The one-line version of each

- **Context (PLAYBOOK/DIRECTIVE):** hold the minimum needed to choose the next
  action; fetch, isolate, or defer everything else. The bill is `window × turns`.
- **Harness (HARNESS):** a capable model still ships wrong work without a
  harness — build all four pillars, and put the gates that must hold in hooks.

*Everything here is Tier 3 — fetched on demand, never pre-loaded.*
