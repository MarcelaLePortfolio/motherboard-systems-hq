#!/usr/bin/env bash
set -euo pipefail

SIGNALS_JSON="${1:-{}}"
TMP_FILE="$(mktemp)"

printf '%s' "$SIGNALS_JSON" > "$TMP_FILE"
npx tsx scripts/phase87_13_situation_summary_cli.ts "$(cat "$TMP_FILE")"
rm -f "$TMP_FILE"
