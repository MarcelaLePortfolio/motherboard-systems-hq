#!/bin/bash

echo "Checking Docker container status..."
docker compose ps

echo ""
echo "Checking dashboard health endpoint..."
curl -v --max-time 5 http://localhost:8080/api/health

echo ""
echo "Checking tasks endpoint with timeout..."
curl -v --max-time 5 http://localhost:8080/api/tasks
