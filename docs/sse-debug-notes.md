SSE CORS debug notes:

- 2025-11-26: Updated ops_stream.py and reflections_stream.py to use Access-Control-Allow-Origin: * for local development.
- Verified both SSE servers are running on ports 3201 (OPS) and 3200 (Reflections).
- Next step: reload the dashboard at http://localhost:3022 and confirm that:
  - No CORS errors appear in the browser console.
  - System Reflections and OPS alerts begin populating live.
