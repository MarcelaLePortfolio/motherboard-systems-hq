#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY POST-COLLABORATION RUNTIME CAPABILITY STATE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY AUTHORIZED CLASSIFICATION SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-post-collaboration-runtime-capability-state\.sh$|^ M scripts/classify-post-collaboration-runtime-capability-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_SURFACE_CONFIRMED"

echo
echo "=== VERIFY SUCCESSOR RECONCILIATION CHECKPOINT ==="
git merge-base --is-ancestor cb3d1de2 HEAD || {
  echo "STOP: successor reconciliation checkpoint cb3d1de2 is not in current lineage."
  exit 2
}
echo "SUCCESSOR_RECONCILIATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY FOUR-PHASE COLLABORATION RUNTIME CLOSURE ==="

phase_commits=(
  "3d61e635"
  "c0934a3b"
  "3320b0ed"
  "1a3fb8d7"
  "91699254"
)

for commit in "${phase_commits[@]}"; do
  git cat-file -e "${commit}^{commit}" 2>/dev/null || {
    echo "STOP: required closure commit $commit is unavailable."
    exit 2
  }

  git merge-base --is-ancestor "$commit" HEAD || {
    echo "STOP: required closure commit $commit is not in current lineage."
    exit 2
  }

  git show -s --format='%h %s' "$commit"
done

echo "PHASE_1_RESPONSE_COMPOSITION_CLOSURE=CONFIRMED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE=CONFIRMED"
echo "PHASE_3_ATTENTION_MANAGEMENT_CLOSURE=CONFIRMED"
echo "PHASE_4_COLLABORATION_GOVERNANCE_CLOSURE=CONFIRMED"
echo "COLLABORATION_RUNTIME_MILESTONE_VALIDATION=CONFIRMED"

echo
echo "=== PRESERVE COMPLETED MILESTONE MAP ==="
cat <<'COMPLETED'
COMPLETED_MILESTONE=MATILDA_COLLABORATION_RUNTIME

PHASE_1=RESPONSE_COMPOSITION
PHASE_1_STATUS=CLOSED
PHASE_1_CORRIDORS=
  1. Summary Composition
  2. Reasoning Classification / Reasoning Composition
  3. Evidence Composition
  4. Boundary Composition
  5. Adaptive Detail Selection

PHASE_2=INVESTIGATION_LIFECYCLE
PHASE_2_STATUS=CLOSED
PHASE_2_CORRIDORS=
  1. Current-state and semantic-model reconciliation
  2. Minimum lifecycle fact / transition semantics
  3. Structured response representation
  4. Persistence ownership and IEL representation
  5. IEL reconstruction read seam
  6. Workflow transport
  7. Prior lifecycle context transport
  8. Cross-turn transition validation
  9. Closure assessment and classification

PHASE_3=ATTENTION_MANAGEMENT
PHASE_3_STATUS=CLOSED
PHASE_3_CORRIDORS=
  1. Current-state reconciliation
  2. Responsibility-boundary investigation
  3. Minimum attention semantic distinction
  4. Closure-readiness classification
  5. Closure

PHASE_4=COLLABORATION_GOVERNANCE
PHASE_4_STATUS=CLOSED
PHASE_4_CORRIDORS=
  1. Current-state reconciliation
  2. Collaboration authorization boundary
  3. Residual governance responsibility
  4. Closure-readiness classification
  5. Closure

MILESTONE_CLOSURE_VALIDATION=CONFIRMED
COMPLETED

echo
echo "=== SUCCESSOR MILESTONE DISCOVERY RULES ==="
cat <<'RULES'
The next milestone MUST be discovered explicitly.

Do not:
- treat successor reconciliation itself as the milestone;
- promote Generation Stability merely because it was previously deferred;
- invent a Phase 5 of Collaboration Runtime;
- assume the successor milestone has four phases;
- assume every phase has five corridors;
- begin implementation before the milestone, phases, and corridors are classified.

For every credible successor candidate, determine:

1. What remaining user/system problem does it solve?
2. What repository evidence proves that problem remains?
3. Why is it not already solved by the Conversation Engine?
4. Why is it not already solved by the completed Collaboration Runtime?
5. Is the responsibility large and coherent enough to constitute a milestone?
6. What distinct responsibilities naturally group beneath it as phases?
7. What bounded repository-supported corridors belong beneath each phase?
8. Which phase ordering is architecturally required?
9. Which corridor ordering is architecturally required?
10. What evidence would falsify the candidate milestone?

The discovery must ultimately produce a writable milestone map:

SUCCESSOR_MILESTONE=<name>
MILESTONE_PURPOSE=<purpose>

PHASE_1=<name>
PHASE_1_PURPOSE=<purpose>
PHASE_1_CORRIDORS=
  1. <corridor>
  2. <corridor>

PHASE_2=<name or NONE>
PHASE_2_PURPOSE=<purpose or NONE>
PHASE_2_CORRIDORS=
  ...

Continue only for repository-supported phases.

Also preserve:
DEFERRED_BUT_NOT_PROMOTED=
OUT_OF_SCOPE=
DEPENDENCIES=
VALIDATION_BOUNDARY=
IMPLEMENTATION_AUTHORIZED=NO

If evidence cannot yet support the milestone name or complete map, record
NOT_YET_DETERMINED rather than filling the gap speculatively.
RULES

echo
echo "=== CLASSIFY REMAINING CAPABILITY EVIDENCE ==="

grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=_PRE_RESTORE_BROKEN_STATE \
  --exclude-dir=files \
  'Generation Stability|generation stability|generation-stability|generation policy|generation-policy|reliability|semantic history ranking|hybrid context|recovery|correlation|prompt evolution|model runtime context|20-turn|successor corridor|successor milestone|Deferred successor|Deferred Work|deferred and separate|remaining capability|remaining gap|not yet implemented|implemented but not surfaced|ABSENT|NOT_IMPLEMENTED' \
  docs scripts server routes client/src \
  2>/dev/null |
head -n 1200 || true

echo
echo "=== TARGETED GENERATION STABILITY EVIDENCE ==="

for file in \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh \
  scripts/classify-adaptive-detail-live-stability.sh \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh \
  scripts/classify-adaptive-detail-generation-stability-control-seam.sh \
  scripts/classify-scoped-matilda-generation-control-contract.sh \
  scripts/validate-adaptive-detail-corridor-closure.sh
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    grep -nEi \
      'Generation Stability|generation stability|generation policy|reliability|defer|successor|scope|control seam|acceptance|remaining|not.*response composition|Conversation Engine' \
      "$file" |
    head -n 220 || true
  fi
done

echo
echo "=== TARGETED SEMANTIC-HISTORY DEFERRED EVIDENCE ==="

for file in \
  docs/architecture/SEMANTIC_HISTORY_INVENTORY.md \
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md \
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md \
  docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    grep -nEi \
      'defer|ranking|hybrid|token|context|recovery|correlation|prompt|model|remaining|future|not implemented' \
      "$file" |
    head -n 260 || true
  fi
done

echo
echo "=== CURRENT CAPABILITY CLASSIFICATION FRAME ==="
cat <<'FRAME'
A. SOLVED_OR_STABILIZED
   Conversation Engine core workflow and the four completed Collaboration
   Runtime phases are excluded from successor candidacy unless contradictory
   evidence reopens them.

B. IMPLEMENTED_BUT_NOT_SURFACED
   Must be identified from repository evidence before deciding whether
   presentation/exposure constitutes a successor responsibility.

C. PARTIALLY_IMPLEMENTED_OR_CHARACTERIZED
   Must identify an actual bounded remaining capability gap.

D. DEFERRED_AND_POTENTIALLY_ELIGIBLE
   Generation Stability is known to belong here pending reassessment.
   Other deferred Conversation Engine concerns must be evaluated independently.

E. ABSENT_CAPABILITY
   Must be architecturally meaningful and evidenced as missing.

F. OUTSIDE_MATILDA_BOUNDARY
   Organizational governance, unrelated Mission Control work, infrastructure,
   deployment, or other subsystem concerns remain excluded unless repository
   evidence establishes a direct Matilda dependency.
FRAME

echo
echo "=== DISCOVERY CLASSIFICATION ==="
echo "POST_COLLABORATION_RUNTIME_CAPABILITY_CLASSIFICATION=IN_PROGRESS"
echo "SUCCESSOR_MILESTONE=NOT_YET_DETERMINED"
echo "MILESTONE_PURPOSE=NOT_YET_DETERMINED"
echo "SUCCESSOR_PHASE_MAP=NOT_YET_DETERMINED"
echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DETERMINED"
echo "GENERATION_STABILITY=DEFERRED_AND_POTENTIALLY_ELIGIBLE"
echo "GENERATION_STABILITY_CANONICAL_PROMOTION=NOT_YET_AUTHORIZED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_STARTED=NO"
echo "DR_TIME=NO"
echo "NEXT_ACTION=DISCOVER_AND_RECORD_SUCCESSOR_MILESTONE_PHASE_AND_CORRIDOR_MAP"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-post-collaboration-runtime-capability-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside milestone-discovery classification changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-post-collaboration-runtime-capability-state.sh
git diff --cached --check
git commit -m "Classify post collaboration runtime capability state"
git push
