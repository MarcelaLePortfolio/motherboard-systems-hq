#!/usr/bin/env bash
set -euo pipefail

FILES=(
  "cade_delegate.js"
  "cade_reasoning.js"
  "cade_planner.cjs"
  "cade_heartbeat.cjs"
  "cade_runtime.ts"
  "matilda_runtime.mjs"
)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "== Redundancy Audit ($(date -u +'%Y-%m-%dT%H:%M:%SZ')) =="
echo "Repo: $ROOT"
echo

exists() { [[ -e "$1" ]]; }

search_refs() {
  local base="$1"
  grep -RIn --exclude-dir={.git,node_modules,dist,build,out} \
    -E "(from ['\"][^\"']*${base}['\"]|require\(['\"][^\"']*${base}['\"]\)|\\b${base}\\b)" . || true
}

for f in "${FILES[@]}"; do
  base_no_ext="${f%.*}"
  echo "-- ${f} --"
  if exists "$f"; then
    echo "Found: $f"
  elif exists "scripts/_local/${f}"; then
    f="scripts/_local/${f}"; echo "Found: $f"
  elif exists "scripts/_local/agent-runtime/${f}"; then
    f="scripts/_local/agent-runtime/${f}"; echo "Found: $f"
  elif exists "scripts/${f}"; then
    f="scripts/${f}"; echo "Found: $f"
  else
    echo "Not found in repo."
  fi

  # Redundancy notes
  case "$f" in
    *cade_runtime.ts)
      [[ -f "scripts/_local/agent-runtime/cade_runtime.ts" ]] &&
        echo "Note: TS replacement exists → cade_runtime.ts"
      ;;
    *matilda_runtime.mjs)
      [[ -f "scripts/_local/matilda_runtime.ts" ]] &&
        echo "Note: TS replacement exists → matilda_runtime.ts"
      ;;
  esac

  echo "Searching for references to '${base_no_ext}':"
  matches="$(search_refs "${base_no_ext}")"
  if [[ -n "$matches" ]]; then
    echo "$matches"
    echo "Verdict: REFERENCED — keep or consider migrating."
  else
    echo "None found."
    echo "Verdict: UNREFERENCED — safe to remove or archive."
  fi
  echo
done
