#!/bin/sh

# Set the target bucket name
S3_BUCKET="marcelas-motherboard-hq-backups"

# Directory where the backups are created
BACKUP_DIR="/backups"

# Variables derived from environment
DB_USER=$POSTGRES_USER
DB_PASS=$POSTGRES_PASSWORD
DB_NAME=$POSTGRES_DB
DB_HOST=postgres # Service name in docker-compose

# Create the file name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="db_backup_$TIMESTAMP.sql"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

# --- 1. Perform PostgreSQL Dump ---
echo "Starting PostgreSQL backup to $BACKUP_PATH..."
set -x
pg_dump -U "$DB_USER" -h "$DB_HOST" -d "$DB_NAME" > "$BACKUP_PATH"
if [ $? -ne 0 ]; then
echo "❌ Database dump FAILED: Password authentication failed."
exit 1
else
set +x

if [ $? -eq 0 ]; then
    echo "if [ $? -ne 0 ]; then
    echo "❌ Database dump FAILED: Check PGPASSWORD and database connectivity."
    exit 1
else
    echo "✅ Database dump successful."
fi"
else
    echo "❌ Database dump failed. Exiting."
    exit 1
fi

# --- 2. Upload to S3 ---
echo "Starting S3 transfer to s3://$S3_BUCKET/database-backups/$BACKUP_FILE..."
set -x
aws s3 cp "$BACKUP_PATH" "s3://$S3_BUCKET/database-backups/$BACKUP_FILE" --region "$AWS_DEFAULT_REGION"
if [ $? -ne 0 ]; then
echo "❌ Database dump FAILED: Password authentication failed."
exit 1
else
set +x

if [ $? -eq 0 ]; then
    echo "✅ S3 transfer successful. Backup process complete."
else
    echo "❌ S3 transfer failed. Check AWS credentials and bucket name."
    exit 1
fi
