#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY OLLAMACHAT RELATIVEPATH NEVER TYPE ERROR ==="

REQUIRED_ANCESTOR="50823af3"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-ollamachat-relativepath-never-type-error\.sh$|^ M scripts/classify-ollamachat-relativepath-never-type-error\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING INVESTIGATION ==="
grep -nE \
  'LOCAL_RUNTIME_START_FAILURE=CONFIRMED|FAILURE_CLASS=TYPESCRIPT_COMPILE_ERROR|FAILURE_FILE=scripts/utils/ollamaChat.ts|FAILURE_LINE=1130|IMPLEMENTATION_NOT_STARTED|NEXT_ACTION=CLASSIFY_SMALLEST_SAFE_TYPE_FIX' \
  scripts/investigate-ollamachat-relativepath-never-type-error.sh

echo
echo "=== SUPPORT SOURCE TYPE DEFINITIONS ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '195,225p'

echo
echo "=== SUPPORT SOURCE PARSING ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '505,655p'

echo
echo "=== EXISTING VALIDATED ACCESS PATHS ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1015,1108p'

echo
echo "=== FAILING FILTER / MAP ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1110,1148p'

echo
echo "=== REPRODUCE CURRENT TYPECHECK ==="
set +e
npm run check > /tmp/ollamachat-never-classification-tsc.log 2>&1
CHECK_STATUS=$?
set -e

cat /tmp/ollamachat-never-classification-tsc.log

echo
echo "TSC_EXIT_STATUS=$CHECK_STATUS"

echo
echo "=== VERIFY TARGET ERROR REMAINS EXACT ==="
grep -nF \
  "scripts/utils/ollamaChat.ts(1130,26): error TS2339: Property 'relativePath' does not exist on type 'never'." \
  /tmp/ollamachat-never-classification-tsc.log

grep -nF \
  "scripts/utils/ollamaChat.ts(1130,52): error TS2339: Property 'lineNumber' does not exist on type 'never'." \
  /tmp/ollamachat-never-classification-tsc.log

echo "TARGET_NEVER_TYPE_ERROR_CONFIRMED"

echo
echo "=== VERIFY SEPARATE ATLAS ERROR ==="
grep -nF \
  "routes/atlas/why.ts(32,54): error TS2554: Expected 2 arguments, but got 3." \
  /tmp/ollamachat-never-classification-tsc.log || true

echo "ATLAS_TYPE_ERROR_REMAINS_SEPARATE"

cat <<'CLASSIFICATION'

Ollama Chat relativePath / lineNumber never-type classification:

1. Local runtime startup is blocked by a TypeScript compilation failure in
   scripts/utils/ollamaChat.ts.

2. The failure is at the supportDrivenEvidenceSources filter/map pipeline.

3. The support reference has already passed bounded parsing and validation
   before reaching this pipeline.

4. Earlier branches in the same function successfully discriminate
   project_context_excerpt and access relativePath / lineNumber.

5. The failing code adds an explicit Extract-based type predicate:

   Extract<
     MatildaSupportSourceReference,
     { type: "project_context_excerpt" }
   >

6. Under the current MatildaSupportSourceReference declaration shape,
   TypeScript resolves that predicate target to never.

7. Therefore the observed failure is compile-time narrowing, not evidence of a
   malformed runtime support reference.

8. The smallest safe fix is type-only at this narrowing seam.

9. The fix must preserve:
   - support-source parsing;
   - support-source validation;
   - deduplication;
   - provenance semantics;
   - prompt behavior;
   - response schema;
   - workflow behavior;
   - persistence;
   - Investigation Lifecycle;
   - one model invocation.

10. The existing routes/atlas/why.ts TS2554 error is separate and must not be
    bundled into this correction.

11. No production runtime edit is performed by this classification.

CLASSIFICATION

echo
echo "OLLAMACHAT_NEVER_TYPE_ERROR_CLASSIFIED"
echo "FAILURE_CLASS=COMPILE_TIME_TYPE_NARROWING"
echo "FAILURE_SEAM=SUPPORT_DRIVEN_EVIDENCE_SOURCE_FILTER"
echo "INVALID_ASSUMPTION=EXTRACT_TYPE_PREDICATE_RESOLVES_TO_NEVER"
echo "RUNTIME_DATA_SHAPE_FAILURE=NOT_ESTABLISHED"
echo "RUNTIME_SEMANTICS_CHANGE_REQUIRED=NO"
echo "SMALLEST_SAFE_FIX=TYPE_ONLY_NARROWING_CORRECTION"
echo "ATLAS_WHY_TS2554=SEPARATE"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=IMPLEMENT_BOUNDED_OLLAMACHAT_SUPPORT_REFERENCE_TYPE_CORRECTION"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts; then
  echo "STOP: ollamaChat.ts changed during classification."
  git diff -- scripts/utils/ollamaChat.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-ollamachat-relativepath-never-type-error\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-ollamachat-relativepath-never-type-error.sh
git diff --cached --check
git commit -m "Classify Ollama Chat never type error"
git push
