# The Portable Playbook

**What transferred out of one project, and what it cost to learn.**

Written 2026-07-22, after cutting a codebase's always-on agent context from ~112k to
~47k tokens in a day. Every claim here is backed by something that actually happened,
and the failures are included — they are the useful part.

*On "we":* one developer working with a coding agent across a single long session.
Not a team, not a study. One project, one migration. The mechanisms below should
transfer; the numbers are a single data point and deserve to be read that way.

*On the numbers:* 112k and 47k are tokenizer-measured. §6 explains why that
distinction matters more than it sounds like it should.

Designed to be copied into any repo. Nothing below is specific to a domain, a stack,
or a framework.

---

## 1. The economics that drive everything

**The whole context window is re-sent and re-charged on every turn.** So a file loaded
at session start is not paid once, it is paid `window × turns`. A 50k-token standing
load across a 40-turn session is 2M tokens of re-sending.

This makes cost and quality the *same problem*, not a trade-off. A bloated window is
both more expensive and worse at reasoning, because attention dilutes. In practice
agents seem to reason sharply in a bounded window and degrade quietly past it — no
error, no warning, just worse decisions. Where that boundary sits varies by model and
by task, so treat it as a direction, not a threshold: less standing context is
reliably better, and you will not get an alert when you cross into worse.

**The one-line rule:** hold the minimum needed to *choose the next action*; fetch,
isolate, or defer everything else.

**Files on disk cost nothing.** Only loading costs. This inverts normal documentation
instincts: many small fetchable files beat one comprehensive always-on file, and you
should never delete something to save space — move it.

---

## 2. Three tiers

- **Tier 1 — always-on.** The agent instruction file (`CLAUDE.md`, `AGENTS.md`,
  `.cursorrules`, or your tool's equivalent). Per-turn imperatives, the project's hard
  invariants, and an **authorities index**: a table of *authority → path → what it
  governs*. Budget it hard.
- **Tier 2 — the bookshelf.** Procedures as skills or slash commands, loaded only when
  a task matches.
- **Tier 3 — deep reference.** `docs/`, fetched on demand, never standing.

**The most common failure is Tier 1 carrying project memory.** Architecture, business
rules, schema values, units, column names, design tokens, a build queue — inlined into
the file that loads every session. That prose belongs in Tier 3, reached through the
authorities index.

Watch for the self-contradiction: files like this often *state* "this is intent and
rules, never the ground truth for a value or unit" and then list hex codes and decimal
precisions three lines later. If that rule exists, the memory section already violates
it — cite it when proposing the split.

---

## 3. The three-way test (the most portable idea here)

Living documents rot because everything gets appended and nothing leaves. The fix is
one question asked of every line:

> **Would a future task do something *differently* because of it?** → it is a
> **lesson**. Put it with the lessons.
> **Does it merely record that something happened?** → it is **history**. Put it in a
> receipt ledger.
> **Is it still true and still constraining work?** → it is **state**. It stays.

Three different files, three different lifetimes. Most "context bloat" is history
wearing state's clothing.

**The receipt ledger.** History is not a narrative retelling — that duplicates
whatever per-task docs you already keep, and duplicates drift. It is a table:
task · date · PR · merge SHA · test count · spec path. One row per shipped thing, plus
the verbatim record beneath. It earns its place only by holding what git does not:
which spec covers it, what a human verified in the real environment, what got deferred
and where.

---

## 4. How to actually do the migration

**Snapshot first, always.** Copy the file to `_archive/` before touching it. Everything
downstream — the guard, the diff, the ability to recover — depends on an untouched
original.

**Move verbatim. Never summarize to shrink.** Summarizing is where facts die, and it is
unnecessary: the destination is disk, where size is free. The only reason to summarize
is if a human will read it linearly, which they will not.

**Hoist before you drain.** This is the step that is easy to miss and expensive to get
wrong. Shipped records are *not homogeneous* — each mixes a dead receipt with live
carry-forward. In our case, buried inside "completed" task records were a parked task
with its pinned facts, an unfinished slice plan carrying a ~900× units landmine, an
open security residual, and a live "this credential is a bearer token" warning. A block
move would have archived all of them out of sight.

Sweep for the markers before moving anything:
`STILL OPEN`, `PARKED`, `CARRY FORWARD`, `DEFERRED`, `NEXT`, `MUST`, `TODO`.

**Kill superseded warnings — they are worse than clutter.** We found a prominent
constraint reading "X is enforced by ZERO running code" that had been resolved three
tasks earlier. It sounded current and authoritative. A resolved constraint that still
reads as live actively misleads; tag it superseded and drain it.

**When unsure whether something is live or dead: keep it and flag it.** The destination
lands slightly fatter and a human resolves the ambiguous ones. Losing a real constraint
is far worse than carrying an extra line.

**Verify the destination exists BEFORE removing the source.** We probed a memory block
against the docs it was supposedly duplicating and found **five facts that existed
nowhere else in the repo** — core domain logic that a naive swap would have deleted.
Probe first, migrate, re-probe, *then* remove.

---

## 5. Guards, and how they lie to you

Every migration claim — "nothing was lost", "everything is reachable" — is a **claim
until something checks it**. Write the check. Then make it fail on purpose. **A guard
you have not watched go red is faith, not enforcement.**

Ours caught two genuinely dropped headings on its very first run. That alone justified
writing it.

But guard design has sharp edges, and we hit four:

**Vacuous guards.** Our second migration copied a file into a superset destination. The
obvious check — "does every original line survive?" — *could never fail*, no matter how
badly we mangled the index. Ask of every guard: what state of the world makes this go
red? If you cannot answer concretely, it observes nothing.
*Fix:* assert the property that can actually break. Ours became: every heading in both
files, every rule in the index, every detail line in the detail file, and no count
drift between them.

**Guards that cry wolf.** Our first guard compared against a frozen snapshot, so it went
red the moment a tracked line was *legitimately* edited. A guard that fails on healthy
content gets ignored, then deleted — worse than no guard.
*Fix:* an **allowlist with a required reason**. A line stops being tracked only when
someone records why. Retirement becomes a conscious act rather than a silent deletion.

**Broken instruments.** A guard reported **all 54** tracked facts as lost. Nothing was
missing. The cause: `printf … | grep -q` under `set -o pipefail`. `grep -q` exits on
first match, `printf` takes SIGPIPE, and `pipefail` propagates that as failure — so
every *successful* lookup read as a miss. The check did not error, it **inverted**.
*Fix, and the general rule:* never pipe into an early-exiting consumer (`grep -q`,
`head`) inside a `pipefail` script when you branch on the exit code. Redirect from a
file. And **validate the instrument on one case you can confirm by hand before
believing an alarming measurement.**

**Fixes that break what they fix.** Repairing the above, we normalized backticks to
unwrap allowlist entries — which mangled real content that legitimately ended in a code
span, and the guard failed on healthy data again.
*Fix:* store allowlist entries raw. More generally: after fixing a guard, re-run the
*original* passing case, not just the new one.

Three separate times in one session a guard fired and **the guard was wrong, not the
content**. Budget for that.

---

## 6. Measure. Do not estimate.

We estimated tokens with `chars ÷ 4`. **It undercounted by 65%** — dense markdown and
tables tokenize badly. The reported standing load went from "15k" to "68k" to a
measured 112k across three revisions, each one presented confidently.

**Anchor every estimate on one real measurement.** Measure one file properly with the
actual tokenizer, derive the ratio, scale the rest — and say plainly which numbers are
measured and which are scaled.

This matters beyond tokens. It is the same discipline as pinning a unit, a column name,
or a stored value against the live system instead of a doc. Assumptions feel like
knowledge.

---

## 7. Making it stick

A one-time cleanup regrows. **The migration is worth less than the rule that keeps it
drained.**

Put the discipline in whatever ritual already runs at a session boundary — a handoff
skill, a stop hook, a checklist:

1. **Move shipped records out.** Merged, no live carry-forward → it is history.
2. **Kill superseded warnings.**
3. **Check the budget.** A concrete number (we used ~250 lines) that triggers a drain.
   "Keep it tidy" is not a rule; a number is.
4. **Run the guards.**
5. **Never summarize a record to shrink it.**

Make the completion criterion *fail* if state files still hold settled records. A rule
that does not block anything is a preference.

**Sync a beat early.** The end of a long session is the worst moment to trust an agent
to write a clean handoff — the window is exactly as degraded as the work. Hand off at a
natural boundary, before quality drops.

---

## 8. Model routing

The right objective is **lowest cost per *correct* task**, not per token. A cheap model
producing a subtle mess costs more once you add the rescue, the review, and the context
of the mess.

The standard advice: plan with a strong model, execute with a cheaper one; escalate for
high-stakes work; give subagents a fixed roster so nobody toggles models by hand.

**Test that advice against your own failure data before adopting it.** We did, and
mostly declined it — not because the advice is wrong in general, but because our
records pointed elsewhere. The questions worth asking in any project:

- **Where do your defects actually appear?** The premise is "planning decides
  correctness, execution just carries it out." Our review records said otherwise:
  blocking defects were repeatedly **introduced during implementation**, after an
  approved plan — in one case *while fixing an earlier defect the author's own
  self-review had named*. Moving the build to a cheaper model targets exactly the phase
  where failures happened.
- **Does the exclusion list swallow your work?** Such guidance usually says never
  cheap-model anything touching money, auth, tenancy, migrations, or security
  invariants. Check what fraction of your roadmap that excludes. For us it was nearly
  all of it — so the roster would have been overridden almost daily.
- **Does the default contradict a default you already set?** Ours already said "absent a
  recorded decision, a task is high-rigor." The proposal said "default to the cheaper
  mode, escalate for high-rigor." Those point opposite directions; one has to give,
  consciously.
- **Does a subagent roster duplicate procedures you already have?** If you have skills
  for spec, review, and TDD, an agent prompt that *restates* them creates a second copy
  that drifts. Make agents **thin and invoke the skills** instead.
- **Splitting phases across agents has an unpriced cost:** the plan, the build, and the
  review each lose the context the others built.

**What we did adopt:** one read-only search agent on the cheapest model. No invariant
surface, returns distilled summaries rather than file dumps, and carries two
obligations — state that its results are *derived* (so any load-bearing fact needs
confirming against the live system), and **state its search coverage honestly**,
because a confident summary over a partial sweep turns "nothing found" into a wrong
decision.

**Baseline before optimizing.** Measure a week of real spend on your actual task mix.
Neither intuition is worth much against data.

**The biggest lever is upstream anyway.** A tight, fact-pinned spec lets even a cheaper
model succeed first-try, which shrinks the premium far more than any model dial.
Spending on a stronger model is often paying to paper over thin context you could have
pinned cheaply. We cut standing context 58% in a day; that is the same lever.

---

## 9. Process discipline (learned the hard way)

**Never chain a guard run and a commit in one command.** We did, a guard went red, and
the commit landed anyway. The gate batches; it never disappears. Run checks as their own
step and read the result before proceeding.

**Distinguish "the tests pass" from "it works."** Green means nothing mechanical broke.
It cannot tell you whether the always-on file still carries what is needed every turn,
or whether migrated domain facts are still *true*. Name the checks a human must do in
the real environment, and say plainly when they were skipped.

**Do not let unrun checks evaporate.** If something merges without its verification,
carry it forward explicitly as outstanding. Spoken deferrals vanish; written ones do not.

**Ask when a one-word instruction spans a gate.** "go" could mean *proceed* or *commit*.
When one reading crosses a boundary that is hard to reverse, ask rather than pick.

**Say what you are doing during long silent tool runs.** From the user's side, five
quiet tool calls are indistinguishable from a hang — and interrupting mid-migration
risks a half-moved file.

---

## 10. A canary

After a lean-context migration, the failure mode is silent: the structure exists but the
agent ignores it and pulls everything anyway.

**Watch for an agent quoting deep reference nobody asked for** — the build queue, a
design token, a domain list — in a task that had no reason to touch it. That means depth
is being loaded, not fetched, and the structure is not working.

Conversely, the success signal: a fresh session picks up a mid-flight task **from the
state file alone**, without reading code or docs to reconstruct where things stand.

---

## One-page checklist

**Migrating**
- [ ] Snapshot the original to `_archive/` before any edit
- [ ] Measure properly — one real measurement, then scale; label what is measured
- [ ] Probe: does the destination already hold these facts? Find what has no home
- [ ] Hoist live carry-forwards out of records before draining them
- [ ] Move verbatim; never summarize to shrink
- [ ] Tag and drain superseded warnings
- [ ] Unsure whether a line is live? Keep it and flag it
- [ ] Verify facts landed **before** removing the source

**Guarding**
- [ ] Write a checkable property for every preservation claim
- [ ] Ask: what state of the world makes this go red? (kill vacuous guards)
- [ ] Watch it fail on purpose, at least twice, in different ways
- [ ] Add an allowlist-with-reason so legitimate change does not cry wolf
- [ ] Validate the instrument by hand before believing an alarming result
- [ ] Re-run the original passing case after fixing a guard

**Keeping it**
- [ ] Put the drain in the session-boundary ritual
- [ ] Set a numeric budget, not "keep it tidy"
- [ ] Make the completion criterion fail if state holds settled records
- [ ] Hand off a beat early, before the window degrades

**Models**
- [ ] Baseline real spend before optimizing
- [ ] Check where your defects actually appear before moving the build phase
- [ ] Check whether the exclusion list swallows your roadmap
- [ ] Keep agents thin — invoke skills, do not restate them
- [ ] Doubt resolves *upward*, toward the stronger model
