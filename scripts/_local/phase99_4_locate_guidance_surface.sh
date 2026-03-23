#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

rm -f scripts/_local/phase99_4_guidance_confidence_patch.py

echo "GUIDANCE FILES"
find src -type f \( -iname '*guidance*.ts' -o -path '*/guidance/*' \) | sort

echo
echo "OPERATOR COGNITION FILES"
find src -type f \( -iname '*operator*.ts' -o -iname '*situation*.ts' -o -iname '*summary*.ts' \) | sort
