#!/bin/bash
set -e

echo "Testing /api/subsystem-status endpoint..."

curl -s http://localhost:8080/api/subsystem-status | jq .

echo "If you see ok:true and subsystem list, endpoint is live."
