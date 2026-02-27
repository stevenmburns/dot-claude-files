---
name: build-issue
description: Implement a feature issue using test-driven development
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
---

# Implement Feature with TDD

Read a GitHub feature issue, implement it test-first, and open a PR that references the issue.

## Usage

`/build-issue <issue-number>`

## Steps

1. **Read the issue** with `gh issue view <number> --json title,body,comments` to understand the desired behavior and acceptance criteria
2. **Explore the codebase** to locate relevant files — understand existing patterns, data models, and conventions in the affected area
3. **Create a feature branch** named descriptively (e.g. `feature/<short-description>`)
4. **Write tests first** that describe the desired behavior from the issue's acceptance criteria:
   - Tests should fail because the feature does not exist yet, not due to a technical problem (missing import, unresolvable module, etc.)
   - If a test fails for a technical reason, fix that problem first so it fails for the right reason before continuing
   - Follow existing test conventions in the project (file location, naming, test runner)
5. **Run the tests** to confirm they fail for the right reason
6. **Implement the feature** — write what is needed to make the tests pass
7. **Run tests** to confirm all new tests pass and nothing else is broken — check CLAUDE.md or `package.json`/`pyproject.toml` for the test command; if tests fail, fix them before continuing
8. **Stage and commit** with a descriptive conventional commit message; include `Closes #<number>` in the commit body
9. **Push the branch** with `-u` flag
10. **Create a PR** with `gh pr create`:
    - Title: concise description of the feature (under 70 chars)
    - Body must include `Closes #<number>` so GitHub auto-closes the issue on merge; summarize what was built and how
11. Report the PR URL to the user
