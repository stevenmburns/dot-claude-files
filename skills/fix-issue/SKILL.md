---
name: fix-issue
description: Read a GitHub issue, implement a fix, and open a PR that references the issue
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
---

# Fix Issue

Read a GitHub issue, implement a fix, and open a PR that references the issue.

## Usage

`/fix-issue <issue-number>`

## Steps

1. **Read the issue** with `gh issue view <number> --json title,body,comments` to understand the bug
2. **Explore the codebase** to locate the relevant code — read files, search for patterns mentioned in the issue
3. **Create a feature branch** named descriptively (e.g. `fix/<short-description>`)
4. **Write a failing test** that reproduces the bug — run it to confirm it fails before making any fix
   - The test must fail because of the behavior described in the issue, not due to a technical problem (missing file, unresolvable import, missing module, etc.)
   - If the test fails for a technical reason, fix that problem first so the test fails for the right reason before continuing
5. **Implement the fix** — edit only what is necessary to fix the bug; do not refactor or clean up surrounding code
6. **Run tests** to confirm the new test passes and nothing else is broken — check the project's CLAUDE.md or pyproject.toml/package.json for the test command; if tests fail, fix them before continuing
7. **Stage and commit** the changed files with a descriptive conventional commit message; include `Closes #<number>` in the commit body
8. **Push the branch** with `-u` flag
9. **Create a PR** with `gh pr create`:
   - Title: concise description of the fix (under 70 chars)
   - Body must include `Fixes #<number>` so GitHub auto-closes the issue on merge; summarize root cause and changes
10. Report the PR URL to the user
