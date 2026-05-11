
# Phase 717 — Task History Removal Paused

Status: PAUSED

Current stable visual state:

- Recent Tasks: present

- Task History: present

- Execution Inspector: removed

- Recent Logs shell: removed

- Telemetry Console: preserved

- Runtime: healthy

Reason for pause:

- Task History removal attempts proved structurally coupled to telemetry layout wrappers.

- Current source and served dashboard still contain Task History.

- Do not continue removal without a cleaner layout strategy.

- Preserve current stable state instead of layering speculative fixes.

Next safe corridor:

- Leave Task History in place for now.

- Continue polishing Recent Tasks lifecycle card.

- Only revisit Task History removal after mapping surrounding layout dependencies.

- Preserve checkpoint tag: phase717-stable-telemetry-console.

