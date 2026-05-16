
# Worker Semantic Helpers

This directory is reserved for additive worker-side semantic artifact helpers.

## Rules

- Helpers must not mutate task contracts.

- Helpers must not mutate retry contracts.

- Helpers must not require database migrations.

- Helpers must preserve markdown fallback output.

- Helpers must be inspectable before being wired into runtime execution.

## Intended Future Responsibilities

- Classify artifact kind.

- Classify semantic intent.

- Extract structured sections.

- Prepare semantic metadata for Preview.

- Reduce frontend-only semantic interpretation over time.

