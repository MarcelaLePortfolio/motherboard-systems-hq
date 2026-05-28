
# Governed Planning Route Smoke Result

## Context

The initial governed planning route smoke committed in:

    50dd539b Add governed planning route smoke validation

contained a payload-shape mismatch.

The smoke attempted to pass the flat route payload directly into the governed planning pipeline, but the pipeline expects a structured input containing:

- intent

- mutation_scope

- execution_plan

- patch_spec

## Failure Observed

The failing smoke returned:

    Error: execution intent requires objective

with code:

    MISSING_EXECUTION_OBJECTIVE

## Corrective Commit

The fix was committed in:

    d6e58b7c Fix governed planning route smoke payload shape

## Correction Applied

The smoke was updated to transform the flat route payload into the canonical pipeline input shape:

- payload.actor -> intent.actor

- payload.target -> intent.target

- payload.objective -> intent.objective

- payload.requested_outcome -> intent.requested_outcome

- payload.proposed_changes -> patch_spec.patches

The smoke now supplies explicit:

- mutation_scope

- execution_plan

- patch_spec

## Passing Smoke Result

The corrected smoke returned:

    {

      "ok": true,

      "route_validation": "governed_planning_route_smoke",

      "phase": "planning_only",

      "envelope_version": "matilda.cade.exec.v1",

      "governance_ok": true,

      "approval_gate_ok": true,

      "cade_plan_ok": true,

      "mutation_performed": false,

      "shell_execution_performed": false,

      "autonomous_execution_performed": false

    }

## Stabilized Meaning

The governed planning route smoke now proves that route-style payloads can be translated into the canonical governed planning pipeline shape.

## Boundary Preserved

The route smoke confirms:

- no mutation occurred

- no shell execution occurred

- no autonomous execution occurred

- governance validation passed

- approval gate passed

- Cade planning passed

- canonical envelope version remained `matilda.cade.exec.v1`

## Protocol Note

This was a targeted correction after a failing smoke, not a speculative layer.

No rollback was required because the failure had an obvious cause and a narrowly scoped fix.

