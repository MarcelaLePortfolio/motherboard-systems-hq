#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c1c1692f2"
OUTPUT="docs/checkpoints/APPROVED_PACKAGE_BLANK_RENDER_DIAGNOSIS.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

bash diagnose-approved-package-blank-render.sh > "$OUTPUT" 2>&1

cat "$OUTPUT"

git diff --check -- "$OUTPUT"
git add -- "$OUTPUT"
git commit -m "Capture approved package blank render diagnosis"
git push origin "$BRANCH"
