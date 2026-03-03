#!/bin/bash
FILE=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
if [[ "$FILE" == *.py ]]; then
    ruff check --fix . 2>/dev/null
    ruff format . 2>/dev/null
fi
