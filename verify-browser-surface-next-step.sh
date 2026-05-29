
#!/usr/bin/env bash

set -euo pipefail

TS="$(date +%Y%m%d_%H%M%S)"

REPORT="browser-surface-next-step-${TS}.md"

cat > "$REPORT" << REPORT_EOF

# Browser Surface Next Step

Current verified state:

- Served dashboard URL is http://localhost:8080

- Served phase530 bridge contains Preview, Inspect trace, and Inspect logs markers.

- API row task-card-controls-visible-smoke contains payload.artifact, payload.trace, and payload.logs.

- Therefore the remaining issue is not missing backend data or missing served renderer code.

Next operator check:

1. Open this exact URL:

   http://localhost:8080/?v=task-card-controls-visible-smoke-$(date +%s)

2. Hard refresh the browser:

   - Chrome: Cmd + Shift + R

3. In Recent Tasks, look for:

   - Task card controls visible smoke

   - Preview

   - Inspect trace

   - Inspect logs

If those controls are still not visible, the next fix should inspect the live browser DOM/mounted surface, because the API and served renderer contract already pass.

REPORT_EOF

cat "$REPORT"

git add "$REPORT" verify-browser-surface-next-step.sh

git commit -m "Record browser surface next step"

git push

