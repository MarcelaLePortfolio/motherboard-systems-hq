
# Capability Routing Model

## Purpose

This document defines the canonical capability-based routing architecture of the Motherboard Headquarters operating model.

The organization routes work by required capabilities rather than by specific actors.

This allows organizational growth without coupling operational artifacts to individual runners.

---

# Core Principle

Work is assigned to capabilities.

Capabilities are assigned to actors.

Work is not assigned directly to actors.

---

# Lifecycle

Package

↓

Delegation

↓

Governance Validation

↓

Derive Required Capabilities

↓

Envelope

↓

Ellis

↓

Capability Resolution

↓

Assignment

↓

Operational Department

---

# Capability Definition

A capability represents a type of operational work that can be performed by one or more actors.

Examples:

- engineering_planning

- repository_analysis

- architecture_review

- desktop_operations

- external_backup

- storage_maintenance

Capabilities are organizational assets.

Capabilities are not actors.

Capabilities are not departments.

---

# Capability Ownership

Capabilities are defined by departments.

Examples:

Engineering Department owns:

- engineering_planning

- repository_analysis

- architecture_review

Desktop Operations Department owns:

- desktop_operations

- external_backup

- storage_maintenance

Departments may define new capabilities.

---

# Capability Registry

Atlas owns the Capability Registry.

The Capability Registry records:

- Capability

- Owning Department

- Satisfying Actors

- Capability Relationships

- Capability Lineage

Atlas maintains organizational knowledge.

Atlas does not perform routing.

---

# Capability Derivation

Governance Validation derives required capabilities during operationalization review.

Example:

Package:

Outcome:

Implement governance validator support

Derived Capabilities:

- engineering_planning

Example:

Package:

Outcome:

Back up repository to Rio Drive

Derived Capabilities:

- desktop_operations

- external_backup

Capabilities are derived from operational requirements.

Capabilities are not derived by Ellis.

---

# Envelope Contribution

Governance Validation writes required capabilities into the Envelope.

Example:

Required Capabilities:

- engineering_planning

- repository_analysis

The Envelope contains capability requirements.

The Envelope does not contain actor assignments.

---

# Routing Responsibility

Ellis owns capability resolution and assignment.

Ellis consumes:

- Required Capabilities

- Operational Corridor

- Envelope State

Ellis determines:

- Assignment

- Ownership

- Routing State

Ellis does not define capabilities.

Ellis does not maintain the registry.

---

# Actor Resolution

Actors satisfy capabilities.

Examples:

engineering_planning

↓

Cade

desktop_operations

↓

Effie

Multiple actors may satisfy the same capability.

Capability satisfaction may evolve over time.

The routing model must not depend upon specific actor identities.

---

# Multi-Department Routing

A Package may require multiple capabilities.

Example:

Required Capabilities:

- engineering_planning

- external_backup

Ellis may assign:

Cade

↓

Effie

or other valid capability providers.

The capability model supports sequential and future parallel routing.

---

# Future Organizational Growth

The capability model must support:

- New departments

- New actors

- Specialized teams

- Department expansion

- Multi-agent operation

without requiring changes to:

- Package

- Delegation

- Governance Validation

- Envelope structure

---

# Organizational Principle

Capabilities are the routing language of the organization.

Actors are implementation details.

Departments define capabilities.

Atlas records capabilities.

Governance Validation derives capabilities.

Ellis routes by capabilities.

Actors satisfy capabilities.

