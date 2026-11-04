---
name: draft-goal-condition
description: Draft or refine a precise, evidence-checkable Codex /goal condition from a user prompt. Use when the user asks to write a goal, goal condition, objective, success criteria, completion condition, stop condition, or to convert a fuzzy task prompt into a durable Codex goal with outcome, verification, constraints, scope boundaries, iteration policy, and blocked-stop criteria.
---

# Draft Goal Condition

## Overview

Turn a prompt into a compact work contract that Codex can pursue honestly. Prefer measurable outcomes, explicit evidence, bounded scope, and clear stop rules over activity descriptions such as "keep working" or "improve this."

This skill drafts goal text. Do not call `create_goal` or start a durable goal unless the user explicitly asks to set, start, or pursue the goal.

## Workflow

1. Extract the user's real objective.
   - Identify the artifact, repo, system, behavior, or decision the user cares about.
   - Convert activity language into an end state.
   - Preserve user constraints exactly when they are already clear.

2. Fill the goal contract.
   - **Outcome**: what concrete thing will be true when the work is done.
   - **Verification**: tests, commands, evals, review checks, artifacts, source evidence, or manual acceptance criteria that prove completion.
   - **Constraints**: behavior, APIs, files, style, performance, security, cost, compatibility, or user preferences that must not regress.
   - **Boundaries**: files, modules, tools, data sources, environments, or non-goals that define the allowed work area.
   - **Iteration policy**: how Codex should respond after each attempt, test result, or research pass.
   - **Blocked stop condition**: when Codex should stop and report the blocker instead of guessing or looping.

3. Ask at most one concise clarification question only if the missing detail could send the agent toward the wrong outcome. If the ambiguity is minor, make the safest assumption and label it.

4. Draft the goal in one copy-ready block. Keep it short enough to paste after `/goal`, but include the verification evidence and stop condition inside the objective.

5. Include a brief quality check after the draft when useful:
   - `Outcome`: one sentence.
   - `Evidence`: concrete command, artifact, or acceptance bar.
   - `Scope`: in and out of scope.
   - `Stop`: blocked condition.

## Drafting Pattern

Use this shape unless the user requests a different format:

```text
/goal Achieve <specific end state> for <artifact/system/scope>, verified by <evidence or checks>. Preserve <constraints>. Work only within <boundaries/non-goals>. After each attempt, <iteration policy>. Stop and report blockers if <blocked condition>.
```

For non-code work, replace tests with the evidence standard:

```text
/goal Produce <decision-ready artifact> for <audience/use case>, verified by <source coverage, review criteria, or acceptance checklist>. Stay within <scope and constraints>. Iterate by <review/refinement loop>. Stop if <missing information or access blocker> prevents defensible completion.
```

## Quality Bar

A good goal condition answers:

- What concrete state should be true at completion?
- What evidence would convince a skeptical reviewer that it is done?
- What must remain unchanged?
- What is explicitly out of scope?
- What should Codex do after failed tests, inconclusive evidence, or partial progress?
- What blocker should end the run rather than cause repeated attempts?

Reject or rewrite goals that only say:

- "Keep going."
- "Improve this."
- "Make progress."
- "Investigate X."
- "Fix everything."
- "Do the best you can."

## Heuristics

- For bugs: require a reproduction, a fix, and failing-then-passing evidence when possible.
- For tests: name the exact command and pass condition.
- For performance: name the metric, target, measurement method, and run count.
- For migrations: name the target state, affected surfaces, compatibility constraints, and validation command.
- For research: name the decision the research must support, sources in scope, evidence threshold, and uncertainty reporting.
- For writing: name the intended audience, artifact type, acceptance criteria, tone or style constraints, and revision loop.
- For cleanup or refactoring: name allowed files, behavior-preservation tests, and the minimum visible outcome.

## Examples

Weak prompt:
> Help clean up this repo.

Better goal:
```text
/goal Reduce obvious maintenance debt in the current repo by identifying and applying the smallest coherent cleanup that improves readability without changing behavior, verified by a clean `git diff` review and the repo's relevant tests passing. Keep public APIs and generated files unchanged. Stop and report if no test command or safe cleanup target can be identified from local context.
```

Weak prompt:
> Figure out why the eval is worse.

Better goal:
```text
/goal Identify the most likely cause of the eval regression and produce an evidence-backed diagnosis with the smallest confirming experiment, verified by before/after eval output, relevant logs, or a clear negative result. Do not make broad model or data changes unless the evidence points there. Iterate by testing one hypothesis at a time. Stop if required data, credentials, or baseline outputs are unavailable.
```
