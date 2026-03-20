---
name: close-duplicate
description: Close a GitHub issue as a duplicate of another issue
user-invocable: true
allowed-tools: Bash
---

# Close Duplicate Issue

Close a GitHub issue as a duplicate of another issue, with a standardized comment.

## Usage

`/close-duplicate <issue-number> <original-issue-number>`

## Steps

1. **Validate both issues exist**: Run `gh issue view <issue-number> --json number,title,state` and `gh issue view <original-issue-number> --json number,title,state` to confirm both exist.
2. **Check state**: If the issue is already closed, report that and stop. If the original issue is closed, mention that it was already resolved.
3. **Close with comment**: Run `gh issue close <issue-number> --comment "Duplicate of #<original-issue-number>." --reason "not planned"`
4. Report the result: "Closed #NN as duplicate of #MM (<original title>)."
