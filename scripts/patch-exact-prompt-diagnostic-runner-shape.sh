#!/usr/bin/env bash
set -euo pipefail

echo "=== PATCH EXACT PROMPT DIAGNOSTIC RUNNER SHAPE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor cf6acc1a HEAD

runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"

test -f "$runner"
grep -q '^const observations: Observation\[\] = \[\];$' "$runner"
grep -q 'observations.push(await run(pair, "control"));' "$runner"
grep -q 'observations.push(await run(pair, "experimental"));' "$runner"

python3 <<'PY'
from pathlib import Path

path = Path("scripts/run-bounded-prompt-presentation-diagnostic.ts")
text = path.read_text()

start = text.index("const observations: Observation[] = [];")
footer = 'console.log("PRODUCTION_CHANGE=NONE");'
footer_start = text.index(footer, start)
footer_end = footer_start + len(footer)

body = text[start:footer_end]

indented = "\n".join(
    ("  " + line if line else "")
    for line in body.splitlines()
)

replacement = (
    "async function main(): Promise<void> {\n"
    + indented
    + "\n}\n\n"
    + "void main();"
)

text = text[:start] + replacement + text[footer_end:]
path.write_text(text)
PY

echo "=== VERIFY EXACT PATCH ==="
grep -n 'async function main' "$runner"
grep -n 'await run' "$runner"
grep -n 'void main' "$runner"

echo "=== TARGETED TYPESCRIPT CHECK ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  scripts/utils/ollamaChat.ts \
  "$runner"

echo "TARGETED_TYPESCRIPT_CHECK=PASS"
git diff --check

cat <<'MAP'
REPAIR_HYPOTHESIS=
3

PATCH_BASIS=
EXACT_OBSERVED_LOCAL_RUNNER_SHAPE

TOP_LEVEL_AWAIT=
REMOVED

ASYNC_MAIN_WRAPPER=
PRESENT

TARGETED_TYPESCRIPT_CHECK=
PASS

PRODUCTION_CHANGE=
NONE

ATLAS_CHANGE=
NONE

NEXT_ACTION=
COMMIT_VALIDATED_DIAGNOSTIC_SURFACES
MAP
