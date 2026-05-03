#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

SHORTLIST="docs/recovery_full_audit/34_visual_shell_candidate_shortlist.txt"
MATRIX="docs/recovery_full_audit/35_shell_candidate_boot_matrix.txt"

python3 - <<'PY'
from pathlib import Path
import re

root = Path.cwd()
scan = root / "docs/recovery_full_audit/33_actual_layout_divergence_scan.txt"
out = root / "docs/recovery_full_audit/34_visual_shell_candidate_shortlist.txt"

text = scan.read_text() if scan.exists() else ""

commits = []
seen = set()

patterns = [
    r'([0-9a-f]{8,40})\s+.*(?:phase 58|phase 59|phase 60|phase 61|phase 62|phase 63|phase 64|phase 65|phase 88|phase 90|phase 96|workspace|layout|operator console|guidance|restore|dashboard html|shell|atlas|tabs)',
    r'([0-9a-f]{8,40})\s+.*(?:public/index\.html|public/dashboard\.html)',
]

for line in text.splitlines():
    low = line.lower()
    if not re.search(r'[0-9a-f]{8,40}', line):
        continue
    if any(term in low for term in [
        "phase 58", "phase 59", "phase 60", "phase 61", "phase 62", "phase 63",
        "phase 64", "phase 65", "phase 88", "phase 90", "phase 96",
        "workspace", "layout", "operator console", "guidance", "restore",
        "dashboard html", "shell", "atlas", "tabs"
    ]):
        m = re.search(r'([0-9a-f]{8,40})', line)
        if m:
            sha = m.group(1)
            if sha not in seen:
                seen.add(sha)
                commits.append((sha, line.strip()))

# fallback if scan parsing yields nothing
if not commits:
    fallback = [
        ("8049baef", "Phase 63 — restore stable dashboard html and lock dark background"),
        ("ee8ea4f8", "Phase 65: restore dashboard layout-bearing files from v63 golden checkpoint"),
        ("5617ea98", "mount phase 90.8 operator guidance panel in matilda workspace"),
        ("4c55719f", "fix phase 90.8 operator guidance visibility in matilda workspace"),
        ("5a8bf422", "Phase 96: Complete operator guidance design intent — wire SSE stream into Matilda operator workspace panel"),
    ]
    commits = fallback

# keep top 5 unique
commits = commits[:5]

with out.open("w") as f:
    f.write("PHASE 457 - VISUAL SHELL CANDIDATE SHORTLIST\n")
    f.write("============================================\n\n")
    f.write("Derived from docs/recovery_full_audit/33_actual_layout_divergence_scan.txt\n\n")
    for sha, line in commits:
        f.write(f"{sha} | {line}\n")
PY

CANDIDATES="$(awk -F'|' '/^[0-9a-f]{8,40} \|/ {gsub(/ /,"",$1); print $1}' "$SHORTLIST" | head -n 5)"

{
  echo "PHASE 457 - SHELL CANDIDATE BOOT MATRIX"
  echo "======================================="
  echo
  echo "SOURCE_SHORTLIST=$SHORTLIST"
  echo
} > "$MATRIX"

PORT=8100

for SHA in $CANDIDATES
do
  PORT=$((PORT+1))
  WT="../mbhq_recovery_visual_compare/shell_${SHA}"

  {
    echo "===== $SHA ====="
    echo "WORKTREE=$WT"
    echo "PORT=$PORT"
  } >> "$MATRIX"

  git worktree remove "$WT" --force 2>/dev/null || true
  rm -rf "$WT" || true
  git worktree add "$WT" "$SHA"

  (
    set -euo pipefail
    cd "$WT"

    python3 - <<'PY'
from pathlib import Path
p = Path("docker-compose.yml")
if p.exists():
    text = p.read_text()
    text = text.replace('- "5432:5432"\n', '')
    text = text.replace('- 5432:5432\n', '')
    p.write_text(text)
PY

    cat > docker-compose.override.yml <<OVERRIDE
services:
  dashboard:
    ports:
      - "${PORT}:3000"
  postgres:
    ports: []
OVERRIDE

    docker compose down -v --remove-orphans || true
    docker compose up -d postgres
    sleep 6

    docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'
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

    docker compose up --build -d dashboard
    sleep 8

    {
      echo "--- compose ps -a ---"
      docker compose ps -a || true
      echo
      echo "--- dashboard logs ---"
      docker compose logs dashboard --tail=80 || true
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
        grep -Eo 'Operator Console|Guidance|Workspace|Atlas|Task Delegation|Agent Pool|Matilda Chat Console|Recent Tasks|Task Activity Over Time|Probe lifecycle' | \
        sort -u || true
      echo
      echo "--- url ---"
      echo "http://localhost:${PORT}"
    } > "$ROOT/docs/recovery_full_audit/shell_${SHA}_boot.txt" 2>&1 || true
  ) || true

  {
    echo "LOG=docs/recovery_full_audit/shell_${SHA}_boot.txt"
    sed -n '1,120p' "docs/recovery_full_audit/shell_${SHA}_boot.txt" || true
    echo
  } >> "$MATRIX"

done

sed -n '1,240p' "$SHORTLIST"
printf '\n\n'
sed -n '1,320p' "$MATRIX"
