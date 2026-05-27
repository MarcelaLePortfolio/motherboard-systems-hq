#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "PHASE 70A OPERATOR HEALTH CHECK"
echo "--------------------------------"

bash scripts/_local/phase70a_health_snapshot.sh

echo ""
echo "WRITING SNAPSHOT RECORD"
bash scripts/_local/phase70a_run_health_snapshot.sh

echo ""
echo "PHASE 70A HEALTH CHECK COMPLETE"
