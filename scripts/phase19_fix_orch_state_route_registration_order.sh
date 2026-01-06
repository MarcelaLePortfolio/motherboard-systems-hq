
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

SERVER_FILE="server.mjs"
test -f "$SERVER_FILE"


perl -0777 -i -pe '
  s/^\s*registerOrchestratorStateRoute\(app\);\s*\n//mg;
' "$SERVER_FILE"
perl -0777 -i -pe '
  if ($_ !~ /registerOrchestratorStateRoute\(app\)\s*;/) {
    $_ =~ s/(const\s+app\s*=\s*express\(\)\s*;\s*\n)/$1registerOrchestratorStateRoute(app);\n/s;
  }
' "$SERVER_FILE"

echo "=== Verify placement ==="
rg -n "const\\s+app\\s*=\\s*express\\(\\)\\s*;|registerOrchestratorStateRoute\\(app\\)" "$SERVER_FILE"
