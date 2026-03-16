---
name: fresh-clone
description: Clone the current repo into a sibling directory with a fresh Python venv
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# Fresh Clone

Create a fresh clone of the current repository in a parallel directory, with its own Python virtual environment.

## Instructions

1. Determine the current repo's remote URL and current branch:
   - Run `git remote get-url origin` to get the remote URL
   - Run `git rev-parse --abbrev-ref HEAD` to get the current branch

2. Choose the clone directory:
   - The clone goes in a sibling directory next to the current repo
   - First, determine the **base name**: take the current directory name and strip any existing `-cloneN` suffix (e.g., `my-project-clone2` → `my-project`, `my-project` → `my-project`)
   - Name the clone `<base-name>-clone0`. If that exists, try `-clone1`, `-clone2`, etc. until a free name is found

3. Clone the repo:
   - `git clone <remote-url> <clone-dir>`
   - `cd <clone-dir>`
   - Check out the same branch: `git checkout <branch>` (skip if already on it)

4. Set up the Python virtual environment:
   - `python3.12 -m venv .venv`
   - Activate it: `source .venv/bin/activate`
   - Install dependencies based on what's available, in priority order:
     - If `pyproject.toml` exists with `[project.optional-dependencies]`: `pip install -e '.[dev]'`
     - Else if `pyproject.toml` or `setup.py` exists: `pip install -e .`
     - Else if `requirements.txt` exists: `pip install -r requirements.txt`
   - Report what was installed

5. Print a summary:
   - The full path to the clone
   - The branch checked out
   - The Python version and venv location
   - How to activate: `source <clone-dir>/.venv/bin/activate`
