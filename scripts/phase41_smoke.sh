#!/usr/bin/env bash
set -euo pipefail

scripts/phase41_invariants_gate.sh

if [ -x scripts/phase41_scenario_matrix_dump.sh ]; then
  scripts/phase41_scenario_matrix_dump.sh | head -n 80
fi
