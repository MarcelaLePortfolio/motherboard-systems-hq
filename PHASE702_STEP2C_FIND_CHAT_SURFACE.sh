#!/usr/bin/env bash
set -euo pipefail

echo "Locating actual chat UI files (not just 'Matilda' mentions)..."

grep -RInE "chat|Chat|message|Message|input|Input|textarea|/api/chat" app components pages src 2>/dev/null || true

git status --short
