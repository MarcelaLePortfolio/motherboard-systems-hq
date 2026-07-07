
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== current HEAD ==="

git log --oneline -5

echo

echo "=== dashboard project switcher source ==="

grep -n "project-context-selector\|project-context-menu\|Motherboard HQ" public/dashboard.html

echo

echo "=== registry seed file ==="

cat projects/registry.example.json

echo

echo "=== server route hints ==="

grep -n "dashboard\|public/dashboard.html\|express\|createServer\|app.get\|app.post" server.mjs | head -120

echo

echo "=== db client ==="

sed -n '1,220p' db/client.ts

echo

echo "=== server db ==="

sed -n '1,220p' server/sqlite.js

