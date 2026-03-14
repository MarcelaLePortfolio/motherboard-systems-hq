PHASE 65A — PROTECTED SURFACE REGISTRY
Date: 2026-03-14

Purpose:
Authoritative registry of protected dashboard structure.

PROTECTED (STRUCTURE LOCKED)

public/dashboard.html
public/css/dashboard.css
public/js/phase61_tabs_workspace.js
public/js/phase61_recent_history_wire.js

Rules:

No DOM restructuring
No ID mutation
No grid changes
No container movement
No mount order changes

SEMI-PROTECTED

public/js/agent-status-row.js
public/js/dashboard-bundle-entry.js

Allowed:
Behavior fixes
Telemetry wiring

Not allowed:
Layout mutation
DOM structure edits

OPEN SURFACES

Telemetry scripts
Protection guards
Docs
Verification scripts

STRUCTURAL AUTHORIZATION RULE

Any change to protected files requires:

Layout phase declaration
Golden checkpoint
Layout contract pass
Drift guard pass

RECOVERY BASELINE

Golden:
v63.0-telemetry-integration-golden

