---
name: delegated-build
description: Implement a scoped change via a subagent (opus or sonnet, chosen by stakes) while the session model reviews the diff and independently re-runs the gates before opening the PR
---

# The agent builds, you review

Delegate a well-scoped implementation to a subagent, then act as the
reviewer: read the full diff, re-derive the load-bearing logic, and re-run
every gate yourself before pushing. The agent's claims are inputs to the
review, never substitutes for it.

The builder model is a knob; the review is not. Steps 3-6 are identical
whether opus or sonnet wrote the code.

## When to use

- The task is a scoped, checkable implementation (a kernel, a solver
  extension, a migration) with objective gates: tests, agreement tolerances,
  benchmarks.
- NOT for exploratory/design work where the shape of the answer is unknown —
  scope that first, then delegate the build.

## Steps

### 1. Scope and prepare (you)

- Create the branch yourself and leave it checked out.
- Collect context pointers BEFORE writing the brief: the target files/methods
  (with line refs), the house patterns the change must follow (existing
  precedents in-repo), the oracle/reference the result must agree with, and
  the measurement instrument (profiler, harness) if perf is claimed.
- Decide the gates up front and write them into the brief as requirements —
  agreement tolerance (bit-exact vs house tolerance, and which), full-suite
  green, pinned constants unmoved, before/after measurements.

### 2. Choose the builder model

If the invocation named a model (`/delegated-build sonnet ...`), use it. If
not, decide with one question: **if the implementation were subtly wrong,
would the gates catch it?**

- **Decisive gates** — an independent oracle, an analytic reference, a
  bit-exactness check, an adversarial probe that fails when the path is
  disabled. A wrong implementation dies on the gate. Use **sonnet**: the
  well-precedented work (an in-repo pattern to follow, plumbing, adapters,
  test backfill, mechanical migrations) where you are paying for throughput,
  not for judgment.
- **Self-consistency gates** — the tests mostly prove the code agrees with
  itself, or correctness rests on sign conventions, index algebra, boundary
  cases, or numerical conditioning that no gate pins down. Use **opus**.
  Subtle-and-plausible is exactly the failure mode a weaker builder produces
  and a weak gate passes.

Two notes on the capability differential:

- If the builder matches the session model, you gain context isolation and
  parallelism, not capability. Still worth it for a long mechanical build
  that would otherwise flood this context — just don't expect a second
  opinion out of it.
- If the builder is *stronger* than the session model, the review is the
  weaker read. Do not skip it; lean harder on the gates and the oracle, and
  say so explicitly in the PR's review notes.

### 3. Brief the agent

Launch with `Agent(subagent_type: "general-purpose", model: "<chosen>")`.
Background it if you have review or other work to do meanwhile; otherwise run
synchronously. The brief skeleton (every section matters — past failures trace
to omitted ones):

```
Implement <issue/goal, one line>.

## Environment
- Repo: <path> — work on the ALREADY CHECKED OUT branch `<branch>`.
  Do NOT push, do NOT create a PR. Commit locally in logical units;
  end each commit body with the Co-Authored-By line.
- Python/tooling: <exact interpreter path, build/rebuild command if any>.
- HARD RULE: <resource caps — e.g. wrap heavy runs in
  prlimit --as=$((24*1024*1024*1024))> .

## The issue (verbatim)
> <paste it — do not paraphrase>

## Context to read before designing
- <file:method pointers, house-pattern precedents, the oracle, the
  measurement instrument, known traps ("check X before assuming Y")>

## Requirements
- <the gates, numbered, each independently checkable>
- No regressions: full suite green (<current count>). No pinned constant
  moved. House comment style: constraints and derivations, not narration.

## Deliverables (final report)
1. What you built and the key design decision, with rationale.
2. Files touched, commits made.
3. Measured results per gate — numbers, not adjectives.
4. Anything that contradicts the brief's assumptions; follow-ups you'd file.
```

A sonnet builder needs the context pointers to be more specific, not the
requirements to be looser: name the precedent file to copy from rather than
describing the pattern, and spell out the tolerance rather than saying
"house tolerance".

### 4. Review (you — never skip, never subcontract)

- `git log main..HEAD` + `git diff main` — read the WHOLE diff.
- Re-derive the load-bearing logic independently (sign conventions, index
  algebra, boundary cases) — don't just check it "looks like" the report.
- Audit the tests as designs: does the reference side genuinely bypass the
  new path? Would the test pass trivially if the feature were absent? Is
  there an adversarial probe (wrong-sign / disabled-path) pinning the result
  to an oracle rather than to agreement-with-itself?
- Check house patterns: comment style, existing macro/helper reuse, no
  unrelated reformatting, docs updated where the change makes them stale
  (dated addendum, never rewriting run records).

### 5. Gate re-run (you)

Re-run every gate yourself — full suite, the new tests, and at least one
headline measurement (a benchmark rung, an agreement figure). The agent's
numbers must reproduce. Resource caps apply to your runs too.

### 6. Rework loop

Small nits: fix them yourself and note it in the PR. Real gaps: SendMessage
the same agent (it keeps its context) with the specific finding; re-review
the increment. Do not silently rewrite large parts — that discards the
context the agent has and the review trail.

If a sonnet builder misses the same gap twice, stop iterating and re-brief
opus on the remaining delta. Two failed rounds is the signal that the task
was misclassified in step 2, not that the brief needs a third revision.

### 7. PR (you)

Push and open the PR yourself. The body carries the gates with measured
numbers, and a "Review notes" section stating who implemented (which model),
what you verified independently, and anything you'd flag to a human
reviewer. Report the PR URL and your review verdict to the user; leave
merging to the user unless they've said otherwise.
