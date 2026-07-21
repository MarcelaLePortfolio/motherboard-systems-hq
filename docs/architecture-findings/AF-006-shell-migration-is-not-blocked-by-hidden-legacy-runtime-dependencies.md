# AF-006 — Shell Migration Is Not Blocked by Hidden Legacy Runtime Dependencies

Status: Accepted

Confidence: High

## Question

Does the React shell migration depend on undiscovered runtime behavior embedded within the legacy dashboard?

## Evidence

### Repository Evidence

Repository inspection established that:

- The React shell is architecturally independent of the legacy dashboard.
- The server owns the authoritative SSE contract.
- Legacy dashboard modules primarily consume server behavior.
- Historical runtime artifacts are distinct from the active runtime.

### Reasoning

The discovery corridor found no evidence that essential runtime semantics remain hidden exclusively within the legacy dashboard. The architectural dependencies required for migration are explicit and centered on the active server contract.

## Finding

Shell migration is not blocked by hidden legacy runtime dependencies.

Migration work should focus on preserving server contracts and intentionally reimplementing presentation behavior rather than searching for undiscovered runtime logic.

## Implications

Future migration efforts can proceed from established architectural boundaries with reduced risk of uncovering critical hidden runtime behavior late in the process.

Additional repository investigation should be driven by new evidence rather than an assumption of undiscovered coupling.

## Supersedes

None.
