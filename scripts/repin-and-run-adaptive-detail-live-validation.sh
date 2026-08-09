#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

path="scripts/run-adaptive-detail-mixed-content-live-validation.sh"

python3 <<'PY'
from pathlib import Path

path = Path("scripts/run-adaptive-detail-mixed-content-live-validation.sh")
text = path.read_text()

old = "0a3251f5"
new = "33580c13"

count = text.count(old)

if count != 2:
    raise SystemExit(
        f"STOP: expected exactly two runner checkpoint references to {old}; found {count}."
    )

path.write_text(text.replace(old, new))
print("Repinned runner checkpoint to 33580c13.")
PY

git diff --check
git diff -- "$path"

git add "$path" scripts/repin-and-run-adaptive-detail-live-validation.sh
git commit -m "Repin Adaptive Detail live validation runner"
git push

./scripts/run-adaptive-detail-mixed-content-live-validation.sh
