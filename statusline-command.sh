#!/usr/bin/env python3
"""Claude Code status line: user@host dir | git branch+status | token usage | model"""

import json
import os
import subprocess
import sys

# ANSI color codes
GREEN   = "\033[32m"
YELLOW  = "\033[33m"
CYAN    = "\033[36m"
MAGENTA = "\033[35m"
BLUE    = "\033[34m"
RESET   = "\033[0m"


def colorize(text, color):
    if not text:
        return ""
    return f"{color}{text}{RESET}"


def git_info(cwd):
    """Return formatted git branch + status string, or empty string if not a repo."""
    def run(args):
        result = subprocess.run(
            args,
            cwd=cwd,
            capture_output=True,
            text=True,
        )
        return result

    # Check if inside a git repo
    check = run(["git", "-C", cwd, "rev-parse", "--git-dir"])
    if check.returncode != 0:
        return ""

    # Get branch name (fall back to short SHA for detached HEAD)
    branch_result = run(["git", "-C", cwd, "symbolic-ref", "--short", "HEAD"])
    if branch_result.returncode == 0:
        branch = branch_result.stdout.strip()
    else:
        sha_result = run(["git", "-C", cwd, "rev-parse", "--short", "HEAD"])
        branch = sha_result.stdout.strip() if sha_result.returncode == 0 else "unknown"

    # Staged files
    staged_result = run(["git", "-C", cwd, "diff", "--cached", "--name-only"])
    staged = len([l for l in staged_result.stdout.splitlines() if l.strip()])

    # Unstaged modified files
    unstaged_result = run(["git", "-C", cwd, "diff", "--name-only"])
    unstaged = len([l for l in unstaged_result.stdout.splitlines() if l.strip()])

    # Untracked files
    untracked_result = run(["git", "-C", cwd, "ls-files", "--others", "--exclude-standard"])
    untracked = len([l for l in untracked_result.stdout.splitlines() if l.strip()])

    flags = []
    if staged:
        flags.append(f"+{staged}")
    if unstaged:
        flags.append(f"~{unstaged}")
    if untracked:
        flags.append(f"?{untracked}")

    if flags:
        return f"[{branch} {' '.join(flags)}]"
    return f"[{branch}]"


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        data = {}

    # Directory
    cwd = (
        data.get("workspace", {}).get("current_dir")
        or data.get("cwd")
        or os.getcwd()
    )
    dir_name = os.path.basename(cwd.rstrip("/")) or cwd

    dir_str = colorize(dir_name, YELLOW)

    # Git
    git_part = ""
    try:
        git_text = git_info(cwd)
        if git_text:
            git_part = " " + colorize(git_text, CYAN)
    except Exception:
        pass

    # Token usage
    token_part = ""
    try:
        ctx = data.get("context_window", {})
        used_pct = ctx.get("used_percentage")
        if used_pct is not None:
            used_int = round(float(used_pct))
            used_tokens = ctx.get("used_tokens", "")
            tokens_str = f"{used_tokens:,}" if used_tokens else ""
            token_part = " " + colorize(f"| ctx: {tokens_str} ({used_int}%)", MAGENTA)
    except Exception:
        pass

    print(f"{dir_str}{git_part}{token_part}")


if __name__ == "__main__":
    main()
