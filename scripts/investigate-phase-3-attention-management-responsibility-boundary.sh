#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE PHASE 3 ATTENTION MANAGEMENT RESPONSIBILITY BOUNDARY ==="

REQUIRED_ANCESTOR="169d30e3"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 current-state classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INVESTIGATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-phase-3-attention-management-responsibility-boundary\.sh$|^ M scripts/investigate-phase-3-attention-management-responsibility-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING PHASE 3 CLASSIFICATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE_CLASSIFIED|DEDICATED_ATTENTION_SEMANTIC_ARTIFACT=ABSENT|DEDICATED_ATTENTION_RUNTIME=ABSENT|DEDICATED_ATTENTION_PERSISTENCE=ABSENT|ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY=UNRESOLVED|PHASE_3_IMPLEMENTATION=NOT_AUTHORIZED|NEXT_UNIT=INVESTIGATE_PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY' \
  scripts/classify-phase-3-attention-management-current-state.sh

echo
echo "=== INVENTORY COLLABORATION-RUNTIME GOVERNANCE / PHASE DEFINITIONS ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Attention Management|attention management|Phase 3|PHASE_3|active attention|deferred work|governing attention|attention allocation|attention priorit' \
  docs scripts server db 2>/dev/null |
head -n 2200 || true

echo
echo "=== INVENTORY INVESTIGATION-LIFECYCLE ATTENTION SEMANTICS ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'governingQuestion|governing investigation|govern.*attention|cease governing attention|superseded|abandoned|resolved' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh \
  scripts/classify-phase-2-investigation-lifecycle-closure.sh \
  scripts/utils/ollamaChat.ts 2>/dev/null |
head -n 1800 || true

echo
echo "=== INVENTORY HISTORY AUTHORITY / CONTAMINATION / SELECTION ==="
sed -n '1,240p' server/matilda-history-authority-evaluator.ts
printf '\n--- CONTAMINATION ---\n'
sed -n '1,280p' server/matilda-history-contamination-evaluator.ts
printf '\n--- SELECTION ---\n'
cat server/matilda-history-selection-runtime.ts

echo
echo "=== INVENTORY PROJECT-CONTEXT RETRIEVAL / SEGMENT SELECTION INPUTS ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'projectContextExcerpts|projectContextSegmentCandidates|selectedContextSegments|candidate_evidence_not_authority|materially affects the immediate reply' \
  server scripts/utils 2>/dev/null |
head -n 1800 || true

echo
echo "=== SEARCH FOR PRIORITY / DEFERRED / ACTIVE-CONCERN SEMANTICS ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-phase-3-attention-management-responsibility-boundary.sh' \
  'priority|prioritize|prioritization|deprioritize|deferred|defer|active concern|active question|current concern|current objective|governing objective|competing concern|multiple concerns|focus of attention|attention target' \
  docs scripts server db 2>/dev/null |
head -n 2400 || true

echo
echo "=== SEARCH FOR EXISTING SEMANTIC OBJECTS THAT COULD RECEIVE ATTENTION ==="
grep -RInE -C 5 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'unresolved_questions|unresolved question|investigationIdentity|governingQuestion|objective|concern|work item|candidate.*question|question.*candidate' \
  server db scripts/utils docs 2>/dev/null |
head -n 2200 || true

echo
echo "=== SEARCH FOR MULTIPLE-SIMULTANEOUS-INVESTIGATION SUPPORT ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'multiple investigation|simultaneous investigation|concurrent investigation|active investigations|investigation.*array|investigations.*array|investigation candidates|candidate investigations' \
  docs scripts server db 2>/dev/null |
head -n 1400 || true

echo
echo "=== VERIFY CURRENT SINGLE PRIOR-LIFECYCLE CHANNEL ==="
grep -nE -C 8 \
  'priorInvestigationLifecycle|Prior Matilda-authored Investigation Lifecycle state' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY CURRENT CONVERSATION CONTEXT CONTRACT ==="
cat server/matilda-conversation-context-runtime.ts

cat <<'FINDINGS'

Phase 3 — Attention Management responsibility-boundary investigation:

Established starting boundary:

PHASE_1_RESPONSE_COMPOSITION=CLOSED
PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED
PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE=CLASSIFIED
DEDICATED_ATTENTION_SEMANTIC_ARTIFACT=ABSENT
DEDICATED_ATTENTION_RUNTIME=ABSENT
DEDICATED_ATTENTION_PERSISTENCE=ABSENT
ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY=UNRESOLVED
PHASE_3_IMPLEMENTATION=NOT_AUTHORIZED

This investigation must identify the residual responsibility, if any, that
remains after existing capabilities are accounted for.

Required decomposition:

1. Response Composition already owns how the immediate response is composed,
   including adaptive detail behavior.

2. Conversation-history preparation already owns deterministic eligibility,
   contamination evaluation, and selectedHistory construction.

3. Project-context retrieval and selectedContextSegments already provide bounded
   candidate evidence and semantic admission for the immediate response.

4. Investigation Lifecycle already allows Matilda to identify a governing
   investigation, preserve its semantic identity, state its governingQuestion,
   and author lifecycle events.

5. Therefore none of those capabilities may simply be renamed Attention
   Management.

Questions requiring evidence-based determination:

A. What user-visible or semantic failure remains possible despite all of the
   above capabilities being present?

B. Can Matilda currently distinguish between multiple simultaneously relevant
   concerns that are all valid but should receive different levels of immediate
   attention?

C. Does the current Investigation Lifecycle contract permit only one governing
   investigation artifact per turn, and if so, is that intentionally sufficient
   or evidence of a residual attention-allocation problem?

D. Is "deferred" a semantic status already represented anywhere, or is deferred
   work currently only a collaboration/governance concept?

E. Can a concern remain valid and unresolved while intentionally not governing
   the immediate response?

F. If yes, what existing durable semantic representation identifies that
   concern so it can later regain attention?

G. Does superseded or abandoned mean a concern is semantically ended rather
   than merely deprioritized?

H. Does resolved mean a question is determined rather than temporarily removed
   from attention?

I. If those lifecycle events are terminal semantic meanings rather than
   attention priorities, does Phase 3 require a separate concept for
   "still valid, but not currently governing"?

J. Is attention fundamentally selection among multiple valid semantic concerns,
   rather than selection among raw conversation turns or evidence excerpts?

K. If attention requires semantic prioritization, must Matilda author that
   prioritization because runtime cannot infer semantic importance safely?

L. After Matilda authors priority, what deterministic runtime responsibility,
   if any, is necessary?

M. Is persistence necessary for deferred-but-still-valid concerns to survive
   across turns, or can existing durable artifacts represent them?

N. Would a new Attention Management artifact duplicate Investigation Lifecycle,
   or does evidence establish a genuinely orthogonal semantic dimension?

O. What is the minimum semantic distinction needed to prevent Matilda from
   either forgetting valid deferred concerns or allowing them to compete
   indefinitely with the immediate governing concern?

P. What evidence would establish that no new Phase 3 runtime is needed and that
   existing Investigation Lifecycle plus context selection already satisfies
   the intended responsibility?

Classification discipline:

Do not assume Phase 3 requires a new artifact.

Do not assume Phase 3 requires persistence.

Do not assume Phase 3 requires multiple investigations.

Do not assume "deferred" is a lifecycle event.

Do not reinterpret superseded or abandoned as temporary deprioritization unless
repository evidence explicitly supports that meaning.

Do not make deterministic runtime the author of semantic importance.

Do not treat chronology as priority.

Do not treat retrieval rank as semantic priority.

Do not treat selectedHistory eligibility as semantic priority.

Do not treat selectedContextSegments admission as semantic priority.

Do not reopen Adaptive Detail Selection.

Do not reopen Investigation Lifecycle.

Do not implement.

Do not change database schema.

Do not change structured response schema.

Do not change prompts.

Do not change workflow behavior.

Do not change Conversation Context Runtime.

Do not add model invocations.

Preserve:

Matilda
= semantic Interpretation Authority

Response Composition
= closed Phase 1 responsibility

Investigation Lifecycle
= closed Phase 2 semantic continuity responsibility

History Selection
= deterministic eligible conversation-history selection

Project Context Selection
= bounded evidence/context admission

Runtime
= deterministic responsibilities only when explicit invariants are established

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts
then
  echo "STOP: production runtime changed during Phase 3 responsibility-boundary investigation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-phase-3-attention-management-responsibility-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 3 investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-phase-3-attention-management-responsibility-boundary.sh
git diff --cached --check
git commit -m "Investigate Phase 3 Attention Management responsibility boundary"
git push
