#!/usr/bin/env bash
set -euo pipefail

BASE_TAG="v11.30.1-ui-complete-ok"
BRANCH="feature/phase12-real-routing"

echo "== Phase 12 Resume =="
echo "Base tag: ${BASE_TAG}"
echo "Branch:   ${BRANCH}"
echo

echo "== Sanity check: current HEAD =="
git --no-pager log --oneline -1
echo

echo "== Stack reminder =="
echo "Run when ready:"
echo "  docker-compose down"
echo "  docker-compose up --build -d"
echo
echo "Open:"
echo "  http://127.0.0.1:8080/dashboard"
echo
echo "Proceed with backend routing audit:"
echo "  - chat endpoint"
echo "  - task delegation"
echo "  - task list / completion"
