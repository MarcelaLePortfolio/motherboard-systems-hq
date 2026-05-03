#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

open "http://localhost:8081" || true
open "http://localhost:8082" || true
open "http://localhost:8083" || true

printf "%s\n" \
"PHASE 457 - RECOVERY VISUAL COMPARE URLS" \
"=======================================" \
"" \
"phase65_layout      -> http://localhost:8081" \
"phase65_wiring      -> http://localhost:8082" \
"operator_guidance   -> http://localhost:8083" \
"" \
"Next step: visually compare all three and identify the exact desired checkpoint." \
> docs/recovery_full_audit/19_recovery_visual_compare_urls.txt
