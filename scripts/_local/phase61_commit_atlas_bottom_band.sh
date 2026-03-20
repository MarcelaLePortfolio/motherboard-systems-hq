#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add public/dashboard.html
git commit -m "Move Atlas subsystem card to full-width bottom band"
git push
