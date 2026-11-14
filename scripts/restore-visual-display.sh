#!/bin/bash
# DASHBOARD_ROLLBACK_PROTECTION_GUARD_V2
echo "BLOCKED=LEGACY_DASHBOARD_ROLLBACK_DISABLED"
echo "REASON=PROTECTED_REACT_DASHBOARD_IS_AUTHORITATIVE"
echo "RECOVERY=GOVERNED_REACT_DASHBOARD_ONLY"
exit 78
echo "💫 Restoring Visual Output Display (graph + alerts + canvas integration)..."
git checkout v0.6.12.2-visual-output-display -- public/js public/dashboard.html
echo "✅ Visual Output Display restored. Restarting server..."
pm2 restart server
sleep 3
open http://localhost:3000/dashboard.html
