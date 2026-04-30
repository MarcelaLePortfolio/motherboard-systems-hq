#!/bin/bash

echo "Checking /api/tasks status, headers, and body on dashboard port 3000..."
echo ""

echo "HTTP response:"
curl -s -i http://localhost:3000/api/tasks

echo ""
echo "Parsed body attempt:"
curl -s http://localhost:3000/api/tasks | jq '.' 2>/dev/null || {
  echo "Body was empty or not valid JSON."
  echo "Raw body:"
  curl -s http://localhost:3000/api/tasks
}
