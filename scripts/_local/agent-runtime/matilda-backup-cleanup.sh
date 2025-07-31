#!/bin/bash
# 🧹 Matilda Backup Cleanup & Log Enforcement
# Ensures all logs are stored in Backups/Logs and rotates to keep only 10 newest

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
LOG_DIR="$PROJECT_DIR/Backups/Logs"
mkdir -p "$LOG_DIR"

echo "🔄 Running Matilda backup log cleanup at $(date)"

# 1️⃣ Move any stray log files from Desktop into Logs folder
mv ~/Desktop/MOTHERBOARD_*.txt "$LOG_DIR/" 2>/dev/null || true
mv ~/Desktop/backup_*.log "$LOG_DIR/" 2>/dev/null || true
mv ~/Desktop/MOTHERBOARD_*.log "$LOG_DIR/" 2>/dev/null || true

# 2️⃣ Rotate logs: keep only 10 newest (.txt and .log combined)
cd "$LOG_DIR" || exit 1
setopt NULL_GLOB 2>/dev/null || true  # enable nullglob in zsh, harmless in bash
ls -t MOTHERBOARD_*.txt backup_*.log MOTHERBOARD_*.log 2>/dev/null | tail -n +11 | xargs -I {} rm -f "{}"
unsetopt NULL_GLOB 2>/dev/null || true

echo "✅ Log cleanup complete — Desktop should now be clear of log files."
