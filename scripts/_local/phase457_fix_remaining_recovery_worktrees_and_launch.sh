#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

WT_BASE="../mbhq_recovery_visual_compare"

TARGETS=(
  "phase65_layout|recovery/phase65_layout|8081|mbhq_phase65_layout"
  "phase65_wiring|recovery/phase65_wiring|8082|mbhq_phase65_wiring"
  "operator_guidance|recovery/operator_guidance|8083|mbhq_operator_guidance"
)

fix_compose() {
  local wt_path="$1"

  cd "$wt_path"

  if [ ! -f docker-compose.yml ]; then
    echo "MISSING docker-compose.yml in $wt_path"
    return 1
  fi

  cp docker-compose.yml docker-compose.yml.pre_phase457_fix 2>/dev/null || true

  python3 - <<'PY'
from pathlib import Path

p = Path("docker-compose.yml")
lines = p.read_text().splitlines()

out = []
in_postgres = False
skip_ports = False

for line in lines:
    stripped = line.strip()

    if line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
        if stripped == "postgres:":
            in_postgres = True
            skip_ports = False
        else:
            in_postgres = False
            skip_ports = False

    if in_postgres and line.startswith("    ports:"):
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

  cat > docker-compose.override.yml <<OVERRIDE
services:
  postgres:
    ports: []
  dashboard:
    ports:
      - "8080:3000"
OVERRIDE

  docker compose down -v --remove-orphans || true
  cd "$ROOT"
}

launch_target() {
  local name="$1"
  local branch="$2"
  local port="$3"
  local project="$4"
  local wt_path="$WT_BASE/$name"
  local log="$ROOT/docs/recovery_full_audit/${name}_phase457_launch.txt"

  {
    echo "NAME=$name"
    echo "BRANCH=$branch"
    echo "WORKTREE=$wt_path"
    echo "PORT=$port"
    echo "PROJECT=$project"
    echo

    if [ ! -d "$wt_path" ]; then
      echo "WORKTREE_MISSING -> creating"
      git worktree add "$wt_path" "$branch"
    fi

    echo "--- fixing compose ---"
    fix_compose "$wt_path"

    cd "$wt_path"

    cat > docker-compose.phase457.port.override.yml <<PORTOVERRIDE
services:
  postgres:
    ports: []
  dashboard:
    ports:
      - "${port}:3000"
PORTOVERRIDE

    echo "--- compose up ---"
    COMPOSE_PROJECT_NAME="$project" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.port.override.yml \
      down -v --remove-orphans || true

    COMPOSE_PROJECT_NAME="$project" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.port.override.yml \
      up --build -d

    sleep 8

    echo
    echo "--- compose ps ---"
    COMPOSE_PROJECT_NAME="$project" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.port.override.yml \
      ps -a || true

    echo
    echo "--- dashboard logs ---"
    COMPOSE_PROJECT_NAME="$project" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.port.override.yml \
      logs dashboard --tail=80 || true

    echo
    echo "--- postgres logs ---"
    COMPOSE_PROJECT_NAME="$project" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.port.override.yml \
      logs postgres --tail=40 || true

    echo
    echo "--- port listen ---"
    lsof -nP -iTCP:"$port" -sTCP:LISTEN || true

    echo
    echo "--- http head ---"
    curl -I --max-time 10 "http://localhost:${port}" || true

    echo
    echo "--- title ---"
    curl -L --max-time 10 "http://localhost:${port}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true

    cd "$ROOT"
  } > "$log" 2>&1 || true
}

for item in "${TARGETS[@]}"; do
  IFS='|' read -r name branch port project <<< "$item"
  launch_target "$name" "$branch" "$port" "$project"
done

cat > docs/recovery_full_audit/25_recovery_compare_ready_urls.txt <<READYEOF
PHASE 457 - RECOVERY COMPARE READY URLS
=======================================

phase65_layout      -> http://localhost:8081
phase65_wiring      -> http://localhost:8082
operator_guidance   -> http://localhost:8083

Logs:
- docs/recovery_full_audit/phase65_layout_phase457_launch.txt
- docs/recovery_full_audit/phase65_wiring_phase457_launch.txt
- docs/recovery_full_audit/operator_guidance_phase457_launch.txt
READYEOF

open "http://localhost:8081" || true
open "http://localhost:8082" || true
open "http://localhost:8083" || true

echo "DONE"
