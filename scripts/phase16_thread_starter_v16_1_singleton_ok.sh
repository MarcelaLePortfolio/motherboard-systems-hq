set -euo pipefail
cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "=== Phase16 Thread Starter (v16.1 singleton OK) ==="
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "HEAD:   $(git --no-pager log -1 --oneline)"
echo

echo "=== Confirm stable tag exists locally + on origin ==="
git show-ref --tags | rg -n "v16\.1-phase16-ops-reflections-singleton-ok" || true
git ls-remote --tags origin | rg -n "v16\.1-phase16-ops-reflections-singleton-ok" || true
echo

echo "=== Confirm /dashboard includes owner + bundle (order matters) ==="
rg -n --hidden --no-ignore -S "phase16_sse_owner_ops_reflections\\.js|bundle\\.js" public/dashboard.html | tail -n 8 || true
echo

echo "=== Confirm no owner-started null EventSource ternaries remain ==="
rg -n --hidden --no-ignore -S "__PHASE16_SSE_OWNER_STARTED\\s*\\?\\s*null\\s*:\\s*new EventSource" public/bundle.js || echo "✅ none"
echo

echo "=== Quick SSE headers ==="
curl -sS -I "http://127.0.0.1:8080/events/ops" | head -n 5 || true
curl -sS -I "http://127.0.0.1:8080/events/reflections" | head -n 5 || true
echo

echo "=== Quick connect snapshots (short) ==="
( curl -sS -N "http://127.0.0.1:8080/events/ops" | head -n 6 ) || true
( curl -sS -N "http://127.0.0.1:8080/events/reflections" | head -n 6 ) || true
echo

echo "=== Handoff doc ==="
ls -la PHASE16_v16.1_SINGLETON_OK_HANDOFF.md
echo
echo "DONE. Open /dashboard and paste the probe from the handoff doc into DevTools."
