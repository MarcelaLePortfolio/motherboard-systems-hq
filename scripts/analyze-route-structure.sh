
#!/usr/bin/env bash

echo "=== ROUTE STRUCTURE MAP ==="

echo ""

echo "[routes root]"

find routes -maxdepth 1 -type f | head -50

echo ""

echo "[routes/routes subtree]"

find routes/routes -type f | head -50

echo ""

echo "=== DUPLICATE ROUTE NAMES ==="

for f in $(find routes -type f -name "*.ts" | sed 's#.*/##' | sort | uniq -d); do

  echo "DUPLICATE: $f"

done

echo ""

echo "=== DB IMPORT DEPTHS ==="

grep -R "../db" routes | sed 's/:.*//' | sort | uniq -c | sort -nr | head -20

echo ""

echo "=== EXPRESS USAGE SAMPLE ==="

grep -R "express.Router" routes | head -20

