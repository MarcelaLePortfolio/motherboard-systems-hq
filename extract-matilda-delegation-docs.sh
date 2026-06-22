
#!/usr/bin/env bash

set -euo pipefail

OUT="MATILDA_DELEGATION_DOC_EXTRACT_$(date +%Y%m%d_%H%M%S).md"

KEYWORDS='Matilda|Cade|delegate|delegation|prompt|task prompt|execution prompt|task contract|conversation|chat|scope|constraint|approval|confirmation|authority|rollback|validation|project selection|selected project'

{

  echo "# Matilda Delegation / Prompt Creation Documentation Extract"

  echo

  echo "Generated: $(date)"

  echo

  echo "## Keyword Matches"

  echo

  find . \

    \( -path './.git' -o -path './node_modules' -o -path './.next' -o -path './dist' -o -path './build' \) -prune -o \

    -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.rtf' \) -print \

    | sort \

    | while IFS= read -r file; do

        if grep -Eiq "$KEYWORDS" "$file"; then

          echo

          echo "### $file"

          grep -nEi "$KEYWORDS" "$file" || true

        fi

      done

  echo

  echo "## Full Contents of High-Signal Files"

  echo

  for file in \

    "./docs/MATILDA_CHAT_ROUTING_DIAGNOSIS.md" \

    "./docs/MATILDA_CHAT_PHASE2_MILESTONES.md" \

    "./docs/MATILDA_CHAT_PHASE_STATUS.md" \

    "./docs/MATILDA_CHAT_PHASE2_STATUS_SNAPSHOT.md" \

    "./docs/MATILDA_CHAT_RECOMMENDED_MILESTONES.md" \

    "./docs/NEXT_STEPS_MATILDA_CHAT_PHASE2.md" \

    "./PHASE11_TASK_DELEGATION_RUN_SEQUENCE.md" \

    "./PHASE11_DELEGATE_TASK_EXECUTION_NOTE.md" \

    "./PHASE11_DELEGATE_TASK_RESULT.md" \

    "./PHASE11_DELEGATE_TASK_QUICKSTART.md" \

    "./PHASE14_1_TASK_CONTRACT.md" \

    "./PHASE25_AUTHORITY_ORCHESTRATION_CONTRACT.md" \

    "./docs/checkpoints/PHASE79_AUTHORITY_MODEL_CONTRACT_20260316.md" \

    "./docs/checkpoints/PHASE79_CONTROLLED_AUTOMATION_BOUNDARY_SPEC_20260316.md" \

    "./docs/checkpoints/PHASE79_CONFIRMATION_GATE_CONTRACT_20260316.md" \

    "./docs/contracts/DELEGATION_ENVELOPE_V1.md"

  do

    if [ -f "$file" ]; then

      echo

      echo "---"

      echo

      echo "# FILE: $file"

      echo

      cat "$file"

      echo

    fi

  done

} > "$OUT"

echo "Created $OUT"

git add "$OUT" extract-matilda-delegation-docs.sh

git commit -m "Extract Matilda delegation documentation"

git push

