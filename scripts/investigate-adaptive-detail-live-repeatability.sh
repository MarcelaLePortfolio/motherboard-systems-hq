#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE ADAPTIVE DETAIL — LIVE REPEATABILITY ==="

if [[ "$(git rev-parse --short HEAD)" != "0fe5d29d" ]]; then
  echo "STOP: HEAD no longer matches reconciled validation-criteria checkpoint 0fe5d29d."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-live-repeatability\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Observed state before repeatability probe:

1. Child identity presentation was separated from parent Source notation.

2. Structural validation and the Ollama regression suite remained green.

3. One live run after that separation produced:

   supportSourceReferences = []

   selectedContextSegments:
     relevant child
     immaterial child

   reply:
     omitted the immaterial deferred-work content.

4. That run did not reproduce the invalid child-derived parent identity.

5. The validation criteria were subsequently reconciled to the established
   distinction between:

   selectedContextSegments:
     semantic admission

   supportSourceReferences:
     explicit support provenance

6. No runtime or prompt behavior changed during that reconciliation.

7. The next live rerun, against the same runtime and same bounded fixture,
   produced:

   project_context_excerpt:
     docs/adaptive-detail-live-validation.md:20

   project_context_excerpt:
     docs/adaptive-detail-live-validation.md:22

8. Runtime correctly failed closed because :22 is not a supplied parent Source
   identity.

9. Therefore the same implementation and same fixture have now produced both:

   A. a response without the invalid :22 parent support identity;

   B. a response with the invalid :22 parent support identity.

10. The presentation-level separation is therefore not yet demonstrated to be
    behaviorally reliable.

11. The latest failure must not be explained away by the revised validation
    criteria because it occurs before those success criteria are evaluated.

12. Exact support-source validation remains correct and must remain fail-closed.

13. No evidence supports weakening that validation.

14. No evidence supports silently deleting the invalid :22 reference.

15. No evidence supports synthesizing or repairing support provenance after the
    model responds.

16. No additional prompt wording is authorized in this investigation.

17. Before another implementation hypothesis is opened, determine whether the
    observed behavior is repeatably unstable across identical independent live
    invocations.

Repeatability probe:

Run exactly three independent executions of the existing bounded live validator.

Each execution remains:

  one user message
  -> one ollamaChat call
  -> one Ollama invocation.

Do not retry inside a single invocation.

Do not modify runtime between trials.

For each trial record only:

- exit code;
- whether :22 appeared in parsed support;
- whether the runtime failed closed;
- whether ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED was reached.

Interpretation:

If all three trials pass:
  do not declare closure;
  classify the previously observed failure as intermittent and investigate model
  output stability before closure.

If any trial emits :22:
  classify support provenance generation as behaviorally unstable under the
  current contract.

If all three trials emit :22:
  the current presentation-level hypothesis is strongly unsupported as a
  reliable solution.

No production changes are authorized by this probe alone.
FINDINGS

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent \
  http://localhost:11434/api/tags \
  >/dev/null

echo "OLLAMA_AVAILABLE"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

invalid_count=0
pass_count=0
fail_closed_count=0

for trial in 1 2 3; do
  echo
  echo "=== LIVE REPEATABILITY TRIAL $trial ==="

  set +e
  npx tsx scripts/validate-adaptive-detail-mixed-content-live.ts \
    >"$tmp_dir/trial-$trial.log" 2>&1
  rc=$?
  set -e

  cat "$tmp_dir/trial-$trial.log"

  invalid_22=false
  behavior_supported=false
  failed_closed=false

  if grep -q '"lineNumber": 22' "$tmp_dir/trial-$trial.log"; then
    invalid_22=true
    invalid_count=$((invalid_count + 1))
  fi

  if grep -q 'ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED' \
    "$tmp_dir/trial-$trial.log"
  then
    behavior_supported=true
    pass_count=$((pass_count + 1))
  fi

  if grep -q \
    'project-context support reference that was not supplied in this invocation' \
    "$tmp_dir/trial-$trial.log"
  then
    failed_closed=true
    fail_closed_count=$((fail_closed_count + 1))
  fi

  echo
  echo "TRIAL_${trial}_EXIT_CODE=$rc"
  echo "TRIAL_${trial}_INVALID_PARENT_LINE_22=$invalid_22"
  echo "TRIAL_${trial}_FAILED_CLOSED=$failed_closed"
  echo "TRIAL_${trial}_BEHAVIOR_SUPPORTED=$behavior_supported"
done

echo
echo "=== REPEATABILITY SUMMARY ==="
echo "INVALID_PARENT_LINE_22_COUNT=$invalid_count"
echo "FAILED_CLOSED_COUNT=$fail_closed_count"
echo "BEHAVIOR_SUPPORTED_COUNT=$pass_count"

if [[ "$invalid_count" -gt 0 && "$invalid_count" -lt 3 ]]; then
  classification="ADAPTIVE_DETAIL_SUPPORT_PROVENANCE_BEHAVIOR_UNSTABLE"
elif [[ "$invalid_count" -eq 3 ]]; then
  classification="ADAPTIVE_DETAIL_PRESENTATION_SEPARATION_NOT_RELIABLE"
elif [[ "$pass_count" -eq 3 ]]; then
  classification="ADAPTIVE_DETAIL_PRIOR_FAILURE_INTERMITTENT_REQUIRES_STABILITY_RECONCILIATION"
else
  classification="ADAPTIVE_DETAIL_LIVE_BEHAVIOR_REPEATABILITY_INCONCLUSIVE"
fi

echo "CLASSIFICATION=$classification"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY RUNTIME / PROMPT UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts; then
  echo "STOP: ollamaChat.ts changed during repeatability investigation."
  git diff -- scripts/utils/ollamaChat.ts
  exit 2
fi

echo "OLLAMA_RUNTIME_AND_PROMPT_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_LIVE_REPEATABILITY_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=DETERMINE_FROM_REPEATABILITY_CLASSIFICATION"

git add scripts/investigate-adaptive-detail-live-repeatability.sh
git commit -m "Investigate Adaptive Detail live repeatability"
git push
