import { useState } from "react";
import NavigationRegion, { type ShellWorkspace } from "./NavigationRegion";
import WorkspaceMount from "./WorkspaceMount";
import ProjectContextControl from "../project-context/ProjectContextControl";
import "./shell.css";

export default function Shell() {
  const [activeWorkspace, setActiveWorkspace] =
    useState<ShellWorkspace>("dashboard");

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

        <div
          className="shell-project-context"
          data-shell-region="project-context"
        >
          <ProjectContextControl />
        </div>
      </header>

      <div className="shell-body">
        <NavigationRegion
          activeWorkspace={activeWorkspace}
          onSelectWorkspace={setActiveWorkspace}
        />
        <WorkspaceMount activeWorkspace={activeWorkspace} />
      </div>
    </div>
  );
}
