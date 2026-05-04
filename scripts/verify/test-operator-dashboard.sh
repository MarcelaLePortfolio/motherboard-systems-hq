#!/bin/bash
set -e

echo "PHASE 647 — OPERATOR DASHBOARD VALIDATION START"

echo "Opening Operator Dashboard..."
open http://localhost:8080/dev/page-OperatorDashboard

echo ""
echo "Manual check:"
echo "- Page loads"
echo "- Subsystem panel visible"
echo "- Guidance panel visible"
echo "- Both update independently"
echo "- Layout is clean and stacked"

echo ""
echo "PHASE 647 — OPERATOR DASHBOARD VALIDATION COMPLETE"
