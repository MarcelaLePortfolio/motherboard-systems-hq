
#!/bin/bash

set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

OUTPUT_DIR="./tmp/semantic-snapshots"

OUTPUT_FILE="$OUTPUT_DIR/semantic-snapshot-$TIMESTAMP.json"

mkdir -p "$OUTPUT_DIR"

echo "Exporting semantic observability snapshot..."

curl -s http://localhost:3000/api/tasks > "$OUTPUT_FILE"

echo ""

echo "Snapshot written to:"

echo "$OUTPUT_FILE"

echo ""

echo "Top-level semantic fields observed:"

python3 - << 'PY'

import json

import glob

import os

files = sorted(glob.glob("./tmp/semantic-snapshots/*.json"))

latest = files[-1]

with open(latest) as f:

    payload = json.load(f)

tasks = payload.get("tasks", [])

observed = set()

for task in tasks:

    artifact = task.get("artifact") or {}

    for key in artifact.keys():

        if "semantic" in key:

            observed.add(key)

print(json.dumps(sorted(observed), indent=2))

PY

