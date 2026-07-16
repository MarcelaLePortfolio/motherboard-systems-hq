# PHASE GOVERNANCE CONTRACT v1.0

## Core Principle — Phases are expensive
A phase is a system-level state change, not a label. If it does not change runtime behavior, data flow, or architecture boundaries, it is not a phase.

---

## Phase Creation Rule (Strict Gate)
A new phase may only be created if all are true:
- Introduces a new runtime behavior boundary
- Changes data flow, event flow, or UI architecture meaningfully
- Cannot be expressed as patch, refactor, module replacement, or compatibility shim

Otherwise it must remain within the existing phase.

---

## Phase Registry Authority
Single source of truth:
- /docs/PHASE_REGISTRY.md

Rules:
- If not in registry, it does not exist
- No implicit phases from filenames or comments
- No emergent phase naming

---

## Phase Modification Rules
A phase may only be:
- Extended (same ID, expanded safely)
- Replaced (explicit supersession)
- Deprecated (legacy only, not executed)

Never fork or duplicate phases silently.

---

## Frontend Contract Rule
Frontend must never assume backend capabilities exist.
If missing:
- Render explicit "MISSING BACKEND CONTRACT" state
- Do not infer or simulate backend behavior

---

## Backend Contract Rule
Backend must not:
- Maintain hidden legacy duplicates
- Serve multiple implicit UI interpretations
- Mix versioned contracts without explicit routing

---

## Compatibility Layer Rule
Compat layers must:
- Live under /compat/*
- Be explicitly labeled temporary
- Never become part of core execution path

---

## Multi-AI Responsibility Boundaries
Agents must not cross-infer system structure.

| Agent | Domain |
|------|--------|
| Cade | Frontend / UI execution |
| Backend | API / event truth |
| Atlas | System mapping |
| Effie | Operational tooling |

No agent may assume missing architecture.

---

## Anti-Drift Rule
If 3 consecutive failed stabilization attempts occur:
- Stop
- Revert to last stable state
- Do not introduce new phase or abstraction

---

## System Stability Definition
System is stable only if:
- /ui is sole valid entrypoint
- backend contracts are explicit and real
- no hidden dashboard routes exist
- no dual UI systems are active
