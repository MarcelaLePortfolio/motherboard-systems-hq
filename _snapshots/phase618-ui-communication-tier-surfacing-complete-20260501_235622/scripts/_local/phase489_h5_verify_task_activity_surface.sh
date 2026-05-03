#!/usr/bin/env bash
set -euo pipefail

echo "=== /api/runs sanity check ==="
curl -i -s --max-time 3 "http://localhost:8080/api/runs?limit=20" | sed -n '1,120p'
echo

echo "=== /api/tasks sanity check ==="
curl -i -s --max-time 3 "http://localhost:8080/api/tasks" | sed -n '1,120p'
echo

echo "=== open dashboard for Task Activity review ==="
open "http://localhost:8080/?v=$(date +%s)"
