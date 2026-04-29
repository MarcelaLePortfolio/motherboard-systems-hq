#!/bin/sh
set -e

echo "=== MIGRATION ENGINE (POSIX SAFE) ==="

BOOTSTRAP="docker-entrypoint-initdb.d/00_phase54_bootstrap.sql"

echo "running base bootstrap"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$BOOTSTRAP"

echo "migration engine complete"
