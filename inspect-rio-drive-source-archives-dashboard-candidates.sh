
#!/usr/bin/env bash

set -euo pipefail

python3 inspect-rio-drive-source-archives-dashboard-candidates.py

git add inspect-rio-drive-source-archives-dashboard-candidates.py inspect-rio-drive-source-archives-dashboard-candidates.sh RIO_DRIVE_SOURCE_ARCHIVE_DASHBOARD_CANDIDATES.txt _dashboard_candidate_previews/rio-drive-source-archives || true

git commit -m "Inspect Rio Drive source archive dashboard candidates" || true

git push

