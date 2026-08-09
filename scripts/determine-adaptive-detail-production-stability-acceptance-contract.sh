#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== DETERMINE ADAPTIVE DETAIL — PRODUCTION STABILITY ACCEPTANCE CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "e943c38f" ]]; then
  echo "STOP: HEAD no longer matches seeded-stability classification checkpoint e943c38f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/determine-adaptive-detail-production-stability-acceptance-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== SEMANTIC BEHAVIORAL VALIDATION DOCTRINE ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='determine-adaptive-detail-production-stability-acceptance-contract.sh' \
  -Ei 'behavioral validation|fail.closed|fail closed|nondetermin|repeatab|reproduc|semantic generation|model invocation|malformed|structured output|contract enforcement|reliability' \
  docs/architecture docs/governance scripts 2>/dev/null || true

echo
echo "=== SUMMARY / REASONING / EVIDENCE / BOUNDARY CLOSURE PRECEDENT ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -Ei 'closure|behavior supported|validation complete|fail.closed|nondetermin|live validation|model output' \
  scripts/*summary* \
  scripts/*reasoning* \
  scripts/*evidence* \
  scripts/*boundary* 2>/dev/null || true

echo
echo "=== ADAPTIVE DETAIL ORIGINAL OBJECTIVE / ACCEPTANCE EVIDENCE ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='determine-adaptive-detail-production-stability-acceptance-contract.sh' \
  -Ei 'Adaptive Detail|immaterial|materiality|selectedContextSegments|semantic admission|mixed content|immediate reply|acceptance|closure' \
  docs scripts 2>/dev/null || true

echo
echo "=== FAIL-CLOSED RESPONSE CONTRACT PRECEDENT ==="
sed -n '1,180p' scripts/guard-ollama-response-contract.sh

echo
echo "=== SEMANTIC HISTORY BEHAVIORAL VALIDATION ==="
sed -n '1,260p' docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md 2>/dev/null || true

echo
echo "=== REPOSITORY READINESS DOCTRINE ==="
sed -n '1,240p' docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md 2>/dev/null || true

echo
echo "=== RECENT ADAPTIVE DETAIL DETERMINATIONS ==="
for file in \
  scripts/classify-adaptive-detail-selection-support-ownership.sh \
  scripts/revise-adaptive-detail-mixed-content-validation-criteria.sh \
  scripts/classify-adaptive-detail-live-stability.sh \
  scripts/classify-adaptive-detail-generation-stability-control-seam.sh \
  scripts/classify-scoped-matilda-generation-control-contract.sh \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    sed -n '1,360p' "$file"
  fi
done

echo
echo "=== DETERMINATION ==="
cat <<'FINDINGS'
Repository-supported determination:

1. Adaptive Detail's established semantic objective is not identical text
   generation across repeated model invocations.

2. The corridor exists to improve semantic detail selection so that supplied
   colocated project context does not cause immaterial content to contaminate
   the immediate reply.

3. selectedContextSegments is explicitly model-authored semantic admission
   metadata.

4. Deterministic runtime code is explicitly prohibited from deciding semantic
   materiality.

5. Therefore deterministic equality of selectedContextSegments across every
   unseeded invocation is not an established architectural requirement.

6. supportSourceReferences is separately model-authored support provenance.

7. Runtime code deterministically validates support identities against the
   supplied source universe and fails closed on invented or unsupplied
   identities.

8. The structured response contract already treats malformed or incomplete
   semantic artifacts as model-generation failures that must fail closed rather
   than be silently repaired.

9. Existing architecture therefore distinguishes:

   semantic generation:
     model-authored and potentially variable;

   contract enforcement:
     deterministic and fail-closed.

10. Repository evidence does not establish a general requirement that semantic
    generation corridors produce byte-identical or semantically identical
    results across repeated unseeded invocations.

11. Prior behavioral-validation work evaluates whether required semantic and
    architectural behaviors are supported while preserving deterministic
    boundaries, not whether stochastic generation is eliminated.

12. The bounded unseeded Adaptive Detail evidence established that the current
    implementation can produce the intended immediate reply behavior:

    - relevant context remains available;
    - immaterial colocated content remains absent from the immediate reply.

13. Multiple unseeded runs produced that intended behavior.

14. One documented unseeded run instead authored an invalid :22 project support
    identity.

15. Runtime rejected that invalid support identity before it could become
    accepted provenance.

16. No evidence shows that the invalid :22 identity was persisted, surfaced as
    accepted evidence, silently repaired, or converted into authoritative state.

17. Therefore the observed failure is contained by the established fail-closed
    contract.

18. The seeded diagnostic further established that, under a reproducible
    sampling state, the same current contract consistently produces:

    - relevant child selected;
    - immaterial child omitted;
    - immaterial reply detail omitted;
    - valid parent support only.

19. Seeded evidence is admissible as diagnostic capability evidence because it
    demonstrates that the current prompt/schema/runtime combination can express
    and validate the intended behavior.

20. Seeded evidence does not prove unseeded production reliability and must not
    be represented as such.

21. A production seed would alter shared Conversation Engine generation policy
    and remains outside this corridor.

22. Likewise, temperature/top_p/top_k policy belongs to Conversation Engine
    generation governance rather than Adaptive Detail semantic-selection
    architecture.

23. The remaining unseeded variance therefore belongs to a separate generation
    stability/reliability concern unless evidence shows it materially prevents
    normal Conversation Engine use.

24. Current evidence does not establish that occasional fail-closed semantic
    generation prevents normal use.

25. Current evidence does establish that invalid structured provenance does not
    pass deterministic runtime validation.

26. Adaptive Detail must not redefine success as:

    every unseeded model invocation must produce identical structured semantic
    artifacts.

27. Doing so would impose a new global model-determinism requirement that was
    not part of the corridor's original objective and would improperly pull
    generation-policy governance into Adaptive Detail.

28. Adaptive Detail acceptance should instead require:

    A. the intended user-facing semantic behavior is demonstrated;

    B. semantic admission remains owned by Matilda;

    C. support provenance remains independently model-authored;

    D. deterministic runtime validation accepts only supplied identities;

    E. invalid identities fail closed;

    F. no silent semantic repair or filtering occurs;

    G. no second model invocation occurs;

    H. Evidence Composition semantics remain unchanged;

    I. production generation policy is not silently altered.

29. Those acceptance conditions are currently supported by repository evidence.

30. The intermittent invalid :22 output should remain explicitly documented as
    a generation-stability limitation, not erased from the record.

31. That limitation should be deferred to a separate Conversation Engine
    generation-stability corridor if further reliability hardening is desired.

32. It does not require reopening Boundary Composition.

33. It does not justify weakening fail-closed validation.

34. It does not justify promoting the validation-only seed into production.

Classification:

ADAPTIVE_DETAIL_GENERATION_STABILITY_BELONGS_TO_SEPARATE_CORRIDOR

Closure implication:

Adaptive Detail is eligible for corridor-closure validation provided closure
explicitly preserves the following limitation:

  Unseeded model-authored support provenance has demonstrated intermittent
  invalid identity generation; deterministic runtime validation rejects such
  output fail-closed. Broader semantic-generation stability is deferred to a
  separate Conversation Engine generation-policy/reliability corridor.

Smallest next unit:

VALIDATE_ADAPTIVE_DETAIL_CORRIDOR_CLOSURE

That validation must confirm:

1. deterministic segmentation remains intact;
2. candidate transport remains intact;
3. selectedContextSegments remains model-authored;
4. exact candidate membership validation remains fail-closed;
5. supportSourceReferences remains independently model-authored;
6. support identities remain parent-source based;
7. invalid support identities remain fail-closed;
8. user-facing mixed-content behavior has demonstrated immaterial-detail
   omission;
9. seeded diagnostic capability is validation-only;
10. production workflow supplies no seed;
11. no production generation parameters were changed;
12. Evidence Composition remains unchanged;
13. one model invocation remains intact;
14. no semantic post-filtering exists;
15. no second semantic author exists;
16. the generation-stability limitation is explicitly recorded as deferred.

Do not implement additional runtime behavior before closure validation.
FINDINGS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION SEED ABSENT ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow unexpectedly supplies validation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== VERIFY NO PRODUCTION SAMPLING POLICY ==="
if grep -n -E 'temperature:|top_p:|top_k:|seed:' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow contains generation sampling policy."
  exit 2
fi
echo "PRODUCTION_SAMPLING_POLICY_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_GENERATION_STABILITY_BELONGS_TO_SEPARATE_CORRIDOR"
echo "NEXT_UNIT=VALIDATE_ADAPTIVE_DETAIL_CORRIDOR_CLOSURE"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh
git commit -m "Determine Adaptive Detail production stability acceptance"
git push
