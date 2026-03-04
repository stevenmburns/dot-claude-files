---
name: create-pr
description: Push the current branch and open a PR to merge it into main, with a title derived from the branch name and commit changes
user-invocable: true
allowed-tools: Bash
---

# Open a PR to Merge Current Branch into Main

Push the current branch and create a pull request targeting `main`.

## Steps

1. Run `git status` to check for any uncommitted changes (staged or unstaged). If any exist, stage and commit them before proceeding — do not create the PR with a dirty working tree. Use a descriptive commit message and include the `Co-Authored-By` trailer.
2. Run `git branch --show-current` to get the branch name
3. Run `git log main..HEAD --oneline` and `git diff main...HEAD` to understand what changed
4. Derive a clear, human-readable PR title from both the branch name and the actual changes — do not just restate the branch name verbatim; synthesize a title that captures the intent
5. Push the branch with `git push -u origin <branch>` if not already pushed
6. Open the PR with `gh pr create --base main --title "..." --body "..."` using the standard body format below

## PR Body Format

```
## Summary
<2-4 bullet points describing what changed and why>

## Test plan
- [ ] <relevant test steps>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Do not ask for confirmation. Push and open the PR, then return the PR URL.
