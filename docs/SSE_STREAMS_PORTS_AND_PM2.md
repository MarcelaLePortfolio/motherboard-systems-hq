SSE Streams – Ports, Helper, and PM2

Final configuration:

Reflections SSE
- Script: reflections-stream/reflections_stream.py
- Port: 3101
- Mode: --serve

Ops SSE
- Script: ops-stream/ops_stream.py
- Port: 3201
- Mode: --serve

Helper script
- scripts/start-sse-streams.sh
  - Runs:
    - python3 reflections-stream/reflections_stream.py 3101 --serve &
    - python3 ops-stream/ops_stream.py 3201 --serve &

PM2 ecosystem
- ecosystem.sse-streams.config.cjs
  - Uses:
    - args: "3101 --serve"
    - args: "3201 --serve"

Usage

Manual bring-up:
1. Start Node dashboard:
   NODE_ENV=development PORT=3000 node server.mjs &
2. Start SSE streams:
   ./scripts/start-sse-streams.sh
3. Open:
   http://127.0.0.1:3000

PM2-managed SSE streams:
1. pm2 start ecosystem.sse-streams.config.cjs
2. pm2 status
3. pm2 save

Once at least one reflections and one ops SSE stream are running, the dashboard should show:
- Live agent badges (not "unknown")
- Streaming System Reflections
- Streaming Critical Ops Alerts
