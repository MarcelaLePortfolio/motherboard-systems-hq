#!/bin/bash
# ⏱ Matilda Auto-Deploy Cron Script
# Runs the patch script every 5 minutes via PM2 for continuous monitoring

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
PATCH_SCRIPT="$PROJECT_DIR/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js"

echo "🔄 Starting Matilda Auto-Deploy Cron (every 5 min)..."

# Stop any existing PM2 process
pm2 stop matilda-auto-deploy || true
pm2 delete matilda-auto-deploy || true

# Start with PM2 in cron mode
pm2 start "node $PATCH_SCRIPT" --name matilda-auto-deploy --cron "*/5 * * * *"

# Save PM2 state for persistence
pm2 save

echo "✅ Matilda auto-deploy cron is active. It will log heartbeats and trigger deploys on UI changes."
