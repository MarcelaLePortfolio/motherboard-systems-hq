export type ShellWorkspace = "dashboard" | "chat";

type NavigationRegionProps = {
  activeWorkspace: ShellWorkspace;
  onSelectWorkspace: (workspace: ShellWorkspace) => void;
};

export default function NavigationRegion({
  activeWorkspace,
  onSelectWorkspace,
}: NavigationRegionProps) {
  return (
    <nav
      className="shell-navigation-region"
      data-shell-region="navigation"
      aria-label="Primary navigation"
    >
      <section aria-labelledby="shell-navigation-primary">
        <h2 id="shell-navigation-primary">Workspace</h2>

        <button
          type="button"
          aria-current={activeWorkspace === "dashboard" ? "page" : undefined}
          onClick={() => onSelectWorkspace("dashboard")}
        >
          Dashboard
        </button>

        <button
          type="button"
          aria-current={activeWorkspace === "chat" ? "page" : undefined}
          onClick={() => onSelectWorkspace("chat")}
        >
          Chats
        </button>
      </section>

      <section aria-labelledby="shell-navigation-departments">
        <h2 id="shell-navigation-departments">Departments</h2>
        <p>Department navigation is intentionally deferred.</p>
      </section>

      <section aria-labelledby="shell-navigation-system">
        <h2 id="shell-navigation-system">System</h2>
        <p>Diagnostics is intentionally deferred.</p>
      </section>
    </nav>
  );
}
