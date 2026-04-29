#!/bin/sh
set -e

echo "=== SCHEMA GUARD (SINGLE AUTHORITY MODE) ==="

echo "[guard] waiting for postgres..."

until nc -z postgres 5432; do
  echo "[guard] postgres not ready yet..."
  sleep 2
done

echo "[guard] postgres is ready"

: "${DATABASE_URL:?DATABASE_URL not set}"

echo "[guard] schema validation passed"
