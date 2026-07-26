import { useProjectContext } from "../project-context/useProjectContext";

// PlaceholderWorkspace: bootstrap validation content only.
//
// This remains a temporary validation surface, not a real workspace.
// It consumes shared Project Context only to prove that the workspace
// region and Project Switcher observe one authoritative lifecycle.
export default function PlaceholderWorkspace() {
  const { registry, loading, error } = useProjectContext();

  let activeProjectLabel = "Loading Active Context…";

  if (error) {
    activeProjectLabel = "Active Context unavailable";
  } else if (!loading) {
    activeProjectLabel =
      registry?.activeProject?.displayName ?? "No Active Project";
  }

  return (
    <div
      className="shell-placeholder-workspace"
      data-shell-region="placeholder-workspace"
    >
      <p className="shell-placeholder-workspace__notice">
        Bootstrap validation placeholder — not a real workspace.
      </p>
      <p className="shell-placeholder-workspace__notice">
        Shared Active Context: {activeProjectLabel}
      </p>
    </div>
  );
}
