#!/bin/bash

echo "Checking /api/tasks structure..."

curl -s http://localhost:8080/api/tasks | jq '.' || curl -s http://localhost:8080/api/tasks

echo ""
echo "If jq failed, raw JSON is shown above."
echo "Confirm fields for UI mapping before proceeding."
