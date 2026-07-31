import MatildaChatWorkspace from "../matilda-chat/MatildaChatWorkspace";
import {
  MissionControlProvider,
} from "../mission-control/MissionControlProvider";
import {
  PackageReadProvider,
} from "../packages/PackageReadProvider";
import MissionDashboardWorkspace from "./MissionDashboardWorkspace";
import type { ShellWorkspace } from "./NavigationRegion";

function PackagesWorkspacePlaceholder() {
  return (
    <section
      className="shell-placeholder-workspace"
      aria-labelledby="packages-workspace-heading"
    >
      <h1 id="packages-workspace-heading">Packages</h1>

      <p>
        Package review presentation is intentionally
        deferred.
      </p>
    </section>
  );
}

type WorkspaceMountProps = {
  activeWorkspace: ShellWorkspace;
};

export default function WorkspaceMount({
  activeWorkspace,
}: WorkspaceMountProps) {
  return (
    <main
      className="shell-workspace-mount"
      data-shell-region="workspace-mount"
      aria-label="Workspace content area"
    >
      {activeWorkspace === "dashboard" ? (
        <MissionControlProvider>
          <MissionDashboardWorkspace />
        </MissionControlProvider>
      ) : activeWorkspace === "packages" ? (
        <PackageReadProvider>
          <PackagesWorkspacePlaceholder />
        </PackageReadProvider>
      ) : (
        <MatildaChatWorkspace />
      )}
    </main>
  );
}
