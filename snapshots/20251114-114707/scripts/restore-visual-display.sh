#!/bin/bash
echo "💫 Restoring Visual Output Display (graph + alerts + canvas integration)..."
git checkout v0.6.12.2-visual-output-display -- public/js public/dashboard.html
echo "✅ Visual Output Display restored. Restarting server..."
pm2 restart server
sleep 3
open http://localhost:3000/dashboard.html
