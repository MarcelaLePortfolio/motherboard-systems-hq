#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--stdin" ]]; then
  npx tsx scripts/phase87_17_system_situation_summary_cli.ts --stdin
  exit 0
fi

if [[ "${1:-}" == "--file" ]]; then
  JSON_FILE="${2:-}"
  if [[ -z "$JSON_FILE" ]]; then
    echo "Missing file path after --file" >&2
    exit 1
  fi

  npx tsx scripts/phase87_17_system_situation_summary_cli.ts --file "$JSON_FILE"
  exit 0
fi

SIGNALS_JSON="${1:-{}}"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}

trap cleanup EXIT

printf '%s\n' "$SIGNALS_JSON" > "$TMP_FILE"
npx tsx scripts/phase87_17_system_situation_summary_cli.ts --file "$TMP_FILE"
