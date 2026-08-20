# Matilda UI 503 — Dashboard Visible Smoke Test Connection Refusal

Issue resolved: NO

Observed result:
- The browser returned `ERR_CONNECTION_REFUSED` at `http://127.0.0.1:5173/`.
- The Matilda request was NOT submitted.
- No visible Matilda response was produced.
- The authorized dashboard submission was NOT consumed.
- No additional diagnostic Ollama invocation occurred.

Classification:
- DASHBOARD_VISIBLE_SMOKE_TEST_REACHED_MATILDA=NO
- FAILURE_CLASS=FRONTEND_RUNTIME_REACHABILITY
- MATILDA_503_REPRODUCED=NO
- SUPPORT_REFERENCE_FIX_DISPROVEN=NO
- ISSUE_RESOLVED=NO

Next evidence required:
- Inspect the actual frontend process and listener state.
- Determine why the earlier readiness check reported port 5173 ready although the browser could not connect.
- Do not retry the dashboard submission until frontend reachability is established.
