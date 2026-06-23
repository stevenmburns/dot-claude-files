---
name: tidy-branch
description: Interactively clean up the current branch's commits (squash fixups, reword sloppy messages, reorder, drop) before merging — especially important on repos using rebase-merge where every branch commit lands on main verbatim
user-invocable: true
allowed-tools: Bash, Read, Write
---

# Tidy the Current Branch Before Merging

Review the commits on the current branch (those that would land on `main` via rebase-merge or PR) and help the user collapse, reword, reorder, or drop them into a clean, review-ready sequence. Works by proposing a rebase plan, getting user approval, and then executing a non-interactive `git rebase -i` with a scripted todo-list.

**When to use this**: before `/merge-pr` on a repo configured for rebase-merge (where messy commits pollute `main` directly, not just the PR diff). Also useful before `/create-pr` if the in-progress branch has accumulated "wip", "fix typo", or "address review" commits that should be collapsed into their logical parents.

**When NOT to use this**: if the branch has already been merged; if you're on `main` or another protected branch; if the commits are already clean (one tidy commit per logical change).

## Steps

1. **Check preconditions.** Run `git branch --show-current`. If the branch is `main` or `master`, stop and report — this skill is for feature branches only. Run `git status` — if the working tree is dirty, stop and report (commit or stash first; rebase on a dirty tree is a mess).

2. **Run lint and fix.** Run the project's linter on the entire repo (the same scope CI checks — typically `ruff check --fix` and `ruff format` for Python projects; check `pyproject.toml` or CI config for the exact commands and paths). If the linter produces changes, stage and commit them with a `style: ruff fix` message (including the `Co-Authored-By` trailer). This ensures lint fixes are captured as a commit *before* the rebase plan is built, so they can be squashed into their logical parent during tidying. If the linter finds unfixable errors, stop and report.

3. **Determine the base.** Fetch the latest remote state *first* — `git fetch origin` — then base everything on the remote-tracking ref `origin/main`, **not** the local `main` branch. The local `main` ref is frequently stale (it only moves when you check it out and pull), and comparing against it lists commits that are *already* on the remote `main` as if they were new candidates to tidy — which is wrong and dangerous (you'd be rewriting already-merged history). Confirm the base with `git merge-base HEAD origin/main` and list candidates with `git log origin/main..HEAD --oneline`. (Substitute the repo's actual default branch if it isn't `main`.) If `git log main..HEAD` and `git log origin/main..HEAD` disagree, that disagreement *is* the signal that local `main` is stale — trust `origin/main`.

4. **Check push state.** Run `git log @{u}..HEAD --oneline` and `git log HEAD..@{u} --oneline` (the second may fail if no upstream — that's fine). Record whether the branch has an upstream and whether the local/remote have diverged. This determines whether step 7 needs a force-push.

5. **Analyze the commits.** For each commit in `git log origin/main..HEAD --oneline`:
   - Read the full message with `git log origin/main..HEAD --format=fuller`
   - Note which files each one touches with `git log origin/main..HEAD --stat`
   - Identify candidates for:
     - **Squash** — commits that are fixups, typo fixes, "address review" commits, or small amendments to a logical parent commit. Look for message prefixes like "fix", "typo", "wip", "review", "fixup!", "squash!", or commits that only touch files already touched by an earlier commit.
     - **Reword** — commits with vague messages ("wip", "update", "changes"), missing context, or wrong tone (e.g. "fixed bug" instead of describing the root cause).
     - **Reorder** — logical changes that landed out of order (e.g. a test commit landed before its implementation, or a refactor commit is interleaved with unrelated feature work).
     - **Drop** — commits that got reverted on the same branch, dead-end experiments, or accidentally-committed files. Be *very* conservative here — prefer keeping the commit and asking the user over silently dropping it.

6. **Propose a plan and get approval.** Write a clear plan as a markdown table or list, showing: original commit order, proposed action (pick/squash/fixup/reword/drop/reorder), and for reword/squash cases the proposed new message. Present it to the user and wait for explicit approval before executing. This is a destructive history rewrite — confirmation is required, not optional. If the user wants changes to the plan, revise and re-present.

7. **Execute the plan.** Once approved:
   - Write the desired todo-list to a temporary file (each line: `<action> <short-sha> <subject>`, where action is one of `pick`, `squash`, `fixup`, `reword`, `edit`, `drop`).
   - Write any new commit messages that reword/squash operations need to their own temp files (one per commit that needs a new message).
   - Invoke the rebase non-interactively:
     ```bash
     GIT_SEQUENCE_EDITOR="cp /tmp/tidy-todo.txt" \
     GIT_EDITOR="<msg-editor-script>" \
     git rebase -i <base-sha>
     ```
     where `<msg-editor-script>` is a small shell script the skill writes that checks the commit being edited and substitutes the appropriate pre-written message. For the common case of a single squash with a known final message, a simpler pattern is `GIT_EDITOR='cp /tmp/new-msg.txt' git rebase -i <base>`.
   - If the rebase hits a conflict, stop and report to the user — do not try to auto-resolve. The user will resolve and either `git rebase --continue` manually or abort.

8. **Verify the result.** After rebase completes, show `git log origin/main..HEAD --oneline` so the user can see the new tidy history. Run `git log origin/main..HEAD --stat` briefly to confirm file counts and that no content was dropped unexpectedly. If the rebase changed the diff relative to `origin/main` (it shouldn't unless `drop` was used), flag this explicitly.

9. **Force-push if needed.** If the branch had an upstream and the history rewrite diverged it:
   - Use `git push --force-with-lease` (never plain `--force`) to update the remote branch. `--force-with-lease` refuses to push if someone else has pushed to the branch since the last fetch, which protects collaborators.
   - If the force-push fails (lease rejected), stop and report — someone else's work is at risk.
   - If the branch has no upstream, just report "no upstream, no push needed; run `git push -u origin <branch>` when ready."

## Important notes

- **Never rewrite commits that already landed on main** or another shared/protected branch. The skill targets only commits between `origin/main` and `HEAD` (the *fetched* remote ref — see step 3, not the possibly-stale local `main`) — commits already on the remote default branch are never touched. Skipping the `git fetch` in step 3 is the classic way to violate this: a stale local `main` makes already-merged commits look like fresh branch work.
- **Force-push uses `--force-with-lease`, not `--force`**. This is non-negotiable even on solo repos, because the cost of a mistake is lost work.
- **Ask, don't guess, for edge cases.** If a commit message is terse but might be intentional (e.g. "WIP: parking for tomorrow" on a draft PR), ask the user before rewording. If a commit looks like a revert, ask before dropping.
- **Conflict recovery is the user's job.** This skill does not try to resolve conflicts automatically. If a rebase fails, stop and hand back to the user with `git status` output.
- **This skill mutates history.** Never run it on `main`, never run it on commits older than the merge base, and always get explicit plan approval before executing.
