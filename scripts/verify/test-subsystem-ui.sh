#!/bin/bash
set -e

echo "PHASE 635 — UI VALIDATION START"

echo "Opening Subsystem Status page..."
open http://localhost:8080/dev/page-SubsystemStatus

echo "Manual check:"
echo "- Page loads"
echo "- Subsystem list visible"
echo "- Atlas / Guidance / Execution shown"
echo "- Status updates every ~5 seconds"

echo "PHASE 635 — UI VALIDATION COMPLETE"
