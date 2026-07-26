export type ShellWorkspace =
  | "mission-control"
  | "conversation"
  | "engineering"
  | "operations-department"
  | "atlas"
  | "effie"
  | "cade"
  | "executive-review"
  | "operations"
  | "archives"
  | "media-library"
  | "settings";

type NavigationRegionProps = {
  activeWorkspace: ShellWorkspace;
  onSelectWorkspace: (workspace: ShellWorkspace) => void;
};

const conversationThreads = [
  "Retrieval Runtime",
  "UI Shell",
  "Mobile App",
];

export default function NavigationRegion({
  activeWorkspace,
  onSelectWorkspace,
}: NavigationRegionProps) {
  return (
    <aside
      className="shell-navigation-region"
      data-shell-region="navigation"
      aria-label="Headquarters navigation"
    >
      <button
        type="button"
        className={activeWorkspace === "mission-control" ? "active" : ""}
        onClick={() => onSelectWorkspace("mission-control")}
      >
        Mission Control
      </button>

      <section className="shell-nav-group">
        <h2>Conversations</h2>

        <div className="shell-nav-scroll">
          {conversationThreads.map((thread) => (
            <button
              key={thread}
              type="button"
              className={
                activeWorkspace === "conversation" ? "active" : ""
              }
              onClick={() => onSelectWorkspace("conversation")}
            >
              {thread}
            </button>
          ))}
        </div>
      </section>

      <section className="shell-nav-group">
        <h2>Departments</h2>

        <button onClick={() => onSelectWorkspace("engineering")}>
          Engineering
        </button>

        <button onClick={() => onSelectWorkspace("operations-department")}>
          Operations
        </button>

        <button onClick={() => onSelectWorkspace("atlas")}>
          Atlas
        </button>

        <button onClick={() => onSelectWorkspace("effie")}>
          Effie
        </button>

        <button onClick={() => onSelectWorkspace("cade")}>
          Cade
        </button>
      </section>

      <section className="shell-nav-group">
        <button onClick={() => onSelectWorkspace("executive-review")}>
          Executive Review
        </button>

        <button onClick={() => onSelectWorkspace("operations")}>
          Operations
        </button>

        <button onClick={() => onSelectWorkspace("archives")}>
          Archives
        </button>

        <button onClick={() => onSelectWorkspace("media-library")}>
          Media Library
        </button>
      </section>

      <footer className="shell-navigation-footer">
        <button onClick={() => onSelectWorkspace("settings")}>
          Settings
        </button>
      </footer>
    </aside>
  );
}
