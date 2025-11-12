
set -euo pipefail

echo "🔥 Pre-warming agents (Matilda, Cade, Effie)…"

function ping_json () {
  local URL="$1"; local BODY="$2"
  curl -s -m 3 -H "Content-Type: application/json" -X POST "$URL" -d "$BODY" >/dev/null || true
}

ping_json "http://localhost:3001/matilda_chat" '{"message":"Ping for warmup"}'

ping_json "http://localhost:3001/cade" '{"type":"noop","payload":{"ts":'$(date +%s)'}}'

ping_json "http://localhost:3001/effie" '{"op":"noop"}'

echo "✅ Pre-warm sequence issued."
