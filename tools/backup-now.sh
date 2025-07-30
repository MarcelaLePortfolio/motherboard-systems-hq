#!/bin/zsh
set -e

PROJECT=~/Desktop/Motherboard_Systems_HQ
timestamp=$(date +%Y%m%d_%H%M)
backup_dir=~/Desktop/Motherboard_FullBackup_$timestamp
zip_file=~/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_$timestamp.zip
log_file=~/Desktop/MOTHERBOARD_BACKUP_LOG_$timestamp.txt

mkdir -p "$backup_dir/project" "$backup_dir/pm2" "$backup_dir/dotfiles"

echo "✅ Backing up from: $PROJECT"

# 1️⃣ Copy full project
rsync -a "$PROJECT/" "$backup_dir/project/"

# 2️⃣ Save PM2 environment
pm2 save
cp ~/.pm2/dump.pm2 "$backup_dir/pm2/dump.pm2"
rsync -a ~/.pm2/ "$backup_dir/pm2/full_pm2/"

# 3️⃣ Save dotfiles
for file in ~/.zshrc ~/.gitconfig ~/.npmrc; do
  [ -f "$file" ] && cp "$file" "$backup_dir/dotfiles/"
done

# 4️⃣ Create notes
cat > "$backup_dir/notes.txt" << NOTES
Full Motherboard Systems Backup
Date: $(date)
Source: $PROJECT
Includes full project, PM2 env, dotfiles
NOTES

# 5️⃣ Create zip with log of skipped files
cd ~/Desktop
echo "🔹 Creating zip archive..."
(zip -r "$zip_file" "$(basename "$backup_dir")" 2>&1) | tee "$log_file"

# 6️⃣ Remove temp folder
rm -rf "$backup_dir"

# 7️⃣ Verification summary
echo
echo "🔹 Backup complete: $zip_file"
echo "🔹 Log of skipped files: $log_file"

# Optional: run your critical file check
~/Desktop/Motherboard_Systems_HQ/tools/verify-critical.sh | tee -a "$log_file"
