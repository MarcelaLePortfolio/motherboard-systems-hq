#!/bin/bash
# 🚀 Matilda Auto-Deploy - Unified Starter Script (5-min heartbeat & deploy)

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
PATCH_SCRIPT="$PROJECT_DIR/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js"

echo "🔄 Starting Matilda auto-deploy workflow..."

# Stop any old PM2 processes
pm2 stop matilda-auto-deploy || true
pm2 delete matilda-auto-deploy || true

# Start auto-deploy as a PM2 cron job every 5 minutes
pm2 start "node $PATCH_SCRIPT" --name matilda-auto-deploy --cron "*/5 * * * *"

# Save PM2 state for persistence
pm2 save

# Show PM2 processes for confirmation
pm2 ls

echo "✅ Matilda auto-deploy workflow is now active!"
