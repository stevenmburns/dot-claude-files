# Fix Issue

Read a GitHub issue, implement a fix, open a PR that references the issue, merge it, and close the issue.

## Usage

`/fix-issue <issue-number>`

## Steps

1. **Read the issue** with `gh issue view <number> --json title,body,comments` to understand the bug
2. **Explore the codebase** to locate the relevant code — read files, search for patterns mentioned in the issue
3. **Create a feature branch** named descriptively (e.g. `fix/<short-description>`)
4. **Write a failing test** that reproduces the bug — run it to confirm it fails before making any fix
5. **Implement the fix** — edit only what is necessary to fix the bug; do not refactor or clean up surrounding code
6. **Run tests** to confirm the new test passes and nothing else is broken — check the project's CLAUDE.md or pyproject.toml/package.json for the test command; if tests fail, fix them before continuing
7. **Stage and commit** the changed files with a descriptive conventional commit message; include `Closes #<number>` in the commit body
8. **Push the branch** with `-u` flag
9. **Create a PR** with `gh pr create`:
   - Title: concise description of the fix (under 70 chars)
   - Body must include `Fixes #<number>` so GitHub auto-closes the issue on merge; summarize root cause and changes
10. **Merge the PR** with `gh pr merge --squash --delete-branch`
11. **Switch back to main and pull** (`git checkout main && git pull`)
12. **Verify the issue is closed** with `gh issue view <number> --json state,closed`
13. Report the merged PR URL and confirm the issue is closed
