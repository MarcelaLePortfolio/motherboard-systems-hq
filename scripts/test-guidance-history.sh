#!/bin/bash

echo "Testing /api/guidance-history endpoint..."

curl -s http://localhost:8080/api/guidance-history | jq

echo ""
echo "If ok=true and no errors → PASS (history may be empty until wired)"
