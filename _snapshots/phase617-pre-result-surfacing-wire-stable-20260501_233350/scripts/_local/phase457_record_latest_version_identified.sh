#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

sed -n '1,220p' docs/recovery_full_audit/45_latest_version_identified.txt
