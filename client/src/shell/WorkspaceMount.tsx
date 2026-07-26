import MatildaChatWorkspace from "../matilda-chat/MatildaChatWorkspace";
import MissionDashboardWorkspace from "./MissionDashboardWorkspace";
import PlaceholderWorkspace from "./PlaceholderWorkspace";
import type { ShellWorkspace } from "./NavigationRegion";

type WorkspaceMountProps = {
  activeWorkspace: ShellWorkspace;
};

export default function WorkspaceMount({
  activeWorkspace,
}: WorkspaceMountProps) {
  switch (activeWorkspace) {
    case "mission-control":
      return <MissionDashboardWorkspace />;

    case "conversation":
      return <MatildaChatWorkspace />;

    case "engineering":
      return <PlaceholderWorkspace title="Engineering" />;

    case "operations-department":
      return <PlaceholderWorkspace title="Operations Department" />;

    case "atlas":
      return <PlaceholderWorkspace title="Atlas" />;

    case "effie":
      return <PlaceholderWorkspace title="Effie" />;

    case "cade":
      return <PlaceholderWorkspace title="Cade" />;

    case "executive-review":
      return <PlaceholderWorkspace title="Executive Review" />;

    case "operations":
      return <PlaceholderWorkspace title="Operations" />;

    case "archives":
      return <PlaceholderWorkspace title="Archives" />;

    case "media-library":
      return <PlaceholderWorkspace title="Media Library" />;

    case "settings":
      return <PlaceholderWorkspace title="Settings" />;

    default:
      return <MissionDashboardWorkspace />;
  }
}
