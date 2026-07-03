
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== latest commits ==="

git log --oneline -6

echo

echo "=== project registry route changes currently unstaged or staged ==="

git diff -- server.mjs server/project-registry.mjs public/dashboard.html

echo

echo "=== dashboard script area around project switcher ==="

grep -n -B 20 -A 80 "project-context-selector" public/dashboard.html

echo

echo "=== script tag locations near bottom ==="

grep -n "<script\|</script>" public/dashboard.html | tail -30

