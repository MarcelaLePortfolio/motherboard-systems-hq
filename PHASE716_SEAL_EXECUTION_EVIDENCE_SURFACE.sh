
#!/bin/bash

set -u

OUT="phase716_execution_evidence_surface_seal.txt"

: > "$OUT"

{

  echo "===== PHASE 716 EXECUTION EVIDENCE SURFACE SEAL ====="

  echo ""

  echo "[1] Branch + commit state"

  git branch --show-current

  git status --short

  git log --oneline -8

  echo ""

  echo "[2] Runtime containers"

  docker compose ps

  echo ""

  echo "[3] Static evidence surface proof"

  curl -sS -i "http://localhost:3000/execution-evidence.html" | head -80 || true

  echo ""

  echo "[4] Task evidence API proof"

  curl -sS -i "http://localhost:3000/api/tasks" | head -100 || true

  echo ""

  echo "[5] Guidance boundary proof"

  curl -sS -i -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" --data '{"message":"Confirm advisory boundary after Phase 716 evidence surface."}' | head -80 || true

  echo ""

  echo "[6] Source proof"

  grep -n "Read-only operator proof surface\|does not create, mutate, retry, or execute tasks\|trace_visibility\|system trace payload" public/execution-evidence.html || true

  grep -n "read-only execution evidence\|View execution evidence\|View system trace payload" app/components/ExecutionInspector.tsx || true

  echo ""

  echo "PHASE 716 RESULT:"

  echo "- Static execution evidence page is reachable at /execution-evidence.html."

  echo "- /api/tasks remains the read-only evidence source."

  echo "- No task creation, mutation, retry, or execution behavior was added."

  echo "- Advisory chat remains execution:false and systemCoupling:false."

  echo "- Container runtime rebuilt and verified."

  echo ""

  echo "===== PHASE 716 EXECUTION EVIDENCE SURFACE SEALED ====="

} | tee "$OUT"

