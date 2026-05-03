#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-}"
NOTE="${2:-}"

mkdir -p docs

if [ -n "$RESULT" ]; then
  case "$RESULT" in
    INLINE_STYLE_FREE_SHELL_STABLE|INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
      ;;
    *)
      echo "Invalid result: $RESULT"
      exit 1
      ;;
  esac

  cat > docs/phase474_6_inline_style_free_shell_result.txt <<EOT
PHASE 474.6 — INLINE-STYLE-FREE SHELL RESULT
============================================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT
fi

echo "=== STAGING CHECK ==="
ls -1 scripts/phase474_5_observe_inline_style_free_shell.sh 2>/dev/null || true
ls -1 scripts/phase474_6_record_inline_style_free_shell_result.sh 2>/dev/null || true
ls -1 docs/phase474_5_observe_inline_style_free_shell.txt 2>/dev/null || true
ls -1 docs/phase474_6_inline_style_free_shell_result.txt 2>/dev/null || true
ls -1 docs/phase474_0_observe_styled_shell_result.txt 2>/dev/null || true
echo

git add \
  scripts/phase474_5_observe_inline_style_free_shell.sh \
  scripts/phase474_6_record_inline_style_free_shell_result.sh \
  docs/phase474_5_observe_inline_style_free_shell.txt \
  docs/phase474_6_inline_style_free_shell_result.txt \
  docs/phase474_0_observe_styled_shell_result.txt

git status --short

git commit -m "Phase 474.5 stage inline-style-free shell observation artifacts and optional result capture"
git push
