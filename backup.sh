#!/bin/sh

# Set the environment variables required for pg_dump and AWS CLI
# PGPASSWORD must be explicitly exported for pg_dump to use it non-interactively.
export PGPASSWORD
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

# Database connection details (using service names from docker-compose)
PG_HOST=postgres
PG_USER=hq_user
PG_DB=motherboard_db
BACKUP_DIR="/backups"
AWS_BUCKET="s3://motherboard-systems-backup-storage"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Generate a timestamp for the backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${PG_DB}_backup_${TIMESTAMP}.sql"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

echo "Starting PostgreSQL backup to ${BACKUP_PATH}..."

# 1. Perform the database dump
if pg_dump -U "$PG_USER" -h "$PG_HOST" -d "$PG_DB" > "$BACKUP_PATH"; then
    echo "Successfully created dump file: ${BACKUP_FILE}"
else
    echo "ERROR: pg_dump failed. Check logs for details."
    exit 1
fi

# 2. Upload the dump file to S3
echo "Uploading ${BACKUP_FILE} to ${AWS_BUCKET}..."

# We use the full AWS CLI path since it might not be in PATH on Alpine.
if /usr/bin/aws s3 cp "$BACKUP_PATH" "$AWS_BUCKET/$BACKUP_FILE"; then
    echo "Successfully uploaded backup to S3."

    # 3. Clean up the local file after successful upload
    echo "Cleaning up local file ${BACKUP_PATH}..."
    rm "$BACKUP_PATH"
else
    echo "ERROR: AWS S3 upload failed. Backup remains locally at ${BACKUP_PATH}."
    exit 1
fi

echo "Backup process finished."
