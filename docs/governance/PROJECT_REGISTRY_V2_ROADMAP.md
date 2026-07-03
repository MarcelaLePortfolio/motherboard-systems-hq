
# Project Registry V2 Roadmap

Status: Approved

Prerequisite: Project Registry V1 Complete

## Guiding Principle

Projects should enter the registry through normal operator workflows,

not through manual edits to registry.example.json.

The registry becomes the authoritative source of Active Context.

---

## Phase V2-A — Register Existing Project

Current UI:

✓ Register Existing Project...

Implement:

- Select an existing local repository.

- Validate it is a Git repository.

- Read its metadata.

- Register it into project_registry.

- Refresh the Project Switcher.

- Do not switch Active Context automatically.

Success Criteria:

- No manual JSON editing.

- No database manipulation by the operator.

---

## Phase V2-B — New Project

Current UI:

✓ New Project...

Implement:

- Prompt for project name.

- Create repository scaffold.

- Initialize Git.

- Register project.

- Optionally switch Active Context.

Success Criteria:

One workflow creates both the repository and the registry entry.

---

## Phase V2-C — Project Metadata

Each project should eventually expose:

- displayName

- repository path

- remote URL

- project type

- project icon

- health status

- services

- branch

- last opened

- favorite

- archived

---

## Phase V2-D — Automatic Discovery

Optional future enhancement:

Scan configured workspace roots for Git repositories that are not yet registered,

then offer one-click registration.

---

## Deferred

- Header redesign

- Project ontology

- Multi-workspace federation

- Cross-project task orchestration

