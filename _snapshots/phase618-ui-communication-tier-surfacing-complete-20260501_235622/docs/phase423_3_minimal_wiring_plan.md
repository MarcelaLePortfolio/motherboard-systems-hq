PHASE 423.3 — MINIMAL WIRING PLAN

Planned order:

1. Expand ConsumptionRegistryEnforcementEntrypointResult
   to include governance gating fields

2. Preserve existing execution behavior

3. Add a single governance eligibility read
   at the execution entrypoint

4. Return blocked result if governance is not eligible

5. Leave downstream execution internals untouched

Required boundary:

Execution must consume only a stable exported
governance eligibility surface.

No direct coupling to governance internals allowed.
