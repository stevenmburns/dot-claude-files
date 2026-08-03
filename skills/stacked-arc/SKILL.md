---
name: stacked-arc
description: Land a multi-unit issue as ONE integration PR to main, with each unit built by a delegated subagent on its own stacked sub-PR, reviewed and re-gated by the session model before merging into the integration branch. Use when an issue decomposes into 3+ independently-checkable units that should hit main as a single batch.
---

# Stacked arc: one integration PR, delegated stacked units

Land a whole issue as one PR to main. Each unit of work is a sub-PR stacked
onto an integration branch, built by a subagent under the `delegated-build`
skill's contract (you review the diff, re-run the gates, re-verify at least
one mutation/probe yourself), and merged into the integration branch as soon
as its own CI is green. The integration PR merges to main once, at the end.

Use when: the issue decomposes into 3+ scoped units with objective gates,
the units touch disjoint files (or nearly so), and the user wants one
atomic landing on main instead of a trickle.

## Setup (before any unit)

1. `gh api repos/{owner}/{repo} --jq '{merge_commit: .allow_merge_commit, squash: .allow_squash_merge, rebase: .allow_rebase_merge}'`
   — learn the allowed merge method NOW, not at first merge. On a
   rebase-only repo the final merge lands every unit commit on main
   verbatim (still one atomic batch, one CI run); on a squash repo the
   final squash concatenates every commit message — see contagion below.
2. Verify CI triggers on stacked PRs: the workflow's `pull_request` trigger
   must have no `branches:` filter. If it's filtered to main, sub-PRs get
   no CI and your local gate runs are the only line of defense.
3. Create the integration branch off main and PUSH it (a sub-PR's base must
   exist on the remote). Naming: `issue-<N>-<slug>`.
4. Do NOT open the top-level PR yet — GitHub refuses a PR with zero
   commits. Open it as a DRAFT right after the first unit merges into the
   integration branch, with a unit checklist in the body.

## Unit loop (repeat per unit; parallelize after unit 1)

1. Unit 1 establishes the house pattern the rest copy. Pick its builder by
   the delegated-build model rule, leaning strong (opus) when there is no
   in-repo precedent to imitate; later units can be sonnet with the
   precedent file NAMED in their brief.
2. Sequential unit: branch off the integration branch in the main checkout.
   Parallel units: `git worktree add <scratchpad>/wt-<unit> -b <branch>
   <integration-branch>` — one worktree per unit, disjoint target files,
   launch all builders in one message. Each brief must state its worktree
   path and that pushing/PR-opening is forbidden (you do those).
3. On completion, run the delegated-build review yourself IN THAT WORKTREE:
   read the whole diff, re-run every gate, independently re-run at least
   one adversarial probe (e.g. a mutation the tests must catch). The
   builder's numbers must reproduce.
4. Push the unit branch; `gh pr create --base <integration-branch>`. The PR
   body carries gates with measured numbers plus review notes naming the
   builder model and what you verified independently.
5. Wait for the sub-PR's CI (a fresh PR can report "no checks reported" for
   ~a minute — sleep, then `gh pr checks --watch`; never treat that state
   as green). Merge with the repo's allowed method.
6. Cleanup order matters: `gh pr merge --delete-branch` FAILS on a branch
   checked out in a worktree. Merge WITHOUT `--delete-branch`, then
   `git worktree remove <path> --force`, `git branch -D <branch>`,
   `git push origin --delete <branch>`, `git pull` the integration branch.
7. Units merge in completion order, not launch order — fine when files are
   disjoint; a later sub-PR based on an older integration HEAD still merges
   cleanly (its merge-base diff shows only its own commits).

## If main moves mid-arc

Do NOT rebase the integration branch while sub-PRs are open — rewriting the
base's SHAs pollutes every open stacked PR's diff with replayed copies of
already-merged commits. Note the drift and defer. After the last sub-PR
merges: `git rebase origin/main`, resolve (lockfiles usually auto-merge;
validate with a fresh install), `git push --force-with-lease`, then re-run
the full gates on the assembled branch.

## Finish

1. Assembled-branch gates: fresh dependency install + full suite + build,
   run by you in the main checkout.
2. Contagion check before the final merge:
   `git log origin/main..HEAD --format="%B" | grep -niE '\[skip[- ]ci\]|\[ci[- ]skip\]'`
   must return nothing (on squash repos the merge commit inherits every
   message; on rebase repos each message lands verbatim).
3. Update the top-level PR body (unit list with PR numbers and test counts,
   acceptance criteria, verification summary, deferred follow-ups), mark it
   ready for review, wait for its CI.
4. Merging the integration PR to main is the user's call unless they've
   explicitly delegated it. After it merges, confirm a fresh CI run
   triggered on main, then delete the integration branch and file the
   follow-up issues collected during the arc.
