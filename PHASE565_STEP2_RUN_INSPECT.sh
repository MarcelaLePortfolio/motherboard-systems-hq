#!/bin/bash

echo "Running /api/tasks inspection..."

./PHASE565_STEP1_INSPECT_TASKS.sh

echo ""
echo "Review the output above and identify:"
echo "- task id field"
echo "- status field"
echo "- title or payload field"
echo "- timestamps (created_at / updated_at)"
echo ""
echo "Do NOT proceed until mapping is confirmed."
