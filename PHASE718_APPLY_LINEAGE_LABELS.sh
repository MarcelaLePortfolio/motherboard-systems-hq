
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle = '      const explanation = esc(t.explanation_preview || "");'

replacement = '''      const explanation = esc(t.explanation_preview || "");

      const executionStrategyRaw = t.strategy || t.execution_strategy || t.execution_mode || t.executionMode || "";

      const executionStrategy = esc(String(executionStrategyRaw || ""));

      const retryOfRaw = t.retry_of_task_id || (t.meta && t.meta.retry_of_task_id) || (t.execution_meta && t.execution_meta.retry_of_task_id) || "";

      const retryOf = esc(String(retryOfRaw || ""));'''

if replacement not in text:

    if needle not in text:

        raise SystemExit("Expected explanation_preview line not found; aborting.")

    text = text.replace(needle, replacement, 1)

badge = '<div style="flex:0 0 auto;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">lifecycle</div>'

lineage = '''<div style="flex:0 0 auto;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">lifecycle</div>

            ${executionStrategy ? `<div style="flex:0 0 auto;color:#c4b5fd;border:1px solid rgba(196,181,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(88,28,135,.18);">strategy: ${executionStrategy}</div>` : ""}

            ${retryOf ? `<div style="flex:0 0 auto;color:#fcd34d;border:1px solid rgba(252,211,77,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(120,53,15,.18);">retry of: ${retryOf}</div>` : ""}'''

if lineage not in text:

    if badge not in text:

        raise SystemExit("Expected lifecycle badge markup not found; aborting.")

    text = text.replace(badge, lineage, 1)

path.write_text(text)

PY

node --check "$TARGET"

echo "Lineage label anchors:"

grep -nE "executionStrategy|retryOf|strategy:|retry of:" "$TARGET" | head -12

git add "$TARGET" PHASE718_APPLY_LINEAGE_LABELS.sh

git commit -m "Phase 718: surface retry lineage labels"

git push origin dev

