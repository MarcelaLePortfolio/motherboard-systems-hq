#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE ADAPTIVE DETAIL — GENERATION STABILITY CONTROLS ==="

if [[ "$(git rev-parse --short HEAD)" != "935ca1c1" ]]; then
  echo "STOP: HEAD no longer matches live-stability checkpoint 935ca1c1."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-generation-stability-controls\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== OLLAMA REQUEST SEAM ==="
grep -n -C 18 \
  -E 'fetch\(|/api/chat|/api/generate|JSON\.stringify|model:|messages:|stream:|format:|options:' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== GENERATION / SAMPLING OPTIONS IN ADAPTER ==="
grep -n -C 8 \
  -Ei 'temperature|seed|top_p|top_k|min_p|repeat_penalty|num_predict|num_ctx|mirostat|options' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== GENERATION / SAMPLING OPTIONS ACROSS REPOSITORY ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-adaptive-detail-generation-stability-controls.sh' \
  -Ei 'temperature|seed|top_p|top_k|min_p|repeat_penalty|num_predict|num_ctx|mirostat' \
  scripts server routes docs package.json pnpm-lock.yaml 2>/dev/null || true

echo
echo "=== OLLAMA MODEL / BASE URL CONFIGURATION ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-adaptive-detail-generation-stability-controls.sh' \
  -E 'OLLAMA_BASE_URL|OLLAMA_CHAT_MODEL|gemma3:4b|localhost:11434' \
  scripts server routes docs .env* 2>/dev/null || true

echo
echo "=== OLLAMA CHAT TEST CONTRACTS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'fetch|body|request|model|stream|format|options|temperature|seed|top_p|top_k' \
  scripts/utils/ollamaChat*.test.ts 2>/dev/null || true

echo
echo "=== ARCHITECTURAL EVIDENCE ABOUT MODEL INVOCATION / PROMPT STABILITY ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-adaptive-detail-generation-stability-controls.sh' \
  -Ei 'model invocation|one invocation|sampling|determin|nondetermin|temperature|seed|generation setting|generation option|ollama request' \
  docs scripts server 2>/dev/null || true

echo
echo "=== CURRENT OLLAMA VERSION / MODEL DETAILS ==="
if command -v ollama >/dev/null 2>&1; then
  ollama --version || true
  ollama show gemma3:4b 2>/dev/null || true
else
  echo "OLLAMA_CLI_NOT_FOUND"
fi

echo
echo "=== REQUEST PAYLOAD STRUCTURAL EXCERPT ==="
python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
lines = path.read_text().splitlines()

needles = (
    "fetch(",
    "/api/chat",
    "/api/generate",
    "JSON.stringify(",
)

hits = []
for index, line in enumerate(lines):
    if any(needle in line for needle in needles):
        hits.append(index)

seen = set()
for hit in hits:
    start = max(0, hit - 20)
    end = min(len(lines), hit + 40)
    key = (start, end)
    if key in seen:
        continue
    seen.add(key)
    print(f"--- lines {start + 1}-{end} ---")
    for i in range(start, end):
        print(f"{i + 1}: {lines[i]}")
PY

echo
echo "=== CLASSIFICATION EVIDENCE ==="

python3 <<'PY'
from pathlib import Path
import re

source = Path("scripts/utils/ollamaChat.ts").read_text()

controls = {
    "temperature": bool(re.search(r"\btemperature\b", source, re.I)),
    "seed": bool(re.search(r"\bseed\b", source, re.I)),
    "top_p": bool(re.search(r"\btop_p\b", source, re.I)),
    "top_k": bool(re.search(r"\btop_k\b", source, re.I)),
    "options": bool(re.search(r"\boptions\s*:", source)),
}

for name, present in controls.items():
    print(f"{name.upper()}_CONFIGURED={str(present).lower()}")

configured_sampling = any(
    controls[name]
    for name in ("temperature", "seed", "top_p", "top_k")
)

if configured_sampling:
    print(
        "PRELIMINARY_CLASSIFICATION="
        "ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_AVAILABLE"
    )
elif controls["options"]:
    print(
        "PRELIMINARY_CLASSIFICATION="
        "ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_AVAILABLE"
    )
else:
    print(
        "PRELIMINARY_CLASSIFICATION="
        "ADAPTIVE_DETAIL_STABILITY_CAUSE_REMAINS_UNRESOLVED"
    )
PY

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts; then
  echo "STOP: ollamaChat.ts changed during read-only investigation."
  git diff -- scripts/utils/ollamaChat.ts
  exit 2
fi

echo "OLLAMA_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_GENERATION_STABILITY_CONTROLS_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_GENERATION_STABILITY_CONTROL_SEAM_FROM_EVIDENCE"

git add scripts/investigate-adaptive-detail-generation-stability-controls.sh
git commit -m "Investigate Adaptive Detail generation stability controls"
git push
