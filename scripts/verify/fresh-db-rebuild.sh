#!/bin/bash
set -e

echo "PHASE 633 — Fresh DB Validation Starting..."

echo "Stopping containers..."
docker compose down

echo "Removing project volumes..."
docker compose down -v

echo "Rebuilding containers..."
docker compose up -d --build

echo "Waiting for services to stabilize..."
sleep 10

echo "Checking worker logs for schema errors..."
docker logs motherboard_systems_hq-worker-1 | grep -i "error" || true

echo "Checking if columns exist..."
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "\d tasks"

echo "Fresh DB validation complete."
