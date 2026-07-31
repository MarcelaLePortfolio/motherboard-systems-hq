import MatildaChatWorkspace from "../matilda-chat/MatildaChatWorkspace";
import {
  MissionControlProvider,
} from "../mission-control/MissionControlProvider";
import MissionDashboardWorkspace from "./MissionDashboardWorkspace";
import type { ShellWorkspace } from "./NavigationRegion";

type WorkspaceMountProps = {
  activeWorkspace: ShellWorkspace;
};

function PackagesWorkspacePlaceholder() {
  return (
    <section
      className="shell-placeholder-workspace"
      aria-labelledby="packages-workspace-heading"
    >
      <h1 id="packages-workspace-heading">Packages</h1>

      <p className="shell-placeholder-workspace__notice">
        Package review is not implemented yet.
      </p>
    </section>
  );
}

export default function WorkspaceMount({
  activeWorkspace,
}: WorkspaceMountProps) {
  let workspace;

  if (activeWorkspace === "dashboard") {
    workspace = (
      <MissionControlProvider>
        <MissionDashboardWorkspace />
      </MissionControlProvider>
    );
  } else if (activeWorkspace === "packages") {
    workspace = <PackagesWorkspacePlaceholder />;
  } else {
    workspace = <MatildaChatWorkspace />;
  }

  return (
    <main
      className="shell-workspace-mount"
      data-shell-region="workspace-mount"
      aria-label="Workspace content area"
    >
      {workspace}
    </main>
  );
}
