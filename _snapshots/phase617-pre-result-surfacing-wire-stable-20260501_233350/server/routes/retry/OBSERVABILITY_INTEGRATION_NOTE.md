# Observability Integration Note (SAFE / NON-INVASIVE)

This file documents how to safely integrate structured logging into retry flows.

## DO NOT:
- Inject into execution-critical paths
- Await or depend on logging
- Modify existing retry logic

## SAFE PATTERN (REFERENCE ONLY)

import { structuredLog } from "../../utils/observability/index.mjs";

// Example (ONLY at safe boundary, e.g. after response sent or debug branch)
structuredLog("retry.routed", {
  mode: "standard",
  taskId: "123",
});

## PRINCIPLE

Observability must remain:
- Non-blocking
- Side-effect free
- Removable without system impact

## STATUS

DO NOT IMPLEMENT YET — documentation only
