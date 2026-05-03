# Phase 11 – Matilda Chat UX + `/api/chat` Improvement Plan
_Last updated: 2025-12-04_

Baseline:
- Branch: `feature/v11-dashboard-bundle`
- Golden tag: `v11.2-matilda-chat-bundled`
- Dashboard uses single `/bundle.js` entry.
- Matilda chat card + task delegation are visible and functional at a basic level.
- SSE services (OPS 3201 / Reflections 3200) are intentionally offline for now.

This file scopes next steps to:
1. Matilda Chat UX polish (CSS/markup only).
2. `/api/chat` behavior improvements for Matilda.
3. Defers SSE + DB work to later phases.

---

## 1) Matilda Chat UX Polish (Frontend-Only)

### 1.1 Target Experience

The Matilda chat card should:
- Feel like a first-class tile in the dashboard.
- Visually match other cards (borders, spacing, typography).
- Sit in a clear, intentional position (likely hero area under header, above the main rows).
- Handle longer chats gracefully with scroll behavior.

### 1.2 Layout & Placement Checklist

Confirm in `public/dashboard.html` and related JS:

- [ ] Matilda chat card container has a stable ID or class (e.g., `#matilda-chat-card` or similar).
- [ ] Card is positioned in the desired region:
      - Under main header / intro text.
      - Above or alongside task delegation and status tiles.
- [ ] The internal structure is something like:
      - Header (label, subtitle, optional icon).
      - Scrollable messages area.
      - Input + send/delegate controls.

If placement changes are needed:
- [ ] Adjust dashboard layout markup so the chat card lives in a predictable grid region instead of being “tacked on” at the bottom or squeezed in.
- [ ] Keep changes HTML-only (no JS logic changes) for this step.

### 1.3 Visual Styling Checklist

Primary styling file is expected to be:  
- `public/css/dashboard.css`

Make Matilda chat align with other tiles:

- [ ] Card width and max-width are consistent with other cards in its row.
- [ ] Padding and border radius match dashboard tile style.
- [ ] Font sizes and colors are consistent with the rest of the dashboard.
- [ ] Background and border colors work in both light/dark modes (if applicable).

Chat-specific details:

- [ ] Messages area:
      - Has a fixed max-height or uses flex layout to avoid pushing everything down.
      - Is scrollable when there are many messages.
      - Uses readable line-height and spacing between messages.
- [ ] Input row:
      - Input and button are aligned.
      - Button state is clear (normal vs “sending”).
      - Mobile / narrow viewport: input and button don’t wrap in a broken way.

Implementation guideline:
- Prefer adding/adjusting CSS near the bottom of `dashboard.css` with clearly labeled comments such as:
  - `/* Phase 11 – Matilda chat card UX */`
- Avoid editing non-chat rules unless necessary to keep risk low.

### 1.4 UX Behavior (No New Logic Yet)

Frontend behavior that should already be present and just validated:

- [ ] Clicking the “Send” / chat button:
      - Disables the button while the request is in-flight.
      - Shows some feedback like “Sending…” or spinner (if already implemented).
- [ ] On success:
      - Appends Matilda’s reply to the messages area.
      - Re-enables the button and clears the input.
- [ ] On error:
      - Shows a clear but lightweight error text (e.g., `(network error)` or `(server error)`).
      - Re-enables the button.

If any of these are missing, they will be added in the next frontend pass after `/api/chat` is confirmed.

---

## 2) `/api/chat` Behavior Improvements (Backend)

Goal: Make Matilda’s replies feel intentional and stable, even before wiring to the full agent runtime.

Primary backend file is expected to be:
- `server.mjs` (Express app on localhost:3000)

### 2.1 Endpoint Contract

Desired request shape (already used by the dashboard):

- Method: `POST /api/chat`
- Body: JSON
  - `{ "message": string, "agent": "matilda" | string }`

Desired response shape:

- Status: `200 OK` on success.
- Body: JSON
  - `{ "reply": string }`

Error behavior:

- On unexpected errors:
  - Status: `500`
  - Body: `{ "reply": "(error)" }` or similar, plus console logging.

Checklist for `/api/chat` in `server.mjs`:

- [ ] Confirm request body parsing via `express.json()` or similar middleware is in place.
- [ ] Validate presence of `message` and optionally `agent`.
- [ ] If `agent === "matilda"`:
      - Route to Matilda-specific logic.
- [ ] For other agents (if used later), keep behavior well-defined but simple.

### 2.2 Matilda Reply Strategy (Improved Stub for Now)

Until the full Matilda pipeline is integrated, use an “improved stub”:

- [ ] Generate a reply that:
      - Echoes back part of the user’s message.
      - Adds a helpful, deterministic note (e.g., “Matilda received: …”).
      - Avoids referencing features that don’t exist yet.
- [ ] Include minimal context:
      - Maybe prefix reply with “Matilda:” to distinguish in UI.

Example stub reply pattern (concept only):

- `Matilda: I see you said, "<user message>". I’m online and listening from the dashboard.`

### 2.3 Logging and Observability

Optional but recommended:

- [ ] Add a simple console log when `/api/chat` is hit:
      - `console.log("[/api/chat] agent=%s message=%s", agent, message);`
- [ ] Optionally, append a line to a local log or reflections stream for each chat.
- [ ] Ensure logs are concise to avoid noise.

Error handling:

- [ ] Wrap core logic in try/catch.
- [ ] On error:
      - `console.error("Error in /api/chat:", err);`
      - Return `{ reply: "(error)" }` with `500` status.

---

## 3) Frontend Error & Loading States (After Backend Confirmed)

Once `/api/chat` is stable, adjust frontend chat console JS (likely in `public/js/matilda-chat-console.js`):

- [ ] On submit:
      - Disable send button.
      - Optionally show “Sending…” indicator.
- [ ] On success:
      - Add user message + Matilda reply to transcript.
      - Scroll transcript to bottom.
      - Re-enable button and clear input.
- [ ] On error:
      - Show a short error message in transcript area or under input.
      - Re-enable button and keep the user’s message in the input for retry.

Behavior should not depend on SSE being online.

---

## 4) Explicit Deferrals

To keep scope controlled for Phase 11:

- [ ] **No DB schema work** (all DB work is Phase 11.5 – DB Task Storage).
- [ ] **No SSE service restoration** here:
      - OPS @ `http://127.0.0.1:3201/events/ops`
      - Reflections @ `http://127.0.0.1:3200/events/reflections`
- [ ] No changes to task storage or task history beyond what’s already implemented.

These items will be handled in a later mini-phase once Matilda chat UX + `/api/chat` feel solid.

---

## 5) Verification & Tagging

Once items in Sections 1–3 are complete and verified:

- [ ] Confirm dashboard:
      - Loads cleanly with `/bundle.js`.
      - Shows a “settled” Matilda chat card.
      - Allows sending a message and receiving a plausible reply from `/api/chat`.
- [ ] Browser console:
      - No unhandled exceptions when sending chat messages.
      - Only expected network errors for SSE (if services are offline).

When satisfied:

- [ ] Create a new tag, e.g.:
      - `v11.3-matilda-chat-ux-and-chat-endpoint`
- [ ] Treat `v11.3-*` as the next golden baseline for future work (e.g., SSE restoration and DB tasks).

