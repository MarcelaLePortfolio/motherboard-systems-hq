
#!/usr/bin/env bash

set -euo pipefail

PORT="${PORT:-8099}"

echo "Serving dashboard candidate previews at:"

echo "http://localhost:${PORT}/_dashboard_candidate_previews/"

echo

echo "Open each preview and pick the one that visually matches the latest remembered dashboard."

echo "This does not modify localhost:8080."

python3 -m http.server "$PORT"

