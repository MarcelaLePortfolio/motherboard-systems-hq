
# Phase 11 v11.10 – Status After Rollback to v11.7 Bundle

Current state (confirmed in browser):

* OPS pill: visible, green, “OPS: online”, bottom-right corner.
* Agent pool: all agents listed with yellow status.
* Console: shows `[matilda-chat] Matilda chat wiring complete`.
* Dashboard + postgres containers: up via docker-compose on port 8080.

This means:

* We are back on the last known stable bundle baseline for the OPS pill and core dashboard wiring.
* Matilda Chat wiring from that baseline is active again.
* We have NOT yet re-verified Matilda Chat behavior or Task Delegation behavior under v11.10.

---

## Next Functional Checks (Run Now, No Rebuild Needed)

1. Open Dashboard

   * Go to: `http://127.0.0.1:8080/dashboard`
   * Confirm:

     * OPS pill is still green “OPS: online” in the bottom-right.
     * Agent pool still shows agents with yellow status.
     * No new console errors on load.

2. Matilda Chat – Verify End-to-End

   1. In the Matilda Chat input, type:

      * `ping from dashboard — v11.10 rollback baseline check`

   2. Click the Matilda Chat send button.

   3. Open DevTools:

      * **Console** tab:

        * Confirm you still see `[matilda-chat] Matilda chat wiring complete` on page load.
        * Note any new errors or logs that appear when you click send.
      * **Network** tab:

        * Filter by `chat`.
        * Click send again if needed.
        * Look for a `POST /api/chat` request:

          * Status should be `200`.
          * Response should be JSON with Matilda’s reply (not an HTML error page).

   4. Project Visual Output monitor (right column):

      * Confirm it shows a new entry corresponding to the Matilda chat action:

        * Something like “Matilda Chat” or a JSON payload with the response.

3. Task Delegation – Quick Sanity Check

   1. In the Task Delegation input, type:

      * `create a dummy test task for Phase 11 v11.10 rollback baseline`

   2. Click the delegation submit button.

   3. DevTools:

      * **Console**:

        * Note any errors or logs that appear on click.
      * **Network**:

        * Filter by `task` or `delegate`.
        * Look for a `POST` to a task/delegation endpoint (e.g. `/api/delegate-task` or similar) with status `200`.

   4. Project Visual Output monitor:

      * Check for a new entry associated with the delegation request:

        * It may show task `id` and `status`, or a raw JSON payload.

4. What to Report Back

   After running these checks, report:

   * Matilda Chat:

     * Does the send button work?
     * Does a `POST /api/chat` appear with status `200`?
     * Does the Project Visual Output monitor show the interaction?

   * Task Delegation:

     * Does the submit button work?
     * Do you see a `POST` to the delegation endpoint with status `200`?
     * Does the Project Visual Output monitor show anything for the delegation?

   * Any console errors:

     * Copy/paste any red error messages that appear when clicking chat or delegation.

Use this summary as the basis for the next Phase 11 step (either confirming v11.10 functional success or targeting a specific remaining wiring issue).
