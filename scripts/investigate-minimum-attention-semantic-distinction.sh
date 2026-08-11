#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE MINIMUM ATTENTION SEMANTIC DISTINCTION ==="

REQUIRED_ANCESTOR="d49de622"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 responsibility-boundary classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/investigate-minimum-attention-semantic-distinction\.sh$|^ M scripts/investigate-minimum-attention-semantic-distinction\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING CLASSIFICATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY_CLASSIFIED|MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO|ONE_ACTIVE_INVESTIGATION_PER_CONVERSATION_ASSUMPTION=PRESERVED|UNRESOLVED_SEMANTIC_MATERIAL_DURABLY_PRESERVABLE=YES|RESIDUAL_CANDIDATE_DISTINCTION=PRESERVED_VALID_VS_CURRENTLY_GOVERNING_SEMANTIC_MATERIAL|NEW_ATTENTION_ARTIFACT_REQUIRED=UNDETERMINED|NEXT_UNIT=INVESTIGATE_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION' \
  scripts/classify-phase-3-attention-management-responsibility-boundary.sh

echo
echo "=== INSPECT INVESTIGATION LIFECYCLE GOVERNING SEMANTICS ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'governingQuestion|governing investigation|investigationIdentity|lifecycleEvent|lifecycleDetermination|one active investigation|at most one active investigation' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts.sh \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  2>/dev/null | head -n 1800 || true

echo
echo "=== INSPECT IEL UNRESOLVED-QUESTION SEMANTICS ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'unresolved_questions|unresolved questions|uncertainty|matilda_observation|supporting_raw_evidence|lineage_references|supersession_status' \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_VALIDATED_2026-07-05.md \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  2>/dev/null | head -n 1800 || true

echo
echo "=== INSPECT LIVING DRAFT PRESERVATION SEMANTICS ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'unresolved_questions|unresolved questions|current best understanding|evidence_entry_ids|expected_outcome|constraints|recommended_next_action' \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_RUNTIME_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_VALIDATED_2026-07-05.md \
  2>/dev/null | head -n 1600 || true

echo
echo "=== INSPECT PRESERVATION AND DEFERRED RECONCILIATION EVIDENCE ==="
grep -nE -C 12 \
  'Preservation mechanisms were established|deferred reconciliation|open questions|corridor artifacts|Preservation' \
  docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md |
head -n 1000 || true

echo
echo "=== SEARCH FOR EXPLICIT GOVERNING VS NON-GOVERNING SEMANTICS ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'currently governing|current governing|governing concern|governing question|non-governing|not currently governing|preserved.*governing|deferred concern|deferred question|resume.*question|resume.*investigation|return to.*question|return to.*investigation|regain attention|attention priority|semantic priority' \
  docs scripts server db 2>/dev/null |
head -n 1800 || true

echo
echo "=== SEARCH FOR ACTUAL CONTINUITY FAILURE EVIDENCE ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'forgot|forgetting|forgotten|lost concern|lost question|dropped concern|dropped question|continuity failure|context loss|lost context|deferred.*lost|unresolved.*lost|cannot resume|unable to resume|failed to resume|compete indefinitely|competing concern' \
  docs scripts server db 2>/dev/null |
head -n 1800 || true

echo
echo "=== VERIFY CURRENT PRIOR LIFECYCLE SELECTION ==="
grep -nE -C 12 \
  'priorInvestigationLifecycle|investigationLifecycle|newest|non-null|listInterpretationEvidenceLedgerEntries' \
  server/matilda-chat-workflow.ts |
head -n 1200 || true

echo
echo "=== VERIFY CURRENT LIFECYCLE PROMPT BOUNDARY ==="
grep -nE -C 12 \
  'Prior Matilda-authored Investigation Lifecycle state|priorInvestigationLifecycle|Determine the current investigationLifecycle|governingQuestion' \
  scripts/utils/ollamaChat.ts |
head -n 1200 || true

echo
echo "=== VERIFY CURRENT CONVERSATION CONTEXT DOES NOT OWN ATTENTION ==="
cat server/matilda-conversation-context-runtime.ts

cat <<'FINDINGS'

Phase 3 — Minimum Attention Semantic Distinction investigation:

Starting evidence:

1. Phase 3 responsibility-boundary classification identified only one bounded
   candidate residual distinction:

       PRESERVED_VALID_SEMANTIC_MATERIAL
       versus
       CURRENTLY_GOVERNING_SEMANTIC_MATERIAL

2. That classification did not establish a missing artifact, runtime,
   persistence model, schema field, or prompt behavior.

3. The Investigation Lifecycle contract already provides a positive semantic
   representation of the governing investigation through:

       investigationIdentity
       governingQuestion
       lifecycleEvent
       lifecycleDetermination

4. Current repository evidence intentionally permits at most one active
   investigation per conversation.

5. Therefore the governing Investigation Lifecycle artifact already identifies
   which investigation currently owns semantic continuity.

6. IEL and Living Draft representations already preserve unresolved questions,
   uncertainty, evidence lineage, and current best understanding.

7. Preservation does not require every unresolved semantic concern to become an
   active Investigation Lifecycle artifact.

8. The collaboration evidence demonstrates that preserved open questions and
   corridor artifacts can remain available while reconciliation is deferred.

Required determination:

A. Does a separate attention fact add semantic information that cannot already
   be represented by:
      - the one governing Investigation Lifecycle artifact; plus
      - durable unresolved semantic material?

B. Or would such a fact merely restate that the governing investigation governs
   while other preserved unresolved material does not?

C. Is there repository evidence of an actual failure where Matilda cannot later
   recover a still-valid concern because it was preserved but non-governing?

D. Is there repository evidence that preserved unresolved questions require
   individual priority, suspension, deferral, or resumption states?

E. Is there repository evidence that a concern must remain an active
   investigation while not governing the current collaboration?

F. Is there repository evidence that multiple preserved unresolved concerns
   compete semantically for immediate attention in a way the current governing
   Investigation Lifecycle cannot resolve?

G. Does any existing contract require runtime to choose among preserved
   unresolved concerns?

H. Would runtime selection among such concerns require semantic interpretation
   rather than deterministic validation?

Classification rule:

If the repository establishes:

- one governing Investigation Lifecycle artifact;
- durable preservation of other unresolved semantic material;
- no demonstrated continuity failure caused by the absence of a separate
  attention state; and
- no established requirement for multiple simultaneously active investigations;

then the candidate distinction is already representable without a new
Attention Management semantic artifact.

In that case:

CURRENTLY_GOVERNING
= represented positively by the governing Investigation Lifecycle artifact

PRESERVED_BUT_NOT_CURRENTLY_GOVERNING
= unresolved semantic material that remains durably preserved but is not the
  governing Investigation Lifecycle artifact

This is a relational distinction derived from existing semantic ownership, not
a new semantic status that must itself be persisted.

A new semantic fact is justified only if repository evidence demonstrates that
this relational distinction is insufficient to preserve or recover meaning.

Absence of a convenience representation is not evidence of a missing semantic
capability.

Absence of an explicit "deferred" field is not evidence that deferred valid
material is lost.

Do not manufacture a continuity failure from a hypothetical future use case.

Do not require explicit negative state for every preserved concern merely
because the governing concern has explicit positive state.

Do not reinterpret unresolved_questions as active investigations.

Do not reinterpret unresolved_questions as attention queues.

Do not introduce concurrent active investigations.

Do not infer priority from chronology.

Do not infer priority from retrieval rank.

Do not infer priority from selectedHistory order.

Do not infer priority from evidence order.

Do not infer priority from persistence order.

Do not reopen Phase 1.

Do not reopen Phase 2.

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

governing Investigation Lifecycle
= positive semantic representation of the currently governing investigation

unresolved questions / preserved semantic material
= durable representation of meaning that may remain valid without governing the
  immediate collaboration

one active investigation per conversation
= current bounded architectural assumption

Attention Management
= must not become a duplicate representation unless evidence demonstrates a
  semantic gap between those existing capabilities

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_INVESTIGATED"
echo "GOVERNING_INVESTIGATION_POSITIVELY_REPRESENTED=YES"
echo "NON_GOVERNING_UNRESOLVED_MATERIAL_DURABLY_PRESERVABLE=YES"
echo "EXPLICIT_DEFERRED_LIFECYCLE_EVENT=NO"
echo "MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO"
echo "ATTENTION_DISTINCTION_CANDIDATE=RELATIONAL_EXISTING_SEMANTICS"
echo "NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NOT_ESTABLISHED"
echo "ACTUAL_CONTINUITY_FAILURE_REQUIRED_BEFORE_NEW_SEMANTIC_FACT=YES"
echo "PHASE_3_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION"

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
  echo "STOP: production runtime changed during minimum Attention semantic-distinction investigation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-minimum-attention-semantic-distinction\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside minimum Attention semantic-distinction investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-minimum-attention-semantic-distinction.sh
git diff --cached --check
git commit -m "Investigate minimum Attention Management semantic distinction"
git push
