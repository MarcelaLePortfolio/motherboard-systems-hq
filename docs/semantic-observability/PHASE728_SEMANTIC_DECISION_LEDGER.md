
# Phase 728 Semantic Decision Ledger

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Purpose

Record the core authority, safety, and boundary decisions made during Phase 728 semantic observability stabilization.

This ledger preserves the reasoning behind the architecture so future work does not accidentally erase the intent behind the current boundaries.

## Decision Ledger

| Decision | Reason | Risk Prevented | Status |

|---|---|---|---|

| Semantic metadata remains additive only | Preserve runtime stability while allowing observability | Execution drift and hidden orchestration coupling | Preserved |

| Semantic metadata remains artifact-scoped | Keep semantic state attached to outputs, not system control paths | Task routing mutation and top-level semantic leakage | Preserved |

| Markdown fallback remains authoritative | Preserve readable recovery and persistence fallback | Renderer-state corruption and artifact reinterpretation | Preserved |

| Semantic validation remains optional | Prevent semantic helper failure from breaking artifact persistence | Execution failure propagation | Preserved |

| Canonical field is artifact.semantic_artifact | Establish one active producer field | Alias drift and inspection ambiguity | Preserved |

| Defensive aliases remain inspection-only | Preserve devtools resilience without expanding producer surface | Tooling fragmentation and backwards-compatibility breakage | Preserved |

| Runtime attachment is not runtime authority | Allow metadata generation without granting control power | Hidden execution governance by metadata | Preserved |

| Schema reserve values remain inactive unless explicitly promoted | Keep future vocabulary available without implying behavior | Premature semantic authority expansion | Preserved |

| Renderer-authoritative semantics remain deferred | Preserve preview/render containment discipline | Semantic-first rendering drift | Preserved |

| Semantic retry influence remains prohibited | Preserve retry lineage determinism | Retry ambiguity and policy nondeterminism | Preserved |

| Semantic execution routing remains prohibited | Preserve task execution determinism | Classification-driven execution branching | Preserved |

| Preview semantic authority convergence remains deferred | Preserve visual containment and contract clarity | Preview contract mutation and renderer coupling | Preserved |

| Documentation expansion remains allowed | Improve future recovery without runtime risk | Context loss and architectural drift | Preserved |

| Runtime mutation requires explicit future authorization | Prevent accidental corridor escalation | Unreviewed contract mutation | Preserved |

## Operating Principle

Semantic metadata may describe the artifact.

Semantic metadata may not govern the system.

## Human Summary

We did not just add semantic features.

We decided what semantic features are allowed to observe, what they are allowed to describe, and what they are not allowed to control.

That is the core Phase 728 architectural decision.

## Future Use

Before any future corridor promotes semantic metadata into rendering, routing, retry, orchestration, or persistence behavior, this ledger should be reviewed first.

Any future promotion must explicitly answer:

1. What authority is being granted?

2. What contract could be affected?

3. What rollback checkpoint protects the change?

4. What failure mode would force reversal?

5. How does the change preserve deterministic execution?

## Stability Status

This ledger is documentation-only.

No runtime mutation introduced.

No renderer authority introduced.

No orchestration mutation introduced.

