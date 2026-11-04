---
name: peer-review-idea-loop
description: Develop, stress-test, and improve early ideas through iterative blind academic peer review. Use when Codex is asked to create, refine, evaluate, strengthen, or work out an idea, proposal, research direction, technical concept, experiment plan, paper contribution, product thesis, policy argument, or similar intellectual work through multiple expert reviewers, especially when the user asks for peer review, reviewers, critique rounds, academic review, blind review, or iterative idea improvement.
---

# Peer Review Idea Loop

## Overview

Use this skill to turn an idea into a stronger complete work through blind, fresh-context review rounds. Spawn independent sub-agents as academic reviewers, synthesize their critiques, revise the idea, and repeat for up to 5 rounds.

## Core Rules

- Run at most 5 review rounds.
- Stop early when every reviewer rates the current idea at least `weak accept`.
- Use the score scale exactly: `strong reject`, `reject`, `weak reject`, `borderline`, `weak accept`, `accept`, `strong accept`.
- Treat `weak accept`, `accept`, and `strong accept` as meeting the early-stop threshold unless the user explicitly sets a stricter threshold.
- Reviewers must evaluate the idea as a completed, implemented, successful work, not as a proposal or plan.
- Reviewers must write in an academic style: precise, formal, evidence-oriented, and critical without being casual.
- Each review must be blind and fresh. For every reviewer in every round, spawn a new sub-agent with no prior context. Do not reuse reviewer agents across rounds.
- Do not fork the parent context into reviewer agents. Pass only the current idea version, the review prompt, the assigned expertise, and the output schema.
- Never pass earlier variants, earlier reviews, synthesis notes, or improvement plans to reviewers.
- After each round, improve the idea by addressing the full set of reviewer critiques. Add technical substance, concrete mechanisms, evaluation details, required experiments, ablations, controls, baselines, and limitations where needed.

## Reviewer Panel

Use exactly 4 reviewers. Use user-specified reviewer roles when provided; otherwise assign reviewers in an ICLR/MLSys-style program committee pattern: technically rigorous, empirically demanding, novelty-sensitive, systems-aware, and attentive to limitations. For domain-specific ideas, adapt the reviewers' expertise to the field while preserving broad coverage across contribution, method, evidence, implementation, and limitations.

## Round Workflow

### 1. Prepare Current Idea

Create a self-contained idea document for the current round. Include enough detail for a fresh reviewer to understand the work without outside context:

- title or concise name
- problem and motivation
- claimed contribution
- method, mechanism, or intervention
- implementation or operational details
- evidence and results, if already known
- limitations and scope conditions
- open questions, if any

If the starting idea is thin, first expand it into a plausible complete-work description before Round 1. Mark assumptions clearly.

### 2. Spawn Blind Reviewers

Spawn one new sub-agent per reviewer. Use `fork_context: false` when the tool supports it. Each reviewer prompt must be self-contained and must not mention that other reviewers exist.

Use this reviewer prompt pattern:

```text
You are an academic peer reviewer with expertise in: {reviewer_expertise}.

Evaluate the following work as if it has already been fully implemented and the described results are real and successful. Do not evaluate it as a plan, proposal, or future work.

Write in a formal academic peer-review style. Be critical, precise, and constructive.

Score scale: strong reject, reject, weak reject, borderline, weak accept, accept, strong accept.

Current work:
{current_idea}

Return exactly these sections:
1. Summary of Contribution
2. Strengths
3. Weaknesses
4. Required Revisions or Experiments
5. Questions for the Authors
6. Score: {one score from the scale}
7. Confidence: {low, medium, high}
```

### 3. Collect Reviews

Wait for all reviewers to finish. Extract each score, confidence, core weaknesses, required revisions, and required experiments.

If a reviewer does not follow the requested schema, interpret the score conservatively and continue. If a reviewer fails entirely, respawn a fresh reviewer with the same role and the same current idea, still without prior context.

### 4. Synthesize Feedback

Create a synthesis that merges critiques without flattening disagreement:

- distinguish recurring concerns from isolated concerns
- identify the strongest reasons for rejection or borderline scores
- identify missing technical substance
- identify required experiments and why they matter
- identify claims that need narrowing, formalization, or stronger evidence
- preserve useful dissent when reviewers disagree

Do not show this synthesis to reviewers in later rounds.

### 5. Improve the Idea

Revise the idea as a complete work, not as a response memo. Improvements should usually add:

- sharper thesis and contribution
- clearer mechanism or architecture
- stronger causal, formal, or technical argument
- concrete implementation details
- experimental design with datasets, baselines, metrics, ablations, controls, and robustness checks
- evidence of limitations and scope conditions
- revised claims that match the evidence

When reviewers request experiments, either add the experiment and expected interpretation as part of the completed work or explicitly justify why it is out of scope.

### 6. Decide Whether to Continue

Continue to the next round unless:

- all reviewer scores are at least `weak accept`, or
- 5 rounds have completed.

Each new round uses the revised idea only. Reviewers must not receive the synthesis, previous scores, earlier critiques, or previous idea versions.

## Final Output

Return a concise final report:

- final idea version
- final reviewer scores by role and round
- whether the loop stopped by threshold or by 5-round limit
- most important improvements made across rounds
- remaining risks, limitations, and experiments still worth doing

If the process stops before all reviewers reach `weak accept`, state the blocking issues directly.
