#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

bash scripts/_local/phase72_operator_guidance_smoke.sh
bash scripts/_local/phase65_pre_commit_protection_gate.sh
