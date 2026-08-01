import {
  ApprovalRequestProvider,
} from "../approvals/ApprovalRequestProvider";
import ApprovalsWorkspace from "../approvals/ApprovalsWorkspace";
import MatildaChatWorkspace from "../matilda-chat/MatildaChatWorkspace";
import {
  MissionControlProvider,
} from "../mission-control/MissionControlProvider";
import {
  PackageReadProvider,
} from "../packages/PackageReadProvider";
import PackagesWorkspace from "../packages/PackagesWorkspace";
import { useProjectContext } from "../project-context/useProjectContext";
import MissionDashboardWorkspace from "./MissionDashboardWorkspace";
import type { ShellWorkspace } from "./NavigationRegion";

type WorkspaceMountProps = {
  activeWorkspace: ShellWorkspace;
};

export default function WorkspaceMount({
  activeWorkspace,
}: WorkspaceMountProps) {
  const {
    activeProjectId,
  } = useProjectContext();

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
          <PackagesWorkspace />
        </PackageReadProvider>
      ) : activeWorkspace === "approvals" ? (
        <ApprovalRequestProvider
          projectId={activeProjectId}
        >
          <ApprovalsWorkspace />
        </ApprovalRequestProvider>
      ) : (
        <MatildaChatWorkspace />
      )}
    </main>
  );
}
