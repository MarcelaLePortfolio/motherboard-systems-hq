
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== latest commits ==="

git log --oneline -5

echo

echo "=== project switcher script block ==="

sed -n '1025,1095p' public/dashboard.html

echo

echo "=== implementation script exists ==="

ls -l implement-project-registry-v1.sh

