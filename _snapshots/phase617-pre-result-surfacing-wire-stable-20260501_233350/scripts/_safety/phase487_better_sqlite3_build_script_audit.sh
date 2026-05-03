#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 better-sqlite3 BUILD SCRIPT AUDIT ==="

echo
echo "=== 1) Existing binding files (bounded) ==="
find node_modules -path '*better_sqlite3.node' | head -40 || true

echo
echo "=== 2) better-sqlite3 package scripts ==="
node - << 'PY'
const fs = require('fs');
const path = require('path');
const roots = fs.readdirSync('node_modules/.pnpm').filter(x => x.startsWith('better-sqlite3@'));
if (!roots.length) {
  console.log('better-sqlite3 package not found');
  process.exit(0);
}
const pkgPath = path.join('node_modules/.pnpm', roots[0], 'node_modules/better-sqlite3/package.json');
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
console.log('package:', pkgPath);
console.log('version:', pkg.version);
console.log('scripts:', pkg.scripts || {});
PY

echo
echo "=== 3) pnpm config signals ==="
pnpm config get ignore-scripts || true
pnpm config get only-built-dependencies || true
pnpm config get ignored-built-dependencies || true

echo
echo "=== 4) pnpm ignored-builds / approve-builds hints ==="
pnpm ignored-builds || true
pnpm approve-builds --help | sed -n '1,80p' || true

echo
echo "=== 5) Local native build tool presence ==="
command -v python3 || true
python3 --version || true
command -v make || true
make --version 2>/dev/null | head -5 || true
command -v clang || true
clang --version 2>/dev/null | head -5 || true
command -v xcode-select || true
xcode-select -p 2>/dev/null || true

echo
echo "=== 6) Recent better-sqlite3 install/rebuild evidence in pnpm logs (bounded) ==="
find ~/Library/pnpm ~/.pnpm ~/.local/share/pnpm -type f 2>/dev/null \
  | grep -E 'debug|pnpm' \
  | tail -20 || true

echo
echo "=== END PHASE 487 better-sqlite3 BUILD SCRIPT AUDIT ==="
