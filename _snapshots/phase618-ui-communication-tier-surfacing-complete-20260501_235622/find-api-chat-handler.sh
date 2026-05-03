#!/bin/bash

echo "🔍 Searching for ACTUAL /api/chat backend handler..."

# Search common Next.js / Node API route locations only (exclude public)
FILES=$(grep -rl "chat" ./app ./pages 2>/dev/null | grep -E 'api/.*/chat|api/chat' | grep -E '\.(js|ts)$')

if [ -z "$FILES" ]; then
  echo "❌ No backend /api/chat handler found in app/ or pages/."
  exit 1
fi

echo "📄 Candidate files:"
echo "$FILES"
echo "────────────────────────────────"

# Show first match preview
FILE=$(echo "$FILES" | head -n 1)

echo "🔎 Previewing: $FILE"
echo "────────────────────────────────"
sed -n '1,200p' "$FILE"
echo "────────────────────────────────"
echo "✅ Review this file. Confirm if it is placeholder or real logic."
