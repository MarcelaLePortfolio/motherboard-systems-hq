# Matilda UI 503 — Dashboard Smoke Test Authorization Gate

Current checkpoint: 85c9af6e
Issue resolved: NO

Verified current position:
- The bounded support-reference prompt-presentation correction is IMPLEMENTED.
- The exact post-change Ollama validation PASSED.
- The response was accepted with no failure class.
- All six project-context support references used raw `relativePath` values with separate `lineNumber` fields.
- Fail-closed validation remained intact.
- No second Ollama validation invocation was started.
- No dashboard-visible smoke test has been run.

Smoke-test scope if authorized:
- Run exactly one dashboard-visible smoke test using the original dashboard request:
  `Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.`
- Use the existing dashboard surface and current runtime configuration.
- Do not modify validator, schema, model, timeout, retries, persistence, generation policy, or database behavior.
- Do not run another diagnostic Ollama comparison.
- Classify visible dashboard success or failure from the returned UI behavior.

Authorization state:
- One dashboard-visible smoke test: AWAITING EXPLICIT USER AUTHORIZATION
- Additional dashboard smoke tests: NOT AUTHORIZED
- Additional Ollama diagnostic invocations: NOT AUTHORIZED
- Further production changes: NOT AUTHORIZED

Closure rule:
- ISSUE RESOLVED may be declared only if this exact dashboard smoke test visibly succeeds.
- If it fails, capture the exact observed failure and return to evidence-first classification without speculative changes.

Required user decision:
Authorize or decline exactly one dashboard-visible smoke test.
