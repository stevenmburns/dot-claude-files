#!/bin/bash
# PostToolUse hook: run ruff on edited Python files.
# Auto-discovers a project .venv by walking up from the edited file.
# Works on Linux/macOS and Windows (Git Bash).

FILE=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ "$FILE" == *.py ]] || exit 0
[[ -f "$FILE" ]] || exit 0

# Walk up from the file's directory looking for a marker file/dir.
# Echoes the directory containing the marker, or returns 1.
find_up() {
    local marker="$1"
    local dir
    dir=$(cd "$(dirname "$FILE")" 2>/dev/null && pwd) || return 1
    while [[ -n "$dir" && "$dir" != "/" ]]; do
        if [[ -e "$dir/$marker" ]]; then
            echo "$dir"
            return 0
        fi
        local parent
        parent=$(dirname "$dir")
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done
    return 1
}

VENV_DIR=$(find_up .venv)
VENV=${VENV_DIR:+$VENV_DIR/.venv}

# Pick a ruff invocation: prefer venv binary, then `python -m ruff`, then PATH ruff.
if [[ -n "$VENV" && -x "$VENV/Scripts/ruff.exe" ]]; then
    RUFF=("$VENV/Scripts/ruff.exe")
elif [[ -n "$VENV" && -x "$VENV/bin/ruff" ]]; then
    RUFF=("$VENV/bin/ruff")
elif [[ -n "$VENV" && -x "$VENV/Scripts/python.exe" ]]; then
    RUFF=("$VENV/Scripts/python.exe" -m ruff)
elif [[ -n "$VENV" && -x "$VENV/bin/python" ]]; then
    RUFF=("$VENV/bin/python" -m ruff)
elif command -v ruff >/dev/null 2>&1; then
    RUFF=(ruff)
else
    # No ruff available — silently skip rather than fail the hook.
    exit 0
fi

"${RUFF[@]}" check --fix "$FILE" >/dev/null 2>&1

# Only run `ruff format` if the project has explicitly opted in by
# declaring a [tool.ruff.format] section in pyproject.toml. Default to
# leaving formatting alone — repos with non-default style (2-space
# indent, single-quote, etc.) shouldn't get clobbered by Edit-time
# canonicalization that their own CI doesn't enforce.
PROJECT_DIR=$(find_up pyproject.toml)
if [[ -n "$PROJECT_DIR" ]] && grep -qE '^\[tool\.ruff\.format\]' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
    "${RUFF[@]}" format "$FILE" >/dev/null 2>&1
fi

exit 0
