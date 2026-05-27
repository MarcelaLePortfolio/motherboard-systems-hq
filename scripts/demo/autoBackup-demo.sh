
BACKUP_DIR="db/backups"
RETENTION=5  # keep last 5 backups

mkdir -p "$BACKUP_DIR"
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_file="$BACKUP_DIR/main_${timestamp}.db"

echo "💾 Creating SQLite backup → $backup_file"
cp db/main.db "$backup_file"

# prune old backups if more than RETENTION
count=$(ls -1t "$BACKUP_DIR"/main_*.db 2>/dev/null | wc -l | tr -d ' ')
if [ "$count" -gt "$RETENTION" ]; then
  echo "🧹 Pruning old backups (keeping latest $RETENTION)..."
  ls -1t "$BACKUP_DIR"/main_*.db | tail -n +$((RETENTION+1)) | xargs rm -f
fi

echo "✅ Backup complete."
