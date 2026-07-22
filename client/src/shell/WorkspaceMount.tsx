import MatildaChatWorkspace from "../matilda-chat/MatildaChatWorkspace";

// WorkspaceMount: the stable hosting boundary for the active workspace.
//
// The first mounted workspace is Matilda Chat. Workspace selection and
// navigation remain deferred; this component does not interpret project,
// package, lifecycle, or authority state itself.
export default function WorkspaceMount() {
  return (
    <main
      className="shell-workspace-mount"
      data-shell-region="workspace-mount"
      aria-label="Workspace content area"
    >
      <MatildaChatWorkspace />
    </main>
  );
}
