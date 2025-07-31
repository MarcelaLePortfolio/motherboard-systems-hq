#!/bin/bash
# =========================================
# Matilda Backup Script
# =========================================

# Create timestamped backup zip
mkdir -p Backups
timestamp=$(date +%Y%m%d_%H%M)
zip_file="Backups/Motherboard_Backup_${timestamp}.zip"

echo "📦 Creating backup at $zip_file ..."
zip -r "$zip_file" . -x "node_modules/*" "Backups/*" "*.log"

# Rotate backups (keep last 10)
ls -t Backups/Motherboard_Backup_*.zip | tail -n +11 | xargs rm -f

# ✅ Event emitter for dashboard ticker
echo "{\"timestamp\":\"$(date +%s)\",\"agent\":\"matilda\",\"event\":\"backup-complete\"}" >> ui/dashboard/ticker-events.log
