#!/bin/bash
set -e

cd "$(dirname "$0")/.." || {
  echo "❌ Could not determine project root."
  exit 1
}

echo "📂 Searching for JS files under ./public (if present):"
if [ -d public ]; then
  find public -maxdepth 3 -type f -name "*.js" 2>/dev/null || echo "No JS files found under ./public"
else
  echo "❌ public directory not found in $(pwd)"
fi

echo ""
echo "📂 Searching for dashboard-related HTML files (up to 4 levels deep):"
find . -maxdepth 4 -type f \( -name "dashboard*.html" -o -name "*board*.html" -o -name "index.html" \) 2>/dev/null || echo "No candidate dashboard HTML files found."

echo ""
echo "🔍 If you see the correct HTML file path above, rerun with:"
echo "     sed -n '1,160p' <that-html-path>"
echo ""
echo "🔍 If you see the correct JS files above, rerun with:"
echo "     sed -n '1,260p' <that-js-path>"
echo ""
echo "✅ Copy the find output into ChatGPT so we can lock onto the real dashboard HTML + JS paths."
