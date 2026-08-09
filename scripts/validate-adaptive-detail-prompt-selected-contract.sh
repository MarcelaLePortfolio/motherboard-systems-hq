#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — PROMPT + SELECTED SEGMENTS CONTRACT ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "51185ee8" ]]; then
  echo "STOP: HEAD no longer matches implementation baseline 51185ee8."
  exit 2
fi

echo
echo "=== TYPECHECK — ALLOW ESTABLISHED BASELINE DIAGNOSTICS ONLY ==="

set +e
typecheck_output="$(npx tsc --noEmit 2>&1)"
typecheck_rc=$?
set -e

printf '%s\n' "$typecheck_output"

if [[ "$typecheck_rc" -ne 0 ]]; then
  typecheck_errors="$(
    printf '%s\n' "$typecheck_output" |
    grep 'error TS' ||
    true
  )"

  unexpected_typecheck="$(
    printf '%s\n' "$typecheck_errors" |
    grep -Fv "routes/atlas/why.ts(32,54): error TS2554: Expected 2 arguments, but got 3." |
    grep -Fv "scripts/utils/ollamaChat.ts(858,26): error TS2339: Property 'relativePath' does not exist on type 'never'." |
    grep -Fv "scripts/utils/ollamaChat.ts(858,52): error TS2339: Property 'lineNumber' does not exist on type 'never'." ||
    true
  )"

  if [[ -n "$unexpected_typecheck" ]]; then
    echo
    echo "STOP: implementation introduced an unexpected TypeScript diagnostic:"
    printf '%s\n' "$unexpected_typecheck"
    exit 2
  fi

  baseline_count="$(
    printf '%s\n' "$typecheck_errors" |
    grep -c 'error TS' ||
    true
  )"

  if [[ "$baseline_count" -ne 3 ]]; then
    echo
    echo "STOP: TypeScript diagnostic set no longer matches the three established baseline errors."
    exit 2
  fi

  echo
  echo "KNOWN_BASELINE_TYPE_ERRORS_ONLY"
fi

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== EXISTING OLLAMA TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PROMPT_SELECTED_CONTEXT_CONTRACT_VALIDATION_PASSED"
echo "KNOWN_BASELINE_TYPESCRIPT_DIAGNOSTICS_PRESERVED"
echo "READY_TO_COMMIT"
