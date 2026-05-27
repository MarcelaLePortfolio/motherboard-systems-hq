# Phase 39.4 — Signed Grants (Authority Hardening) (Plan)
(Next Phase Handoff)

## One-liner handoff
Replace Option A “local JSON grants” with **signed grant artifacts** verified offline using pinned public keys, keeping the evaluator pure and the enforcement combinator unchanged.

---

## Goal
Move from “operator-local grants” (Option A) to “cryptographically verifiable grants” (Option B) so a rogue runtime/agent cannot forge authorization.

Phase 39.3 provided:
- grant loader + validator (Option A)
- pure combiner + audit record format
- tests + harness

Phase 39.4 adds:
- signed grant format
- offline verification
- key pinning
- deterministic verification tests (using fixture signatures)

---

## Non-goals
- No schema changes.
- No network gatekeeper service yet (Option C).
- No key rotation automation yet.
- No consumption tracking yet (single_use remains an intent until schema/event support exists).

---

## Signed grant format (v1)
### Artifact
JSON document:
- `grant_version: 1`
- `grant` (payload)
- `signature` (base64 or hex)
- `kid` (key id)
- `alg` (e.g., ed25519)

### Payload fields (same as Option A, plus nonce)
- `id`
- `allow_actions`
- `scope`, `scope_id`
- `expires_at` (required)
- `nonce` (required, random string)
- `single_use` (default true)
- `notes` (optional)

### Canonicalization
Signature must be over a **canonical JSON** representation of `grant`:
- stable key ordering (use server/policy/stable_json.mjs)
- no whitespace
- UTF-8 bytes

---

## Key pinning
- `policy/keys.json` (checked in)
  - list of allowed public keys + `kid`
  - algorithm
- Verification rejects unknown `kid`.

---

## Verification flow (offline)
1) Parse signed grant JSON
2) Select public key by `kid`
3) Canonicalize `grant` payload
4) Verify signature (offline crypto)
5) If valid, treat as “grant_ok” with the embedded payload

---

## Tests (must pass)
1) Valid signature verifies + yields grant_ok
2) Modified payload fails verification
3) Unknown `kid` fails
4) Expired grant fails
5) Tier C remains deny even with valid signed grant (same combine rule)

---

## Implementation sketch (future)
- `server/policy/signed_grants.mjs` (verify)
- `policy/keys.json` (pinned public keys)
- `policy/grants.signed.example.json` (fixture)
- tests with pre-generated signature fixtures (no runtime randomness in tests)

---

## Stop point
Phase 39.4 ends when:
- signed grant verification is implemented + tested with fixtures
- key pinning is in place
- Option A loader remains available behind a dev flag (optional), but default path prefers signed grants

