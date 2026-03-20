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
    '(^|[[:space:]])(export[[:space:]]+)?(enum|type|interface)[[:space:]]+ConfidenceLevel\b|export[[:space:]]*\{[^}]*ConfidenceLevel[^}]*\}' \
    . \
  | grep -v '/cognition/situation/' \
  | head -n 1
)"

if [ -z "${CANDIDATE:-}" ]; then
  echo "Could not locate a TypeScript ConfidenceLevel source outside cognition/situation." >&2
  exit 1
fi

export CANDIDATE

python3 << 'PY'
import os
import pathlib
import re

repo = pathlib.Path.cwd().resolve()
candidate = (repo / os.environ["CANDIDATE"]).resolve()

targets = [
    repo / "cognition/situation/situation.types.ts",
    repo / "cognition/situation/classifySituation.ts",
    repo / "cognition/situation/__tests__/classifySituation.test.ts",
    repo / "cognition/situation/__tests__/frameSituation.test.ts",
    repo / "cognition/situation/__tests__/sortSituationFrames.test.ts",
]

for target in targets:
    rel = os.path.relpath(candidate, target.parent).replace(os.sep, "/")
    if not rel.startswith("."):
        rel = "./" + rel

    text = target.read_text()

    text = re.sub(
        r'import type \{ ConfidenceLevel \} from "[^"]+";',
        f'import type {{ ConfidenceLevel }} from "{rel}";',
        text,
    )
    text = re.sub(
        r'import \{ ConfidenceLevel \} from "[^"]+";',
        f'import {{ ConfidenceLevel }} from "{rel}";',
        text,
    )

    target.write_text(text)
    print(f"patched {target.relative_to(repo)} -> {rel}")
PY

echo "Using ConfidenceLevel source: $CANDIDATE"

rg -n 'import .*ConfidenceLevel' cognition/situation
node --import tsx --test \
  cognition/situation/__tests__/classifySituation.test.ts \
  cognition/situation/__tests__/frameSituation.test.ts \
  cognition/situation/__tests__/sortSituationFrames.test.ts
