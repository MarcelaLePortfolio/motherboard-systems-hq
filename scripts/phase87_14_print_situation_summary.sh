#!/usr/bin/env bash
set -euo pipefail

SIGNALS_JSON="${1:-{}}"

SITUATION_SIGNALS_JSON="$SIGNALS_JSON" npx tsx scripts/phase87_13_situation_summary_cli.ts
