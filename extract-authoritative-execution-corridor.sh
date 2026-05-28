
#!/bin/bash

OUT="AUTHORITATIVE_EXECUTION_CORRIDOR.txt"

FILES=(

  "PHASE11_DELEGATE_TASK_QUICKSTART.md"

  "PHASE11_TASK_DELEGATION_RUN_SEQUENCE.md"

  "PHASE14_1_TASK_CONTRACT.md"

  "PHASE25_AUTHORITY_ORCHESTRATION_CONTRACT.md"

  "docs/contracts/DELEGATION_ENVELOPE_V1.md"

  "docs/checkpoints/PHASE79_AUTHORITY_MODEL_CONTRACT_20260316.md"

  "docs/checkpoints/PHASE79_CONTROLLED_AUTOMATION_BOUNDARY_SPEC_20260316.md"

  "docs/checkpoints/PHASE79_CONFIRMATION_GATE_CONTRACT_20260316.md"

  "docs/checkpoints/PHASE61_5_2_DELEGATION_CONTROLS_WIRED_20260310.md"

  "docs/checkpoints/PHASE80_SAFE_ITERATION_ENGINE_COMPLETE.md"

)

rm -f "$OUT"

for file in "${FILES[@]}"

do

  if [ -f "$file" ]; then

    {

      echo

      echo "=================================================================="

      echo "FILE: $file"

      echo "=================================================================="

      echo

      sed -n '1,220p' "$file"

      echo

    } >> "$OUT"

  fi

done

echo "Created $OUT"

