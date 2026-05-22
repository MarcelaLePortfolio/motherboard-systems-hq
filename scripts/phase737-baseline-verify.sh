
#!/usr/bin/env bash

set -euo pipefail

echo "== Git =="

git status --short

git branch --show-current

git remote -v

echo

echo "== Required paths =="

test -d DISASTER_RECOVERY && echo "DISASTER_RECOVERY present"

test -d ARTIFACT_SNAPSHOTS && echo "ARTIFACT_SNAPSHOTS present"

test -f scripts/create-external-disaster-backup.sh && echo "external DR script present"

echo

echo "== Docker =="

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo

echo "== Preview routes smoke check =="

curl -sS http://localhost:3000/api/tasks >/dev/null && echo "/api/tasks OK"

