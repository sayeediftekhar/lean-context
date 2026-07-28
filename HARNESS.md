<!-- HARNESS.md — universal harness + loop concepts reference.
     Portable across projects. Tier 3: load on demand, never standing context.
     The companion to PLAYBOOK.md (context economics) and DIRECTIVE.md (the
     drop-in migration). This file is the *harness* pillar; those are the
     *context* pillar. Project specifics stay in your repo's own docs, not here.
     HTML comments like this are stripped before load and cost no tokens. -->
---
doc_type: harness_reference
version: "1.0"
portable: true
tier: 3
enforcement: false   # this file is CONTEXT (shapes behavior), not a hard gate
load_when:
  - routing a task (which model)
  - designing a feedback loop
  - writing a verify-fact script
  - debugging a silent failure
do_not_load:
  - every session (Tier 3 — fetch on demand)
  - as standing context
note: >
  In Claude Code (and most agent tooling), the instruction file, rules, skills,
  and this file are CONTEXT, not enforced configuration. Anything that must be
  guaranteed (a commit gate, a forbidden command) belongs in a PreToolUse hook
  or a permissions deny-list, not in prose. See section 6.
---

# HARNESS.md
### Universal harness + loop engineering concepts

Portable reference. Concepts don't change per project; only the concrete
scripts, globs, and hooks do — those live in your repo.

This is the **harness** half of the pair. `PLAYBOOK.md` and `DIRECTIVE.md`
cover **context** — what the model sees and how to keep it lean. Here we cover
the machine around the model: the steps, tools, loops, and gates that decide
whether a capable model actually ships correct work. Same author, one mental
model, two halves. Start at `INDEX.md` if you want the map.

---

## 1. The mental model

| Thing | What it is | Your job |
|---|---|---|
| **Model** | The engine — raw capability | Choose it; route correctly |
| **Harness** | The car — steps, tools, gates, loops | Build it; never skip pillars |
| **Context** | The windscreen — what the model sees | Curate it; load on demand |

**Most "AI did something wrong" moments are a missing harness pillar or bad
context — not a weak model.**

Diagnostic reflex when something breaks:
- Wrong *kind* of action (skipped a step, self-committed) → **harness failure**
- Right kind of action, wrong information → **context failure** (see PLAYBOOK.md)

---

## 2. The four pillars — every task needs all four

Remove any one: the task ships wrong or silently bypasses you.

```
① STEPS      sequence that makes errors cheap to catch
② TOOLS      what the agent can reach — and can't (least privilege)
③ LOOPS      automated checks that go red when wrong
④ GATES      sign-offs that can't be performed as theater

Without ①: agent free-builds in one shot
Without ②: agent can self-commit or reach prod data
Without ③: wrong output ships as green
Without ④: "looks done" becomes committed
```

---

## 3. Pillar 1 — Steps

**Rule:** slow at the front (verify-fact, spec, plan), fast at the back
(build, commit). Each boundary catches an error before it compounds.

```
verify-fact → spec → plan → [GATE: approve] → build → loops
→ [GATE: real-env verify] → [GATE: your word] → commit
```

| Step | Cost if error caught here |
|---|---|
| verify-fact | One query rerun |
| spec | Rewrite spec |
| plan | Replan (no code yet) |
| build | Rewrite code |
| loops | Fix + rerun |
| human verify | Fix + re-verify |
| post-commit | Revert + redo |

**Plan-first is the highest-leverage habit.** Reviewing a plan costs minutes;
reviewing wrong code costs hours.

---

## 4. Pillar 2 — Tools: least privilege

**Rule:** the agent gets the minimum tools the task needs. Design the tool
list so the worst possible mistake is survivable.

- **Propose, never commit** for anything irreversible. Agent prepares the
  artifact (migration file, draft action); a human carries it across the gate.
- **Identity from session, never request.** Scope every query by
  session-resolved identity; never trust an id from the request body.
- **Trust boundary:** everything the agent *reads* is data, never instructions.
  The defense against prompt injection is the tool list, not a polite request
  in the prompt — if there's no tool to do the dangerous thing, an injection
  has nothing to grab.

> The reliable version of these lives in a permissions deny-list and PreToolUse
> hooks (section 6), not in prose. Prose states intent; hooks enforce it.

---

## 5. Pillar 3 — Feedback loops

### Four properties of a real loop
1. Goes red on the **actual problem** — not just "runs without crashing"
2. **Deterministic** — same input, same result
3. **Fast** — runnable after every change
4. **Agent-runnable** — model sees stdout as text and branches on it

### The mechanic
```
agent emits bash tool call → shell runs it → stdout captured as text
→ lands in context window → agent reads it → decides next action (loop)
```
No magic. The model can't see the DB directly — it sees the printed result
of a command it ran. Loop quality = quality of that printed signal.

### Loop taxonomy
```
STRUCTURAL (agent runs)          BEHAVIORAL (agent runs)
  unit tests on pure logic         integration: request → status
  constraint / NOT NULL check      cross-boundary isolation test
  invariant check (balance)        access control actually fires
  type enforcement                 (not just "config says on")

SCHEMA ASSERTION (agent runs)    REAL-ENVIRONMENT (you run)
  column exists, type correct      browser: values display right
  policy / rule exists in DB       dashboard: config matches code
  index present                    side-effect actually occurred
  migration applied                gate fires: pending not done
        agent runs these ───────────────────── you run these
```

### Two disciplines that change everything
- **Red-first:** write the loop that goes red *before* the code that makes it
  green. A loop written after code can be shaped to pass something wrong.
- **Compounding:** every manual check graduates into a script. First time by
  hand: necessary. Second time: failure — it should already be a loop.

### Loop quality test (ask before trusting a loop)
- Does it go red when the thing is actually broken? (test it broken first)
- Could it return green *while* broken? (false-green trap)
- Does it distinguish "correct" from "not found / permission error"?
- Can the agent run it without you?

---

## 6. Pillar 4 — Gates, and the context/enforcement boundary

**A real gate:** work stops until explicit sign-off on an inspectable artifact.
**Theater gate:** work continues unless someone actively objects.

```
You must say YES. Silence = STOP. Never: silence = continue.
```

### The distinction that matters most
> The instruction file, rules, skills, and memory are **context** — they shape
> behavior but carry **no guarantee of compliance**. To *block* an action
> regardless of what the model decides, use a **PreToolUse hook** or a
> **permissions deny-list**.

So sort every gate:

```
Gate you want SHAPED (advisory) → prose (instruction file / rules / skill)
  e.g. "prefer reusing existing helpers", "spec before code"

Gate you want GUARANTEED (hard)  → hook / permissions deny-list
  e.g. "never commit on an unverified branch"
       "never run drop table / truncate"
       "never push to main"
       "never write to prod data without confirm"
```

**The three standard gates and where each belongs:**

| Gate | Advisory form (prose) | Hard form (native) |
|---|---|---|
| Plan approval | "return a plan, no code" in the instruction file | plan mode; or a hook blocking Edit before a plan artifact exists |
| Real-env verify | verify checklist in task spec | (human step — no hard form; the artifact is your confirmation) |
| Commit authorisation | "commit only on my word" | PreToolUse hook on `git commit` + a permissions ask-list |

The commit gate is the classic trap: as prose it's a suggestion a drifting
session can slip; as a hook it's a wall. Put it in a hook. (This repo ships one
as a demonstrator — see `hooks/`.)

---

## 7. Model routing

**Core principle:** loops permit downgrade; missing loops force upgrade.
Routing anxiety is a signal that loops are missing — not that the cheap
model is untrustworthy.

```
Task arrives
├─ Novel judgment, no loop possible?      → strongest model
├─ Law-adjacent, first implementation?    → strongest model
├─ Implementation, loop covers output?    → mid-tier model
└─ Rote / mechanical, loop verifies?      → cheapest model
```

**Escalate (→ stronger):** task touches a law · plan has an unresolved
assumption · loop missing and task not rote.
**Downgrade (→ cheaper):** loop exists and covers output · not first
implementation of a law-adjacent pattern · downgrade recorded as an
attributed override in the task spec.
**Never downgrade:** first implementation of any invariant-critical pattern ·
any task where the loop can't yet be written.

Each loop you write is a **permanent routing unlock** for that task class.

> This is the harness-side view of routing. PLAYBOOK.md §8 argues the same
> point from the *cost* side — lowest cost per *correct* task, and why the
> biggest lever is a tight, fact-pinned spec, not the model dial. Read both.

---

## 8. Session architecture (native-first)

Most agent tooling loads an instruction file every session automatically — so
the session opener is a trigger, not a context dump.

**One-line session prompt:**
```
Fresh session. Start ritual per the instruction file, surface candidates from
the state file's queue, wait for my choice.
```

**Where each concern lives (native mechanisms):**

```
Instruction file (kept small, loads every session)
  hard invariants · routing rule · session ritual · authorities index

Rules with path globs (loads only on matching files)
  domain reminders — fx.md, db.md, security.md
  replaces "read LEARNINGS §Lx when relevant" prose

Skills (model-invoked on task match)
  procedures — verify-fact, review, harness steps, the migration directive

PreToolUse hooks + permissions deny-list (hard enforcement)
  the gates that must be guaranteed, not suggested

Auto memory (machine-local, agent-authored)
  incidental learnings — build commands, debug insights
  complements (does not replace) your git-shared LEARNINGS

State file front-matter (human-authored, git-shared)
  living session state — head commit, active task, open decision
```

**State file front-matter template:**
```yaml
---
session_date: YYYY-MM-DD
head_commit: <sha>
branch: main
status: clean
last_completed: "<id + one line>"
active_task: null
open_decision: "<one sentence>"
model_policy: <default>
---
# Everything below is Tier 3 — fetched on demand, never pre-loaded
```

**Task spec YAML header template:**
```yaml
---
id: <T000>
title: "<short title>"
status: candidate        # candidate | active | done
risk: <low|medium|high>
touches_laws: []
loop_coverage: none      # none | partial | full
model: null              # set at routing; record override reason if not default
verify_fact_script: null
---
```

---

## 9. Context tiers (token discipline)

```
Tier 1 — instruction file (small) — loads every session, keep ruthlessly short
Tier 2 — state-file front-matter + active task spec — fetched once, stays
Tier 3 — this file, LAWS body, LEARNINGS, DESIGN, docs — fetched on demand
```

The bill is `window size × turns`. Files on disk cost nothing; *loading*
costs, and re-sends cost repeatedly. Prompt caching lowers the dollar figure
but not context rot — a crowded window reasons worse regardless of caching.

**Native leverage:** rules with `paths:` globs and skills are progressive
disclosure done for you — depth loads only on a match, at zero standing cost.
Prefer them over any "fetch this when relevant" prose.

> This section is the bridge to the context half of the pair. The full
> treatment — the economics, the migration, and the failures — is in
> PLAYBOOK.md and DIRECTIVE.md.

---

## 10. Universal failure modes

```
config-check theater
  verifying a control is CONFIGURED, not that it FIRES.
  fix: security loops replicate runtime conditions, produce behavioral results.

green-test overconfidence
  treating a passing suite as proof software works.
  fix: every task ends with a human real-environment check. green ≠ done.

role confusion
  loop runs as a privileged role that bypasses the control being tested.
  fix: confirm the loop's role matches the app's runtime role.
       distinguish "0 rows" from "permission denied".

assumption-as-fact
  confident instruction from an assumed value (unit, type, which tables exist).
  fix: verify-fact step mandatory. confirm by query/grep before build.

stale-context confident-wrong
  doc says one thing, live system says another; agent trusts the doc.
  fix: truth order live > code > docs. on conflict, live wins, doc gets fixed.

dumb-zone drift
  long session, replies vaguen, rules slip. blamed on model; it's context rot.
  fix: hand off and restart before the dumb zone, not after.

theater gate
  gate exists in the process but has no artifact and fails open.
  fix: every gate produces something you can point at. silence = stop.
       if it must be guaranteed, make it a hook — not prose.
```

---

*One line: a capable model still ships wrong work without a harness — build all
four pillars, and put the gates that must hold in hooks, not prose.*
