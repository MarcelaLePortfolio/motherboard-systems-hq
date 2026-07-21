# AF-005 — Historical Runtime and Current Runtime Have Diverged

Status: Accepted

Confidence: High

## Question

Should historical runtime implementations be assumed to represent the behavior of the current system?

## Evidence

### Repository Evidence

Repository inspection identified:

- Historical runtime artifacts that no longer align with the active server implementation
- Active compatibility endpoints exposed through the current runtime
- Historical implementations that are incomplete or no longer exercised by the running system

### Reasoning

The coexistence of historical runtime code and active runtime implementations demonstrates that not every server artifact represents current system behavior. Runtime authority must therefore be established through the active implementation rather than historical source files alone.

## Finding

The historical runtime and the current runtime have diverged.

Historical implementation artifacts should not be treated as authoritative without corroborating evidence from the active runtime.

## Implications

Repository investigation should distinguish between historical artifacts and active runtime behavior.

Future architectural decisions should prioritize evidence from the current runtime when resolving questions about system behavior.

## Supersedes

None.
