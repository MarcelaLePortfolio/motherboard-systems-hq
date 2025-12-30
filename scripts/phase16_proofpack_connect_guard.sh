
set -euo pipefail

echo "=== A) Guards present in source ==="
rg -n 'Phase16: bail if SSE owner already started|Phase16: guard null EventSource before handlers|__PHASE16_SSE_OWNER_STARTED' public/js/dashboard-status.js

echo
echo "=== B) Exact null-guard line (zsh-safe) ==="
set +H 2>/dev/null || true
rg -n 'if \(!es\) return null;' public/js/dashboard-status.js

echo
echo "=== C) CustomEvent dispatch line present ==="
rg -n 'dispatchEvent\(new CustomEvent\(`mb:\$\{key\}:update`' public/js/dashboard-status.js

echo
echo "=== D) SSE headers probe ==="
curl -fsS -D- -o /dev/null -H "Accept: text/event-stream" "http://127.0.0.1:8080/events/ops" | sed -n '1,12p'

echo
echo "=== E) Dashboard logs clean ==="
docker compose logs --tail=200 dashboard | rg -n "Cannot set properties of null|TypeError|dashboard-status|onopen" && exit 1 || echo "✅ clean"

echo
echo "=== F) Browser console helper ==="
echo "Open: http://127.0.0.1:8080/dashboard"
cat <<'JS'
window.__mbOpsSeen = 0;
window.addEventListener("mb:ops:update", (e) => {
  window.__mbOpsSeen++;
  console.log("mb:ops:update", window.__mbOpsSeen, e.detail?.event, e.detail?.state);
});
JS
