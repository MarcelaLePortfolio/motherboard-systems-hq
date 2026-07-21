import NavigationRegion from "./NavigationRegion";
import WorkspaceMount from "./WorkspaceMount";
import ProjectContextControl from "../project-context/ProjectContextControl";
import "./shell.css";

// Shell: the persistent application frame.
//
// Scope for this corridor: structural hosting only.
// - Does NOT implement a navigation model (workspace-oriented,
//   agent-oriented, or hybrid remains a deferred decision).
// - Does NOT implement attention representation.
// - Does NOT implement continuity/state-preservation mechanics —
//   there is nothing yet to preserve, since no real workspace exists.
// - Does NOT interpret backend, package, or lifecycle state.
//
// Its only confirmed job right now is proving that a stable
// application frame can host a navigation region and a workspace
// mounting area side by side, as separate extension points.
export default function Shell() {
  return (
    <div className="shell-frame" data-shell-region="frame">
      <header className="shell-orientation" data-shell-region="orientation">
        <div className="shell-identity" data-shell-region="identity">
          <span className="shell-identity__mark" aria-hidden="true">
            M
          </span>
          <span className="shell-identity__label">
            Motherboard Systems HQ
          </span>
        </div>

        <div className="shell-project-context" data-shell-region="project-context">
          <ProjectContextControl />
        </div>
      </header>

      <div className="shell-body">
        <NavigationRegion />
        <WorkspaceMount />
      </div>
    </div>
  );
}
