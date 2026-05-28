
#!/usr/bin/env bash

set -euo pipefail

python3 inspect-rio-drive-repo-bundle-dashboard-candidates.py

git add inspect-rio-drive-repo-bundle-dashboard-candidates.py inspect-rio-drive-repo-bundle-dashboard-candidates.sh RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES.txt _dashboard_candidate_previews/rio-drive-repo-bundles || true

git commit -m "Inspect Rio Drive repo bundle dashboard candidates" || true

git push

