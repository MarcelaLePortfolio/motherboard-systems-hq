#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
SITUATION_DIR="$REPO_ROOT/cognition/situation"

if [ ! -d "$SITUATION_DIR" ]; then
  echo "Missing directory: $SITUATION_DIR" >&2
  exit 1
fi

CANDIDATE="$(
  rg -l --hidden --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!coverage' \
    'ConfidenceLevel' "$REPO_ROOT" \
  | grep -v '^./\?cognition/situation/' \
  | grep -v '/cognition/situation/' \
  | head -n 1
)"

if [ -z "${CANDIDATE:-}" ]; then
  echo "Could not locate a ConfidenceLevel source file in repo." >&2
  exit 1
fi

REL_IMPORT="$(python3 - << 'PY'
import os
repo = os.getcwd()
candidate = os.environ["CANDIDATE"]
situation_dir = os.path.join(repo, "cognition", "situation")
candidate_abs = os.path.abspath(candidate)
rel = os.path.relpath(candidate_abs, situation_dir).replace(os.sep, "/")
if not rel.startswith("."):
    rel = "./" + rel
print(rel)
PY
)"

export CANDIDATE
export REL_IMPORT

echo "Using ConfidenceLevel source: $CANDIDATE"
echo "Relative import from cognition/situation: $REL_IMPORT"

python3 - << 'PY'
import os
import pathlib
import re

repo = pathlib.Path(os.getcwd())
rel_import = os.environ["REL_IMPORT"]

targets = [
    repo / "cognition/situation/situation.types.ts",
    repo / "cognition/situation/classifySituation.ts",
    repo / "cognition/situation/__tests__/classifySituation.test.ts",
    repo / "cognition/situation/__tests__/frameSituation.test.ts",
    repo / "cognition/situation/__tests__/sortSituationFrames.test.ts",
]

patterns = [
    r'"\.\./guidance/guidance\.types(?:\.ts)?"',
    r'"\.\./guidance\.types(?:\.ts)?"',
    r'"\.\./types/guidance\.types(?:\.ts)?"',
    r'"\.\./operatorGuidance\.types(?:\.ts)?"',
    r'"\.\./guidance/operatorGuidance\.types(?:\.ts)?"',
    r'"\.\./guidance/[^"]*(?:\.ts)?"',
    r'"\.\./[^"]*guidance[^"]*(?:\.ts)?"',
    r'"\.\./\.\./guidance/[^"]*(?:\.ts)?"',
]

for target in targets:
    text = target.read_text()
    original = text
    for pattern in patterns:
        text = re.sub(pattern, f'"{rel_import}"', text)
    if text != original:
        target.write_text(text)
        print(f"patched {target.relative_to(repo)}")
    else:
        print(f"no change {target.relative_to(repo)}")
PY

node --import tsx --test \
  cognition/situation/__tests__/classifySituation.test.ts \
  cognition/situation/__tests__/frameSituation.test.ts \
  cognition/situation/__tests__/sortSituationFrames.test.ts
