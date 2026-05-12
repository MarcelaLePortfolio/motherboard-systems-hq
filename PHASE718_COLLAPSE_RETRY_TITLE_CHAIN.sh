
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''      const phase718ResolveReadableTitle = (candidateTitle, depth = 0) => {

        const candidate = String(candidateTitle || "");

        if (!candidate || depth > 5) return candidate;

        const nestedRetryMatch = candidate.match(/^(retry differently|requeue)\\s+(t_[a-f0-9-]+)$/i);

        if (!nestedRetryMatch) return candidate;

        const nestedAction = nestedRetryMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently";

        const nestedTarget = nestedRetryMatch[2];

        const nestedTargetTitle = phase718TaskTitleByKey.has(nestedTarget)

          ? phase718ResolveReadableTitle(phase718TaskTitleByKey.get(nestedTarget), depth + 1)

          : nestedTarget;

        return nestedTargetTitle && nestedTargetTitle !== nestedTarget

          ? `${nestedAction}: ${nestedTargetTitle}`

          : nestedAction;

      };

      const operatorAction = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : "";

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const resolvedTargetTitleRaw = operatorTarget && phase718TaskTitleByKey.has(operatorTarget)

        ? phase718ResolveReadableTitle(phase718TaskTitleByKey.get(operatorTarget))

        : operatorTarget;

      const operatorTitle = operatorAction && resolvedTargetTitleRaw

        ? `${operatorAction}: ${resolvedTargetTitleRaw}`

        : (operatorAction || phase718ResolveReadableTitle(rawTitle));

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);'''

new = '''      const phase718ResolveBaseTitle = (candidateTitle, depth = 0) => {

        const candidate = String(candidateTitle || "");

        if (!candidate || depth > 5) return candidate;

        const nestedRetryMatch = candidate.match(/^(retry differently|requeue)\\s+(t_[a-f0-9-]+)$/i);

        if (!nestedRetryMatch) return candidate;

        const nestedTarget = nestedRetryMatch[2];

        return phase718TaskTitleByKey.has(nestedTarget)

          ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(nestedTarget), depth + 1)

          : nestedTarget;

      };

      const operatorAction = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : "";

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const resolvedTargetTitleRaw = operatorTarget && phase718TaskTitleByKey.has(operatorTarget)

        ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(operatorTarget))

        : operatorTarget;

      const operatorTitle = operatorAction && resolvedTargetTitleRaw

        ? `${operatorAction}: ${resolvedTargetTitleRaw}`

        : (operatorAction || phase718ResolveBaseTitle(rawTitle));

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);'''

if old not in text:

    raise SystemExit("Expected nested retry block not found; aborting.")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q "phase718ResolveBaseTitle"

open "http://localhost:3000"

git add "$TARGET" PHASE718_COLLAPSE_RETRY_TITLE_CHAIN.sh

git commit -m "Phase 718: collapse retry title chains"

git push origin dev

