# Motherboard Systems HQ — Greenfield UI Rebuild

## Primary instruction

Treat this as a greenfield frontend project.

The existing legacy dashboard implementation was intentionally excluded because it contains accumulated corruption, historical compatibility layers, duplicate wiring, malformed structure, and incomplete recovery artifacts.

Do not attempt to locate, reconstruct, imitate, import, or infer the previous UI.

Build an entirely new frontend shell from first principles using only:

1. The contracts included in this safe-share package.
2. The reusable React/TypeScript modules included under `reusable/`.
3. Explicit requirements supplied by the user during the engagement.

## Hard boundaries

- Do not request or use `public/index.html`.
- Do not request or use legacy phase scripts.
- Do not request or use backups, snapshots, rollback files, archives, or recovery artifacts.
- Do not treat compatibility routes or placeholder runtime files as backend truth.
- Do not copy visual structure, layout, state wiring, or event handling from the former dashboard.
- Do not silently invent backend capabilities.
- Clearly label missing, proposed, and confirmed contracts.
- Preserve semantic meaning separately from runtime implementation.
- Design against explicit interfaces rather than historical implementation details.

## Required working sequence

Before implementation:

1. Read the complete safe-share package, including:
   - 07_UI_SHELL_DIRECTION.md
   - 08_FRONTEND_IMPLEMENTATION_BOUNDARIES.md
   - 09_OPEN_QUESTIONS.md
2. Identify confirmed contracts, reusable modules, unresolved dependencies, and any hidden coupling to the legacy dashboard.
3. Evaluate the proposed UI shell against the existing backend contracts before proposing architectural changes.
4. Explicitly distinguish:
   - confirmed backend truth
   - frontend interpretation
   - architectural proposal
   - unresolved question
5. Present the evaluation and recommended architecture for user review before writing implementation code.
6. Keep implementation paused until explicitly authorized by the user.

## Reusable code policy

Files under `reusable/` are reference-quality building blocks, not a required application skeleton.

You may:

- preserve them unchanged
- adapt them behind clean interfaces
- extract their models or logic
- recommend replacing a component when its dependencies are unsuitable

You must not assume they define the overall application architecture.

## Outcome

The result should be a new, coherent, maintainable frontend with a newly created application entrypoint and UI shell. It must not inherit structural assumptions from the corrupted legacy dashboard.
