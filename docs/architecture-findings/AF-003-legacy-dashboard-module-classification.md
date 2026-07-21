# AF-003 — Legacy Dashboard Module Classification

Status: Accepted

Confidence: High

## Question

How should the legacy dashboard JavaScript modules be interpreted for future migration work?

## Evidence

### Repository Evidence

Repository inspection of the legacy dashboard JavaScript identified modules spanning:

- presentation
- transport
- domain-adjacent behavior
- legacy integration/glue

Several modules were also determined to be effectively inactive or no-op.

### Reasoning

The legacy dashboard is not architecturally homogeneous. Different modules serve different responsibilities and should not be migrated as a single unit. Classifying modules by responsibility provides a more accurate migration strategy than treating the dashboard as one cohesive application layer.

## Finding

Legacy dashboard modules should be classified by architectural responsibility before migration.

Migration should preserve useful behavior while separating transport, state adaptation, presentation, and legacy integration concerns.

## Implications

Future migration work should evaluate modules individually rather than assuming equivalent architectural value across the legacy dashboard.

Classification should precede replacement or reuse decisions.

## Supersedes

None.
