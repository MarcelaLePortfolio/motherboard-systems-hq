#!/bin/sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE=/backups/db_backup_$DATE.sql
echo "Starting PostgreSQL backup to $BACKUP_FILE..."
export PGPASSWORD=$POSTGRES_PASSWORD
pg_dump -U $POSTGRES_USER -h postgres -d "$POSTGRES_DB" > $BACKUP_FILE
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "Backup successful!"
  echo "File size:"
  ls -lh $BACKUP_FILE
else
  echo "Backup failed with exit code $EXIT_CODE. See error above."
fi

