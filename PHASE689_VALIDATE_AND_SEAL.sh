#!/bin/bash

set -e

echo "Rebuilding containers..."
docker compose up -d --build

echo "Checking coherence API..."
curl -s http://localhost:3000/api/guidance/coherence-shadow | python3 -m json.tool | head -n 120

echo "Checking dashboard root..."
curl -i -s http://localhost:3000/ | head -n 40

echo "Checking dashboard logs..."
docker compose logs --tail=80 dashboard

echo "Checking git status..."
git status --short

echo "Phase 689 validation complete."
