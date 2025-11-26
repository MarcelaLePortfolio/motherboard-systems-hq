#!/bin/bash
set -e

cd "$(dirname "$0")/.." || {
  echo "❌ Could not determine project root."
  exit 1
}

echo "📂 Project root: $(pwd)"

echo ""
echo "🔎 Locating Python SSE servers (ops_stream.py and reflections_stream.py)..."

OPS_FILE="$(find . -maxdepth 6 -type f -name 'ops_stream.py' | head -n 1 || true)"
REFL_FILE="$(find . -maxdepth 6 -type f -name 'reflections_stream.py' | head -n 1 || true)"

if [ -z "$OPS_FILE" ]; then
  echo "❌ Could not find ops_stream.py within 6 levels of $(pwd)"
  echo "   Please locate it manually and update scripts/run-sse-servers.sh."
  exit 1
fi

if [ -z "$REFL_FILE" ]; then
  echo "❌ Could not find reflections_stream.py within 6 levels of $(pwd)"
  echo "   Please locate it manually and update scripts/run-sse-servers.sh."
  exit 1
fi

echo "✅ Found OPS SSE server at: $OPS_FILE"
echo "✅ Found Reflections SSE server at: $REFL_FILE"

echo ""
echo "🚀 Starting Python SSE servers..."
echo "   • OPS SSE  (port 3201)       → $OPS_FILE"
echo "   • Reflections SSE (port 3200) → $REFL_FILE"
echo ""

# Start OPS SSE
python3 "$OPS_FILE" &
OPS_PID=$!
echo "   ↪ OPS SSE PID: $OPS_PID"

# Start Reflections SSE
python3 "$REFL_FILE" &
REFL_PID=$!
echo "   ↪ Reflections SSE PID: $REFL_PID"

echo ""
echo "✅ Both SSE servers started."
echo "   • To stop them, run:  kill $OPS_PID $REFL_PID"
echo ""

wait
