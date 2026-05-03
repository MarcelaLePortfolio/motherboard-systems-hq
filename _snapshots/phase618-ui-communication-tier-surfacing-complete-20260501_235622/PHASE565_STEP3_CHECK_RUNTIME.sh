#!/bin/bash

echo "Checking Docker container status..."
docker compose ps

echo ""
echo "Checking dashboard health endpoint on mapped host port 3000..."
curl -v --max-time 5 http://localhost:3000/api/health

echo ""
echo "Checking tasks endpoint on mapped host port 3000..."
curl -v --max-time 5 http://localhost:3000/api/tasks
