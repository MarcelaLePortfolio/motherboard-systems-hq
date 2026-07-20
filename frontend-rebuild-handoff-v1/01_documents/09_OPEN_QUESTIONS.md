# Open Questions

## Purpose

This document records architectural questions that remain intentionally unresolved.

These are not implementation tasks.

They are areas requiring additional evidence, design discussion, or repository investigation before becoming architectural decisions.

Claude should not treat unanswered questions as permission to invent solutions.

---

## Shell

### Sidebar

Unresolved:

- Final sidebar contents
- Navigation grouping
- Ordering of capabilities
- Project organization
- Recent context presentation
- Multi-project behavior

---

### Deferred Decision: Primary Navigation Model

The primary navigation model is intentionally unresolved.

Possible directions include:

- Workspace-oriented navigation
- Agent-oriented navigation
- A hybrid model

This decision should not be finalized until shell responsibilities, workspace boundaries, and core operator workflows are more stable.

At this stage:

- Agents are actors with defined responsibilities.
- Workspaces are environments where domain-specific work is performed.
- The shell provides orientation, navigation, continuity, and orchestration.

No conclusion should yet be drawn about whether agents appear as primary destinations, status surfaces, contextual drawers, workspace participants, or some combination of these.

Future evaluation should determine which navigation model best supports operator clarity without collapsing agents, workspaces, and organizational functions into the same concept.

This is a deliberate deferral, not a missing design decision.

---

### Workspace Navigation

Unresolved:

- URL strategy
- Browser history behavior
- Deep linking
- Back navigation
- Forward navigation
- Reopening previous workspaces

---

### Workspace State

Unresolved:

- Conversation persistence
- Package persistence
- Investigation persistence
- Unsaved operator work
- State restoration strategy

---

### Contextual Surfaces

Unresolved:

When should an interaction use:

- Full workspace
- Drawer
- Dialog
- Popover
- Inline expansion

The threshold between these presentation forms has not yet been defined.

---

### Packages

Unresolved:

- Sidebar visibility
- Attention indicators
- Lifecycle visualization
- Return-to-origin behavior
- Cross-project package handling

---

### Notifications

Unresolved:

- Background activity presentation
- Agent attention model
- Completion indicators
- Long-running work visibility
- Interrupt versus passive notification behavior

---

### Mobile

Unresolved:

- Narrow-width navigation
- Sidebar behavior
- Workspace switching
- Package review experience
- Tablet behavior

---

### Multi-Window

Unresolved:

- Multiple browser windows
- Multiple tabs
- Shared state
- Concurrent investigations
- Workspace synchronization

---

### Visual Identity

Unresolved:

- Design language
- Motion principles
- Color system
- Density
- Accessibility refinements

Visual styling should follow architecture rather than determine it.

---

## Repository Investigation

Additional repository evidence may still be required regarding:

- Existing reusable modules
- Routing
- State management
- Shared layout components
- SSE integration
- Existing navigation
- Hidden coupling
- Legacy dashboard assumptions

---

## Resolution Principle

Questions listed here remain intentionally open.

Do not resolve them through speculation.

Instead:

- identify evidence
- evaluate tradeoffs
- document findings
- recommend options

Architectural decisions should follow evidence rather than assumptions.
