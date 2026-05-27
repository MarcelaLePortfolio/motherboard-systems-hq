#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

mkdir -p .artifacts

output=".artifacts/phase61_workspace_inventory.txt"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  echo "PHASE 61 WORKSPACE INVENTORY"
  echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo

  echo "== Dashboard / bundle / static candidates (bounded) =="
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './dist' -o -path './build' -o -path './coverage' -o -path './.artifacts' \) -prune \
    -o -type f \
    \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' \) \
    -print \
    | sort \
    | grep -E 'dashboard|bundle|static|public|css|matilda|delegat|atlas|recent|task|activity|operator|workspace|probe|event' \
    | head -n 400
  echo

  echo "== Candidate references: dashboard shell terms (bounded) =="
  grep -RInE \
    'Matilda|Delegation|Recent Tasks|Task Activity Over Time|Atlas|operator|workspace|probe|event stream|Agent Pool|metrics' \
    . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=dist \
    --exclude-dir=build \
    --exclude-dir=coverage \
    --exclude-dir=.artifacts \
    --exclude='*.map' \
    | head -n 500 || true
  echo

  echo "== Existing Phase 60 live polish assets =="
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './.artifacts' \) -prune \
    -o -type f \
    \( -path '*phase60*' -o -name '*phase60*' \) \
    -print \
    | sort \
    | head -n 100
  echo

  echo "== Top-level app/static directories =="
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './.artifacts' \) -prune \
    -o -maxdepth 3 -type d \
    \( -name 'public' -o -name 'static' -o -name 'src' -o -name 'dashboard' -o -name 'css' -o -name 'js' \) \
    -print \
    | sort \
    | head -n 200
} > "$tmp"

mv "$tmp" "$output"

"$repo_root/scripts/enforce_artifact_guard.sh"

printf '%s\n' "$output"
