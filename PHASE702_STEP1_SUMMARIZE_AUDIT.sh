#!/usr/bin/env bash
set -euo pipefail

git add PHASE702_STEP1_SUMMARIZE_AUDIT.sh
git commit -m "Phase 702: add audit summary helper script"
git push

git status --short
