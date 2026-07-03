
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== server import/mount lines ==="

grep -n "project-registry\|mountProjectRegistryRoutes" server.mjs

echo

echo "=== server middleware area ==="

sed -n '35,110p' server.mjs

echo

echo "=== project registry route file head/tail ==="

sed -n '1,80p' server/project-registry.mjs

sed -n '330,390p' server/project-registry.mjs

echo

echo "=== route response ==="

curl -i http://localhost:3001/api/projects/registry || true

