
#!/usr/bin/env bash

set -euo pipefail

REPORT="governed-planning-route-response-shape.txt"

{

  echo "GOVERNED PLANNING ROUTE RESPONSE SHAPE"

  echo

  echo "--- governed planning route import and response area ---"

  sed -n '1,40p' server/routes/governed-planning-route.mjs

  echo

  sed -n '260,340p' server/routes/governed-planning-route.mjs

  echo

  echo "--- pipeline approval artifact source ---"

  sed -n '1,120p' server/execution/governed-planning-pipeline.mjs

  echo

  echo "--- current frontend placeholder ---"

  sed -n '1,160p' public/js/planning-preview-card.js

} | tee "$REPORT"

cat > governed-planning-dataflow-finding.txt << 'NOTE'

GOVERNED PLANNING DATAFLOW FINDING

Finding Status: CONFIRMED

The repo inspection shows:

- The governed planning bundle is built in server/routes/governed-planning-route.mjs.

- The governed planning route is the only route surface currently returning the bundle.

- The current dashboard planning preview card is a placeholder.

- No public dashboard code currently consumes the governed planning bundle.

- Existing artifact preview code remains task-coupled and should not be reused by forcing governed planning artifacts into task records.

Next safe question:

What exact JSON path does the governed planning route return for the planning artifact bundle, and what minimal read-only UI bridge should consume it?

NOTE

git add inspect-governed-planning-dataflow.sh inspect-governed-planning-route-response-shape.sh governed-planning-route-response-shape.txt governed-planning-dataflow-finding.txt

git commit -m "Inspect governed planning route response shape"

git push

