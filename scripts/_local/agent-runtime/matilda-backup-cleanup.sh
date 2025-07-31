#!/bin/bash
# =========================================
# Matilda Backup Cleanup Script
# =========================================

mkdir -p Backups/Logs
mv -f *.log Backups/Logs/ 2>/dev/null || true

# Enforce 10-file limit
cd Backups/Logs
ls -t *.log 2>/dev/null | tail -n +11 | xargs rm -f

# ✅ Event emitter for dashboard ticker
echo "{\"timestamp\":\"$(date +%s)\",\"agent\":\"matilda\",\"event\":\"cleanup-complete\"}" >> ../../ui/dashboard/ticker-events.log
