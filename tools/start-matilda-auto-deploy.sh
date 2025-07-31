#!/bin/bash
# 🚀 Kickstart Matilda's auto-deploy workflow using the 5-min cron

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
CRON_SCRIPT="$PROJECT_DIR/scripts/_local/agent-runtime/matilda-auto-deploy-cron.sh"

echo "🔄 Starting Matilda auto-deploy workflow..."
bash "$CRON_SCRIPT"

# Show PM2 process list for confirmation
pm2 ls
echo "✅ Matilda auto-deploy workflow is now active!"
