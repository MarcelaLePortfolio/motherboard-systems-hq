#!/bin/sh
set -e

echo "=== DOCKER ENTRYPOINT GUARD (SHARED CONTRACT) ==="

if [ -f /scripts/schema_guard.sh ]; then
  sh /scripts/schema_guard.sh
fi

exec "$@"
