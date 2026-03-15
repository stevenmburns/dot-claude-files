# Fresh Clone

Create a fresh clone of the current repository in a parallel directory, with its own Python virtual environment.

## Instructions

1. Determine the current repo's remote URL and current branch:
   - Run `git remote get-url origin` to get the remote URL
   - Run `git rev-parse --abbrev-ref HEAD` to get the current branch

2. Choose the clone directory:
   - The clone goes in a sibling directory next to the current repo
   - Name it `<repo-name>-clone` (e.g., if the repo is `my-project`, clone to `../my-project-clone`)
   - If that directory already exists, append a number: `<repo-name>-clone-2`, `-3`, etc.

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
