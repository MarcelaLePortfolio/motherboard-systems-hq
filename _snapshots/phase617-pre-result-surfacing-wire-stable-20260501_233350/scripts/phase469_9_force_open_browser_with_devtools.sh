#!/usr/bin/env bash
set -euo pipefail

echo "Opening Chrome with DevTools forced..."

# macOS Chrome path
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

URL="http://localhost:8080/dashboard.html"

if [ -f "$CHROME" ]; then
  "$CHROME" --auto-open-devtools-for-tabs "$URL" >/dev/null 2>&1 &
  echo "Launched Chrome with DevTools forced open."
else
  echo "Chrome not found at expected path."
  echo "Opening with default browser instead..."
  open "$URL"
fi

echo
echo "NEXT:"
echo "- DevTools should already be open."
echo "- Go to Console tab."
echo "- Press Command + Shift + R"
echo "- Copy red errors."
