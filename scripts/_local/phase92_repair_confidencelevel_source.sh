#!/usr/bin/env bash
set -euo pipefail

CANDIDATE="$(
  rg -l --hidden \
    --glob '!node_modules' \
    --glob '!dist' \
    --glob '!build' \
    --glob '!coverage' \
    --glob '!scripts/**' \
    --glob '*.ts' \
    --glob '*.tsx' \
    '(^|[[:space:]])(export[[:space:]]+)?(enum|type)[[:space:]]+ConfidenceLevel\b|export[[:space:]]*\{[^}]*ConfidenceLevel[^}]*\}' \
    . \
  | grep -v '/cognition/situation/' \
  | head -n 1
)"

if [ -z "${CANDIDATE:-}" ]; then
  echo "ConfidenceLevel definition not found"
  exit 1
fi

export CANDIDATE

python3 << 'PY'
import os
import pathlib
import re

repo = pathlib.Path.cwd()
candidate = pathlib.Path(os.environ["CANDIDATE"]).resolve()

targets = [
    repo/"cognition/situation/situation.types.ts",
    repo/"cognition/situation/classifySituation.ts",
    repo/"cognition/situation/__tests__/classifySituation.test.ts",
    repo/"cognition/situation/__tests__/frameSituation.test.ts",
    repo/"cognition/situation/__tests__/sortSituationFrames.test.ts",
]

for target in targets:

    rel = os.path.relpath(candidate, target.parent).replace("\\","/")
    if not rel.startswith("."):
        rel = "./"+rel

    txt = target.read_text()

    txt = re.sub(
        r'import type \{ ConfidenceLevel \} from ".*";',
        f'import type {{ ConfidenceLevel }} from "{rel}";',
        txt
    )

    txt = re.sub(
        r'import \{ ConfidenceLevel \} from ".*";',
        f'import {{ ConfidenceLevel }} from "{rel}";',
        txt
    )

    target.write_text(txt)

    print("patched", target)
PY

echo "ConfidenceLevel source:"
echo "$CANDIDATE"

node --import tsx --test \
cognition/situation/__tests__/classifySituation.test.ts \
cognition/situation/__tests__/frameSituation.test.ts \
cognition/situation/__tests__/sortSituationFrames.test.ts

