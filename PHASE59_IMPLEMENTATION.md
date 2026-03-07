# Phase 59 — Dashboard Composition Implementation Pass

## Scope Lock
UI-only composition pass from the restored stable baseline.

## Do Not Change
- backend architecture
- schema
- SSE mechanics
- policy logic
- task lifecycle
- collapsibility
- runtime DOM injection overlays

## Composition Target
Top bar
- Motherboard Systems Operator Console
- Uptime / Health / heartbeat summary

Agent strip
- Matilda / Cade / Effie / Atlas

Primary row
- Probe Lifecycle summary
- Probe Event Stream

Second row
- Operator tools: Matilda Chat + Task Delegation
- Project Visual Output

Third row
- Atlas Subsystem Status
- System Reflections / secondary diagnostics

## Execution Rules
1. Work directly in dashboard structure and CSS.
2. Reuse existing stable panels.
3. Reorganize hierarchy and visual weight only.
4. Keep Probe Lifecycle + Probe Event Stream visually primary.
5. Keep Project Visual Output secondary but strong.
6. Keep chat / delegation present but quieter than lifecycle truth.
7. Keep Atlas / reflections present as supporting context.
8. No overlay hacks.
9. No JS behavior changes unless strictly required for existing layout wiring.
10. Stop after structural composition pass is stable.

## Acceptance
- single intentional operator console layout
- clean fresh boot rendering
- stable scroll / refresh behavior
- no rendering regressions
- no new runtime instability
