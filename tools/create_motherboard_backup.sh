/* eslint-disable import/no-commonjs */
#!/bin/bash

# 🧠 Motherboard Backup Script – Includes Everything Except Nested Backups

timestamp=$(date +"%Y%m%d_%H%M")
backup_dir="$HOME/Desktop"
backup_name="MOTHERBOARD_SYSTEMS_BACKUP_${timestamp}.zip"
project_root="$HOME/Desktop/Motherboard_Systems_HQ"

echo "📦 Creating backup: $backup_name"

zip -r "$backup_dir/$backup_name" "$project_root" \
  -x "$project_root/Backups/*.zip" \
  -x "$project_root/Backups/Archive/*.zip" \
  -x "$project_root/Backups/Logs/*.zip"

echo "✅ Done: $backup_name"
