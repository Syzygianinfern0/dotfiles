---
name: commit-planner
description: Inspect the current repo's uncommitted changes and propose a commit plan — for each commit, the files it includes, a title, and a body — without staging or committing anything. Use when the user asks to plan commits, organize changes into commits, split a diff, draft commit messages, figure out how to commit, or tidy up after a big experiment run. Output is draft-only for the user to approve, reject, or revise next turn.
---

# Commit Planner

## What this does

Look at everything uncommitted in the working tree, decide how it should be
carved into commits, and propose that plan. One commit is a valid plan; so is
five. The shape follows the changes, not a quota.

**This skill only proposes.** It never runs `git add`, `git commit`, `git stash`,
or anything that mutates the index or history. The output is a set of drafts the
user will approve, reject, or amend on the next turn. If they approve, *that* is
when commits get made — and only if the user asks.

## Scope: which changes are even in play

Before grouping anything, decide what set of changes this plan covers. There are
two cases:

1. **Conversation already about specific work.** If this skill is invoked inside
   a session that was doing or discussing a particular change, the plan covers
   only the files belonging to *that* work. Other uncommitted files that are
   unrelated to the conversation are **left out** — list them under a "Left out"
   section with a one-line reason each, so the user sees they were seen and
   deliberately excluded, not missed.
2. **Cold invocation.** If there's no conversational context tying the request to
   a subset (e.g. the user just says "plan my commits" in a fresh session),
   consider the whole working tree and group all of it.

When unsure which case applies, state the assumption you're making and proceed;
ask a single clarifying question only if guessing wrong would put unrelated files
into a commit.

## Workflow

1. **Read the working tree.** Gather, in one batch:
   - `git status --porcelain` — tracked changes + untracked files (already
     excludes gitignored, so generated/large artifacts won't appear).
   - `git diff` and `git diff --staged` — actual content of the changes.
   - `git diff --stat` — size/shape at a glance.
   - For untracked files of interest, peek at contents (`head`, or read the file)
     enough to know what they are.
   - `git log --format='%s%n%n%b' -10` — learn this repo's commit style (subject
     length, mood, body format, bullet conventions) and match it.

2. **Apply scope** (see above) to get the candidate file set.

3. **Group into commits by intent, not by mechanics.** A good commit is one
   coherent, self-contained change. Signals that things belong together — or
   apart:
   - Same feature / fix / concern → together. Unrelated concerns → split.
   - Code that adds a capability + the docs/tests for *that* capability → usually
     together.
   - A broad mechanical change (rename, format, dep bump) → its own commit, kept
     out of substantive ones so review is easy.
   - Tooling/harness code vs. the results/artifacts it produced vs. the
     write-up → often natural commit boundaries for experiment work.
   - If splitting would create commits that don't build or don't stand on their
     own, prefer fewer commits. Don't over-engineer the plan into tiny slices.
   - **Prefer one commit** unless there's a real reason to split. "It could be
     split" isn't the same as "it should be."

4. **Order the commits** so each is sound on its own and dependencies come first
   (e.g. the code before the doc that references it). Note ordering only matters
   when commits are interdependent.

5. **Write each commit's message** in the repo's house style:
   - Subject: imperative mood, concise (~50 chars), no trailing period.
   - Blank line, then a body explaining *what changed and why* — the reasoning a
     reviewer can't get from the diff. Bullets are fine; match what `git log`
     shows.
   - Skip the body only for a genuinely trivial change where the subject says it
     all.
   - **No `Co-Authored-By` / AI-attribution trailer.** **Do not hard-wrap** if
     the destination renders Markdown with hard breaks; otherwise wrap body prose
     at a normal width to match existing commits.

6. **Present the plan** in the format below and stop. Do not stage or commit.

## Output format

Open with a one-line summary ("Proposing N commits covering X" or "One commit
covers everything here"). Then one block per commit:

```
### Commit 1 of N — <imperative subject>

Files:
- path/to/file_a
- path/to/file_b

Body:
<commit body as it would be written>
```

If any uncommitted files were deliberately excluded (scope case 1), add:

```
### Left out (not part of this plan)
- path/to/unrelated_file — <why it's unrelated to this work>
```

Close with one line inviting the user to approve, reject, or request changes —
and make clear nothing has been staged or committed.

## Rules

- Never run a mutating git command. Read-only inspection only.
- Every candidate file lands in exactly one proposed commit, or in "Left out."
  Don't silently drop a file.
- Don't invent files. Only plan around what `git status` actually reports.
- Honor the user's commit conventions (no AI co-author line; no hard-wrapped PR/
  commit bodies where breaks render literally).
- Keep it proportional: a small change gets one commit and a short message, not a
  ceremony.
