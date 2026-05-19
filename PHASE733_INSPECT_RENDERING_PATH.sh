
#!/bin/bash

set -euo pipefail

echo "=== Phase 733 Rendering Path Inspection ==="

echo

echo "=== Candidate files mentioning artifact preview/rendering ==="

find public routes src -type f 2>/dev/null \

  ! -path "*/node_modules/*" \

  ! -path "*/.git/*" \

  ! -path "*/backups/*" \

  -print0 \

  | xargs -0 grep -nE "artifact|preview|sanitize|innerHTML|markdown|\\\\n" 2>/dev/null \

  | head -200 || true

echo

echo "=== Server candidate scan ==="

grep -nE "artifact|preview|sanitize|innerHTML|markdown|\\\\n" server.ts 2>/dev/null || true

echo

echo "=== Known renderer bridge files ==="

find public src routes -type f 2>/dev/null \

  | grep -Ei 'render|preview|artifact|phase530|semantic|markdown' \

  | sort || true

