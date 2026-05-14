
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VISUAL PREVIEW DIRECTION CHECKPOINT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_VISUAL_PREVIEW_DIRECTION_CHECKPOINT.txt"

cat > "$OUT" << 'NOTE'

PHASE 719 VISUAL PREVIEW DIRECTION CHECKPOINT

Current state:

- Preview pill works.

- Preview modal opens.

- Preview route fetches artifact content successfully.

- Shared worker/dashboard artifact volume works.

- Current artifact content is markdown text, so modal still renders text.

Correct target:

- Preview should become a visual artifact surface, not another descriptive/details modal.

- Details/Trace/Logs remain text/debug surfaces.

- Preview should show what was built.

Implication:

- Do not keep improving the raw text modal as the final Preview UX.

- Next corridor should create a rendered visual preview layer.

- For markdown artifacts, render into a visual document/card surface.

- For future HTML/image artifacts, render as visual output directly.

- Preserve read-only route and no retry/execution contract changes.

Next safe mutation:

- Replace raw preformatted preview body with a rendered visual artifact container.

- Keep raw markdown hidden/fallback only, not primary.

NOTE

git add PHASE719_VISUAL_PREVIEW_DIRECTION_CHECKPOINT.sh

git add "$OUT"

git commit -m "Phase 719: checkpoint visual preview direction"

git push origin "$BRANCH"

