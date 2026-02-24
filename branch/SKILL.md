---
name: branch
description: Create an appropriately named git branch based on current uncommitted changes in the worktree
user-invocable: true
allowed-tools: Bash
---

# Create Branch from Uncommitted Changes

Look at the current uncommitted changes and create an appropriately named git branch.

## Steps

1. Run `git diff` and `git status` to understand what has changed
2. Infer a concise, descriptive branch name from the nature of the changes (lowercase, hyphen-separated, no more than 5-6 words)
3. Run `git checkout -b <branch-name>` to create and switch to the branch

Do not ask for confirmation — just pick the best name and create the branch. Report the branch name you chose and why.
