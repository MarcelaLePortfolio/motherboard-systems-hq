#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 77 — ADAPTIVE PLAYBOOK ORDERING SMOKE"

tsx scripts/_local/phase77_adaptive_playbook_ordering_smoke.ts

echo "PHASE 77 ADAPTIVE PLAYBOOK ORDERING SMOKE COMPLETE"
