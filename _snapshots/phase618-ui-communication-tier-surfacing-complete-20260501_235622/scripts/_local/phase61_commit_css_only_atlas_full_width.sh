#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add public/dashboard.html
git commit -m "Restore Atlas full-width with CSS-only change"
git push
