
#!/bin/bash

OUT="EXECUTION_IMPLEMENTATION_SURFACES.txt"

rm -f "$OUT"

{

  echo "# Execution Implementation Surface Discovery"

  echo

  echo "=================================================================="

  echo "LIKELY EXECUTION ROUTES"

  echo "=================================================================="

  grep -RliE "delegateTask|task execution|queue task|run task|execution envelope" \

    server worker api routes src . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    2>/dev/null | head -40

  echo

  echo "=================================================================="

  echo "LIKELY MATILDA / CADE PROMPT SURFACES"

  echo "=================================================================="

  grep -RliE "Matilda|Cade|prompt generation|delegate prompt|system prompt" \

    server worker api routes src docs . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    2>/dev/null | head -40

  echo

  echo "=================================================================="

  echo "LIKELY PROJECT ROOT / WORKSPACE SURFACES"

  echo "=================================================================="

  grep -RliE "projectRoot|workspaceRoot|repoRoot|working directory|cwd" \

    server worker api routes src . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    2>/dev/null | head -40

  echo

  echo "=================================================================="

  echo "LIKELY AUDIT / RECONCILIATION SURFACES"

  echo "=================================================================="

  grep -RliE "audit|reconciliation|rollback|verification outcome|event writer" \

    server worker api routes src docs . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    2>/dev/null | head -40

} > "$OUT"

echo "Created $OUT"

