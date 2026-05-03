#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"

TS_CANDIDATE="$(
  rg -l --hidden \
    --glob '!node_modules' \
    --glob '!dist' \
    --glob '!build' \
    --glob '!coverage' \
    --glob '!*.sh' \
    --glob '*.ts' \
    --glob '*.tsx' \
    '(^|\s)(export\s+)?(enum|type|interface)\s+ConfidenceLevel\b|export\s*\{[^}]*ConfidenceLevel[^}]*\}' \
    "$REPO_ROOT" \
  | grep -v '/cognition/situation/' \
  | head -n 1
)"

if [ -z "${TS_CANDIDATE:-}" ]; then
  echo "Could not locate a TypeScript source file for ConfidenceLevel." >&2
  exit 1
fi

echo "Using ConfidenceLevel source: $TS_CANDIDATE"

python3 - << 'PY'
import os
import pathlib
import re

repo = pathlib.Path(os.getcwd())
candidate = pathlib.Path(os.environ["TS_CANDIDATE"]).resolve()

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
        r'from\s+"[^"]*guidance[^"]*"',
        f'from "{rel}"',
        text,
    )
    target.write_text(text)
    print(f"patched {target.relative_to(repo)} -> {rel}")
PY
