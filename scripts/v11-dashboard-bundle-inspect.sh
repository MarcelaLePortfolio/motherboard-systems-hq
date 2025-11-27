#!/bin/bash
set -e

cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ

echo "===== v11 Dashboard Bundle Inspection ====="
echo "Branch: $(git branch --show-current)"
echo "Tag v11.0-stable-dashboard present?:"
git tag --list 'v11.0-stable-dashboard' || true
echo

echo "=== Grep for bundle.js references in server and dashboard ==="
grep -n "bundle.js" server.mjs public/dashboard.html 2>/dev/null || echo "No direct bundle.js references in these files."
echo

echo "=== public/js files ==="
if [ -d public/js ]; then
  ls -1 public/js
else
  echo "No public/js directory."
fi
echo

echo "=== public/scripts files ==="
if [ -d public/scripts ]; then
  ls -1 public/scripts
else
  echo "No public/scripts directory."
fi
echo

echo "=== public root JS/CSS files ==="
if [ -d public ]; then
  find public -maxdepth 1 \( -name "*.js" -o -name "*.css" \) -print
else
  echo "No public directory."
fi
echo

echo "=== Snippet: top of public/dashboard.html (first 120 lines) ==="
if [ -f public/dashboard.html ]; then
  sed -n '1,120p' public/dashboard.html
else
  echo "public/dashboard.html not found."
fi
echo

echo "=== Snippet: bottom of public/dashboard.html (last 120 lines) ==="
if [ -f public/dashboard.html ]; then
  tail -n 120 public/dashboard.html
fi
echo

echo "=== Done. Use this info to plan unified bundle.js wiring. ==="
