#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

SHORTLIST="docs/recovery_full_audit/34_visual_shell_candidate_shortlist.txt"
OUT="docs/recovery_full_audit/37_shell_candidates_after_base_8080_removal.txt"

if [ ! -f "$SHORTLIST" ]; then
  echo "MISSING_SHORTLIST=$SHORTLIST" > "$OUT"
  exit 1
fi

SHAS="$(awk -F'|' '/^[0-9a-f]{8,40} \|/ {gsub(/ /,"",$1); print $1}' "$SHORTLIST" | head -n 5)"

{
  echo "PHASE 457 - SHELL CANDIDATES AFTER BASE 8080 REMOVAL"
  echo "===================================================="
  echo
  echo "PURPOSE"
  echo "Remove the inherited dashboard 8080 binding from shell candidate worktrees,"
  echo "then relaunch each candidate on its own isolated host port."
  echo
  echo "KNOWN FAILURE JUST PROVED"
  echo "Each shell candidate still inherited published: 8080 from base docker-compose.yml,"
  echo "so adding 8101/8102/etc. was not enough."
  echo
} > "$OUT"

PORT=8100

for SHA in $SHAS
do
  PORT=$((PORT + 1))
  WT="../mbhq_recovery_visual_compare/shell_${SHA}"
  LOG="docs/recovery_full_audit/shell_${SHA}_base_8080_removed.txt"

  {
    echo "===== $SHA ====="
    echo "WORKTREE=$WT"
    echo "PORT=$PORT"
    echo
  } >> "$OUT"

  if [ ! -d "$WT" ]; then
    {
      echo "--- status ---"
      echo "MISSING_WORKTREE"
      echo
    } > "$LOG"
    {
      echo "LOG=$LOG"
      sed -n '1,120p' "$LOG"
      echo
    } >> "$OUT"
    continue
  fi

  (
    set -euo pipefail
    cd "$WT"

    python3 - <<'PY'
from pathlib import Path

p = Path("docker-compose.yml")
text = p.read_text()

lines = text.splitlines()
out = []
in_dashboard = False
skip_ports = False

for line in lines:
    stripped = line.strip()

    if line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
        in_dashboard = (stripped == "dashboard:")
        skip_ports = False

    if in_dashboard and line.startswith("    ports:"):
        skip_ports = True
        continue

    if skip_ports:
        if line.startswith("      ") or stripped == "":
            continue
        skip_ports = False

    out.append(line)

text = "\n".join(out) + "\n"
while "\n\n\n" in text:
    text = text.replace("\n\n\n", "\n\n")

p.write_text(text)
PY

    rm -f docker-compose.override.yml docker-compose.phase457.override.yml

    cat > docker-compose.phase457.port.override.yml <<OVERRIDE
services:
  dashboard:
    ports:
      - "${PORT}:3000"
  postgres:
    ports: []
OVERRIDE

    echo "--- compose config ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml config

    echo
    echo "--- compose down ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml down -v --remove-orphans || true

    echo
    echo "--- start postgres ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml up -d postgres
    sleep 6
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml ps -a

    echo
    echo "--- seed runtime tables ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml exec -T postgres psql -U postgres -d postgres <<'SQL'
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

    echo
    echo "--- start dashboard ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml up --build -d dashboard
    sleep 8

    echo
    echo "--- compose ps -a ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml ps -a || true

    echo
    echo "--- dashboard logs ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml logs dashboard --tail=80 || true

    echo
    echo "--- postgres logs ---"
    docker compose -f docker-compose.yml -f docker-compose.phase457.port.override.yml logs postgres --tail=60 || true

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
    echo "--- markers ---"
    curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | \
      grep -Eo 'Operator Console|Guidance|Workspace|Atlas|Task Delegation|Agent Pool|Matilda Chat Console|Recent Tasks|Task Activity Over Time|Probe lifecycle|Critical Ops Alerts|System Reflections' | \
      sort -u || true

    echo
    echo "--- url ---"
    echo "http://localhost:${PORT}"
  ) > "$ROOT/$LOG" 2>&1 || true

  {
    echo "LOG=$LOG"
    sed -n '1,160p' "$LOG"
    echo
  } >> "$OUT"
done

sed -n '1,360p' "$OUT"
