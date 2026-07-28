# Getting Started

Plain-language guide to adding this to any project and what you get out of it.
No jargon. If you want the deeper "why," read [`PLAYBOOK.md`](PLAYBOOK.md); if
you want the full map, read [`INDEX.md`](INDEX.md).

---

## What this is (one line)

A small kit that keeps your AI coding agent **fast, cheap, and accurate** by
loading only what it needs, when it needs it — plus a checklist for building
tasks so the agent doesn't quietly ship broken work.

It has two halves:

- **Context** — stop the agent from re-reading giant files every message.
- **Harness** — a simple structure (steps, tools, checks, sign-offs) so work
  gets done right, not just fast.

---

## How to add it to a project

### Easiest way — if you use Claude Code

Run these two commands in Claude Code:

```
/plugin marketplace add sayeediftekhar/lean-context
/plugin install lean-context@lean-context
```

That's it. The right help now appears automatically when a task needs it, and
stays out of the way otherwise.

### Works with any agent (Cursor, Codex, Aider, …)

1. Copy these files into your project folder:
   `HARNESS.md`, `PLAYBOOK.md`, `DIRECTIVE.md`, `INDEX.md`
2. When you want to tidy a project's context, tell your agent:

   > *"Read `DIRECTIVE.md` and execute it. Stop at each STOP for my approval."*

3. The agent walks you through it and **asks before changing anything.**

---

## How you actually use it (day to day)

- **Starting a new project?** Point the agent at `DIRECTIVE.md` — it sets up a
  tidy structure for you.
- **Agent feeling slow, expensive, or forgetful?** Same thing — run
  `DIRECTIVE.md`; it trims the clutter.
- **Not sure how to test a task, or which model to use?** The
  `harness-engineering` help kicks in and guides you.
- **Want a safety net on commits?** Turn on the commit gate — set an
  environment variable in your shell:
  - `LEAN_CONTEXT_COMMIT_GATE=warn` — gentle reminder before each commit
  - `LEAN_CONTEXT_COMMIT_GATE=block` — hard stop until you confirm
  - (unset) — off by default, nothing happens

---

## How it helps you (in simple terms)

- 💸 **Cheaper** — the agent stops re-reading giant files every message, so you
  burn far fewer tokens. (Real test: ~112k → ~47k standing tokens — more than
  half off.)
- ⚡ **Faster & smarter** — a less cluttered agent makes better decisions and
  gets things right the first time.
- 🧠 **Less forgetting** — a fresh chat can pick up where the last one left off
  without re-reading everything.
- ✅ **Fewer silent mistakes** — the checklist catches "looks done but isn't"
  before it gets committed.
- 🧩 **Plug-and-play** — works the same across your projects; set it up once,
  reuse everywhere.

---

## The one idea behind all of it

Don't hand the agent everything up front. Keep a short "table of contents" in
view and let it grab the one thing it needs, when it needs it.

**Cheaper *and* sharper at the same time.**

---

*Next: skim [`INDEX.md`](INDEX.md) for the full map, or just drop `DIRECTIVE.md`
into a project and tell your agent to run it.*
