# Matilda UI 503 — Frontend Reachability Classification

Issue resolved: NO

Observed evidence:
- Vite process PID 19296 is listening on IPv6 loopback only:
  - `[::1]:5173`
- Direct IPv4 probe to `127.0.0.1:5173` fails with connection refused.
- Backend is healthy on port 3000.
- The prior browser failure therefore occurred before Matilda request submission.

Classification:
- FRONTEND_PROCESS_RUNNING=YES
- FRONTEND_LISTENER_BOUND_TO_IPV6_LOOPBACK=YES
- FRONTEND_IPV4_LOOPBACK_REACHABLE=NO
- PRIOR_READINESS_CHECK_FALSE_POSITIVE_FOR_127_0_0_1=YES
- ROOT_CAUSE_OF_BROWSER_REFUSAL=IPV4_IPV6_BINDING_MISMATCH
- MATILDA_503_REPRODUCED=NO
- SUPPORT_REFERENCE_FIX_DISPROVEN=NO
- AUTHORIZED_VISIBLE_SUBMISSION_CONSUMED=NO
- ISSUE_RESOLVED=NO

Next action:
- Use the already-running Vite listener at `http://localhost:5173` or `http://[::1]:5173`.
- Do not restart or kill PID 19296.
- Do not start another frontend process.
- Do not submit the Matilda request yet.
- First verify that the existing listener is reachable through localhost/IPv6.
