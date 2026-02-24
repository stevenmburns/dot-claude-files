---
name: merge
description: Merge the open PR for the current branch into main, delete the branch, and pull main
user-invocable: true
allowed-tools: Bash
---

# Merge Current Branch PR into Main

Merge the open pull request for the current branch.

## Steps

1. Run `git branch --show-current` to get the current branch name
2. Run `gh pr view` to confirm a PR exists and is open
3. Run `gh pr merge --squash --delete-branch` to squash-merge and delete the remote branch
4. Switch to main and pull: `git checkout main && git pull`

Do not ask for confirmation. Merge, clean up, and report the result.
