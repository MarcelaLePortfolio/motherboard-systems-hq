#!/bin/bash
set -euo pipefail

Phase 11 – Step 2: Safe Bundling Integration
This script rebuilds the dashboard bundle from the current working tree.
Run it from anywhere: it will cd into the repo root automatically.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "📂 Repo root: ${REPO_ROOT}"
cd "${REPO_ROOT}"

echo "✅ Current git status (pre-build):"
git status

echo "🔧 Running dashboard bundle build..."
npm run build:dashboard-bundle

echo "✅ Bundle build complete."

echo
echo "Next manual steps (not automated here):"
echo " 1) Ensure your dashboard container/dev server is running."
echo " 2) Open http://127.0.0.1:8080/dashboard
 (or your dev URL)."
echo " 3) Verify:"
echo " - OPS pill renders correctly and stays stable."
echo " - Matilda chat, task delegation, and tiles still work."
echo " - Browser console shows no new errors related to bundle.js."
echo
echo "If everything looks good, you may tag a new Phase 11 stable checkpoint."
