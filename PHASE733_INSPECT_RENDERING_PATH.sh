
#!/bin/bash

set -euo pipefail

echo "=== Phase 733 Rendering Path Inspection ==="

echo

echo "=== Candidate files mentioning artifact preview/rendering ==="

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=backups \

  "artifact\|preview\|sanitize\|innerHTML\|markdown\|\\n" \

  public routes src server.ts 2>/dev/null | head -200

echo

echo "=== Known renderer bridge files ==="

find public src routes -type f 2>/dev/null | grep -Ei 'render|preview|artifact|phase530|semantic|markdown' | sort

