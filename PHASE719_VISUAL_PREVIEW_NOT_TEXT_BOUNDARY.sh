
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VISUAL PREVIEW NOT TEXT BOUNDARY ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_VISUAL_PREVIEW_NOT_TEXT_BOUNDARY.txt"

cat > "$OUT" << 'NOTE'

PHASE 719 VISUAL PREVIEW NOT TEXT BOUNDARY

Current confirmed state:

- Artifact persistence works.

- Shared worker/dashboard artifact volume works.

- Read-only artifact preview route works.

- Preview modal fetches artifact content.

- Markdown renderer is active.

User-visible issue:

- Preview still appears as text.

- This is not the target UX.

Correct interpretation:

- Rendering markdown as styled text is insufficient.

- Preview must represent the artifact visually.

- Details, Trace, Logs can remain text.

- Preview should not be another text/debug/info modal.

Architectural implication:

- Current worker artifacts are markdown files.

- A truly image-like preview needs either:

  1. worker-produced HTML/image artifacts, or

  2. a frontend visual renderer that converts artifact content into a visual mock/snapshot surface.

Next safe corridor:

- Do not keep polishing raw markdown.

- Create a distinct visual preview surface.

- Hide raw markdown by default.

- Suppress execution trace from Preview.

- Preserve raw markdown only behind a fallback/debug affordance if needed.

- Preserve read-only route.

- Preserve retry/execution contracts.

- Preserve DB schema.

NOTE

git add PHASE719_VISUAL_PREVIEW_NOT_TEXT_BOUNDARY.sh

git add "$OUT"

git commit -m "Phase 719: define visual preview not text boundary"

git push origin "$BRANCH"

echo "===== VISUAL PREVIEW BOUNDARY CHECKPOINT COMPLETE ====="

