#!/usr/bin/env bash
set -euo pipefail

echo "=== 1) Confirm current branch ==="
git rev-parse --abbrev-ref HEAD
echo

echo "=== 2) Fetch latest origin and tags ==="
git fetch origin --tags
echo

echo "=== 3) Show v11.7-ops-pill-dashboard-stable tag commit ==="
git show -s --oneline v11.7-ops-pill-dashboard-stable
echo

echo "=== 4) Show current HEAD commit ==="
git show -s --oneline HEAD
echo

echo "=== 5) Check merge-base of HEAD and v11.7-ops-pill-dashboard-stable ==="
git merge-base --octopus HEAD v11.7-ops-pill-dashboard-stable | xargs -I{} git show -s --oneline {}
echo

echo "=== 6) Show diff summary between v11.7 tag and current HEAD (backend-related files) ==="
git diff --stat v11.7-ops-pill-dashboard-stable..HEAD -- server.mjs routes/ || echo "No backend diffs between tag and HEAD for these paths."
echo

echo "=== 7) Verify dashboard layout files match origin/main (HTML/CSS) ==="
echo "--- Diff stat for public/dashboard.html and public/css/dashboard.css vs origin/main ---"
git diff --stat origin/main..HEAD -- public/dashboard.html public/css/dashboard.css || echo "No layout diffs vs origin/main for these files."
echo

echo "=== 8) Optional: show SHA1 checksums of layout files locally vs origin/main ==="
echo "--- Local checksums ---"
shasum public/dashboard.html public/css/dashboard.css
echo
echo "--- origin/main checksums ---"
git show origin/main:public/dashboard.html | shasum
git show origin/main:public/css/dashboard.css | shasum
echo

echo "Verification complete. Review the outputs above to confirm:"
echo "- Backend is based on v11.7-ops-pill-dashboard-stable."
echo "- Layout files (dashboard.html, dashboard.css) match origin/main."
