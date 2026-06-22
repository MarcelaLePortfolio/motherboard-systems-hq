
#!/bin/bash

set -u

git status --short > /tmp/working-tree.txt

echo "== Tracked modifications =="

grep '^ M' /tmp/working-tree.txt || true

echo ""

echo "== Untracked total =="

grep '^??' /tmp/working-tree.txt | wc -l

echo ""

echo "== Likely local/generated candidates =="

grep '^??' /tmp/working-tree.txt | grep -E '(\.DS_Store|node_modules/|logs/|backups/|db/main\.db|\.tmp-|\.log$|\.tmp$)' || true

echo ""

echo "== Root-level untracked files =="

grep '^?? [^/]*$' /tmp/working-tree.txt || true

echo ""

echo "== Untracked scripts =="

grep '^?? .*\.sh$' /tmp/working-tree.txt || true

echo ""

echo "== Untracked docs/reports/text artifacts =="

grep '^?? .*\.(txt|md)$' /tmp/working-tree.txt || true

