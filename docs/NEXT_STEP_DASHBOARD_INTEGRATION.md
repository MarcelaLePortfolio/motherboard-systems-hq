# Next Step – Wire Matilda Chat Console into Dashboard

Branch: feature/v11-dashboard-bundle

## Current Status

- `public/js/matilda-chat-console.js` is implemented and pushed.
- Script is correct and ready.
- Backend `/api/chat` is functioning.
- Dashboard does NOT yet load the script.

## Why You Do Not See the Chat Console Yet

The Matilda Chat Console script will ONLY run if the dashboard HTML includes:

<script src="/js/matilda-chat-console.js"></script>

Right now, the dashboard HTML (or bundled script pipeline) does not reference it.  
Therefore the browser never loads the file → no chat card appears.

## Required Integration Step

Edit your dashboard HTML file and add this line near the other scripts, typically before the closing </body>:

<script src="/js/matilda-chat-console.js"></script>

Once this line is added:

- The Matilda Chat Console will appear above Task Delegation.
- It will POST to /api/chat.
- It will show sent messages and Matilda's replies.

This is the ONLY missing step before the feature becomes visible.
