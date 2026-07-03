
#!/bin/bash

set -e

echo "=== repo status ==="

git status

echo

echo "=== latest commits ==="

git log --oneline -8

echo

echo "=== modal location ==="

grep -n -B 5 -A 80 "project-register-modal" public/dashboard.html

echo

echo "=== body/script tail structure ==="

grep -n "<body\|</body>\|<script\|</script>\|project-register-modal" public/dashboard.html | tail -80

echo

echo "=== cancel listener lines ==="

grep -n -B 10 -A 20 "project-register-cancel\|registerModalElements.cancel\|closeRegisterModal" public/dashboard.html

