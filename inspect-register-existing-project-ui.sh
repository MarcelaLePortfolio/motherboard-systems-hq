
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== latest commits ==="

git log --oneline -8

echo

echo "=== latest DR reference ==="

echo "20260703_140651"

echo

echo "=== project switcher DOM ==="

sed -n '528,584p' public/dashboard.html

echo

echo "=== project switcher script ==="

sed -n '1046,1238p' public/dashboard.html

echo

echo "=== backend registration route ==="

grep -n "registerProject\|/api/projects/register" server/project-registry.mjs

