
#!/usr/bin/env bash

set -euo pipefail

python3 compare-backend-against-rio-drive-v2.py

git add compare-backend-against-rio-drive-v2.py compare-backend-against-rio-drive-v2.sh BACKEND_RIO_DRIVE_COMPARISON_V2.txt

git commit -m "Compare backend against Rio Drive recovery sources v2"

git push

