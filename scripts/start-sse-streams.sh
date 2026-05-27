#!/usr/bin/env bash

# Start Reflections SSE Stream
python3 reflections-stream/reflections_stream.py 3101 --serve &
echo "Started reflections stream on port 3101"

# Start Ops SSE Stream
python3 ops-stream/ops_stream.py 3201 --serve &
echo "Started ops stream on port 3201"

echo ""
echo "Both SSE streams launched. Refresh http://127.0.0.1:3000 to see live updates."
