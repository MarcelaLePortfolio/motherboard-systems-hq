# Matilda Chat Console – Implementation Notes

Branch: feature/v11-dashboard-bundle

## Files

- `public/js/matilda-chat-console.js`
  - Injects a new "Matilda Chat Console" card into the dashboard UI.
  - Looks for the Task Delegation card and inserts itself directly **above** it.
  - Provides:
    - Scrollable transcript area
    - Textarea input
    - "Send" button
  - Wires to the backend endpoint:
    - `POST /api/chat` with body:
      - `{ "message": "<user text>", "agent": "matilda" }`

## Behavior

- On page load, the script:
  1. Creates the Matilda Chat card DOM elements.
  2. Attempts to find the Task Delegation card via:
     - `[data-section="task-delegation"]`
     - `#task-delegation-card`
     - `.task-delegation-card`
  3. If found, inserts the Matilda card just before it.
  4. If not found, inserts the card at the top of `<body>` as a fallback.
- The chat transcript visually separates:
  - `You:` (user messages)
  - `Matilda:` (backend replies)
- Enter key behavior:
  - `Enter` submits the message.
  - `Shift+Enter` inserts a newline.

## Backend dependency

- Requires `server.mjs` to be running and exposing:
  - `POST /api/chat`
  - Expected JSON response:
    - `{ "reply": "Matilda placeholder: <your message>" }` (or equivalent)

## Next integration steps (manual reminder)

- Ensure the dashboard HTML or bundle loads:
  - `/js/matilda-chat-console.js`
- Once loaded by the dashboard:
  - The Matilda Chat Console will appear above Task Delegation.
