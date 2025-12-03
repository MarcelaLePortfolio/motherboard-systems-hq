SSE Streams – Helper Script & PM2 Setup

Files added:

1) scripts/start-sse-streams.sh
   - Starts both Python SSE servers from the repo root:
       python3 reflections-stream/reflections_stream.py &
       python3 ops-stream/ops_stream.py &
   - Usage:
       ./scripts/start-sse-streams.sh

2) ecosystem.sse-streams.config.cjs
   - PM2 config to keep both SSE processes alive.
   - Basic usage:
       pm2 start ecosystem.sse-streams.config.cjs
       pm2 status
       pm2 save

Once at least one reflections and one ops SSE stream are running,
the dashboard should show live agent badges, System Reflections,
and Critical Ops Alerts.
