
# Phase 717 — Recent Tasks Minimal Polish Plan

Objective:

Perform ONE contained Recent Tasks visual polish pass only.

Scope:

- Improve spacing/padding inside Recent Tasks cards

- Slightly improve action button grouping

- Preserve all telemetry wrappers

- Preserve Task History

- Preserve Telemetry Console structure

- Preserve execution/task contracts

- Preserve SSE/event wiring

Non-goals:

- No tab removals

- No telemetry container restructuring

- No broad CSS rewrites

- No retry architecture changes

- No execution coupling changes

- No lifecycle pipeline changes

Success criteria:

- Recent Tasks easier to scan visually

- Runtime remains stable

- No DOM breakage

- No missing panels

- Rollback remains anchored to:

  phase717-stable-telemetry-console

Protocol:

- Single contained UI pass only

- Validate immediately after change

- Seal checkpoint if stable

- Move back to higher-ROI work afterward

