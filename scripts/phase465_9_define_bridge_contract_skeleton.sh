#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase465_9_bridge_contract_skeleton.txt"

mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 465.9 — GOVERNANCE → EXECUTION BRIDGE CONTRACT SKELETON
=============================================================

CLASSIFICATION INPUT

Phase 465.1 classification:
PARTIAL_BRIDGE_WITH_PREP

Phase 465.2 gap analysis:
FULL_CHAIN_DISCONNECTED

Confirmed owner candidates selected for focused bridge definition:
- Intake owner: server/taskContract.mjs
- Governance owner: server/policy/policy_eval.mjs
- Execution/preparation owner: server/orchestration/policy-pipeline.ts

PURPOSE

Define the explicit structural bridge contract that does NOT yet enable
execution expansion, but does establish a deterministic handoff model between:

1. Intake normalization boundary
2. Governance evaluation boundary
3. Execution/preparation boundary

NO RUNTIME WIRING
NO EXECUTION EXPANSION
NO AUTHORITY REDISTRIBUTION

────────────────────────────────

CURRENT OWNER ROLES

1) INTAKE OWNER
File:
server/taskContract.mjs

Observed role:
- normalize incoming task state
- validate new task shape
- validate allowed status transitions
- canonicalize task record before read/write boundaries

Structural responsibility:
- produce a normalized, valid task envelope
- reject malformed or invalid task states before governance sees them

2) GOVERNANCE OWNER
File:
server/policy/policy_eval.mjs

Observed role:
- derive deterministic governance signals from task/run context
- produce shadow-mode decision object
- produce reasons/confidence/enforcement posture without side effects

Structural responsibility:
- evaluate normalized intake payload
- emit governance decision package
- remain side-effect free

3) EXECUTION/PREPARATION OWNER
File:
server/orchestration/policy-pipeline.ts

Observed role:
- collect policy decisions
- apply decisions to orchestration context
- emit orchestration events
- advance context through policy pipeline loop

Structural responsibility:
- consume governance decision package
- convert approved decision outputs into preparation-stage context/event emission
- still not equivalent to execution runtime expansion

────────────────────────────────

MISSING STRUCTURAL BRIDGE

No explicit contract currently defines:

normalized intake payload
→ governance evaluation input
→ governance decision output
→ preparation-ready pipeline input

This is the disconnected chain boundary.

────────────────────────────────

REQUIRED BRIDGE CONTRACT

A future explicit bridge contract should define, at minimum:

A. Intake → Governance handoff

Input shape requirements:
- task.id
- task.title
- task.agent
- task.status
- task.notes
- task.source
- task.trace_id
- task.error
- task.meta
- task.created_at
- task.updated_at

Guarantees:
- normalized
- validated
- canonical status
- deterministic field presence rules

B. Governance evaluation package

Input:
- normalized task envelope
- optional run envelope
- stable now_ms capture

Output:
- version
- decision.allow
- decision.enforce
- decision.reasons[]
- decision.confidence
- signals.task_id
- signals.run_id
- signals.kind
- signals.action_tier
- signals.attempts
- signals.max_attempts
- signals.claimed_by
- signals.now_ms

Guarantees:
- side-effect free
- replay-stable
- no mutation of intake object
- explicit decision package only

C. Governance → Preparation bridge

Preparation consumer should accept:
- normalized intake envelope
- governance decision package
- optional orchestration event seed

Preparation boundary outputs may include:
- policy pipeline context update
- emitted orchestration events
- operator mode changes
- intent changes

But must NOT yet include:
- direct worker execution
- runtime execution launch
- autonomous self-authorization
- implicit task dispatch

────────────────────────────────

PROPOSED BRIDGE CONTRACT SKELETON

Conceptual contract name:
GovernanceExecutionBridgeContract

Shape:

{
  intake: {
    task: NormalizedTaskEnvelope,
    run?: NormalizedRunEnvelope
  },
  governance: {
    version: string,
    decision: {
      allow: boolean,
      enforce: boolean,
      reasons: Array<{ code: string, value?: string }>,
      confidence: string
    },
    signals: {
      task_id: string | null,
      run_id: string | null,
      kind: string | null,
      action_tier: string | null,
      attempts: number | null,
      max_attempts: number | null,
      claimed_by: string | null,
      now_ms: number
    }
  },
  preparation: {
    accepted: boolean,
    ctx_updates: {
      operatorMode?: string,
      intent?: string
    },
    emitted_events: Array<unknown>
  }
}

────────────────────────────────

INVARIANTS

Required invariants for future implementation:

- Intake must be normalized before governance evaluation.
- Governance evaluation must remain side-effect free.
- Governance output must be explicit and serializable.
- Preparation must consume governance package explicitly.
- Preparation may emit events, but may not directly execute work.
- No mutation of source intake object across bridge stages.
- All bridge stages must be replay-stable.

────────────────────────────────

NEXT PHASE TARGET

Next phase should NOT wire behavior yet.

Next phase should:
- define the bridge contract file
- map each owner file to the contract boundaries
- prove compatibility without runtime mutation

That keeps the corridor structural, deterministic, and within scope.
EOT

echo "Wrote $OUT"
