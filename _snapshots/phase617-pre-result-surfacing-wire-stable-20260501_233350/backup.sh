#!/bin/sh

DB_USER="db_backup_agent"
DB_NAME="motherboard_db"
PG_HOST="postgres"
S3_BUCKET_PATH="s3://[YOUR-MASKED-BUCKET]/motherboard-hq-backups/"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/backups/${DB_NAME}_backup_${TIMESTAMP}.sql"

# Set password for non-interactive pg_dump
export PGPASSWORD=$(cat /run/secrets/postgres_password)

echo "Starting PostgreSQL backup to ${BACKUP_FILE}..."

pg_dump -h "${PG_HOST}" -U "${DB_USER}" -d "${DB_NAME}" > "${BACKUP_FILE}"

if [ -s "${BACKUP_FILE}" ]; then
  echo "Backup successful! File saved to ${BACKUP_FILE}"
  
  echo "Attempting to upload backup to S3..."
  aws s3 cp "${BACKUP_FILE}" "${S3_BUCKET_PATH}${BACKUP_FILE##*/}"
  
  if [ $? -ne 0 ]; then
    echo "WARNING: S3 upload failed. (This may be expected if AWS variables are not set.)"
  fi
else
  echo "ERROR: Backup failed. ${BACKUP_FILE} is empty or missing."
fi
