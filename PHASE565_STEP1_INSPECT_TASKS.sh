#!/bin/bash

echo "Checking /api/tasks status, headers, and body..."
echo ""

echo "HTTP response:"
curl -s -i http://localhost:8080/api/tasks

echo ""
echo "Parsed body attempt:"
curl -s http://localhost:8080/api/tasks | jq '.' 2>/dev/null || {
  echo "Body was empty or not valid JSON."
  echo "Raw body:"
  curl -s http://localhost:8080/api/tasks
}
