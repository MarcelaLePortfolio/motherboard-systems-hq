// PlaceholderWorkspace: bootstrap validation content only.
//
// This is not a real workspace, not a preview of a real workspace,
// and not a design proposal. It exists solely so that a human (or
// an automated check) can confirm the WorkspaceMount region renders
// something when the shell is loaded. It carries no domain logic,
// no backend awareness, and no lifecycle interpretation.
export default function PlaceholderWorkspace() {
  return (
    <div className="shell-placeholder-workspace" data-shell-region="placeholder-workspace">
      <p className="shell-placeholder-workspace__notice">
        Bootstrap validation placeholder — not a real workspace.
      </p>
      <p className="shell-placeholder-workspace__notice">
        This confirms the workspace mount region renders correctly.
      </p>
    </div>
  );
}
