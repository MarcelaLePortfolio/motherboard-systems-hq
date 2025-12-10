
# Phase 11 – OPS SSE Temporarily Disabled

## What happened

You saw these in the browser console:

* `EventSource's response has a MIME type ("text/html") that is not "text/event-stream". Aborting the connection.`
* `[OPS SSE] EventSource setup failed: TypeError: "" is not a function`

### Explanation

1. **MIME type error**

   * The dashboard JS tried to open a Server-Sent Events stream with:

     * `new EventSource("/events/ops")`
   * For SSE to work, `/events/ops` must return:

     * `Content-Type: text/event-stream`
     * A streaming response with lines starting with `data: ...`
   * Instead, your backend returned an HTML page (likely a 404 or generic error), so the browser:

     * Detected `text/html` instead of `text/event-stream`
     * Aborted the EventSource connection
     * Logged:
       `EventSource's response has a MIME type ("text/html") that is not "text/event-stream". Aborting the connection.`

2. **`[OPS SSE] EventSource setup failed: TypeError: "" is not a function`**

   * This is a follow-on error from the failed EventSource setup.
   * Our previous code attempted to wire the SSE and hit an internal path where a value that was expected to be callable wasn’t.
   * Once the EventSource fails due to the wrong MIME type, downstream logic that assumes a live SSE connection can throw additional errors like this.

Because the backend SSE endpoint is not ready yet, the *root cause* is **server-side**, not the dashboard JS.

---

## Matilda Chat & Delegation Warnings

You also saw:

* `[Dashboard bundle] Matilda chat elements missing. Form: false Input: true Output: false`
* `[Dashboard bundle] Delegation elements missing. Form: false Input: true Log: false`

### Explanation

These come from defensive checks in `dashboard-bundle-entry.js`:

* The script looks for specific DOM nodes by ID:

  * `matilda-chat-form`, `matilda-chat-input`, `project-viewport-output`
  * `task-delegation-form`, `task-delegation-input`, `task-delegation-log`
* At that moment:

  * The **inputs** existed (so `Input: true`),
  * But the **form** and/or **output/log containers** with those exact IDs did not (`Form: false`, `Output: false`, `Log: false`).

The warnings mean: “I can’t safely attach event listeners because the expected DOM structure isn’t fully present.”

We resolved this by:

1. Rebuilding `public/dashboard.html` with consistent IDs:

   * `id="matilda-chat-form"`, `id="matilda-chat-input"`, `id="project-viewport-output"`
   * `id="task-delegation-form"`, `id="task-delegation-input"`, `id="task-delegation-log"`
2. Adding JS fallbacks:

   * If the form is missing but the input exists, use `input.form`
   * If the output/log containers are missing, create them dynamically

After those fixes, the warnings no longer block functionality; they’ll only appear if the DOM gets out of sync again.

---

## v11.10 Decision

For **OPS SSE** in v11.10:

* **EventSource wiring has been removed** from the bundle.
* The OPS pill is now:

  * Always rendered
  * Left as static text: `OPS: Unknown`
  * No longer attempts to open `/events/ops`

This keeps the dashboard clean (no SSE console errors) while the backend is still under construction.

---

## Future Fix (Later Phase)

When you’re ready to restore live OPS status:

1. Implement `/events/ops` on the backend to:

   * Return `Content-Type: text/event-stream`
   * Stream JSON status events (e.g. `data: {"status":"Online"}`)

2. Re-enable the EventSource logic in `public/js/dashboard-bundle-entry.js`:

   * `var opsSource = new EventSource("/events/ops");`
   * Update the pill text from incoming events.

Until then, v11.10 intentionally keeps the OPS pill static and error-free.
