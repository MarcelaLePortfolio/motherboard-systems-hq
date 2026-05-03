#!/bin/bash

echo "▶️ PHASE 622 — POST-CONTAINERIZATION CHECK"
echo ""

echo "Checking running containers..."
docker ps

echo ""
echo "Checking container logs (last 50 lines)..."
docker logs motherboard_systems_hq-dashboard-1 --tail 50 2>/dev/null || true
docker logs motherboard_systems_hq-worker-1 --tail 50 2>/dev/null || true

echo ""
echo "Checking system health endpoint..."
curl -s http://localhost:8080/api/health || echo "Health endpoint not reachable"

echo ""
echo "✅ If containers are running and no errors appear, system is STABLE at Phase 622."
