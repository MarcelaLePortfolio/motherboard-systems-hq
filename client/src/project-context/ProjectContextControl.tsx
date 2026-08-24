import { useState } from "react";
import { inspectProjectPath } from "./projectRegistryApi";
import { useProjectContext } from "./useProjectContext";

function deriveProjectId(name: string) {
  return name
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function deriveDisplayName(name: string) {
  return name
    .trim()
    .replace(/[-_]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

export default function ProjectContextControl() {
  const { registry, loading, error, switchProject, registerProject } =
    useProjectContext();

  const [open, setOpen] = useState(false);
  const [registering, setRegistering] = useState(false);
  const [path, setPath] = useState("");
  const [projectId, setProjectId] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [validPath, setValidPath] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  if (loading) {
    return (
      <button className="shell-project-picker" type="button" disabled>
        Loading projects…
      </button>
    );
  }

  if (error && !registry) {
    return (
      <button className="shell-project-picker" type="button" disabled>
        Project Registry unavailable
      </button>
    );
  }

  async function inspect() {
    setBusy(true);
    setMessage(null);

    try {
      const result = await inspectProjectPath(path);
      setValidPath(result.ok);
      setMessage(result.message);

      if (result.ok && result.projectDirectoryName) {
        if (!projectId.trim()) {
          setProjectId(deriveProjectId(result.projectDirectoryName));
        }
        if (!displayName.trim()) {
          setDisplayName(deriveDisplayName(result.projectDirectoryName));
        }
      }
    } catch (err) {
      setValidPath(false);
      setMessage(err instanceof Error ? err.message : "Inspection failed.");
    } finally {
      setBusy(false);
    }
  }

  async function submit() {
    if (!validPath) return;

    setBusy(true);
    setMessage(null);

    try {
      await registerProject({
        projectId: projectId.trim(),
        displayName: displayName.trim(),
        projectRootPath: path.trim(),
      });

      setRegistering(false);
      setPath("");
      setProjectId("");
      setDisplayName("");
      setValidPath(false);
      setOpen(true);
    } catch (err) {
      setMessage(err instanceof Error ? err.message : "Registration failed.");
    } finally {
      setBusy(false);
    }
  }

  const projects = registry?.projects ?? [];
  const activeProjectId = registry?.activeProjectId ?? null;

  const activeProjects = projects.filter(
    (project) => project.projectId === activeProjectId,
  );

  const availableProjects = projects.filter(
    (project) =>
      project.projectId !== activeProjectId &&
      project.registrationStatus === "registered" &&
      project.availabilityStatus === "available" &&
      project.activeContextEligible,
  );

  const archivedProjects = projects.filter(
    (project) =>
      project.projectId !== activeProjectId &&
      (project.registrationStatus !== "registered" ||
        project.availabilityStatus !== "available" ||
        !project.activeContextEligible),
  );

  return (
    <div className="project-context-control">
      <button
        className="shell-project-picker"
        type="button"
        aria-expanded={open}
        aria-haspopup="menu"
        onClick={() => setOpen((value) => !value)}
      >
        <span>{registry?.activeProject?.displayName ?? "No Active Project"}</span>
        <span aria-hidden="true">⌄</span>
      </button>

      {open && (
        <div className="project-context-menu" role="menu">
          {activeProjects.length > 0 && (
            <div className="project-lifecycle-group">
              <div className="project-lifecycle-group__label">Active</div>
              {activeProjects.map((project) => (
                <button
                  key={project.projectId}
                  className="project-context-menu__item"
                  data-active="true"
                  type="button"
                  role="menuitem"
                  onClick={() => {
                    void switchProject(project.projectId).then(() =>
                      setOpen(false),
                    );
                  }}
                >
                  {project.displayName}
                </button>
              ))}
            </div>
          )}

          {availableProjects.length > 0 && (
            <div className="project-lifecycle-group">
              <div className="project-lifecycle-group__label">Available</div>
              {availableProjects.map((project) => (
                <button
                  key={project.projectId}
                  className="project-context-menu__item"
                  type="button"
                  role="menuitem"
                  onClick={() => {
                    void switchProject(project.projectId).then(() =>
                      setOpen(false),
                    );
                  }}
                >
                  {project.displayName}
                </button>
              ))}
            </div>
          )}

          {archivedProjects.length > 0 && (
            <div className="project-lifecycle-group">
              <div className="project-lifecycle-group__label">
                Archived / Inactive
              </div>
              {archivedProjects.map((project) => (
                <button
                  key={project.projectId}
                  className="project-context-menu__item"
                  data-lifecycle="archived"
                  type="button"
                  role="menuitem"
                  disabled
                >
                  {project.displayName}
                </button>
              ))}
            </div>
          )}

          <button
            className="project-context-menu__item"
            type="button"
            role="menuitem"
            onClick={() => {
              setOpen(false);
              setRegistering(true);
              setMessage(null);
            }}
          >
            + Register Existing Project
          </button>
        </div>
      )}

      {registering && (
        <div
          role="presentation"
          style={{
            position: "fixed",
            inset: 0,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            padding: "1rem",
            background: "rgba(0,0,0,.55)",
            zIndex: 2000,
          }}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="project-registration-title"
            style={{
              width: "min(520px,100%)",
              padding: "1.25rem",
              boxSizing: "border-box",
              background: "#fff",
              border: "1px solid #ccc",
              borderRadius: ".5rem",
            }}
          >
            <h2 id="project-registration-title">Register Existing Project</h2>

            <label>
              Project root path
              <input
                type="text"
                value={path}
                onChange={(event) => {
                  setPath(event.target.value);
                  setValidPath(false);
                }}
                style={{
                  display: "block",
                  width: "100%",
                  boxSizing: "border-box",
                }}
              />
            </label>

            <button
              type="button"
              disabled={busy || !path.trim()}
              onClick={() => void inspect()}
            >
              {busy ? "Inspecting…" : "Inspect Repository"}
            </button>

            {message && <p>{message}</p>}

            <label>
              Project ID
              <input
                type="text"
                value={projectId}
                onChange={(event) => setProjectId(event.target.value)}
                style={{
                  display: "block",
                  width: "100%",
                  boxSizing: "border-box",
                }}
              />
            </label>

            <label>
              Display name
              <input
                type="text"
                value={displayName}
                onChange={(event) => setDisplayName(event.target.value)}
                style={{
                  display: "block",
                  width: "100%",
                  boxSizing: "border-box",
                }}
              />
            </label>

            <div
              style={{
                display: "flex",
                gap: ".5rem",
                marginTop: "1rem",
              }}
            >
              <button
                type="button"
                disabled={busy}
                onClick={() => setRegistering(false)}
              >
                Cancel
              </button>

              <button
                type="button"
                disabled={
                  busy ||
                  !validPath ||
                  !projectId.trim() ||
                  !displayName.trim()
                }
                onClick={() => void submit()}
              >
                {busy ? "Registering…" : "Register Project"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
