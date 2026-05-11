
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 MANUAL RETRY UI CHECK ====="

docker compose ps

echo ""

echo "Open dashboard:"

echo "http://localhost:3000"

echo ""

echo "Manual checklist:"

echo "1. Recent Tasks cards show Requeue and Retry differently buttons."

echo "2. Requeue opens confirmation modal."

echo "3. Cancel closes modal with no mutation."

echo "4. Submit creates a retry task."

echo "5. Retry differently creates a fresh-context retry task."

echo "6. Recent Tasks refreshes after successful submission."

echo ""

echo "After manual pass, run:"

echo "git status --short"

echo "git log --oneline --decorate -5"

echo "===== END MANUAL CHECK ====="

