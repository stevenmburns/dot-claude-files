---
name: pre-pr-check
description: Before opening a PR, check whether the changed logic has test coverage and surface any gaps
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read
---

# Pre-PR Test Coverage Check

Analyze the changes on the current branch against main and check whether the modified logic has corresponding tests.

## Steps

1. Run `git diff main...HEAD --name-only` to get the list of changed files
2. Run `git diff main...HEAD` to understand what logic actually changed — focus on non-trivial changes (skip config, lockfiles, markup-only changes, etc.)
3. For each file with meaningful logic changes, search for a corresponding test file using naming conventions (e.g. `*.test.ts` alongside source, `test_*.py` in a `tests/` directory)
4. For files that have a test file, scan the test file to assess whether the changed behavior appears to be tested
5. Summarize your findings:
   - List files with logic changes that have adequate coverage
   - List files with logic changes that appear untested or undertested — be specific about what behavior is missing tests
   - Note any files intentionally skipped (config, generated code, etc.) and why
6. If gaps exist, ask the user whether they want to address them now (via `/add-tests`) or proceed to `/create-pr` anyway — do not block, just make the gaps explicit
