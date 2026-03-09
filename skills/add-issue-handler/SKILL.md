---
name: add-issue-handler
description: Add a GitHub Actions workflow that uses Claude Code to automatically fix bugs and implement features when issues are opened or labeled
user-invocable: true
allowed-tools: Bash, Write
---

# Add Claude Code Issue Handler

Create a GitHub Actions workflow that triggers when a bug or enhancement issue is opened or labeled, and invokes Claude Code to fix or implement it using the project's `/fix-issue` and `/build-issue` skills.

## Steps

### 1. Get the dot-claude-files URL

The project's Claude skills live in `~/.claude`. The workflow must clone that repo in CI so the skills are available at runtime.

```bash
git -C ~/.claude remote get-url origin
```

Convert the result from SSH to HTTPS format:
- `git@github.com:user/repo.git` → `https://github.com/user/repo`

### 2. Create a new branch

```bash
git checkout -b ci/add-claude-issue-handler
```

### 3. Create `.github/workflows/claude-issue-handler.yml`

Create the directory if needed: `mkdir -p .github/workflows`

Write the file, substituting the actual HTTPS dot-claude-files URL for `<DOT_CLAUDE_URL>`:

```yaml
name: Claude Issue Handler

on:
  issues:
    types: [opened, labeled]

jobs:
  fix-bug:
    if: contains(github.event.issue.labels.*.name, 'bug')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Set up Claude config
        run: git clone <DOT_CLAUDE_URL> ~/.claude
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/fix-issue ${{ github.event.issue.number }}"
          allowed_tools: "Bash,Glob,Grep,Read,Write,Edit"

  build-feature:
    if: contains(github.event.issue.labels.*.name, 'enhancement')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Set up Claude config
        run: git clone <DOT_CLAUDE_URL> ~/.claude
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/build-issue ${{ github.event.issue.number }}"
          allowed_tools: "Bash,Glob,Grep,Read,Write,Edit"
```

### 4. Commit

```bash
git add .github/workflows/claude-issue-handler.yml
git commit -m "ci: add Claude Code issue handler workflow"
```

### 5. Report to the user

- The path to the workflow file created
- Remind them to add `ANTHROPIC_API_KEY` to repo secrets: **Settings → Secrets and variables → Actions → New repository secret**
- The workflow fires when a **bug** or **enhancement** label is present at issue open time, or added later via labeling
- Run `/create-pr` when ready to merge
