---
name: merge-pr
description: Merge the open PR for the current branch into main, delete the branch, and pull main
user-invocable: true
allowed-tools: Bash
---

# Merge Current Branch PR into Main

Merge the open pull request for the current branch.

## Steps

1. Run `git branch --show-current` to get the current branch name
2. **Check for unpushed commits**: run `git log @{u}..HEAD --oneline`. If there are unpushed commits, push them first with `git push`. If the push fails, report the error and stop — do not merge.
3. **Check for local/remote divergence**: run `git status` and verify the branch is not ahead of or diverged from its upstream. If it is, stop and report — squash merge will silently drop unpushed local commits.
4. Wait for CI to pass: run `gh pr checks --watch` to monitor check status. If checks fail, report the failure and stop — do not merge.
5. Run `gh pr merge --squash --delete-branch` to squash-merge and delete the remote branch (this will fail clearly if no PR exists, so no separate confirmation step is needed)
6. Switch to main and pull: `git checkout main && git pull`

Do not ask for confirmation. Wait for CI, merge, clean up, and report the result.
