#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"

TS_CANDIDATE="$(
  rg -l --hidden \
    --glob '!node_modules' \
    --glob '!dist' \
    --glob '!build' \
    --glob '!coverage' \
    --glob '!scripts/**' \
    --glob '*.ts' \
    --glob '*.tsx' \
    '(export[[:space:]]+(enum|type|interface)[[:space:]]+ConfidenceLevel\b|export[[:space:]]*\{[^}]*ConfidenceLevel[^}]*\}|enum[[:space:]]+ConfidenceLevel\b|type[[:space:]]+ConfidenceLevel\b|interface[[:space:]]+ConfidenceLevel\b)' \
    . \
  | grep -v '/cognition/situation/' \
  | head -n 1
)"

if [ -z "${TS_CANDIDATE:-}" ]; then
  echo "Could not locate a TypeScript ConfidenceLevel source outside cognition/situation." >&2
  exit 1
fi

export TS_CANDIDATE

python3 - << 'PY'
import os
import pathlib
import re

repo = pathlib.Path(os.getcwd()).resolve()
candidate = (repo / os.environ["TS_CANDIDATE"]).resolve()

targets = [
    repo / "cognition/situation/situation.types.ts",
    repo / "cognition/situation/classifySituation.ts",
    repo / "cognition/situation/__tests__/classifySituation.test.ts",
    repo / "cognition/situation/__tests__/frameSituation.test.ts",
    repo / "cognition/situation/__tests__/sortSituationFrames.test.ts",
]

pattern = re.compile(
    r'from\s+"[^"]*(guidance|ConfidenceLevel|phase92_fix_guidance_imports|phase92_repair_confidencelevel_imports)[^"]*"'
)

for target in targets:
    rel = os.path.relpath(candidate, target.parent).replace(os.sep, "/")
    if not rel.startswith("."):
        rel = "./" + rel

    text = target.read_text()
    new_text = pattern.sub(f'from "{rel}"', text)
    target.write_text(new_text)
    print(f"patched {target.relative_to(repo)} -> {rel}")
PY

echo "Using ConfidenceLevel source: $TS_CANDIDATE"

node --import tsx --test \
  cognition/situation/__tests__/classifySituation.test.ts \
  cognition/situation/__tests__/frameSituation.test.ts \
  cognition/situation/__tests__/sortSituationFrames.test.ts
