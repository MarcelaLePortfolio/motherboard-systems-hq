#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit
WT_BASE="../mbhq_recovery_visual_compare"

CANDIDATES=(
  "cba8b3c0|8121|Consolidate operator column into tabbed workspace"
  "74a241ca|8122|Phase 61: consolidate operator workspace layout"
  "df791714|8123|Phase 61: add observational workspace tab system"
  "d2601c1e|8124|Phase 61: convert telemetry column into tabbed observational workspace"
  "9c68c540|8125|Restore Phase 61 dashboard to last good visual state"
)

SUMMARY="docs/recovery_full_audit/41_true_tabbed_workspace_candidate_boots.txt"
: > "$SUMMARY"

for item in "${CANDIDATES[@]}"; do
  IFS='|' read -r SHA PORT LABEL <<< "$item"
  WT="$WT_BASE/tabbed_${SHA}"
  LOG="$ROOT/docs/recovery_full_audit/tabbed_${SHA}_boot.txt"

  rm -rf "$WT" || true
  git worktree add "$WT" "$SHA" >/dev/null

  (
    cd "$WT"

    python3 - <<'PY'
from pathlib import Path
p = Path("docker-compose.yml")
if p.exists():
    t = p.read_text()
    lines = t.splitlines()
    out = []
    in_dashboard = False
    in_postgres = False
    skip_ports = False
    dash_port_block_done = False
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

    {
      echo "SHA=$SHA"
      echo "LABEL=$LABEL"
      echo "WORKTREE=$WT"
      echo "PORT=$PORT"
      echo

      echo "--- compose ps -a ---"
      docker compose -f docker-compose.yml -f docker-compose.override.yml ps -a || true
      echo

      echo "--- dashboard logs ---"
      docker compose -f docker-compose.yml -f docker-compose.override.yml logs dashboard --tail=100 || true
      echo

      echo "--- port listen ---"
      lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN || true
      echo

      echo "--- http headers ---"
      curl -I --max-time 10 "http://localhost:${PORT}" || true
      echo

      echo "--- title ---"
      curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true
      echo

      echo "--- visual markers ---"
      curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | \
        grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History|Agent Pool|Atlas Subsystem Status|Critical Ops Alerts|System Reflections' | \
        sort -u || true
      echo

      echo "--- tab ids ---"
      curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | \
        grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|operator-workspace-card|observational-workspace-card' | \
        sort -u || true
      echo

      echo "--- url ---"
      echo "http://localhost:${PORT}"
    } > "$LOG" 2>&1
  ) || true

  {
    echo "===== $SHA ====="
    echo "LABEL=$LABEL"
    echo "URL=http://localhost:${PORT}"
    echo "LOG=docs/recovery_full_audit/tabbed_${SHA}_boot.txt"
    echo
    sed -n '1,160p' "$LOG" || true
    echo
  } >> "$SUMMARY"
done

open "http://localhost:8121" || true
open "http://localhost:8122" || true
open "http://localhost:8123" || true
open "http://localhost:8124" || true
open "http://localhost:8125" || true

sed -n '1,360p' "$SUMMARY"
