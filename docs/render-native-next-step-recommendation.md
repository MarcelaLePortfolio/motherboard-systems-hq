
# Render-Native Next Step Recommendation

Status: READY

Corridor: SANDBOX ONLY

Recommended next implementation:

Add one new semantic node type:

- list

Why list node first:

- supports evidence summaries

- supports readiness checks

- supports blocker lists

- supports execution steps

- improves visual usefulness without introducing asset loading, chart rendering, or runtime complexity

Do not add yet:

- images

- charts

- interactive controls

- live Preview adapter

- production renderer wiring

Reason:

The sandbox renderer is stable, styled, and backed up. The safest next expansion is one deterministic node type that increases semantic expressiveness while preserving renderer containment.

