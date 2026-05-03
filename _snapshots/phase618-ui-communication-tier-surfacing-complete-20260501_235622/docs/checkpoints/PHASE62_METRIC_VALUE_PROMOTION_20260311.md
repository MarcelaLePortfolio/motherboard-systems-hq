# Phase 62 Metric Value Promotion
Date: 2026-03-11

## Intent
Make the metrics panel read like telemetry tiles rather than miniature content cards.

## Change
- Move each numeric value above its label
- Increase value emphasis
- Reduce tile height slightly
- Preserve 2x2 grid layout
- Preserve IDs and behavior

## Reason
The prior pass tightened sizing, but the metric cards still read label-first.
This pass makes the number the primary readout.
