#!/bin/bash
set -e

echo "PHASE 640 — GUIDANCE UI VALIDATION START"

echo "Opening Guidance Panel page..."
open http://localhost:8080/dev/page-GuidancePanel

echo ""
echo "Manual check:"
echo "- Page loads"
echo "- Subsystem context is visible"
echo "- Guidance section renders (even if empty)"
echo "- Updates every ~5 seconds"

echo ""
echo "PHASE 640 — GUIDANCE UI VALIDATION COMPLETE"
