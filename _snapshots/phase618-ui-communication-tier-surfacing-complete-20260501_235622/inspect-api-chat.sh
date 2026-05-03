#!/bin/bash

echo "🔍 Locating /api/chat handler..."

FILE=$(grep -rl "api/chat" . | grep -E '\.(js|ts|tsx)$' | head -n 1)

if [ -z "$FILE" ]; then
  echo "❌ No /api/chat handler found."
  exit 1
fi

echo "📄 Found file: $FILE"
echo "────────────────────────────────"
echo "🔎 Preview (first 200 lines):"
echo "────────────────────────────────"
sed -n '1,200p' "$FILE"
echo "────────────────────────────────"
echo "✅ Inspection complete. Confirm placeholder behavior before patching."
