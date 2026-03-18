#!/usr/bin/env bash
set -euo pipefail

SIGNALS_JSON="${1:-{}}"

npx tsx scripts/phase87_13_situation_summary_cli.ts "$SIGNALS_JSON"
