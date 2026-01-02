
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== Phase 16.3 post-merge verify ==="

echo
echo "1) Confirm branch + tags"
git --no-pager log -1 --oneline
git tag --points-at HEAD | rg -n 'v16\.3' || true

echo
echo "2) Confirm dashboard has single indicator + script, and no empty src scripts"
rg -n 'phase16-sse-indicator|phase16_sse_status_indicator\.js' public/dashboard.html
rg -n '<script[^>]*\bsrc\s*=\s*""|<script[^>]*\bsrc\s*=\s*'\'''\''' public/dashboard.html && {
  echo "ERROR: found empty src script tag(s)"; exit 1;
} || echo "✅ no empty script src tags"

echo
echo "3) Confirm indicator JS exists"
test -f public/js/phase16_sse_status_indicator.js && echo "✅ indicator JS present"

echo
echo "4) Quick runtime sanity (endpoints should exist and respond)"
curl -fsS -I http://127.0.0.1:8080/events/ops | head -n 1 || true
curl -fsS -I http://127.0.0.1:8080/events/reflections | head -n 1 || true

echo
echo "DONE ✅"
