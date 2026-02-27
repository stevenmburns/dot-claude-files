---
name: create-bug-issue
description: Synthesize a bug description into a clean GitHub issue with the "bug" label
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read
---

# Create Bug Issue

Turn a rough bug description into a well-structured GitHub issue, informed by light codebase analysis.

## Usage

`/create-bug-issue <description>`

## Steps

1. **Understand the report** — identify the unexpected behavior, what triggered it, and what was expected instead
2. **Do light codebase analysis** — search for code relevant to the reported area to ground the issue and identify likely affected files or components; do not investigate the root cause, just enough to write an accurate, targeted description
3. **Synthesize the issue**:
   - **Title**: concise, specific, under 70 chars — describe the broken behavior, not just the symptom (e.g. "QSO save fails silently when park ID is missing" not "bug in save")
   - **Body**: use the template below — write clearly and specifically; do not copy the user's input verbatim; improve clarity, fill in implied steps, and add relevant context from codebase analysis
4. **Create the issue**:
   ```
   gh issue create --title "..." --body "..." --label "bug"
   ```
   If the "bug" label does not exist, create it first: `gh label create bug --color d73a4a`
5. **Report** the issue number and URL

## Issue Body Template

```
## Summary
<1-2 sentences describing the bug and its impact>

## Steps to reproduce
1. <step>
2. <step>
3. <step>

## Expected behavior
<What should happen>

## Actual behavior
<What actually happens>

## Context
<Relevant notes from codebase analysis — affected files, related components, any obvious suspects — omit if nothing meaningful to add>
```
