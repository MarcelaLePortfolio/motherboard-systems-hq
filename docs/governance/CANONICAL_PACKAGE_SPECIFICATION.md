
# Canonical Package Specification

## Purpose

The Package is the canonical meaning artifact of the Motherboard Headquarters operating model.

The Package represents Matilda's authoritative interpretation of user intent.

The Package is the source of truth for meaning.

The Package must remain independent from operationalization, routing, assignment, and execution concerns.

---

# Organizational Position

Lifecycle:

User

↓

Matilda

↓

Package

↓

Delegation

↓

Governance Validation

↓

Envelope

---

# Core Principle

Packages own meaning.

Packages do not own operationalization.

Packages do not own routing.

Packages do not own assignment.

Packages do not own execution.

The Package remains the authoritative source of intent throughout the lifecycle.

---

# Required Fields

## package_id

Purpose:

Unique Package identifier.

Owner:

Matilda

Immutable after creation.

---

## requested_outcome

Purpose:

The outcome the user wishes to achieve.

Examples:

- Add governance validation support

- Back up repository to Rio Drive

- Create executive dashboard

Owner:

Matilda

---

## scope

Purpose:

Defines what work is included.

Examples:

Included:

- Dashboard UI

- Summary cards

Owner:

Matilda

---

## containment

Purpose:

Defines protected boundaries.

Examples:

Allowed:

- Dashboard UI

Excluded:

- Database schema

- Backup engine

- Authentication system

Owner:

Matilda

---

## constraints

Purpose:

Defines conditions that must remain true.

Examples:

- Preserve renderer-authoritative Preview

- Preserve existing SSE behavior

- Maintain current governance boundaries

Owner:

Matilda

---

## success_criteria

Purpose:

Defines how completion is evaluated.

Examples:

- Dashboard renders successfully

- Existing functionality preserved

- Required information visible

Owner:

Matilda

---

# Optional Fields

## context

Purpose:

Relevant contextual information required to understand the request.

Examples:

- Existing architecture references

- Prior decisions

- Relevant project state

Owner:

Matilda

---

## style_presentation_intent

Purpose:

Defines presentation expectations.

Examples:

- Executive audience

- Summary-first

- Low information density

- Technical audience

- Detailed operational view

Owner:

Matilda

---

## exclusions

Purpose:

Explicitly identifies work that is not requested.

Examples:

- Do not modify backend services

- Do not redesign existing workflows

Owner:

Matilda

---

# Package Quality Requirements

A valid Package must:

- Clearly define the requested outcome

- Clearly define scope

- Clearly define containment

- Clearly define constraints

- Clearly define success criteria

A Package must not require downstream invention of meaning.

---

# Prohibited Package Content

Packages must not contain:

## Actor Assignment

Examples:

- Assign to Cade

- Assign to Effie

Assignment belongs to Ellis.

---

## Required Capabilities

Examples:

- engineering_planning

- desktop_operations

Capabilities are derived by Governance Validation.

---

## Operational Corridor

Examples:

- planning_only

- execution_authorized

Operational corridors belong to Governance Validation.

---

## Governance Findings

Governance findings belong to Governance Validation.

---

## Routing Information

Routing belongs to Ellis.

---

## Execution Strategy

Examples:

- Use React

- Use PostgreSQL

- Implement via service layer

Execution strategy belongs to operational departments.

---

# Organizational Principle

The Package represents what the CEO wants.

The Package does not determine how the organization fulfills that request.

Meaning must remain separate from operationalization.

