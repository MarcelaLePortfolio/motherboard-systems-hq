
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 REFRESH DASHBOARD STATIC ====="

docker compose restart dashboard

sleep 3

./PHASE719_VERIFY_SERVED_SEMANTIC_UI.sh

git status --short

git log --oneline --decorate -5

echo "===== COMPLETE ====="

