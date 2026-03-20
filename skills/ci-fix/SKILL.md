---
name: ci-fix
description: Fix CI failures on the current branch's PR by reading logs, applying fixes, and pushing
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
---

# Fix CI Failures

Automatically diagnose and fix CI failures on the current branch's PR.

## Usage

`/ci-fix`

## Steps

1. **Identify failures**: Run `gh pr checks` to list check statuses. If all checks pass, report that and stop.
2. **Read failure logs**: For each failed check, get the run ID and fetch logs with `gh run view <run-id> --log-failed`. Parse the output to understand what failed (lint, test, type-check, etc.).
3. **Diagnose and fix**:
   - **Lint/format failures** (ruff, eslint, prettier, etc.): Run the formatter/linter locally with auto-fix, e.g. `ruff format .` or `ruff check --fix .`
   - **Test failures**: Read the failing test output, locate the relevant source code, and fix the issue
   - **Type-check failures**: Read the error, fix the type issue in the source
   - For other failures, investigate the logs and apply the minimal fix
4. **Verify locally**: Re-run the failed check locally to confirm the fix works (e.g. `ruff format --check .`, `pytest`, etc.)
5. **Commit and push**: Stage the changed files, commit with a message like "Fix CI: <description of what was wrong>", and push
6. **Watch CI**: Run `gh pr checks --watch` to confirm all checks now pass. If they fail again, repeat from step 2 (max 2 retries, then report the remaining failure and stop).
7. Report the result to the user.
