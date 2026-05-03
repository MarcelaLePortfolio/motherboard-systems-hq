#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CURRENT_SHA="$(git rev-parse HEAD)"
RESCUE_REF="phase487-local-rescue-$(date +%Y%m%d_%H%M%S)"

git tag -f "$RESCUE_REF" "$CURRENT_SHA"

git fetch origin phase119-dashboard-cognition-contract
git reset --hard origin/phase119-dashboard-cognition-contract

rm -f docs/phase487_postgres_socket_and_db_url_probe.txt
rm -f docs/phase487_git_pack_bloat_trace.txt
rm -f logs/phase487_runtime_resume.log
rm -f public/index.html.phase487_pre_surgical_guidance_merge.bak
rm -f public/index.html.phase487_pre_bundle_transplant.bak
rm -f public/index.html.phase487_pre_disable_card_sync.bak
rm -f .git/index.lock .git/HEAD.lock .git/ORIG_HEAD.lock
find .git -name "*.lock" -delete 2>/dev/null || true

git checkout "$RESCUE_REF" -- public/index.html

python3 - << 'PY'
from pathlib import Path
gitignore = Path(".gitignore")
existing = gitignore.read_text(encoding="utf-8") if gitignore.exists() else ""
block = """
# Phase 487 local-generated artifacts
docs/phase487_postgres_socket_and_db_url_probe.txt
docs/phase487_git_pack_bloat_trace.txt
logs/phase487_runtime_resume.log
public/*.phase487_pre_*.bak
"""
if block.strip() not in existing:
    with gitignore.open("a", encoding="utf-8") as f:
        if existing and not existing.endswith("\n"):
            f.write("\n")
        f.write(block.lstrip("\n"))
PY

printf '\n===== POST-RESET STATUS =====\n'
git status --short

printf '\n===== VERIFY SERVED FILE MARKERS =====\n'
grep -nE 'Confidence: limited|PHASE 493|PHASE 494|PHASE 495|PHASE 496|PHASE 497|PHASE 498|PHASE 499|PHASE 509' public/index.html | head -n 40 || true

git add public/index.html .gitignore
git commit -m "phase487: rebuild branch without giant probe blob and preserve recovered index state"
git push origin HEAD:phase119-dashboard-cognition-contract
