#!/usr/bin/env bash
set -euo pipefail

git add PHASE702_STEP3_LABEL_DEMO_UI.sh
git commit -m "Phase 702: add demo UI labeling script"
git push

git status --short
