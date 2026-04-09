---
name: merge-pr
description: Merge the open PR for the current branch into main, delete the branch, and pull main
user-invocable: true
allowed-tools: Bash
---

# Merge Current Branch PR into Main

Merge the open pull request for the current branch.

**Before merging on a rebase-merge repo**: every commit on the branch will land on `main` verbatim, not collapsed into a single squash blob. If the branch has messy "wip" / "fix typo" / "address review" commits, consider running `/tidy-branch` first to clean them up.

## Steps

1. Run `git branch --show-current` to get the current branch name
2. **Check for unpushed commits**: run `git log @{u}..HEAD --oneline`. If there are unpushed commits, push them first with `git push`. If the push fails, report the error and stop — do not merge.
3. **Check for local/remote divergence**: run `git status` and verify the branch is not ahead of or diverged from its upstream. If it is, stop and report.
4. Wait for CI to pass: run `gh pr checks --watch` to monitor check status. If checks fail, report the failure and stop — do not merge.
5. Run `gh pr merge --rebase --delete-branch` to rebase-merge and delete the remote branch. This preserves each commit's identity on main (one PR = N commits, not one squashed blob), which makes `git blame`, `git bisect`, and "which PR introduced this" queries meaningfully finer-grained. The individual commits on the branch should already be tidy — if they aren't, interactive-rebase the branch locally before running this skill. (`gh pr merge` will fail clearly if no PR exists, so no separate confirmation step is needed.)
6. Switch to main and pull: `git checkout main && git pull --rebase` (use `--rebase` to avoid creating a pointless merge commit if main moved while the PR was in review)

Do not ask for confirmation. Wait for CI, merge, clean up, and report the result.
