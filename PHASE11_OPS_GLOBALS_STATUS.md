
Phase 11 – OPS Globals Status Checkpoint

Dashboard bundle is now wired to OPS SSE via ops-globals-bridge.js.

window.lastOpsHeartbeat and window.lastOpsStatusSnapshot are successfully populated from OPS SSE events (e.g., { type: "hello", source: "ops-sse", ... }) when loading http://127.0.0.1:8080/dashboard.

Matilda chat wiring is confirmed working alongside OPS globals in the unified bundle.js.
