#!/usr/bin/env bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

docker-compose down
npm run build:dashboard-bundle
docker-compose up --build -d
docker-compose ps
