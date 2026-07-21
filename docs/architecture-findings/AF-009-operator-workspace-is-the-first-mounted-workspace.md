# AF-009 — Operator Workspace Is the First Mounted Workspace

Status: Accepted

Confidence: High

## Question

What should be the first real workspace mounted within the React shell?

## Evidence

### Repository Evidence

Repository inspection established that:

- `WorkspaceMount` is intentionally generic and exists only as a stable workspace host.
- The legacy dashboard organizes operator functionality under a single **Operator Workspace** containing Chat and Delegation as panels.
- The current runtime (`server/index.ts`) does not mount the legacy chat, delegation, or operator-guidance runtime endpoints.
- The shell and current runtime therefore expose different levels of capability, and the runtime remains authoritative.

### Reasoning

The shell should remain responsible only for hosting workspaces, not deciding their internal behavior.

The legacy dashboard provides evidence of product intent, while the current runtime defines which capabilities may be truthfully exposed. These concerns must remain separate.

The Operator Workspace is the strongest architectural candidate for the first mounted workspace because it represents a coherent user-facing capability boundary rather than a single feature or transport.

## Finding

The first workspace mounted through `WorkspaceMount` should be the Operator Workspace.

`WorkspaceMount` should remain workspace-agnostic, while the Operator Workspace owns future operator-facing capabilities such as Chat, Delegation, and related operator surfaces.

Capabilities that are not currently supported by the active runtime should remain explicitly unavailable until their backend contracts are intentionally restored.

## Implications

The React shell continues to function as a generic composition layer.

Future implementation should replace the placeholder workspace with an `OperatorWorkspace` component rather than embedding operator-specific behavior into the shell itself.

Legacy dashboard artifacts may inform workspace structure but must not be treated as authoritative runtime behavior.

## Supersedes

None.
