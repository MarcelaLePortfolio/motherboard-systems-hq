import { useState } from "react";
import { useProjectContext } from "./useProjectContext";

export default function ProjectContextControl() {
  const {
    registry,
    loading,
    error,
    switchProject,
  } = useProjectContext();

  const [open, setOpen] = useState(false);

  if (loading) {
    return (
      <button className="shell-project-picker" type="button" disabled>
        <span>Loading projects…</span>
      </button>
    );
  }

  if (error) {
    return (
      <button className="shell-project-picker" type="button" disabled>
        <span>Project Registry unavailable</span>
      </button>
    );
  }

  async function handleProjectSelection(projectId: string) {
    try {
      await switchProject(projectId);
      setOpen(false);
    } catch {
      // Error state is already handled by the hook.
    }
  }

  return (
    <div className="project-context-control">
      <button
        className="shell-project-picker"
        type="button"
        aria-expanded={open}
        aria-haspopup="menu"
        onClick={() => setOpen((value) => !value)}
      >
        <span>
          {registry?.activeProject?.displayName ?? "No Active Project"}
        </span>
        <span aria-hidden="true">⌄</span>
      </button>

      {open && (
        <div className="project-context-menu" role="menu">
          {registry?.projects.map((project) => {
            const isActive =
              project.projectId === registry.activeProjectId;

            return (
              <button
                key={project.projectId}
                className="project-context-menu__item"
                data-active={isActive || undefined}
                type="button"
                role="menuitem"
                onClick={() => void handleProjectSelection(project.projectId)}
              >
                {project.displayName}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
