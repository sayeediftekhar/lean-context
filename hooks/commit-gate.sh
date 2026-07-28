#!/usr/bin/env bash
# commit-gate.sh — the demonstrator for HARNESS.md §6.
#
# The whole point of §6: a gate you want GUARANTEED belongs in a hook, not in
# prose. As prose, "commit only on my word" is a suggestion a drifting session
# slips. As this hook, it is a wall the model cannot talk its way past.
#
# It is OPT-IN, so installing the plugin surprises no one. A plugin that hard-
# blocked every commit by default would itself be user-hostile — you choose:
#
#   LEAN_CONTEXT_COMMIT_GATE unset/off  → do nothing              (default)
#   LEAN_CONTEXT_COMMIT_GATE=warn       → advisory reminder, commit proceeds
#   LEAN_CONTEXT_COMMIT_GATE=block      → hard gate, commit blocked (exit 2)
#
# Set it in your shell, or in .claude/settings.json env, for the sessions where
# you want the gate live.

set -eu

mode="${LEAN_CONTEXT_COMMIT_GATE:-off}"
[ "$mode" = "off" ] && exit 0

# Read the PreToolUse event JSON from stdin.
# NOTE: we read into a variable and pattern-match — deliberately NOT
# `... | grep -q ...` under pipefail, the exact footgun documented in
# PLAYBOOK.md §5, where an early-exiting consumer inverts the check.
payload="$(cat)"

# Only act on an actual `git commit`.
case "$payload" in
  *"git commit"*) : ;;
  *) exit 0 ;;
esac

reminder='Lean-Context commit gate — confirm the three gates before this lands (HARNESS.md §6):
  1. Real-environment verify — did you check it WORKS, not just that tests are green? (green != done)
  2. Preservation — no fact dropped, nothing summarized to shrink, snapshot taken.
  3. Your word — is this commit actually authorized right now?'

if [ "$mode" = "block" ]; then
  # Exit 2 = blocking error; stderr is fed back to the agent. This is the wall.
  printf '%s\n\n[blocked by lean-context commit gate] Set LEAN_CONTEXT_COMMIT_GATE=warn for advisory, or unset to disable.\n' "$reminder" >&2
  exit 2
fi

# warn (or any other value): advisory, non-blocking.
printf '%s\n' "$reminder" >&2
exit 0
