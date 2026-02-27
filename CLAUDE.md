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

## Project-Specific Notes
See each project's CLAUDE.md for project-specific conventions.
