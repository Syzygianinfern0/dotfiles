---
name: with-the-power-of-friendship
description: Reach a conclusion on a hard judgment call by running a panel of models from both families (Claude Opus 5.5 and Fable 5.2, GPT-6 Astra and GPT-6.1 Sol) through independent answers, then anonymized cross-critique, with the calling agent as a neutral moderator who writes a decision memo. Use when the user asks for a panel, a discussion or debate between models or agents, several opinions or a second opinion from the other family, wants the models to convince each other, or invokes with-the-power-of-friendship (often at the end of a prompt, as in "...? with-the-power-of-friendship"). Not for questions a quick check of code, docs or data can settle.
---

# With the power of friendship

You are the **moderator**. Four panelists (by default) deliberate on one question; you frame it, check facts, run the
rounds and write the memo. You are not a panelist and you keep your own view out of the rounds. The protocol below was
itself settled by such a panel (Opus, Fable, Astra, Sol, two rounds).

The value is in the cruxes and the dissent, not in agreement: four models agreeing is weak evidence because their
errors are correlated. Never present a vote count as confidence.

## 0. Is a panel the right tool?

Say in one line whether the question is a judgment call (direction, design, plan, framing, what to cut) or something
checkable. If it is checkable, check it yourself and tell the user; run the panel only if they still want it. A smaller
panel is fine for lower stakes: one seat per family (e.g. `opus sol`).

**Frame at the user's altitude.** Keep the user's question, in their words, as the headline of the packet, and hold
the rest of the packet to it too: the decision line, the options, the context you select and "what a good answer must
cover". Narrowing usually enters there, not in the headline.

- If the user named no decision, write "No decision pending; the user wants an assessment." Do not invent one. Include
  options only if the user has real alternatives.
- Project plans, roadmaps and next steps are evidence, not the frame. Do not let a planned next step define success.
- For a question about something the user built or plans, the packet states what it is for: the user's words, then
  goals documented in design docs, then your inferences, each labelled with its source (the roadmap's ordering is not a
  priority). Coverage must include what exists today, what it is meant to do, and what closing the gap would take.
- Operational detail goes in only where it changes the answer, with that connection stated.
- Test before sending: could a panelist satisfy every coverage item and still not answer the user's question? If yes,
  rewrite.

**Check the framing before round 1** when the packet will contain a decision, options, a concrete case or coverage
items the user did not state. Show in one line, in the user's terms, what you will ask and the top two things the
panel must cover, and ask one question: what result would make this worth it to them, or what matters most. Wait for
the reply. If the packet adds nothing the user did not state, skip without comment. A wrong frame wastes the whole
panel; this costs one message. (Panel split on this, by family: the GPT seats would ask only when an unresolved
ambiguity would materially change the answer, and otherwise proceed with stated assumptions. The testable trigger was
adopted because "would materially change it" is the judgment that failed.)

## 1. Set up

- Panel directory: a fresh scratch directory per question (the agent's scratchpad, or `${TMPDIR:-/tmp}/panels/<date>-<slug>`).
  Keep it out of the repo unless the user wants the record kept.
- Dispatcher: `panel-ask` (in `~/bin`). Every seat goes through it, whatever agent you are, so both hosts behave the same.
  `panel-ask seats` lists seats; `panel-ask run -h` shows options.
- Seats: `opus` (claude:claude-opus-5-5), `fable` (claude:claude-fable-5-2), `astra` (codex:gpt-6-astra), `sol` (codex:gpt-6.1-sol). Others as
  `name=claude:<model>` or `name=codex:<model>`.
- Panelists are read-only: Claude seats get only Read/Grep/Glob under `--restricted` with no MCP or skills; Codex seats
  run in the read-only sandbox without the user's config, MCP servers, plugins or apps. They can read the working
  directory (`-C`), the panel directory, and for Claude seats any `--add-dir`. Put every file they need in one of those.
- Web access is off for every seat by default. Pass `--web` (to every round of that panel) when the answer depends on
  outside facts you cannot settle and put in the packet yourself: current versions, prices, recent papers or releases,
  what other projects do. It gives Claude seats WebSearch/WebFetch and Codex seats live web search. Leave it off for
  judgment calls about the user's own code, design or plan: searching costs time and money and pulls the seats toward
  whatever they find instead of independent reasoning. Say in the packet's context that seats may search.

## 2. Round 1: independent and blind

Write `round1.md`, the frozen packet every seat receives unchanged (the dispatcher prepends a short read-only preamble):

- the user's question verbatim, then the decision it feeds (or "no decision pending"); options only if real, plus
  permission to say it is the wrong question
- for something the user built or plans: what it is for, with sources (see "Frame at the user's altitude")
- context, constraints, budget, deadlines; decisions the user has already made
- facts you have verified, with how; file pointers to read
- what a good answer must cover
- **not**: your own leaning, other models' answers, the panel's composition (no model names, families or seat count;
  "other independent analyses exist" is enough), earlier conversation beyond what the question needs

Require this answer shape, at most about 700 words:

```
Answer:           (to the question as asked; commit, no hedging everything; recommend an action when relevant)
Confidence:       low | medium | high
Cruxes:           the 2–3 points the answer rests on
What would change my mind:
Is this the right question?:
```

Run: `panel-ask run <dir> 1 [-C <workdir>] [--add-dir <dir>] [--web]`. It runs the seats in parallel (often 2–10 minutes; run it
in the background if your host allows and wait for completion, don't poll), writes `<seat>_r1.md`, and records session
ids in `sessions.json` and outcomes in `status.tsv`.

If a seat fails (`status` not `ok`), rerun just that seat once (`panel-ask run <dir> 1 <seat> --fresh`). If it fails again,
continue without it and say so. Never substitute another model silently.

## 3. Between rounds: you check, index, and hide yourself

1. Read every answer in full. Check each decisive factual claim you can (code, docs, CLI help); record it as verified
   or refuted, with how.
2. **Coverage check.** Write one line: "The user asked X; round 1 answered Y." List the parts of X no seat answered,
   including gaps every seat shares (a disagreement index cannot find those). If Y is narrower, repair the agenda:
   replace the packet requirements that narrowed it, and make X and the omissions the first items of round 2; do not
   just append them last. Tell the user in one line in your interim message without waiting, unless the repair depends
   on intent only they know (then ask, as in §0). If nothing in round 1 bears on X, fix the packet and re-run round 1
   with `--fresh` instead.
3. List the disagreements as cruxes D1..Dn, ordered by how much they bear on the user's question as asked (not by how
   concrete they are). Keep an operational point as a crux if it changes the answer; move useful but non-decisive ones
   to a **Findings** list the seats need not take positions on (decisive findings still reach the final answer); omit
   irrelevant ones. State each side at its strongest and point to where it appears
   ("Panelist R, bullet 3"), using the anonymous labels from `panel-ask label <dir> 1` (stable for the whole panel,
   kept in `labels.json`). The index is navigation, not a replacement: the full answers go along.
4. Write `round2_head.md`:
   - verified facts and user decisions since round 1, with sources
   - the user's question again, any omissions from the coverage check, and the Findings list
   - the crux index, with "take a position on each, one short paragraph each"
   - the rules: hold or change on each crux and give the reason either way; "others agree" is not a reason; holding
     needs no apology; challenge the index if it misstates you
   - required ending: `Changed from round 1:` (what and why, or "nothing") and
     `Final position for the memo (≤80 words):` recommendation, surviving objection, what would change it
   - **not**: an "everyone agreed" section, counts, your own leaning, model names
   - `{SELF}` in the head becomes that reader's own label
5. `panel-ask pack <dir> 1` writes `round2_<seat>.md`: your head plus all round-1 answers, anonymized, in a different
   random order for each reader. It warns if an answer names a model or family; edit the answer file and re-pack.

**If round 1 converged** (no crux that matters for the decision), do not invent a contrarian. Make round 2 short: each
seat names the least-supported assumption they all share, the most plausible way the recommendation fails, and the
observation that would overturn it. Label the outcome "convergence", not independent confirmation.

## 4. Round 2: cross-critique

`panel-ask run <dir> 2`. Seats resume their round-1 sessions, so each one answers as the same panelist and can say what
changed its mind. (Astra dissented here, preferring fresh contexts to reduce position-defence; the cited-reason rule
is the mitigation. Use `--fresh` if a seat's earlier context is a problem.)

## 5. Stop or continue

Stop after round 2 by default. Run round 3 only if a crux the decision depends on is still open **and** there is new
information (a fact you checked, new evidence, a user decision). Three rounds at most. Disagreements that come down to
values or preferences (risk appetite, venue, taste) go to the user unresolved; do not settle them by attrition.

## 6. The memo

Write two things.

Before writing, repeat the coverage check against the user's original question. Say plainly what the panel did not
answer; do not fill the gap with confident prose.

**The answer to the user** (in chat): its first line answers their question as they asked it. Then a few short
paragraphs or bullets: the reasons, the objection still standing, what is theirs to decide, and a next step if one is
useful (an assessment does not need to become an action plan). Plain
language: no panel labels (D1, Panelist R), no project-internal names or acronyms unless defined on first use, no
process narration. End with the path to the memo and the cost.

**`memo.md`** in the panel directory, the full record:

- **Question** and **recommendation**, then confidence, and why
- **Verified facts** that shaped it
- **Each crux**: how it resolved, and who held out
- **Minority reports**: quoted from the seats' final-position statements, with the condition under which they would be
  right. One substantiated objection can outweigh three endorsements; say so when it does
- **Changes of mind**, with the reason given; flag any change that cited no new argument or evidence
- **Family splits**: if the split falls along Claude vs GPT lines, say so (a signal, not noise)
- **Cheapest next test** for each open crux; questions only the user can decide
- **Moderator's view**, labelled as yours, including where you disagree with the panel
- **Provenance**: seats and models, the label key, rounds, failures or missing seats, cost (from `status.tsv`: Claude seats
  report it, Codex seats are priced from token usage at LiteLLM list prices; an "unknown" stays unknown, never zero;
  both are API-equivalent figures, not a subscription bill), whether `--web` was on, and links to every brief and answer

Representation check: only if your recommendation goes against most of the panel, or you paraphrase a dissent instead
of quoting it, resume that seat with one short question ("Is this your position? ≤50 words") and quote the reply
verbatim.

## 7. Follow-ups

- A clarification of the same decision: continue the same panel as the next round.
- A new or related decision (different options or criteria): a new panel directory and fresh sessions. Carry over only
  verified facts and the user's decisions, not the earlier recommendations.

## Asymmetries (stated, not hidden)

- Isolation differs: Codex seats are sandboxed read-only at the OS level; Claude seats have no write or shell tools.
- Cost: Claude seats report it themselves; Codex seats are priced by `panel-ask` from token counts and LiteLLM's
  catalog, so a model missing from the catalog shows "unknown".
- Seat names map to model slugs in `panel-ask`; update `SEATS` there when models change.
