#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 76 — PLAYBOOK SMOKE"

tsx scripts/_local/phase76_playbook_smoke.ts

echo "PHASE 76 PLAYBOOK SMOKE COMPLETE"
