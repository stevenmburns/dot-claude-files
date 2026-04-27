#!/bin/bash
# PostToolUse hook: run ruff on edited Python files.
# Auto-discovers a project .venv by walking up from the edited file.
# Works on Linux/macOS and Windows (Git Bash).

FILE=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ "$FILE" == *.py ]] || exit 0
[[ -f "$FILE" ]] || exit 0

# Walk up from the file's directory looking for a .venv
find_venv() {
    local dir
    dir=$(cd "$(dirname "$FILE")" 2>/dev/null && pwd) || return 1
    while [[ -n "$dir" && "$dir" != "/" ]]; do
        if [[ -d "$dir/.venv" ]]; then
            echo "$dir/.venv"
            return 0
        fi
        local parent
        parent=$(dirname "$dir")
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done
    return 1
}

VENV=$(find_venv)

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
"${RUFF[@]}" format "$FILE" >/dev/null 2>&1

exit 0
