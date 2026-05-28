
#!/usr/bin/env bash

set -euo pipefail

python3 inspect-rio-drive-repo-bundle-dashboard-candidates-v2.py

git add inspect-rio-drive-repo-bundle-dashboard-candidates-v2.py inspect-rio-drive-repo-bundle-dashboard-candidates-v2.sh RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt _dashboard_candidate_previews/rio-drive-repo-bundles-v2 || true

git commit -m "Inspect Rio Drive repo bundle dashboard candidates v2" || true

git push

