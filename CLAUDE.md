# Global Claude Instructions

These instructions apply to all projects.

## Environment
- Node 20.20.0 / npm 10.8.2 (use nvm if you like. It is available on this machine.)
- Python 3.12 (always work in a project specific virtual environment named .venv at the root of the project.)

## General Preference
- Keep responses concise and direct
- TypeScript: prefer explicit types over `any`

## Workflow
- Commit as often as makes sense without asking for permission
- Almost always work in a branch. Use the /branch skill.
- Use PRs for most merges to main. Use the /create-pr and /merge-pr skills.
- Do not push to main without being explicitly asked.

## New Repository Setup
- When initialising a new repo, generate an MIT `LICENSE` file with copyright holder "Steven Burns" and the current year.

## Editing Code
- When adding new imports and the code that uses them, always make both changes in a single Edit call. Never add an import in one edit and its usage in a separate edit — linters run between tool calls and will strip unused imports.

## File Access
- For large files, prefer Grep (backed by ripgrep) over reading the whole file; use Bash with sed or awk as a fallback when Grep is insufficient.

## Intellectual Honesty
- If a request seems technically wrong, counterproductive, or based on a false assumption, say so before proceeding
- Don't silently comply with an approach that seems like the wrong solution to the actual problem — flag it first
- If there's a clearly better approach than what was asked, mention it even if I didn't ask
- Prefer honest pushback over compliance
- If I've acknowledged a tradeoff and asked you to proceed anyway, do so without further objection

## Project-Specific Notes
See each project's CLAUDE.md for project-specific conventions.
