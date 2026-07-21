# AF-007 — Project Registry Is an Independent Backend Capability

Status: Accepted

Confidence: High

## Question

Is Project Registry fundamentally a React frontend feature, or is it an independent backend capability?

## Evidence

### Repository Evidence

Repository inspection established that:

- A complete Project Registry implementation exists in `server/project-registry.mjs`.
- The backend exposes the following lifecycle endpoints:
  - `GET /api/projects/registry`
  - `POST /api/projects/inspect-path`
  - `POST /api/projects/register`
  - `POST /api/projects/archive`
  - `POST /api/projects/restore`
  - `POST /api/projects/active`
- `server/index.ts` imports `mountProjectRegistryRoutes` and mounts the Project Registry routes during server startup.

### Reasoning

The Project Registry capability is fully implemented and integrated into the active server runtime independently of the React shell. Its lifecycle, authority, and behavior are owned by the backend rather than the frontend.

## Finding

Project Registry is an independent backend capability.

Frontend implementations should consume the Project Registry through its published server contract rather than reimplementing its behavior.

## Implications

Future frontend work should treat Project Registry as an existing backend service whose responsibility is to expose authoritative project lifecycle behavior.

Changes to frontend technology or presentation should not require changes to the Project Registry architecture unless the backend contract itself intentionally evolves.

## Supersedes

None.
