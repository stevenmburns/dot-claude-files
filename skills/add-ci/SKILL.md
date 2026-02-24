---
name: add-ci
description: In a new branch, create a GitHub Actions CI workflow that runs the appropriate test suite and linter(s) for the project (TypeScript, Python, or both)
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read, Write
---

# Add GitHub Actions CI Workflow

Detect the languages and tooling used in this project, create a new branch, then write a GitHub Actions workflow that runs tests and linting.

## Steps

### 1. Detect project languages and tooling

Search the repo for the following signals. Build a mental model of which apply:

**TypeScript / JavaScript:**
- `package.json` files (note their locations — could be root or subdirectories like `frontend/`)
- `scripts.test` field in `package.json` → determines test command (e.g. `vitest`, `jest`)
- `scripts.lint` field in `package.json` → determines lint command (e.g. `eslint .`)
- `vitest.config.*` or `jest.config.*` → confirms test runner
- `eslint.config.*`, `.eslintrc.*`, `.eslintrc.js/ts/json` → confirms ESLint
- `.prettierrc*` → Prettier present
- Node version from `.nvmrc`, `.node-version`, or `engines.node` in `package.json`; fall back to `node --version`

**Python:**
- `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`
- `[tool.pytest.ini_options]` in `pyproject.toml` → pytest
- `pytest.ini`, `conftest.py` → pytest
- `[tool.ruff]` in `pyproject.toml` → ruff linter (preferred over flake8)
- `.flake8`, `[flake8]` in `setup.cfg` → flake8
- `[tool.mypy]` or `mypy.ini` → mypy type-checker
- Python version from `.python-version` or `pyproject.toml requires-python`

Read the relevant `package.json` and config files you find. Do not guess — base every decision on what you actually find.

### 2. Determine working directories

If `package.json` is inside a subdirectory (e.g. `frontend/`), note that path — CI steps will need `working-directory`.

### 3. Create a new branch

Run:
```
git checkout -b ci/add-github-actions
```

### 4. Create `.github/workflows/ci.yml`

Create the directory if needed: `mkdir -p .github/workflows`

Write a workflow file with these principles:
- Trigger on `push: branches: [main]` and `pull_request: branches: [main]` — this ensures exactly one run per event (pushing to a PR branch triggers only `pull_request`; merging to main triggers only `push`). Never use bare `on: push` without a branch filter alongside `on: pull_request` — it causes duplicate runs.
- Use `ubuntu-latest`
- Separate jobs for `lint` and `test` (or combine if minimal tooling)
- Cache dependencies (npm cache or pip cache) for speed
- Use exact major versions for actions (e.g. `actions/checkout@v4`, `actions/setup-node@v4`, `actions/setup-python@v4`, `actions/cache@v4`)
- For Node: use the detected Node version (or `20` if unknown)
- For Python: use the detected Python version (or `3.12` if unknown)
- If a `working-directory` is needed for npm steps, set it at the job level or step level
- Lint job runs first; test job can run in parallel or after lint (parallel is fine)

**TypeScript-only template** (adapt as needed):
```yaml
name: CI

on:
  push:
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <subdir>   # omit if root
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '<version>'
          cache: npm
          cache-dependency-path: <subdir>/package-lock.json  # omit if root
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <subdir>   # omit if root
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '<version>'
          cache: npm
          cache-dependency-path: <subdir>/package-lock.json  # omit if root
      - run: npm ci
      - run: npm test
```

**Python-only template** (adapt as needed):
```yaml
name: CI

on:
  push:
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '<version>'
      - run: pip install ruff   # or flake8/mypy
      - run: ruff check .       # adapt to detected linter

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '<version>'
      - run: pip install -e ".[dev]"   # adapt to project install method
      - run: pytest
```

**Both languages:** add both sets of jobs, prefixing job names with `ts-` and `py-` (e.g. `ts-lint`, `py-test`).

For npm test commands: if `scripts.test` is just `vitest` (without `run`), use `npx vitest run --reporter=verbose` in the workflow instead — plain `vitest` starts in watch mode and will hang forever in CI. The `--reporter=verbose` flag prints each test name inline so CI logs clearly show what ran. Similarly, `jest --watch` should become `jest --ci`. Always use the one-shot / CI-safe variant of the test runner.

For other npm scripts (lint, build, etc.) use the actual commands from `scripts`.

### 5. Commit

Stage and commit the new file:
```
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions workflow for lint and tests"
```

### 6. Report

Tell the user:
- What you detected (languages, test runner(s), linter(s))
- The branch name created
- The path to the workflow file
- A summary of what the workflow does
- Remind them to run `/create-pr` when ready to open a PR
