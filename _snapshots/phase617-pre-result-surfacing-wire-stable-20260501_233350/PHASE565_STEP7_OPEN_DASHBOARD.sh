#!/bin/bash

echo "Opening dashboard at http://localhost:3000 ..."
open http://localhost:3000

echo ""
echo "Verify in UI:"
echo "- Recent Tasks panel renders (even if empty state)"
echo "- Recent Logs panel streams events (if any activity)"
echo "- No console errors"
