
#!/usr/bin/env bash

set -euo pipefail

python3 inspect-rio-drive-disaster-backups-v3.py

git add inspect-rio-drive-disaster-backups-v3.py inspect-rio-drive-disaster-backups-v3.sh RIO_DRIVE_DISASTER_BACKUP_INSPECTION_V3.txt _dashboard_candidate_previews/rio-drive-latest || true

git commit -m "Inspect Rio Drive disaster backup dashboard candidate v3" || true

git push

