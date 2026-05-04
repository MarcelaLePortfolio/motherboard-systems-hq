#!/bin/bash
set -u

echo "---- compose ps before curl ----"
docker compose ps

echo "---- dashboard process list ----"
docker compose exec dashboard ps aux || true

echo "---- direct /api/health ----"
curl -i http://localhost:3000/api/health || true
echo ""

echo "---- direct /api/guidance ----"
curl -i http://localhost:3000/api/guidance || true
echo ""

echo "---- direct /api/guidance-history ----"
curl -i http://localhost:3000/api/guidance-history || true
echo ""

echo "---- compose ps after curl ----"
docker compose ps

echo "---- full dashboard logs ----"
docker compose logs --tail=300 dashboard

echo "---- recent commits ----"
git log --oneline -8

echo "---- git status ----"
git status --short
