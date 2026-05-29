
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="dashboard-port-runtime-diagnosis-${STAMP}.md"

{

  echo "# Dashboard Port Runtime Diagnosis"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Docker Compose Status"

  echo

  docker compose ps || true

  echo

  echo "## Dashboard Container Ports"

  echo

  docker compose port dashboard 3000 || true

  docker compose port dashboard 3001 || true

  docker compose port dashboard 5173 || true

  docker compose port dashboard 8080 || true

  echo

  echo "## Host Curl Probes"

  echo

} > "$REPORT"

urls=(

  "http://localhost:3000"

  "http://localhost:3000/api/tasks"

  "http://localhost:3001"

  "http://localhost:3001/api/tasks"

  "http://localhost:5173"

  "http://localhost:8080"

)

for url in "${urls[@]}"; do

  {

    echo "### $url"

    curl -sS -i --max-time 3 "$url" | head -40 || true

    echo

  } >> "$REPORT"

done

{

  echo "## Dashboard Logs Tail"

  echo

  docker compose logs --tail=160 dashboard || true

  echo

  echo "## Compose File Port References"

  echo

  grep -RIn "3000\|3001\|5173\|8080\|ports:" docker-compose*.yml docker-compose*.yaml 2>/dev/null || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" diagnose-dashboard-port-runtime.sh

git commit -m "Diagnose dashboard port runtime"

git push

