
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"


ROUTE_FILE="$(rg -n '/api/tasks/create|api/tasks/create' -S server public . \
  | cut -d: -f1 | head -n1 || true)"

if [[ -z "${ROUTE_FILE:-}" || ! -f "$ROUTE_FILE" ]]; then
  echo "ERROR: could not locate file defining /api/tasks/create"
  echo "Try: rg -n '/api/tasks/create|api/tasks/create' -S server"
  exit 2
fi
echo "=== target route file ==="
echo "$ROUTE_FILE"
echo
echo "=== show emitTaskEvent usage in route file ==="
rg -n 'emitTaskEvent\(|/api/tasks/create|api/tasks/create' "$ROUTE_FILE" || true
echo
echo "=== patch route: pass pool through to emitTaskEvent ==="
perl -0777 -i -pe '
  my $did = 0;
  if (!$did) {
    $did = s{
      (\n[ \t]*)(await\s+emitTaskEvent\s*\(\s*\{\s*)
    }{$1."const __pool = (globalThis.__DB_POOL || req.app?.locals?.pool || req.app?.locals?.__DB_POOL || null);\n$1"."console.log(\"[phase25] route /api/tasks/create pool\", { hasGlobal: !!globalThis.__DB_POOL, hasLocalsPool: !!req.app?.locals?.pool, hasLocalsDBPool: !!req.app?.locals?.__DB_POOL });\n$1$2"}gex;
  }
  if ($did) {
    s{
      (await\s+emitTaskEvent\s*\(\s*\{\s*)
    }{$1."pool: __pool,\n"}gex;
  } else {
    die "phase25 patch FAILED: could not find `await emitTaskEvent({` in route file\n";
  }
' "$ROUTE_FILE"

echo
echo "=== patch server.mjs: also stash pool on app.locals.pool (for req.app.locals.pool fallback) ==="
TARGET="server.mjs"
if rg -n 'globalThis\.__DB_POOL\s*=\s*pool' "$TARGET" >/dev/null 2>&1; then
  perl -0777 -i -pe '
    # After globalThis.__DB_POOL = pool; add app.locals.pool = pool; (only if not already present nearby)
    s{
      (globalThis\.__DB_POOL\s*=\s*pool;[^\n]*\n)
      (?![ \t]*app\.locals\.pool\s*=\s*pool;)
    }{$1."app.locals.pool = pool;\n"}e;
  ' "$TARGET"
else
  echo "WARN: server.mjs does not contain globalThis.__DB_POOL = pool; (skipping locals patch)"
fi
echo
echo "=== quick verify ==="
echo "--- server.mjs ---"
rg -n 'globalThis\.__DB_POOL|app\.locals\.pool' server.mjs || true
echo
echo "--- route file ---"
rg -n '\[phase25\] route /api/tasks/create pool|const __pool|pool:\s*__pool|emitTaskEvent\(' "$ROUTE_FILE" || true


echo
echo "DONE."
