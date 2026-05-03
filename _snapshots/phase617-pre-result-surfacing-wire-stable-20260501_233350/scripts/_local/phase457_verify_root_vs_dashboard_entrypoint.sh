#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/44_root_vs_dashboard_entrypoint_proof.txt"

CANDIDATES=(
  "3e320f1b3628bb6ada53daf5b76f9acf311d1df5|8131|Phase 62 move Agent Pool beside System Metrics"
  "ee8ea4f820b46206a3c5dbe172454e8f8d368ea6|8132|Phase 65 restore dashboard layout-bearing files"
  "e190b90dc788bc889f1fe5f9f9db147139e43498|8133|Phase 64.4 interactive dashboard baseline"
  "5a8bf4228d45145c920dbf217a80af01319bc4e9|8134|Phase 96 operator guidance"
)

{
  echo "PHASE 457 - ROOT VS DASHBOARD ENTRYPOINT PROOF"
  echo "=============================================="
  echo
  echo "PURPOSE"
  echo "Prove whether we have been visually checking the wrong served page."
  echo "Specifically:"
  echo "- / may be serving public/index.html"
  echo "- /dashboard.html may be serving the true remembered shell from public/dashboard.html"
  echo
} > "$OUT"

for item in "${CANDIDATES[@]}"; do
  IFS='|' read -r SHA PORT LABEL <<< "$item"
  WT="../mbhq_recovery_visual_compare/entry_${SHA}"
  LOG="docs/recovery_full_audit/entry_${SHA}_boot.txt"

  rm -rf "$WT" || true
  git worktree add "$WT" "$SHA" >/dev/null

  (
    cd "$WT"

    python3 - <<'PY'
from pathlib import Path
p = Path("docker-compose.yml")
t = p.read_text()
lines = t.splitlines()
out = []
in_dashboard = False
in_postgres = False
skip_ports = False
for line in lines:
    stripped = line.strip()
    if line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
        in_dashboard = stripped == "dashboard:"
        in_postgres = stripped == "postgres:"
        skip_ports = False
    if (in_dashboard or in_postgres) and line.startswith("    ports:"):
        skip_ports = True
        continue
    if skip_ports:
        if line.startswith("      ") or stripped == "":
            continue
        skip_ports = False
    out.append(line)
p.write_text("\n".join(out) + "\n")
PY

    cat > docker-compose.override.yml <<OVERRIDE
services:
  dashboard:
    ports:
      - "${PORT}:3000"
  postgres:
    ports: []
OVERRIDE

    docker compose -f docker-compose.yml -f docker-compose.override.yml down -v --remove-orphans || true
    docker compose -f docker-compose.yml -f docker-compose.override.yml up -d postgres
    sleep 6

    docker compose -f docker-compose.yml -f docker-compose.override.yml exec -T postgres psql -U postgres -d postgres <<'SQL'
create table if not exists tasks (
  id serial primary key,
  task_id text,
  title text,
  status text,
  created_at timestamptz default now()
);

create table if not exists task_events (
  id bigserial primary key,
  task_id text,
  run_id text,
  kind text,
  status text,
  actor text,
  message text,
  created_at timestamptz default now()
);
SQL

    docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d dashboard
    sleep 8

    ROOT_HTML="$(mktemp)"
    DASH_HTML="$(mktemp)"
    curl -L --max-time 10 "http://localhost:${PORT}/" > "$ROOT_HTML" 2>/dev/null || true
    curl -L --max-time 10 "http://localhost:${PORT}/dashboard.html" > "$DASH_HTML" 2>/dev/null || true

    {
      echo "SHA=$SHA"
      echo "LABEL=$LABEL"
      echo "PORT=$PORT"
      echo

      echo "--- tracked file hashes ---"
      printf 'index.html: '
      shasum -a 256 public/index.html
      printf 'dashboard.html: '
      shasum -a 256 public/dashboard.html
      echo

      echo "--- served / hash ---"
      [ -s "$ROOT_HTML" ] && shasum -a 256 "$ROOT_HTML" || echo "MISSING"
      echo

      echo "--- served /dashboard.html hash ---"
      [ -s "$DASH_HTML" ] && shasum -a 256 "$DASH_HTML" || echo "MISSING"
      echo

      echo "--- served / markers ---"
      grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|Project Visual Output|Critical Ops Alerts|System Reflections|output-display|Agent Pool|Atlas Subsystem Status|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History' "$ROOT_HTML" | sort -u || true
      echo

      echo "--- served /dashboard.html markers ---"
      grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|Project Visual Output|Critical Ops Alerts|System Reflections|output-display|Agent Pool|Atlas Subsystem Status|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History' "$DASH_HTML" | sort -u || true
      echo

      echo "--- served / title ---"
      grep -o '<title>[^<]*</title>' "$ROOT_HTML" | head -n 1 || true
      echo

      echo "--- served /dashboard.html title ---"
      grep -o '<title>[^<]*</title>' "$DASH_HTML" | head -n 1 || true
      echo

      echo "--- URLs ---"
      echo "ROOT_URL=http://localhost:${PORT}/"
      echo "DASH_URL=http://localhost:${PORT}/dashboard.html"
    } > "$ROOT/$LOG"

    rm -f "$ROOT_HTML" "$DASH_HTML"
  ) || true

  {
    echo "===== $SHA ====="
    echo "LABEL=$LABEL"
    echo "LOG=$LOG"
    sed -n '1,160p' "$LOG" || true
    echo
  } >> "$OUT"
done

open "http://localhost:8131/dashboard.html" || true
open "http://localhost:8132/dashboard.html" || true
open "http://localhost:8133/dashboard.html" || true
open "http://localhost:8134/dashboard.html" || true

sed -n '1,360p' "$OUT"
