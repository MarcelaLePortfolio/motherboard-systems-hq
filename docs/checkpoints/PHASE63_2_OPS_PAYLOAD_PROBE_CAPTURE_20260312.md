# PHASE 63.2 OPS PAYLOAD PROBE CAPTURE
Date: 2026-03-12

## Objective

Capture a bounded live `/events/ops` sample to validate emitted `ops.state` shape against the current agent activity consumer.

## Expected Consumer Inputs

- `payload.agents`
- per-agent status-like field
- per-agent freshness timestamp candidate:
  - `at`
  - `ts`
  - `last_activity`
  - `lastActivity`
  - `last_seen`
  - `lastSeen`

## Rule

Use bounded sample capture only.
Do not broaden search into generated bundle maps or historical extract dumps during producer audit.
