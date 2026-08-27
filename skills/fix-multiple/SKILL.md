---
name: fix-multiple
description: Fix several small GitHub issues in ONE branch and ONE PR — separate commits per issue, a single CI run for the whole batch
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
---

# Fix Multiple Issues

Fix a batch of small issues on one branch and open a single PR, so the batch
costs one CI run instead of one per issue. Use for SMALL, low-risk fixes; a
change big enough to want its own review cycle still gets its own PR
(`/fix-issue`).

## Usage

`/fix-multiple <issue-number> <issue-number> [...]`

## Steps

1. **Read every issue first** with `gh issue view <n> --json title,body,comments`
   before writing any code. If two issues touch the same code, note it — order
   the work so the later fix builds on the earlier commit instead of
   conflicting with it. If any issue turns out NOT to be small (needs design
   decisions, wide refactoring, or a risky migration), stop and tell the user
   which one should be pulled out into its own PR before proceeding with the
   rest.
2. **Create one feature branch** named for the batch
   (e.g. `fix/batch-666-667-670` or a short theme name if the issues share one).
3. **Fix the issues one at a time, committing per issue.** For each issue, in
   sequence:
   - Write a failing test that reproduces it (same discipline as `/fix-issue`:
     the test must fail because of the reported behavior, not for a technical
     reason like a missing import — fix technical problems first).
   - Implement the minimal fix; don't refactor surrounding code.
   - Run the tests relevant to this fix so a defect is caught while the diff
     is still small.
   - **Commit before starting the next issue**, with a conventional message
     whose body includes `Closes #<n>`. More than one commit per issue is fine
     (e.g. `test:` then `fix:`) — what matters is that no commit mixes two
     issues, so each issue's diff stays reviewable and revertable on its own.
4. **Run the full test suite once** after the last fix (check CLAUDE.md /
   pyproject.toml / package.json for the command). Fix any interaction
   breakage before opening the PR — an extra commit naming which issues
   interacted is fine.
5. **Push** with `-u` and **create one PR** with `gh pr create`:
   - Title: a batch summary under 70 chars (e.g. `fix: three small buried-serve issues`).
   - Body: one bullet per issue, each with its own `Fixes #<n>` line so GitHub
     auto-closes ALL of them on merge, plus a one-line root-cause/change note
     per bullet.
6. **Merge caveats** (they bite batches more than singles):
   - If the repo squash-merges, every commit message is concatenated into the
     squash commit — check none contains the literal CI-skip directive, or the
     post-merge CI run on main is silently skipped.
   - On repos that rebase-merge (each branch commit lands on main verbatim),
     the per-issue commits are the point — run `/tidy-branch` first if the
     history picked up fixups.
7. Report the PR URL and the list of issues it closes to the user.
