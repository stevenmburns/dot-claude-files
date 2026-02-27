---
name: rename-pr
description: Analyze the changes in the current PR and suggest a more accurate title if the current one no longer fits
user-invocable: true
allowed-tools: Bash
---

# Rename PR

Analyze the current PR's changes and evaluate whether the title still accurately describes what is being done.

## Steps

1. Run `gh pr view --json number,title,body` to get the current PR title and description
2. Run `git log main..HEAD --oneline` and `git diff main...HEAD --stat` to understand the full scope of changes
3. Compare the changes to the current title:
   - Does the title accurately reflect the nature and scope of the changes?
   - Has the work drifted significantly from what the title implies?
   - Is the title too narrow, too broad, or misleading given what was actually done?
4. Based on your analysis:
   - **If a better title is warranted**: propose a specific new title (under 70 chars, conventional style matching the existing title's casing/format) and explain concisely why it's more accurate
   - **If the current title is still appropriate**: explain why it still fits and make no change
5. If you proposed a new title, ask the user to confirm before applying it. Accept yes/no or a user-provided alternative title.
6. If confirmed, run `gh pr edit --title "<new title>"` and report the updated title.
