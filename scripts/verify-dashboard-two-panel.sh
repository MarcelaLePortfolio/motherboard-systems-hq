#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

URL="${1:-http://127.0.0.1:3000/dashboard}"
TMP_HTML="$(mktemp)"
TMP_HEADERS="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML" "$TMP_HEADERS"
}
trap cleanup EXIT

curl -fsS -D "$TMP_HEADERS" "$URL" -o "$TMP_HTML"

required_markers=(
  "Operator Workspace"
  "Chat"
  "Delegation"
  "Recent Tasks"
  "Task Events"
  "Atlas Subsystem Status"
)

missing=0
for marker in "${required_markers[@]}"; do
  if grep -Fq "$marker" "$TMP_HTML"; then
    echo "Found: $marker"
  else
    echo "Missing marker: $marker"
    missing=1
  fi
done

if grep -Fq "Observational Workspace" "$TMP_HTML" || grep -Fq "Telemetry Workspace" "$TMP_HTML"; then
  echo "Found: Observational/Telemetry Workspace"
else
  echo "Missing marker: Observational/Telemetry Workspace"
  missing=1
fi

if grep -Fq "Task History" "$TMP_HTML" || grep -Fq "Task Activity" "$TMP_HTML"; then
  echo "Found: Task History/Task Activity"
else
  echo "Missing marker: Task History/Task Activity"
  missing=1
fi

echo
sed -n '1,20p' "$TMP_HEADERS"

echo
if [ "$missing" -eq 0 ]; then
  echo "Layout contract PASSED."
else
  echo "Layout contract FAILED."
  exit 1
fi
