#!/bin/bash
set -e

echo "🔍 Inspecting actual Matilda chat backend files..."
echo "================================================"
echo

if [ -f "./routes/api-chat.ts" ]; then
  echo "📄 FILE: ./routes/api-chat.ts"
  echo "------------------------------------------------"
  sed -n '1,220p' ./routes/api-chat.ts
  echo
else
  echo "❌ Missing: ./routes/api-chat.ts"
  echo
fi

if [ -f "./server.ts" ]; then
  echo "📄 FILE: ./server.ts (proxy section)"
  echo "------------------------------------------------"
  sed -n '1,180p' ./server.ts
  echo
else
  echo "❌ Missing: ./server.ts"
  echo
fi

echo "✅ Inspection complete."
echo "Paste the output of ./routes/api-chat.ts back into chat first."
