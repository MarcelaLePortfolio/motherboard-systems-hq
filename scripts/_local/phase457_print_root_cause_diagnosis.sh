#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

sed -n '1,240p' docs/recovery_full_audit/39_root_cause_diagnosis.txt
