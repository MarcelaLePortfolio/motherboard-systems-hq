SSE CORS debug notes:

- 2025-11-26:
  - Updated ops_stream.py and reflections_stream.py to use Access-Control-Allow-Origin: * for local development.
  - Added restart-sse-servers.sh helper to cleanly relaunch OPS (3201) and Reflections (3200) servers.
  - Confirmed both Python SSE servers start without port conflicts.
- Current focus:
  - Verify that each SSE endpoint actually streams data (not just accepts connections).
  - Then confirm that the dashboard at http://localhost:3022 renders live OPS + Reflections updates without CORS errors.
