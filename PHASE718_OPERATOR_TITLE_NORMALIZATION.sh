
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

rm -f PHASE718_OPERATOR_TITLE_NORMALIZATION.sh.bak

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle = '      const title = esc(t.title || t.task_id || t.id || "Untitled task");'

replacement = '''      const rawTitle = String(t.title || t.task_id || t.id || "Untitled task");

      const retryTitleMatch = rawTitle.match(/^(retry differently|requeue)\\s+(t_[a-f0-9-]+)$/i);

      const operatorTitle = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : rawTitle;

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);'''

if replacement not in text:

    if needle not in text:

        raise SystemExit("Expected title line not found; aborting.")

    text = text.replace(needle, replacement, 1)

needle_meta = '${updated ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">updated=${updated}</div>` : ""}'

replacement_meta = '''${updated ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">updated=${updated}</div>` : ""}

          ${targetTitle ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">target=${targetTitle}</div>` : ""}'''

if replacement_meta not in text:

    if needle_meta not in text:

        raise SystemExit("Expected metadata line not found; aborting.")

    text = text.replace(needle_meta, replacement_meta, 1)

path.write_text(text)

PY

node --check "$TARGET"

echo "Normalization anchors:"

grep -nE "rawTitle|retryTitleMatch|operatorTitle|targetTitle|target=" "$TARGET" | head -20

git add "$TARGET" PHASE718_OPERATOR_TITLE_NORMALIZATION.sh

git commit -m "Phase 718: normalize retry task titles"

git push origin dev

