#!/usr/bin/env bash
set -euo pipefail

SIGNALS_JSON="${1:-{}}"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}

trap cleanup EXIT

printf '%s\n' "$SIGNALS_JSON" > "$TMP_FILE"
npx tsx scripts/phase87_13_situation_summary_cli.ts --file "$TMP_FILE"
