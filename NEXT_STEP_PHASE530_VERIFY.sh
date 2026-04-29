#!/bin/bash

# Rebuild + restart dashboard
docker compose up -d --build dashboard

# Give it a moment to boot
sleep 2

# Verify SSE endpoint again
echo "---- SSE HEADERS ----"
curl -sS -o /dev/null -w "%{http_code} %{content_type}\n" http://localhost:3000/events/task-events

echo ""
echo "---- SSE STREAM (10s) ----"
curl -N --max-time 10 http://localhost:3000/events/task-events
