import PlaceholderWorkspace from "./PlaceholderWorkspace";

// WorkspaceMount: a stable, generic hosting area for whatever the
// primary workspace turns out to be (Matilda, Packages Inbox, or
// any other future workspace).
//
// This component knows nothing about domain content. It does not
// interpret packages, lifecycle state, agents, or backend data. In
// this corridor it hosts exactly one thing: an inert placeholder
// that proves the mount point itself is stable and reachable.
//
// A later, separate corridor is responsible for deciding how real
// workspaces get mounted here (e.g. by reference, by route, by
// some other mechanism) — that decision is intentionally not made
// by this file.
export default function WorkspaceMount() {
  return (
    <main
      className="shell-workspace-mount"
      data-shell-region="workspace-mount"
      aria-label="Workspace content area"
    >
      <PlaceholderWorkspace />
    </main>
  );
}
