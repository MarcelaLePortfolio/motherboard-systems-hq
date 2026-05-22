
# Render-Native Sandbox HTML Structure Evidence

Status: VERIFIED

Verified source:

- scripts/render-native/output/rendered-sandbox.html

- sandbox/output-snapshots/rendered-sandbox-20260522-095110.html

Observed root:

- #sandbox-render-root

Observed node structure:

- container-node

  - data-node-id="root-node"

  - data-style-token="background"

  - data-layout-token="stack"

- text-node

  - data-node-id="title-node"

  - data-style-token="text"

  - data-layout-token="card"

- text-node

  - data-node-id="body-node"

  - data-style-token="accent"

  - data-layout-token="card"

Verified content:

- Render-Native Sandbox Active

- Deterministic payload emission validated outside live Preview.

Conclusion:

The sandbox renderer emits deterministic HTML with stable node IDs, style tokens, layout tokens, and render root. Future live Preview integration planning must begin from this structure and remain sandbox-first until explicitly approved.

