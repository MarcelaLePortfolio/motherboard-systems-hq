
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 REBUILD DASHBOARD STATIC ====="

docker compose build dashboard

docker compose up -d dashboard

sleep 3

./PHASE719_VERIFY_SERVED_SEMANTIC_UI.sh

git status --short

git log --oneline --decorate -5

echo "===== COMPLETE ====="

