#!/usr/bin/env bash
set -euo pipefail

Rebuild and restart the dashboard + backend after Matilda chat changes.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

docker-compose down
docker-compose up --build -d
