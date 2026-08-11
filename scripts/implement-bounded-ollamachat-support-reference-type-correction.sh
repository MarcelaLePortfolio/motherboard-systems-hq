#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT BOUNDED OLLAMACHAT SUPPORT REFERENCE TYPE CORRECTION ==="

REQUIRED_ANCESTOR="7b996f58"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY AUTHORIZED STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-bounded-ollamachat-support-reference-type-correction\.sh$|^ M scripts/implement-bounded-ollamachat-support-reference-type-correction\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CLASSIFICATION ==="
grep -nE \
  'OLLAMACHAT_NEVER_TYPE_ERROR_CLASSIFIED|FAILURE_CLASS=COMPILE_TIME_TYPE_NARROWING|RUNTIME_SEMANTICS_CHANGE_REQUIRED=NO|SMALLEST_SAFE_FIX=TYPE_ONLY_NARROWING_CORRECTION|NEXT_ACTION=IMPLEMENT_BOUNDED_OLLAMACHAT_SUPPORT_REFERENCE_TYPE_CORRECTION' \
  scripts/classify-ollamachat-relativepath-never-type-error.sh

echo
echo "=== VERIFY CURRENT TARGET BLOCK ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1114,1142p'

echo
echo "=== APPLY STRUCTURAL TYPE-ONLY CORRECTION ==="
python3 - <<'PY'
from pathlib import Path
import re

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

pattern = re.compile(
    r'''(?P<indent>\s*)\.filter\(\s*
\s*\(\s*
\s*reference,\s*
\s*\):\s*reference\s+is\s+Extract<\s*
\s*MatildaSupportSourceReference,\s*
\s*\{\s*type:\s*"project_context_excerpt"\s*\}\s*
\s*>\s*=>\s*
\s*reference\.type\s*===\s*
\s*"project_context_excerpt",\s*
\s*\)''',
    re.MULTILINE,
)

matches = list(pattern.finditer(text))

if len(matches) != 1:
    raise SystemExit(
        f"STOP: expected exactly one Extract-based project-context filter predicate; found {len(matches)}."
    )

replacement = '''          .filter(
            (
              reference,
            ): reference is MatildaSupportSourceReference & {
              type: "project_context_excerpt";
              relativePath: string;
              lineNumber: number;
            } =>
              reference.type ===
                "project_context_excerpt" &&
              typeof reference.relativePath === "string" &&
              typeof reference.lineNumber === "number",
          )'''

path.write_text(pattern.sub(replacement, text, count=1))
PY

echo
echo "=== VERIFY TARGET BLOCK AFTER CORRECTION ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1114,1148p'

echo
echo "=== VERIFY INVALID EXTRACT PREDICATE REMOVED ==="
if sed -n '1114,1148p' scripts/utils/ollamaChat.ts |
  grep -q 'reference is Extract<'; then
  echo "STOP: invalid Extract predicate remains."
  exit 2
fi

echo "INVALID_EXTRACT_PREDICATE_REMOVED"

echo
echo "=== VERIFY BOUNDED CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/(utils/ollamaChat\.ts|implement-bounded-ollamachat-support-reference-type-correction\.sh)$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized implementation surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "BOUNDED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== TYPESCRIPT CHECK ==="
set +e
npm run check > /tmp/ollamachat-type-correction-check.log 2>&1
CHECK_STATUS=$?
set -e

cat /tmp/ollamachat-type-correction-check.log

echo
echo "TSC_EXIT_STATUS=$CHECK_STATUS"

echo
echo "=== VERIFY TARGET ERRORS REMOVED ==="
if grep -qE \
  "scripts/utils/ollamaChat\.ts.*TS2339.*(relativePath|lineNumber).*never" \
  /tmp/ollamachat-type-correction-check.log; then
  echo "STOP: target Ollama Chat never-type error remains."
  exit 2
fi

echo "OLLAMACHAT_NEVER_TYPE_ERRORS_REMOVED"

echo
echo "=== VERIFY REMAINING TYPECHECK ERROR SET ==="
remaining_errors="$(
  grep -E 'error TS[0-9]+' /tmp/ollamachat-type-correction-check.log || true
)"

expected_atlas="routes/atlas/why.ts(32,54): error TS2554: Expected 2 arguments, but got 3."

if [[ -n "$remaining_errors" && "$remaining_errors" != "$expected_atlas" ]]; then
  echo "STOP: unexpected TypeScript errors remain:"
  printf '%s\n' "$remaining_errors"
  exit 2
fi

if [[ "$remaining_errors" == "$expected_atlas" ]]; then
  echo "ONLY_KNOWN_ATLAS_TYPE_ERROR_REMAINS"
else
  echo "FULL_TYPESCRIPT_CHECK_PASSES"
fi

echo
echo "=== VERIFY OLLAMA RESPONSE CONTRACT ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY INVESTIGATION LIFECYCLE CONTRACT ==="
./node_modules/.bin/tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY DIFF ==="
git diff --check
git diff -- scripts/utils/ollamaChat.ts

echo
echo "OLLAMACHAT_SUPPORT_REFERENCE_TYPE_CORRECTION_IMPLEMENTED"
echo "CHANGE_CLASS=TYPE_ONLY"
echo "RUNTIME_SEMANTICS_CHANGE=NONE"
echo "TARGET_COMPILE_ERROR=RESOLVED"
echo "ATLAS_WHY_TS2554=SEPARATE"
echo "DR_TIME=NO"
echo "NEXT_ACTION=VERIFY_LOCAL_BACKEND_STARTUP"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/implement-bounded-ollamachat-support-reference-type-correction.sh

git diff --cached --check
git commit -m "Fix Ollama Chat support reference narrowing"
git push
