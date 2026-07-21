# AF-004 — SSE Semantics Belong to the Server

Status: Accepted

Confidence: High

## Question

Where is the authoritative definition of SSE behavior within the system?

## Evidence

### Repository Evidence

Repository inspection identified:

- server/routes/api-compat.ts exposing the active SSE endpoints
- server/optional-sse.mjs containing an incomplete historical implementation
- Legacy dashboard modules acting as SSE consumers rather than protocol authorities

### Reasoning

The active runtime exposes SSE behavior through the server, while the historical implementation is no longer authoritative. Frontend code consumes the event stream but does not define the protocol itself.

## Finding

The server is the authoritative owner of SSE semantics.

Frontend implementations should consume the server-defined protocol rather than establishing independent SSE behavior.

## Implications

Changes to event formats, endpoint behavior, or protocol semantics should originate from the server.

Frontend migrations should preserve compatibility with the server-defined contract rather than legacy implementation details.

## Supersedes

None.
