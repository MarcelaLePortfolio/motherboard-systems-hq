#!/bin/sh
set -eu

echo "🔐 Ensuring 'postgres' role exists in docker postgres container..."

docker-compose exec postgres sh -c "
  set -eu

  : \"\${POSTGRES_USER:?POSTGRES_USER is required}\"
  : \"\${POSTGRES_DB:?POSTGRES_DB is required}\"

  echo \"➡️ Using POSTGRES_USER=\${POSTGRES_USER}, POSTGRES_DB=\${POSTGRES_DB}\"

  CHECK=\$(psql -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" -tAc \"SELECT 1 FROM pg_roles WHERE rolname='postgres'\")
  if [ -z \"\$CHECK\" ]; then
    echo \"🆕 Creating role postgres...\"
    psql -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" -c \"CREATE ROLE postgres WITH LOGIN PASSWORD 'password';\"
  else
    echo \"✅ Role postgres already exists.\"
  fi
"

echo "✅ Role check complete."
