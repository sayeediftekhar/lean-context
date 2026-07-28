---
description: Refactor this repo's knowledge system into tiered, load-on-demand context (runs the Lean-Context DIRECTIVE, STOP-gated)
argument-hint: "[optional focus, e.g. 'just audit' or 'instruction file only']"
---

Read `${CLAUDE_PLUGIN_ROOT}/DIRECTIVE.md` in full and execute it against **this**
repository.

It is a self-contained, self-gated procedure: **Discover → Propose → Migrate →
Verify**. Follow it exactly, including every **STOP** — at each STOP, present
your output and wait for my explicit approval before writing, moving, or
deleting a single file. Do not skip a STOP because the change "looks safe."

Hold to its prime directives: plan before touching anything; never destroy
content (archive, don't delete); preserve every fact (unsure → keep and flag);
measure tokens with the real tokenizer, never `chars ÷ 4`; and narrate long
tool runs so a silent sequence isn't mistaken for a hang.

Additional focus for this run (may be empty): $ARGUMENTS

If a focus is given, scope the work to it but still honor every STOP and every
preservation guard.
