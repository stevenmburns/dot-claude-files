---
name: create-feature-issue
description: Synthesize a feature description into a clean GitHub issue with the "enhancement" label
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read
---

# Create Feature Issue

Turn a rough feature description into a well-structured GitHub issue, informed by light codebase analysis.

## Usage

`/create-feature-issue <description>`

## Steps

1. **Understand the request** — read the description carefully; identify the core problem being solved, the desired behavior, and any implied constraints
2. **Do light codebase analysis** — search for code relevant to the feature area (existing related files, patterns, data models) to ground the issue in the actual codebase; do not go deep, just enough to write an accurate, concrete description
3. **Synthesize the issue**:
   - **Title**: concise, imperative, under 70 chars (e.g. "Add bulk export to CSV from QSO log")
   - **Body**: use the template below — write clearly and specifically; do not copy the user's input verbatim; improve clarity, remove filler, and add context from your codebase analysis
4. **Create the issue**:
   ```
   gh issue create --title "..." --body "..." --label "enhancement"
   ```
   If the "enhancement" label does not exist, create it first: `gh label create enhancement --color a2eeef`
5. **Report** the issue number and URL

## Issue Body Template

```
## Summary
<1-3 sentences describing the feature and the problem it solves>

## Desired behavior
<What should the system do? Be specific about inputs, outputs, and user-facing behavior>

## Acceptance criteria
- [ ] <concrete, testable criterion>
- [ ] <concrete, testable criterion>

## Context
<Relevant notes from codebase analysis — affected files, related patterns, constraints — omit if nothing meaningful to add>
```
