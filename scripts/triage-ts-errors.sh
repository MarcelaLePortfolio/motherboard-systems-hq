
#!/usr/bin/env bash

echo "=== TS ERROR TRIAGE ==="

echo ""

echo "1. BOOLEAN LITERAL FAILURES"

grep -R "boolean is not assignable to type 'true'" -n db server routes | head -30

echo ""

echo "2. NUMBER/BOOLEAN COMPARISONS"

grep -R "types 'number' and 'boolean'" -n db server routes | head -30

echo ""

echo "3. EXPRESS ROUTER ISSUES"

grep -R "Router does not exist" -n routes server | head -30

echo ""

echo "4. MODULE RESOLUTION FAILURES"

grep -R "Cannot find module '../db" -n routes server | head -30

echo ""

echo "DONE"

