# React Dashboard Restoration and Regression Prevention

## Verified outcome

The intended Motherboard Systems HQ React dashboard was restored at `/ui` and visually confirmed by the operator.

The production server serves `client/dist/index.html` at `/ui` and the corresponding frontend assets under `/assets`.

Cloudflare Access authentication remains registered before the dashboard, asset, and API routes.

Unauthenticated requests to `/ui`, `/api/projects/registry`, and the frontend assets return HTTP 401.

## Root cause and prevention

The previously active server entrypoint served a minimal inline HTML dashboard instead of the existing React frontend.

The restored route now serves the React build.

A dedicated regression contract is implemented in:

- `scripts/verify-react-dashboard-route.sh`
- `.github/workflows/react-dashboard-route-contract.yml`

The contract verifies authentication middleware ordering, React entrypoint routing, absence of legacy inline HTML, and frontend asset existence.

The legacy dashboard layout contract is separate and does not protect the React entrypoint.

## Validation

- TypeScript server check: passed during restoration.
- Server build: passed during restoration.
- React production build: passed.
- React route regression contract: passed.
- Static negative regression characterization: passed.
- Production authentication boundary: passed.
- Authenticated browser verification: confirmed by operator.

## Operational boundaries

Do not replace the React dashboard route with inline HTML or the quarantined legacy dashboard.

Do not bypass Cloudflare Access to restore dashboard visibility.

Do not overwrite unrelated worktree modifications.

Do not perform a production restart solely to create a recovery checkpoint.

The regression guard protects the routing contract but cannot guarantee that every future frontend rendering change will be visually correct.
