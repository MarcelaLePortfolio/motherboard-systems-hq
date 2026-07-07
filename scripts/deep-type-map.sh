
#!/usr/bin/env bash

echo "=== DEEP TYPE GRAPH MAP ==="

echo ""

echo "DB CORE TYPE FAILURES"

grep -R "CreateGovernance" db -n | head -50

echo ""

echo "LIFECYCLE STRUCTURAL FAILURES"

grep -R "operational_" server/db -n server | head -50

echo ""

echo "EXPRESS TYPE BOUNDARY USAGE"

grep -R "express.Router" -n server routes | head -50

echo ""

echo "UNION TYPE BREAKS"

grep -R "| {" server db -n | head -50

echo ""

echo "DONE"

