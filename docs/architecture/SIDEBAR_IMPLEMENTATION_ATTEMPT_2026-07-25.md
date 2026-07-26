# Sidebar Implementation Attempt — 2026-07-25

Commit `750eb79d` established the intended navigation destinations but did not produce the approved sidebar experience.

Observed mismatch:

- Generic browser buttons wrapped horizontally.
- Existing shell typography and spacing remained in control.
- Conversations were hard-coded rather than rendered from authoritative project-scoped conversation data.
- The conversation region was not independently scrollable.
- Department and utility destinations were not visually separated.
- The result did not match the approved Mission Control sidebar reference.

This approach is reverted rather than layered with speculative styling.

The next sidebar implementation must begin by inspecting the existing shell CSS, conversation provider/runtime boundary, and rendered navigation structure before replacing the sidebar as one bounded slice.
