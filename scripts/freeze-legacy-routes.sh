
#!/usr/bin/env bash

echo "Freezing legacy routes/routes into backup snapshot..."

mkdir -p routes/_legacy_backup

cp -R routes/routes routes/_legacy_backup/routes_snapshot_$(date +%Y%m%d_%H%M%S)

echo "Legacy snapshot complete."

