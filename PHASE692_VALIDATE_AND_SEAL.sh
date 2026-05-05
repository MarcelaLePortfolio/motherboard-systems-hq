#!/bin/bash

set -e

docker compose up -d --build

curl -s http://localhost:3000/api/guidance/coherence-shadow | python3 -m json.tool | head -n 140
curl -i -s http://localhost:3000/ | head -n 40
docker compose logs --tail=100 dashboard

git status --short
