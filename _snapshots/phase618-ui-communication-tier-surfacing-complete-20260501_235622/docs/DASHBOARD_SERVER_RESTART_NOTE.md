# Dashboard ERR_CONNECTION_REFUSED – Local Server Restart

Symptom:
- Browser shows: "This site can’t be reached – localhost refused to connect (ERR_CONNECTION_REFUSED)"

Most likely cause:
- Nothing was listening on port 3000 when the dashboard was opened.
- The local dev server process (server.mjs) was not running.

Recovery action used:
- Restarted the local dev server with:
  NODE_ENV=development PORT=3000 node server.mjs &

How to fix this next time:
1. From the Motherboard_Systems_HQ repo root, run:
   NODE_ENV=development PORT=3000 node server.mjs &

2. Wait a few seconds, then visit:
   http://127.0.0.1:3000

Notes:
- The ampersand (&) runs the server in the background so the terminal stays usable.
- No code changes were required; this is a runtime/process issue, not a bug in the
  dashboard layout or Matilda Chat code.
