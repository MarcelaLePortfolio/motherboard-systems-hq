
#!/usr/bin/env bash

set -euo pipefail

echo "--- latest commits ---"

git log --oneline -5

echo

echo "--- inline script syntax final status ---"

grep -nE "SyntaxError|CHECK|node syntax checks" dashboard-inline-script-syntax-final-check.txt || true

echo

echo "--- hard refresh instruction ---"

cat << 'NOTE'

Open:

http://localhost:8080/dashboard.html

Then hard-refresh:

Cmd+Shift+R

Expected:

No "missing ) after argument list" error.

NOTE

