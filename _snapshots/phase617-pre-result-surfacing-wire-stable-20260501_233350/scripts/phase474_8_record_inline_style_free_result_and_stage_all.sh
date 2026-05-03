#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE}"
NOTE="${2:-Page still becomes unresponsive after inline styles were removed.}"

case "$RESULT" in
  INLINE_STYLE_FREE_SHELL_STABLE|INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $RESULT"
    exit 1
    ;;
esac

mkdir -p docs

cat > docs/phase474_6_inline_style_free_shell_result.txt <<EOT
PHASE 474.6 — INLINE-STYLE-FREE SHELL RESULT
============================================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT

echo "Wrote docs/phase474_6_inline_style_free_shell_result.txt"
sed -n '1,120p' docs/phase474_6_inline_style_free_shell_result.txt

git add \
  scripts/phase474_5_observe_inline_style_free_shell.sh \
  scripts/phase474_6_record_inline_style_free_shell_result.sh \
  scripts/phase474_7_stage_observation_artifacts_and_record_result.sh \
  docs/phase474_0_observe_styled_shell_result.txt \
  docs/phase474_5_observe_inline_style_free_shell.txt \
  docs/phase474_6_inline_style_free_shell_result.txt

git status --short

git commit -m "Phase 474.8 record inline-style-free shell result and stage pending observation artifacts"
git push
