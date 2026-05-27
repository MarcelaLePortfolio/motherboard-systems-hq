
#!/bin/bash

echo "Scanning largest Git objects (top 50)..."

git rev-list --objects --all \

  | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \

  | awk '$1=="blob"{print $3, $4}' \

  | sort -n \

  | tail -50 \

  | awk '{printf "%.2f MB\t%s\n", $1/1024/1024, $2}'

echo "Scan complete."

