# Matilda Chat – Routing Diagnosis Checkpoint

Commands just run:

- rg "Systems Operations Dashboard" -n || grep -R "Systems Operations Dashboard" -n .
- rg "/dashboard" server.mjs || grep -n "/dashboard" server.mjs || true

Purpose:

- Identify which file on disk contains the HTML currently served at GET /dashboard.
- Confirm how server.mjs resolves the /dashboard route and which template or static file it sends.
- This will reveal the correct source file where we must add:
  - <script defer src="js/matilda-chat-console.js"></script>
  OR confirm that the script should be loaded via bundle.js only.

Next:

- Once the matching HTML file is identified from the ripgrep/grep results,
  we will directly update THAT file to load js/matilda-chat-console.js,
  then commit and push, and finally verify that the chat console and debug badge appear.
