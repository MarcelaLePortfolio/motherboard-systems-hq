#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase477_7_observe_pure_structure_dashboard.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 477.7 — OBSERVE PURE-STRUCTURE DASHBOARD
==============================================

STATUS
- dashboard route is now serving with:
  • probe banners removed
  • inline scripts removed
  • src scripts removed
- this is the pure-structure isolation checkpoint

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Check:
   - does it remain stable?
   - is the structure still wrong?
   - is any loading behavior still visible?

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- SRC_SCRIPT_FREE_STABLE
- SRC_SCRIPT_FREE_BREAKS
- WHITE_SCREEN_RETURNED

OPTIONAL_NOTE
- brief note on what still looks structurally wrong
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
