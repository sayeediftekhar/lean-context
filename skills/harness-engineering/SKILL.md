---
description: >-
  Design or debug the harness around an AI coding agent — the steps, tools,
  loops, and gates that decide whether a capable model ships correct work. Use
  when planning how to structure a task safely; when designing a feedback loop
  or test that must go red on the real problem; when deciding which model a task
  needs (model routing); when setting up gates, sign-offs, or a commit/approval
  boundary; when choosing what tools/permissions an agent should have (least
  privilege); when setting up a session or handoff ritual; or when debugging a
  silent, false-green, or "agent did the wrong KIND of thing" failure. Keywords:
  feedback loop, verify-fact, model routing, gate, least privilege, prompt
  injection, false green, config-check theater, silent failure, four pillars.
---

# Harness Engineering — the four pillars

This skill runs the harness half of this repo. The full reference is
`${CLAUDE_PLUGIN_ROOT}/HARNESS.md`; read it for the section the task needs.

## First move: diagnose which half is failing

- Agent did the **wrong kind of action** (skipped a step, self-committed,
  reached prod) → **harness failure** → this skill.
- Agent did the right kind of action on **wrong information** → **context
  failure** → use the `lean-context` skill / PLAYBOOK.md instead.

## The four pillars — every task needs all four

```
① STEPS   sequence that makes errors cheap to catch  (slow front, fast back)
② TOOLS   least privilege — worst mistake stays survivable
③ LOOPS   automated checks that go red on the ACTUAL problem
④ GATES   sign-offs that can't be performed as theater (silence = STOP)
```

Route to the right section of `${CLAUDE_PLUGIN_ROOT}/HARNESS.md`:

- **Sequencing a task** → §3 Steps. Plan-first is the highest-leverage habit.
- **Designing a loop/test** → §5 Loops. It must go red when the thing is truly
  broken (test it broken first), be deterministic, fast, and agent-runnable.
  Red-first: write the failing loop before the code that makes it green.
- **Tools / permissions / injection defense** → §4. The defense against prompt
  injection is the tool list, not a polite prompt — remove the dangerous tool.
- **Gates / commit boundary / approvals** → §6. What must be *shaped* → prose;
  what must be *guaranteed* → a PreToolUse hook or deny-list. This repo ships a
  demonstrator commit-gate hook in `hooks/`.
- **Which model?** → §7. Loops permit downgrade; missing loops force upgrade.
  Routing anxiety means a loop is missing. Cross-check `PLAYBOOK.md` §8 (cost
  per *correct* task; a tight spec beats a bigger model).
- **Session / handoff ritual** → §8. Sync a beat *early*, before the window rots.
- **Something shipped wrong-but-green** → §10 failure modes: config-check
  theater, green-test overconfidence, role confusion, assumption-as-fact,
  stale-context, dumb-zone drift, theater gate.

## The loop quality test (apply before trusting any loop)

- Does it go red when the thing is actually broken?
- Could it return green *while* broken? (false-green trap)
- Does it distinguish "correct" from "not found / permission denied"?
- Can the agent run it without a human?

Read the relevant `HARNESS.md` section now, then design against it.
