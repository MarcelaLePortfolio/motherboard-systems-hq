
# Worker Visual Helpers

This directory is reserved for additive worker-side visual composition helpers.

## Rules

- Helpers must not replace the existing Preview route.

- Helpers must not require iframe/srcdoc restoration.

- Helpers must not remove markdown fallback.

- Helpers must not mutate execution strategy enums.

- Helpers must preserve existing visual artifact metadata.

## Intended Future Responsibilities

- Detect visual artifact requests.

- Produce visual composition metadata.

- Generate safer artifact-native render hints.

- Support future preview-aware refinement loops.

