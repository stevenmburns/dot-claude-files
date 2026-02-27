---
name: add-tests
description: Write tests for an existing file or module that lacks coverage
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
---

# Add Tests for Existing Code

Given a file or module, analyze its behavior and write tests that cover its main cases.

## Usage

`/add-tests <file-path>`

## Steps

1. **Read the target file** to understand what it does — its public interface, logic branches, edge cases, and error conditions
2. **Find the test runner** by checking `package.json` scripts or `pyproject.toml` — determine where test files live and what naming convention is used (e.g. `*.test.ts`, `test_*.py`)
3. **Check for existing tests** — search for any existing test file for this module; if one exists, read it and identify what is already covered before writing anything new
4. **Write tests** in the appropriate test file (create it if it doesn't exist, following project conventions):
   - Cover the primary happy path(s)
   - Cover meaningful edge cases and error conditions visible from the code
   - Do not write trivial tests (e.g. "it exists") or tests for implementation details
   - Keep tests focused and independent
5. **Run the tests** to confirm they all pass — if any fail, fix them before proceeding
6. **Report** what was covered and what was intentionally left out (and why)
