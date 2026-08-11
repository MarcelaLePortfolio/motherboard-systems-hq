#!/usr/bin/env bash
set -euo pipefail

echo "=== IMPLEMENT MINIMUM SOURCE-EXCERPT-FIRST FIXED-SEED DIAGNOSTIC ADAPTATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLASSIFICATION CHECKPOINT ==="
expected_head="f91a74dd"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches source-excerpt fixed-seed classification checkpoint $expected_head."
  exit 2
fi

echo "SOURCE_EXCERPT_FIXED_SEED_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY IMPLEMENTATION AUTHORIZATION ==="
grep -nE \
  'AUTHORIZED_TARGET=|scripts/validate-source-excerpt-first-fixed-seed-live\.ts|FIXED_VALIDATION_SEED_424242_IN_DIAGNOSTIC_FIXTURE_ONLY|IMPLEMENT_MINIMUM_SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_ADAPTATION' \
  scripts/classify-minimum-source-excerpt-first-fixed-seed-diagnostic-adaptation.sh

echo "IMPLEMENTATION_AUTHORIZATION=CONFIRMED"

source_fixture="scripts/validate-source-excerpt-first-live.ts"
target_fixture="scripts/validate-source-excerpt-first-fixed-seed-live.ts"
seed_line="      validationGenerationSeed: 424242,"

echo
echo "=== VERIFY TARGET ABSENT ==="
if [[ -e "$target_fixture" ]]; then
  echo "STOP: authorized target already exists: $target_fixture"
  exit 2
fi

echo "TARGET_ABSENT=CONFIRMED"

echo
echo "=== VERIFY SOURCE FIXTURE REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' "$source_fixture"; then
  echo "STOP: source fixture unexpectedly already contains validationGenerationSeed."
  exit 2
fi

if ! grep -q 'projectContextSegmentCandidates' "$source_fixture"; then
  echo "STOP: source fixture no longer satisfies selected-context compatibility requirement."
  exit 2
fi

echo "SOURCE_FIXTURE_BASELINE=CONFIRMED"

echo
echo "=== CREATE SEED-ONLY DIAGNOSTIC COPY ==="
python3 <<'PY'
from pathlib import Path

source_path = Path("scripts/validate-source-excerpt-first-live.ts")
target_path = Path("scripts/validate-source-excerpt-first-fixed-seed-live.ts")

source = source_path.read_text()
seed_line = "      validationGenerationSeed: 424242,\n"

if "validationGenerationSeed" in source:
    raise SystemExit("STOP: source fixture already contains validationGenerationSeed")

call_index = source.find("ollamaChat(")
if call_index < 0:
    raise SystemExit("STOP: ollamaChat call not found in source fixture")

object_index = source.find("    {\n", call_index)
if object_index < 0:
    raise SystemExit("STOP: ollamaChat context object not found in source fixture")

insert_at = object_index + len("    {\n")
adapted = source[:insert_at] + seed_line + source[insert_at:]

if adapted.replace(seed_line, "", 1) != source:
    raise SystemExit("STOP: generated adaptation differs beyond seed insertion")

target_path.write_text(adapted)

print("SOURCE_EXCERPT_FIRST_FIXED_SEED_COPY_CREATED")
PY

echo
echo "=== VERIFY EXACT SEED-ONLY DIFFERENCE ==="
python3 <<'PY'
from pathlib import Path

source_path = Path("scripts/validate-source-excerpt-first-live.ts")
target_path = Path("scripts/validate-source-excerpt-first-fixed-seed-live.ts")
seed_line = "      validationGenerationSeed: 424242,\n"

source = source_path.read_text()
adapted = target_path.read_text()

if adapted.count(seed_line) != 1:
    raise SystemExit("STOP: expected exactly one validation seed insertion")

if adapted.replace(seed_line, "", 1) != source:
    raise SystemExit("STOP: unauthorized difference detected beyond validation seed insertion")

print("EXACT_SEED_ONLY_DIFFERENCE=CONFIRMED")
PY

echo
echo "=== VERIFY SELECTED-CONTEXT CONTRACT PRESERVED ==="
grep -nE \
  'projectContextExcerpts|projectContextSegmentCandidates|sourceStartLine|sourceEndLine|validationGenerationSeed|supportSourceReferences' \
  "$target_fixture"

echo "SELECTED_CONTEXT_CONTRACT=PRESERVED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  awk '{print $2}' |
  grep -vE '^scripts/implement-minimum-source-excerpt-first-fixed-seed-diagnostic-adaptation\.sh$|^scripts/validate-source-excerpt-first-fixed-seed-live\.ts$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized diagnostic scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_CHANGE_SURFACE=CONFIRMED"

echo
echo "=== RESULT ==="
echo "IMPLEMENTATION_RESULT=SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_ADAPTATION_IMPLEMENTED"
echo "FIXED_VALIDATION_SEED=424242"
echo "SINGLE_DIAGNOSTIC_RUN_AUTHORIZED=YES"
echo "REPEATED_RUNS_AUTHORIZED=NO"
echo "PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=RUN_SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_ONCE"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/implement-minimum-source-excerpt-first-fixed-seed-diagnostic-adaptation.sh \
  scripts/validate-source-excerpt-first-fixed-seed-live.ts

git diff --cached --check
git commit -m "Add source excerpt fixed seed diagnostic fixture"
git push
