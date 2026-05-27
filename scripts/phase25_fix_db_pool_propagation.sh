
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="server.mjs"
if [[ ! -f "$TARGET" ]]; then
  echo "ERROR: $TARGET not found at repo root."
  exit 2
fi

echo "=== phase25: before ==="
rg -n 'new\s+Pool\s*\(|__DB_POOL' "$TARGET" || true

if rg -n '__DB_POOL' "$TARGET" >/dev/null 2>&1; then
  echo "OK: __DB_POOL already set"
else
  perl -0777 -i -pe '
    my $did = 0;
    if (!$did) {
      $did = s{
        ((?:const|let)\s+([A-Za-z_]\w*)\s*=\s*new\s+Pool\s*\([\s\S]*?\);\s*\n)
      }{$1."globalThis.__DB_POOL = $2;\n"}e;
    }
    if (!$did) {
      die "phase25 patch FAILED: could not locate Pool init\n";
    }
  ' "$TARGET"
fi

echo "=== phase25: after ==="
rg -n '__DB_POOL' "$TARGET" || true
