
# Preview Wrapper Corridor Findings (Stabilized)

## Status

Preview Wrapper Corridor is considered architecturally stabilized.

Remaining work consists primarily of artifact schemas and implementation mechanics.

---

# Core Finding

The Preview Wrapper belongs to the Application.

The Preview Wrapper does not belong to an individual Package.

Packages propose changes to the Application Wrapper.

---

# Wrapper Ownership

Wrapper ownership is application-scoped.

Pattern:

Application

↓

Wrapper

Not:

Package

↓

Wrapper

The Wrapper persists across Packages.

---

# Package Relationship

Packages modify the Wrapper.

Pattern:

Current Wrapper

+

Package Changes

=

Proposed Wrapper

Packages are implementation units.

The Wrapper is the application experience unit.

---

# Unit of Preview

The unit of Preview is the Application Experience.

The unit of Implementation is the Package.

Users approve:

The future application experience.

Users do not approve:

Individual implementation details.

---

# Proposed Wrapper

Preview renders the Proposed Wrapper.

The Proposed Wrapper represents:

The application after Package fulfillment.

Pattern:

Current Wrapper

↓

Package

↓

Proposed Wrapper

---

# Preview Before Commitment

Execution may not begin until the user has seen the Proposed Wrapper.

The Proposed Wrapper is the concrete representation of the future application state.

---

# Application-Wide Rendering

Preview should render the entire resulting application experience whenever practical.

Users evaluate:

Navigation

Workflow

Discoverability

Placement

User Journey

Users do not merely evaluate isolated components.

Example:

Adding Analytics should preview:

Home

↓

Dashboard

↓

Analytics

↓

Settings

rather than an isolated Analytics page.

---

# Interactive Preview

Users may interact with the Proposed Wrapper before approval.

Preview may include:

- navigation

- forms

- pages

- workflows

- simulated responses

- simulated data

The purpose is future experience evaluation.

---

# Simulated Capabilities

The Wrapper may contain simulated capabilities.

Simulated capabilities represent approved future experience that has not yet been realized.

Users may interact with simulated capabilities.

Simulated capabilities may interact with other simulated capabilities.

---

# Reality Status

Reality is the default state.

Real capabilities are unmarked.

Only non-real capabilities are marked.

Examples:

⚪ Simulated

Real capabilities display no indicator.

---

# Execution Relationship

Execution progressively replaces simulated capabilities with real capabilities.

Pattern:

Simulated

↓

Execution

↓

Real

Execution updates the local project.

Execution materializes into:

- source code

- assets

- configuration

- tests

- project artifacts

owned by the user.

---

# Local-First Invariant

The Wrapper exists within a local-first architecture.

Pattern:

Local Project

↓

Local Wrapper

↓

Local Execution

The Wrapper is not a cloud-authoritative artifact.

The local project remains the implementation source of truth.

---

# Mixed Reality State

The Wrapper may contain:

Real Capabilities

+

Simulated Capabilities

simultaneously.

Execution is not required to complete before future exploration continues.

---

# Additive Composition

The Wrapper is additive by default.

Pattern:

X

+

Y

+

Z

Removal or replacement requires explicit user intent.

Examples:

Remove Department Filter

Replace Department Filter with Global Search

Move Department Filter into Settings

---

# Package Composition

Packages compose.

Packages do not override by default.

Pattern:

Package A

+

Package B

=

Combined Application State

Override behavior requires explicit intent.

---

# User Modification Model

Users modify the application through new intent.

Users do not modify organizational artifacts.

Pattern:

Intent

↓

Package

↓

Preview

↓

Execution

Application changes occur through new Packages.

---

# Redesign Exploration

Users may explore future application states without affecting the current application.

Pattern:

Current Wrapper

↓

Package

↓

Proposed Wrapper

↓

Approve or Discard

No execution occurs until approval.

Current application state remains intact.

---

# Future Branch Principle

The Proposed Wrapper functions as a temporary future experience.

Users may:

Accept Future

or

Discard Future

without affecting the current application.

---

# Alternate Application Realities

Minor evolution occurs within the same project.

Major alternate application directions should be explored as separate local projects.

Pattern:

Project A

↓

Future A

Project B

↓

Future B

The Wrapper represents the future of a specific application.

It does not represent all possible futures of all possible applications.

---

# Organizational Boundary

Artifacts remain organizational concerns.

Examples:

- Packages

- Fulfillment Plans

- Reconciliation Artifacts

- Execution Discovery Artifacts

Users interact with:

The Application Wrapper

not organizational artifacts.

The Wrapper exposes experience state.

The organization manages artifact state.

---

# Corridor Summary

The Wrapper is a persistent application-level future-state projection.

Packages propose changes to the Wrapper.

Preview exposes the resulting future application experience.

Users interact with that future experience before commitment.

Execution progressively transforms approved simulated capabilities into real local functionality.

