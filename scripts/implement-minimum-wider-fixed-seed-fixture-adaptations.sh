#!/usr/bin/env bash
set -euo pipefail

echo "=== IMPLEMENT MINIMUM WIDER FIXED-SEED FIXTURE ADAPTATIONS ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLASSIFICATION CHECKPOINT ==="
expected_head="7e1b8e15"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches minimum validation-set classification checkpoint $expected_head."
  exit 2
fi

echo "MINIMUM_VALIDATION_SET_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY AUTHORIZED ADAPTATIONS ==="
grep -nE \
  'scripts/validate-reasoning-composition-fixed-seed-live\.ts|scripts/validate-structured-evidence-object-fixed-seed-live\.ts|TWO_DIAGNOSTIC_SEED_ONLY_FIXTURE_ADAPTATIONS|IMPLEMENT_MINIMUM_WIDER_FIXED_SEED_FIXTURE_ADAPTATIONS' \
  scripts/classify-minimum-wider-fixed-seed-validation-set.sh

echo "AUTHORIZED_ADAPTATION_BOUNDARY=CONFIRMED"

reasoning_source="scripts/validate-reasoning-composition-live.ts"
reasoning_target="scripts/validate-reasoning-composition-fixed-seed-live.ts"
evidence_source="scripts/validate-structured-evidence-object-live.ts"
evidence_target="scripts/validate-structured-evidence-object-fixed-seed-live.ts"

echo
echo "=== VERIFY TARGETS ABSENT ==="
for target in "$reasoning_target" "$evidence_target"; do
  if [[ -e "$target" ]]; then
    echo "STOP: target already exists: $target"
    exit 2
  fi
done
echo "TARGETS_ABSENT=CONFIRMED"

echo
echo "=== CREATE SEED-ONLY ADAPTATIONS ==="
python3 <<'PY'
from pathlib import Path

pairs = [
    (
        Path("scripts/validate-reasoning-composition-live.ts"),
        Path("scripts/validate-reasoning-composition-fixed-seed-live.ts"),
    ),
    (
        Path("scripts/validate-structured-evidence-object-live.ts"),
        Path("scripts/validate-structured-evidence-object-fixed-seed-live.ts"),
    ),
]

seed_line = "      validationGenerationSeed: 424242,\n"

for source_path, target_path in pairs:
    source = source_path.read_text()

    if "validationGenerationSeed" in source:
        raise SystemExit(
            f"STOP: source already contains validationGenerationSeed: {source_path}"
        )

    call_index = source.find("ollamaChat(")
    if call_index < 0:
        raise SystemExit(f"STOP: ollamaChat call not found: {source_path}")

    object_index = source.find("    {\n", call_index)
    if object_index < 0:
        raise SystemExit(
            f"STOP: ollamaChat context object not found: {source_path}"
        )

    insert_at = object_index + len("    {\n")
    adapted = source[:insert_at] + seed_line + source[insert_at:]

    if adapted.replace(seed_line, "", 1) != source:
        raise SystemExit(
            f"STOP: adaptation differs beyond seed insertion: {target_path}"
        )

    target_path.write_text(adapted)

print("SEED_ONLY_ADAPTATIONS_CREATED")
PY

echo
echo "=== VERIFY EXACT SEED-ONLY DIFFERENCE ==="
python3 <<'PY'
from pathlib import Path

pairs = [
    (
        Path("scripts/validate-reasoning-composition-live.ts"),
        Path("scripts/validate-reasoning-composition-fixed-seed-live.ts"),
    ),
    (
        Path("scripts/validate-structured-evidence-object-live.ts"),
        Path("scripts/validate-structured-evidence-object-fixed-seed-live.ts"),
    ),
]

seed_line = "      validationGenerationSeed: 424242,\n"

for source_path, target_path in pairs:
    source = source_path.read_text()
    adapted = target_path.read_text()

    if adapted.count(seed_line) != 1:
        raise SystemExit(
            f"STOP: expected exactly one seed insertion: {target_path}"
        )

    if adapted.replace(seed_line, "", 1) != source:
        raise SystemExit(
            f"STOP: unauthorized difference detected: {target_path}"
        )

print("EXACT_SEED_ONLY_DIFFERENCE=CONFIRMED")
PY

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
  grep -vE '^scripts/implement-minimum-wider-fixed-seed-fixture-adaptations\.sh$|^scripts/validate-reasoning-composition-fixed-seed-live\.ts$|^scripts/validate-structured-evidence-object-fixed-seed-live\.ts$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized diagnostic adaptation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_CHANGE_SURFACE=CONFIRMED"

echo
echo "=== RESULT ==="
echo "IMPLEMENTATION_RESULT=TWO_DIAGNOSTIC_SEED_ONLY_FIXTURE_ADAPTATIONS_IMPLEMENTED"
echo "FIXED_VALIDATION_SEED=424242"
echo "PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=RUN_EACH_WIDER_FIXED_SEED_ADAPTATION_ONCE"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/implement-minimum-wider-fixed-seed-fixture-adaptations.sh \
  scripts/validate-reasoning-composition-fixed-seed-live.ts \
  scripts/validate-structured-evidence-object-fixed-seed-live.ts

git diff --cached --check
git commit -m "Add wider fixed seed diagnostic fixtures"
git push
