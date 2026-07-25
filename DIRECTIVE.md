# LEAN-CONTEXT DIRECTIVE
### A drop-in instruction that refactors a project's knowledge system into a tiered, load-on-demand structure

> **How to use this file.** Drop it in the repo root of any project — new or existing — and tell your
> coding agent:
> *"Read `DIRECTIVE.md` and execute it. Stop at each STOP for my approval."*
> It works on a fresh repo (it scaffolds) and on an ongoing one (it audits and refactors in place).
> This directive is self-contained: the principles it encodes are in the Appendix, so **no other
> document needs to be loaded to run it.** That is not an oversight — a directive about lean context
> that demanded an extra file at session start would refute itself.

---

## 0. What you are implementing (read first)

You are converting this repository's knowledge system so that **the standing context loaded at the
start of every session is minimal**, while **all depth stays on disk, fetchable on demand**. The goal
is stated exactly once: *the token bill of a session scales as `window size × number of turns`, so we
hold only what's needed to choose the next action, and fetch, isolate, or defer everything else.*

Concretely you will produce three tiers:

- **Tier 1 — always-on rules** (the agent instruction file, kept tiny): only the imperatives needed
  almost every turn.
- **Tier 2 — the bookshelf** (skills / slash commands): procedures loaded only when a task matches.
- **Tier 3 — deep reference** (`/docs`, fetchable): the "why," pulled in only when explicitly needed.

You will also install the **session-typed context** split and the **doc-sync** handoff ritual.

### The instruction file

Throughout this directive, **`INSTRUCTION-FILE`** means whichever file your agent tooling auto-loads at
session start — `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.github/copilot-instructions.md`, or your
equivalent. Identify it in Step 1 and use the real name from then on. If a project has several, treat
the auto-loaded one as Tier 1 and the rest as candidates for Tier 3.

### Accelerators (detect; do not assume)

Some repos run a routing/governance layer, a task-rigor router, or a code-derived call/dependency graph
used to *find* things fast. **Detect what is present in Step 1 rather than assuming any particular
tool.** Where one exists, you are extending its philosophy to the project's docs, not replacing it —
reference it, never reinvent it.

**Two rules about accelerators never bend, whatever the tool:**

1. Their **output** — a route decision, a generated graph, a search result — is never loaded as
   standing context. It is fetched in the moment and dropped.
2. A **derived artefact is never an authority.** The truth order holds absolutely:
   `live DB / schema / data > code > derived graph > prose docs`.

**Watch for the most common offender:** an `INSTRUCTION-FILE` that has grown to carry **project
memory** — architecture, business rules, schema values, units, column names, design tokens, a build
queue — *inline*, so all of it loads every session. That prose belongs in Tier 3 (`docs/`, the schema),
referenced by an authorities index, **not** standing in Tier 1. Splitting it out is usually the single
biggest win of this whole migration.

It is also often what the project's *own* rules already demand — e.g. a stated principle that "this file
is intent and rules, never the ground truth for a value, unit, or column." If such a rule exists, the
memory section already violates it; cite that when you propose the split.

---

## 1. Prime directives (fail closed — obey these over any convenience)

1. **Plan before you touch anything.** Complete Step 1 (Discover) and Step 2 (Propose), then **STOP**
   and wait for explicit approval before writing, moving, or deleting a single file.
2. **Never destroy content.** This is a *re-filing*, not a rewrite. Move or supersede; never delete.
   Anything you remove from an active file goes to `docs/_archive/` with a note on where it came from.
3. **Preserve every fact.** If you are unsure whether a line still matters, **keep it and flag it** —
   do not drop it. Losing a real constraint is far worse than an extra archived line.
4. **Do not touch accelerator-owned code.** Vendored upstream directories, generated graph stores,
   framework-managed manifests — integrate *around* them. Never edit them, and never promote a derived
   artefact to an authority.
5. **One reviewable change at a time.** Show diffs. If the migration is large, slice it and stop
   between slices.
6. **When in doubt, halt and ask** — do not guess a project-specific fact (its hard invariants, its
   money type, its tenancy model). Park the question; keep going on what's safe.
7. **Measure, do not estimate.** Never report a token count derived from `chars ÷ 4`. Measure at least
   one file with the real tokenizer, derive the ratio, scale the rest, and label plainly which numbers
   are measured and which are scaled. Character estimates have undercounted by 65% in practice.
8. **Narrate long tool runs.** Several silent tool calls are indistinguishable from a hang, and an
   interrupt mid-migration risks a half-moved file.

---

## 2. Step 1 — DISCOVER (assume nothing; measure)

Inventory the current knowledge system without changing it. Report a table with one row per file:

| File / path | ~tokens | Loaded at session start? | Role (rules / context / procedure / deep ref / stale?) |
|---|---|---|---|

Cover at least: the `INSTRUCTION-FILE`, any `CONTEXT*.md`, `LEARNINGS*.md`, `README.md`, everything
under `docs/`, everything under your agent config directory (commands, skills, agents, hooks,
settings), and any accelerator framework installed (its vendored directory, manifest, lanes, and its
own how-to docs).

Then determine and state plainly:

- **Which file is the `INSTRUCTION-FILE`?** Name it. Confirm the tooling actually auto-loads it.
- **Does it carry project memory inline?** Split it in your head into (a) always-on rules vs
  (b) project memory — architecture, business logic, schema values/units/columns, design tokens, build
  queue. Report the approximate line/token split. **(b) is the primary front-loading offender** and the
  main thing this migration moves to Tier 3.
- **Accelerators present?** Name any router, rigor lane, or derived-graph tool, and how it is governed.
  Confirm its output is *not* being loaded as standing context, and that no rule treats a derived
  artefact as an authority.
- **New or existing?** New = little/no context system (you'll scaffold). Existing = has docs (you'll
  refactor).
- **Current standing load.** Measure the total tokens pulled into the window at a *typical session
  start* today — i.e. everything a session is told to read up front. **This is the number we're driving
  down; record it as the baseline**, and state how it was measured.
- **Front-loading offenders.** Flag any single file >~400 lines that is loaded up front, and any
  instruction like "read CONTEXT.md, LEARNINGS.md, …" at session start.
- **Duplication.** Note anything that exists in two places — those diverge silently and one copy is
  already wrong.

**STOP.** Present the inventory + baseline + a one-paragraph diagnosis. Wait for approval to propose.

---

## 3. Step 2 — PROPOSE the target structure

Present the target layout below, adapted to what Step 1 found, as a concrete file plan (what gets
created, slimmed, moved, or archived). Do not execute yet.

### Tier 1 — `INSTRUCTION-FILE` (always-on; hard budget ≤ ~80 lines / ~1.5k tokens)

This is the only guaranteed always-in-context slot, so it may contain **only**:

- **Per-turn imperatives** — e.g. *one task = one PR; plan before code; verify in the real environment,
  green tests aren't proof; load context on demand, never front-load.*
- **This project's hard invariants** — the 4–8 rules that block a PR: money type, tenancy scoping, sole
  writer, and so on.
- **A routing line**, if the project has a rigor router: *"Route every task through the router — light
  vs heavy by danger surface."*
- **An authorities index** — a small table of *authority → path → what it governs* (truth/schema, laws,
  living state, design, intent docs). This is the pointer that replaces inlined project memory: the
  agent reads the index, then fetches the one authority a task needs.
- **Imports pointing at depth** (e.g. `@docs/INDEX.md`) so deep material is **discoverable but not
  loaded**.

Nothing that isn't needed almost every turn belongs here.

**Move all project memory out into Tier 3.** Architecture, business rules, schema values/units/columns,
design tokens, build queue, "built so far" — these go to `docs/` (or are already there and merely
duplicated), and Tier 1 keeps only the authorities index that points at them. Verify each moved fact
against its real source (schema, live system, docs) rather than trusting the copy that was in the
instruction file; on any conflict the live source wins.

### Tier 2 — the bookshelf (loaded only on match)

Procedures live as skills / slash commands, not as standing prose:

- **Keep and route through existing accelerators.** If the project already has a rigor router, a token
  optimizer, or a code graph, reference them — never reinvent them. A derived graph belongs inside
  *find-fast* helpers (`verify-fact`, `review`), rebuilt after each task, its output never standing
  context and never an authority.
- **Add only what's missing**, as thin index skills: a **`doc-sync`** command (§5), and — only if an
  existing heavy lane doesn't already cover them — `verify-fact` and `review`.
- Register any new command in whatever thin-index convention the project already uses. Leave vendored
  directories untouched.

### Tier 3 — deep reference (fetchable; never standing)

- A `docs/` folder holding the "why": methodology, deep specs, architecture.
- A thin **`docs/INDEX.md`** (~30 lines): a table of *topic → file*, nothing more. This is the pointer
  the agent reads first, then it fetches only the one file it needs.

### Session-typed context (the load-on-demand core)

- `context/core.md` — tiny shared cold-start state (current phase, what's committed, the one open
  decision). Small enough to always load.
- `context/coding.md` and `context/learning.md` — mode-specific context, loaded per session type, never
  both at once. Add other modes only if the project clearly has them.
- The old monolithic `CONTEXT.md` becomes a **thin handoff pointer** (or is archived) — its bulk is
  split into the above and into `docs/`.

**STOP.** Present the plan as a before→after file map with the *projected* new standing load. Wait for
approval.

---

## 4. Step 3 — MIGRATE (only after approval; slice it)

Execute the approved plan, showing diffs, in this order:

1. **Snapshot.** Copy every file you are about to touch into `docs/_archive/` untouched. Everything
   downstream — the guard, the diff, the ability to recover — depends on an unmodified original.
2. **Probe before you move.** For each block you intend to relocate, confirm the destination does not
   already hold the fact, and confirm no fact in it exists *nowhere else*. Facts with no other home are
   the ones a naive swap deletes.
3. **Hoist live carry-forwards.** Shipped records are not homogeneous — each mixes a dead receipt with
   something still live. Sweep for `STILL OPEN`, `PARKED`, `CARRY FORWARD`, `DEFERRED`, `NEXT`, `MUST`,
   `TODO` before moving any block, and lift those out first.
4. Create `docs/INDEX.md` and the `docs/` structure; move deep prose out of any front-loaded file into
   `docs/`, leaving an import reference behind. **Move verbatim — never summarize to shrink.** The
   destination is disk, where size is free.
5. Slim the `INSTRUCTION-FILE` to the Tier-1 budget. Everything ejected goes to `docs/` (referenced),
   not deleted.
6. Split any giant `CONTEXT.md` into `context/core.md` + `context/coding.md` + `context/learning.md`.
   Archive the original at `docs/_archive/CONTEXT.original.md` with a header noting the split.
7. **Tag and drain superseded warnings.** A resolved constraint that still reads as live is worse than
   clutter — it actively misleads.
8. Add the `doc-sync` command and any missing Tier-2 skill.
9. Wire imports so depth is discoverable, not loaded. Confirm any existing routing still fires.
10. Do **not** modify vendored or accelerator-owned files at any point.

---

## 5. Step 3b — Install the `doc-sync` ritual (the ongoing discipline)

A one-time cleanup regrows. The migration is worth less than the rule that keeps it drained. Create a
`doc-sync` command whose job is the between-session handoff, and document *when* to run it:

**What it does:** updates `context/core.md` and `LEARNINGS.md` (trap → rule → why), and writes the
next-session opening handoff — a **summary** (decisions made, current state, the one open question),
**not a transcript dump**. Keeps every touched file within its budget.

**The drain steps it performs:**

1. Move shipped records out — merged, no live carry-forward → it is history.
2. Kill superseded warnings.
3. Check the budget against a **concrete number** (e.g. ~250 lines) that triggers a drain. "Keep it
   tidy" is not a rule; a number is.
4. Run the guards (§6).
5. Never summarize a record to shrink it.

**When to run it:** at the end of a task, and **before the window rots** — proactively at a natural
chunk boundary, not after quality has already degraded. The end of a long session is the *worst* moment
to trust the agent to write a clean handoff, so sync a beat early.

**Optional:** suggest (do not silently install) a stop/commit hook that nudges "did `context/core.md`
get updated?" so the discipline doesn't depend on memory.

---

## 6. Step 3c — Guards (every preservation claim needs a check)

"Nothing was lost" is a **claim until something checks it**. Write the check, then make it fail on
purpose. **A guard you have not watched go red is faith, not enforcement.**

Four failure modes to design against, all observed in practice:

- **Vacuous guards.** If you copy a file into a superset destination, "does every original line
  survive?" can never fail. Ask of every guard: *what state of the world makes this go red?* If you
  cannot answer concretely, it observes nothing. Assert the property that can actually break.
- **Crying wolf.** A guard frozen against a snapshot goes red the moment a tracked line is
  *legitimately* edited — and a guard that fails on healthy content gets ignored, then deleted. Use an
  **allowlist with a required reason**, so retirement is a conscious act rather than a silent deletion.
- **Broken instruments.** Never pipe into an early-exiting consumer (`grep -q`, `head`) inside a
  `pipefail` script when you branch on the exit code — the successful case reads as failure and the
  check *inverts* rather than errors. Redirect from a file instead. **Validate the instrument on one
  case you can confirm by hand before believing an alarming measurement.**
- **Fixes that break what they fix.** After repairing a guard, re-run the *original passing case*, not
  just the new one.

**Never chain a guard run and a commit in one command.** The gate batches; the commit lands even when
the guard goes red. Run checks as their own step and read the result before proceeding.

---

## 7. Step 4 — VERIFY (definition of done)

The task is not done until you produce `docs/MIGRATION-REPORT.md` containing:

- **Standing load: before → after**, with the token reduction, and a statement of how each number was
  measured. This is the headline result.
- **Fact-preservation check:** confirm nothing was lost — every archived line is accounted for, no
  active constraint dropped. List anything you flagged as uncertain.
- **Wiring check:** the `INSTRUCTION-FILE` is within budget and loads; all imports resolve;
  `docs/INDEX.md` points to real files; any router still triggers; vendored directories untouched.
- **Human verification list:** green checks mean nothing mechanical broke. They cannot tell you whether
  Tier 1 still carries what is needed every turn, or whether migrated domain facts are still *true*.
  Name the checks a human must run in the real environment, and say plainly which were skipped.
- **A one-screen "how to drive this":** which tier holds what, how a new session should start (read the
  thin core + INDEX, fetch depth on demand), and how to run `doc-sync`.

**STOP.** Present the report. The migration is complete only on explicit sign-off.

---

## 8. The canary (how to tell it actually worked)

After the migration the failure mode is silent: the structure exists but the agent ignores it and pulls
everything anyway.

**Failure signal:** an agent quoting deep reference nobody asked for — the build queue, a design token,
a domain list — in a task that had no reason to touch it. Depth is being loaded, not fetched.

**Success signal:** a fresh session picks up a mid-flight task **from the state file alone**, without
reading code or docs to reconstruct where things stand.

---

## 9. What NOT to do (the failure list)

- Do **not** load deep guides or specs at session start — they are Tier-3, fetchable only.
- Do **not** delete anything; archive instead.
- Do **not** edit vendored or accelerator-owned files, or reimplement an existing router.
- Do **not** let the `INSTRUCTION-FILE` grow past its budget "just this once."
- Do **not** guess project-specific facts (invariants, money type, tenancy). Park and ask.
- Do **not** report a token count you estimated from character length.
- Do **not** summarize a record in order to shrink it.
- Do **not** proceed past a STOP without approval.

---

## Appendix — the principles this directive encodes (so no external doc is needed)

- **The bill is `window × turns`.** The whole window is re-sent and re-charged every turn, so cost and
  quality are the same fact: a lean window is both cheaper and sharper.
- **Files on disk cost nothing; loading costs, and re-sending costs repeatedly.** Many small files are
  cheap; one big file front-loaded is expensive, paid every turn.
- **Front-load nothing; index then fetch.** Hold a thin index in context; grep or open the one section
  needed, when needed. The filesystem is the memory.
- **Progressive disclosure.** Procedures live on a bookshelf, loaded only on a task match.
- **Session-typed context.** A coding session shouldn't pay for learning context, or vice versa.
- **Subagent isolation is a cost lever.** Heavy subtasks run in their own window and return a distilled
  result, so the main thread's bill stays small. A subagent must state that its results are *derived*
  and state its search coverage honestly — a confident summary over a partial sweep turns "nothing
  found" into a wrong decision.
- **Lean handoffs; sync before the dumb zone.** A short summary seeds a fresh window better and cheaper
  than pasting a dying session back in.
- **Graduated rigor, fail closed.** Match ceremony to risk; default to the safe path when unsure.
- **Curate, don't hoard.** Install and load only what is actively used.
- **Accelerator output is never standing context, and a derived artefact is never an authority.**
  Truth order: `live DB / schema / data > code > derived graph > prose docs`.
- **Tier 1 holds rules plus an authorities index, never project memory.** Values, units, columns,
  architecture and design tokens live in the schema and `docs/`, fetched on demand — not inlined into
  the file that loads every session.
- **The three-way test for any living document.** Would a future task act *differently* because of this
  line? → lesson. Does it merely record that something happened? → history. Is it still true and still
  constraining work? → state. Three files, three lifetimes. Most context bloat is history wearing
  state's clothing.
- **Measure, don't estimate.** Assumptions feel like knowledge.

*One line: hold the minimum needed to choose the next action; fetch, isolate, or defer everything else.*
