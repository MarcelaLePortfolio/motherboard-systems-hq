#!/usr/bin/env bash

# Simple helper to start both Python SSE streams from the repo root.

python3 reflections-stream/reflections_stream.py &
python3 ops-stream/ops_stream.py &

echo "Started reflections-stream and ops-stream (if no errors were shown above)."
echo "You can now refresh: http://127.0.0.1:3000"
