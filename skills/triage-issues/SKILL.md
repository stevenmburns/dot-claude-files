---
name: triage-issues
description: Scan open GitHub issues, flag duplicates, and summarize with suggested priorities
user-invocable: true
allowed-tools: Bash
---

# Triage Issues

Scan all open GitHub issues, identify potential duplicates, and produce a prioritized summary.

## Usage

`/triage-issues`

## Steps

1. **Fetch all open issues**: Run `gh issue list --state open --limit 100 --json number,title,body,labels,createdAt` to get the full list.
2. **Identify potential duplicates**: Compare issue titles and bodies for similarity. Flag pairs that look like duplicates or near-duplicates.
3. **Categorize**: Group issues by label (bug, enhancement, unlabeled) and by area of the codebase if apparent from the title/body.
4. **Suggest priorities**: For each issue, suggest a priority (high/medium/low) based on:
   - Bugs over enhancements
   - Issues blocking other work
   - Age (older unresolved issues may need attention)
5. **Report**: Present a summary table with columns: #, Title, Labels, Priority, Notes (duplicates, blockers, etc.). Flag any actionable items like "close as duplicate of #NN" or "needs clarification".
