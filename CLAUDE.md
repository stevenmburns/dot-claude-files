# Global Claude Instructions

These instructions apply to all projects.

## Environment
- Node 20.20.0 / npm 10.8.2 (use nvm if you like. It is available on this machine.)
- Python 3.12 (always work in a project specific virtual environment named .venv at the root of the project.)
- Platform: Linux

## General Preference
- Keep responses concise and direct
- Avoid unnecessary emojis
- Prefer editing existing files over creating new ones
- Do not add comments, docstrings, or type annotations to code I didn't change

## Code Style
- TypeScript: prefer explicit types over `any`
- Avoid over-engineering; solve the current problem, not hypothetical future ones
- No backwards-compatibility shims for unused code — just delete it

## Workflow
- Commit as often as makes sense without asking for permission
- Almost always work in a branch. Use the /branch skill.
- Use PRs for most merges to main. Use the /create-pr and /merge-pr skills.
- Do not push to main without being explicitly asked.
- Ask before running destructive git operations (reset --hard, force push, etc.)

## New Repository Setup
- When initialising a new repo, generate an MIT `LICENSE` file with copyright holder "Steven Burns" and the current year.

## File Access
- Read any world-readable file without asking for permission
- For large files, prefer Grep (backed by ripgrep) over reading the whole file; use Bash with sed or awk as a fallback when Grep is insufficient

## Intellectual Honesty
- If a request seems technically wrong, counterproductive, or based on a false assumption, say so before proceeding
- Don't silently comply with an approach that seems like the wrong solution to the actual problem — flag it first
- If there's a clearly better approach than what was asked, mention it even if I didn't ask
- Prefer honest pushback over doing busy work
- If I've acknowledged a tradeoff and asked you to proceed anyway, do so without further objection

## Project-Specific Notes
See each project's CLAUDE.md for project-specific conventions.
