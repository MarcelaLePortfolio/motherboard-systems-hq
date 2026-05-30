
# Lineage Relationship Contract v1

## Classification

Governance Contract

Milestone 5 — Execution Lineage Governance

Status: Draft v1

Depends On:

- Atlas Authority Contract v1

- Execution Lineage Artifact Contract v1

Scope:

Governance only.

No runtime implementation authorization.

---

## Purpose

The Lineage Relationship Contract defines:

- relationship ownership

- relationship categories

- relationship admission requirements

- graph integrity requirements

- relationship immutability requirements

This contract governs lineage edges.

Artifact governance is defined separately.

---

## Foundational Principle

Relationships describe how authoritative lineage artifacts are connected.

Relationships are historical facts.

Relationships are not interpretations.

Relationships are not predictions.

Relationships are not hypotheses.

Only evidence-backed relationships may exist within the authoritative lineage graph.

---

## Relationship Authority

Atlas is the authority responsible for maintaining lineage relationships.

Atlas may:

- establish evidence-backed relationships

- preserve relationships

- reconcile relationships

- preserve supersession history

- preserve dependency history

Atlas may not:

- create relationships through inference

- create relationships through probability

- create relationships through speculation

- create relationships through pattern matching alone

---

## Authoritative Relationship Categories

### Origin Relationships

Purpose:

Preserve artifact origin history.

Authorized relationships:

- derived_from

- originated_from

- created_from

---

### Delegation Relationships

Purpose:

Preserve delegation history.

Authorized relationships:

- delegated_to

- assigned_to

- routed_to

---

### Validation Relationships

Purpose:

Preserve governance review history.

Authorized relationships:

- validated_by

- blocked_by

- approved_by

- escalated_by

---

### Recovery Relationships

Purpose:

Preserve recovery history.

Authorized relationships:

- recovered_by

- corrected_by

- remediated_by

---

### Supersession Relationships

Purpose:

Preserve replacement history.

Authorized relationships:

- supersedes

- superseded_by

- replaces

---

### Impact Relationships

Purpose:

Preserve dependency and roadmap history.

Authorized relationships:

- impacts

- depends_on

- enables

- blocks

---

## Relationship Admission Rule

### Evidence-Anchored Admission Rule

A relationship may enter the authoritative lineage graph only when supported by authoritative evidence.

Relationship creation requires:

- relationship claim

- supporting evidence

- identifiable source artifacts

Missing evidence prevents relationship admission.

---

## Prohibited Admission Sources

The following are insufficient for authoritative relationship admission:

- inference

- probability

- speculation

- pattern matching

- confidence scores

- temporal proximity alone

These sources may identify potential ambiguity but may not create authoritative relationships.

---

## Graph Purity Rule

The authoritative lineage graph shall contain only evidence-backed relationships.

The graph shall not contain:

- hypotheses

- suspicions

- possible relationships

- unresolved assumptions

Potential relationships shall remain outside the authoritative graph.

---

## Lineage Ambiguity Separation Rule

Potential relationships may be preserved as ambiguity artifacts.

Ambiguity artifacts are not lineage relationships.

Ambiguity artifacts do not become authoritative lineage until evidence requirements are satisfied.

---

## Relationship Immutability Rule

Authoritative relationships are permanent historical records.

Relationships may not be:

- rewritten

- deleted

- altered

Historical lineage remains append-only.

---

## Supersession Compatibility Rule

Immutability does not prohibit supersession.

New relationships may supersede earlier relationships through append-only history preservation.

Historical relationships remain preserved.

---

## Evidence Traceability Rule

Every authoritative relationship shall be traceable to supporting evidence.

Relationship validity derives from evidence provenance rather than from Atlas authority alone.

Atlas records relationships.

Evidence authorizes relationships.

---

## Future Preservation Clause

Nothing in this contract shall prohibit future:

- event-level relationship models

- lineage intelligence research

- expanded relationship categories

provided authority boundaries, evidence requirements, privacy constraints, and graph integrity requirements remain intact.

