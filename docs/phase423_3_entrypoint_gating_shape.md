PHASE 423.3 — ENTRYPOINT GATING SHAPE

Observed execution entrypoint:

runConsumptionRegistryEnforcementEntrypoint()
  -> createConsumptionRegistryEnforcementReadonlyView()
  -> return { ok, view }

Minimal governed execution pattern:

1. Read governance eligibility snapshot
2. If authorization not eligible:
   return blocked result
3. Else:
   create readonly execution view
   return normal result

Required design rule:

Do not couple entrypoint to governance internals.
Consume only a stable exported eligibility surface.

Implication:

The correct first mutation is result-shape expansion,
not deep wiring.

Candidate future return pattern:

{
  ok: boolean,
  blockedByGovernance: boolean,
  governanceReason?: string,
  view: ConsumptionRegistryEnforcementReadonlyView
}
