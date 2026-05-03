#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 PNPM BUILD POLICY SOURCE AUDIT ==="

echo
echo "=== 1) Candidate config files ==="
find . -maxdepth 3 \
  \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
  \( -name '.npmrc' -o -name 'pnpm-workspace.yaml' -o -name '.pnpmfile.cjs' -o -name '.pnpmfile.js' -o -name 'package.json' \) \
  -type f -print | sort

echo
echo "=== 2) Config lines mentioning build policy (bounded) ==="
grep -RInE 'ignored-built-dependencies|only-built-dependencies|ignore-scripts|approve-builds|better-sqlite3' \
  . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --include='.npmrc' \
  --include='pnpm-workspace.yaml' \
  --include='.pnpmfile.cjs' \
  --include='.pnpmfile.js' \
  --include='package.json' \
  | head -80 || true

echo
echo "=== 3) Local .npmrc contents (if present) ==="
for f in .npmrc ./.npmrc "$HOME/.npmrc"; do
  if [ -f "$f" ]; then
    echo "--- $f ---"
    sed -n '1,120p' "$f"
    echo
  fi
done

echo
echo "=== 4) pnpm config list (bounded) ==="
pnpm config list | sed -n '1,120p' || true

echo
echo "=== END PHASE 487 PNPM BUILD POLICY SOURCE AUDIT ==="
