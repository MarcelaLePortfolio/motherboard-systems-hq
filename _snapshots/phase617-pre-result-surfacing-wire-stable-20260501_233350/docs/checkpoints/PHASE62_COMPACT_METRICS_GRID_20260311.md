# Phase 62 Compact Metrics Grid
Date: 2026-03-11

## Intent
Tighten the System Metrics panel now that the top row split is stable.

## Change
- Keep metrics in the right-side top panel
- Reduce card padding
- Reduce number size slightly
- Keep four metrics
- Present them as a compact 2x2 grid instead of one long row

## Reason
The metrics values are short numeric readouts, so the original card sizing is larger than necessary for the information density.

## Guardrails
- No ID changes
- No behavior changes
- No SSE changes
- Preserve Phase 61/62 structural contract
